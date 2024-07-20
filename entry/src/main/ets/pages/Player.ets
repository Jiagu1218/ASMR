import { AVCastPicker, AVCastPickerState } from '@kit.AVSessionKit';
import { OperationType, SubHeader } from '@ohos.arkui.advanced.SubHeader'
import { mediaquery, router } from '@kit.ArkUI';
import MediaData from '../entity/MediaData';
import { CURRENT_TIME, DURATION, MEDIA_SERVICE,
  PlayerMode,
  PLAY_MEDIA_DATA,
  PLAY_MODE,
  PLAY_STATE,
  WORK_TRACKS } from '../constant/AppStorageConstant';
import { MediaService } from '../service/MediaService';
import { WebVtt, WebVttData } from '../entity/WebVttData';
import { WebResource } from '../net/WebResoucre';
import { parseMillisecondDuration, parseSecondDuration } from '../util/DayJsUtil';
import ShiLrcView, { LrcEntry } from '../component/Lyrics';
import { WorkTrack, WorkTracks } from '../net/WorkTrack';
import { BusinessError } from '@kit.BasicServicesKit';
import { LogUtil } from '../util/LogUtil';
import { WorkTrackDialog } from '../component/WorkTrackDialog';
import { media } from '@kit.MediaKit';
import { startBackGroundTask } from '../util/BackGroundTaskUtil';
import { common } from '@kit.AbilityKit';

@Preview
@Entry
@Component
struct Player {
  //用来配置CanvasRenderingContext2D对象和OffscreenCanvasRenderingContext2D对象的参数，包括是否开启抗锯齿。true表明开启抗锯齿
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  //用来创建OffscreenCanvas对象，width为离屏画布的宽度，height为离屏画布的高度。通过在canvas中调用OffscreenCanvasRenderingContext2D对象来绘制。
  private offCanvas: OffscreenCanvas = new OffscreenCanvas(600, 600)

  smListener:mediaquery.MediaQueryListener = mediaquery.matchMediaSync('screen and (width < 520vp)')
  mdListener:mediaquery.MediaQueryListener = mediaquery.matchMediaSync('screen and (width >= 520vp) and (width < 840vp)')
  lgListener:mediaquery.MediaQueryListener = mediaquery.matchMediaSync('screen and (width >= 840vp)')

  @StorageLink(MEDIA_SERVICE) mediaService:MediaService = MediaService.build(getContext(this) as common.UIAbilityContext)
  @StorageLink(PLAY_STATE) playerState:media.AVPlayerState = 'idle'
  @StorageLink(PLAY_MODE) @Watch('modeChange') playerMode:PlayerMode = 'order'
  @State lyrics:WebVtt = []
  @State @Watch('lyricIndexChange') lyricIndex:number = -1
  @State modeIcon:Resource = $r('sys.symbol.order_play')
  @State lyricsArray:LrcEntry[] = []
  @StorageLink(DURATION) duration:number = 0
  @StorageLink(CURRENT_TIME) @Watch('onTimeUpdate') currentTime:number = 0
  @StorageLink(WORK_TRACKS) workTracks:WorkTracks = []
  @StorageLink(PLAY_MEDIA_DATA) mediaData: MediaData = {
    id: '0',
    title: '超塩対応彼氏持ちギャルをパパ呼び愛娘にする話',
    duration: 100,
    mediaUrl: '',
    imageUrl: 'http://i0.hdslb.com/bfs/archive/60edd7256f0f49dbd272f8984481a2962f9519a4.jpg@672w_378h_1c_!web-home-common-cover',
    singer:  'alist'
  }
  @State @Watch('workTrackChange') workTrack:WorkTrack|null = null
  @State smContainer:boolean = true
  @State mdContainer:boolean = false
  @State lgContainer:boolean = false

  dialogController: CustomDialogController = new CustomDialogController({
    builder:WorkTrackDialog({showList:this.workTracks,selectWorkTrack:$workTrack})
  })

  lyricIndexChange(){
    const lyrics = this.lyrics[this.lyricIndex]
    LogUtil.info(JSON.stringify(lyrics))
  }

  modeChange() {
    switch (this.playerMode){
      case 'single':this.modeIcon = $r('sys.symbol.repeat_1')
        break
      case 'order':this.modeIcon = $r('sys.symbol.order_play')
        break
      case 'random':this.modeIcon = $r('sys.symbol.shuffle')
        break
    }
  }

  workTrackChange(){
    if (this.workTrack){
      switch (this.workTrack.type){
        case 'audio':
          if(this.playerState == 'playing'){
            const title = this.workTrack.title
            const mediaData:MediaData = {
              id:this.mediaData.id,
              title:title.slice(0,title.lastIndexOf('.')),
              imageUrl:this.mediaData.imageUrl,
              singer:this.mediaData.singer,
              source:this.mediaData.source,
              duration:this.mediaData.duration,
              mediaUrl:(this.workTrack.mediaStreamUrl || this.workTrack.streamLowQualityUrl) as string
            }
            this.mediaService.addPlayData(mediaData)
          }else{
            this.mediaData.mediaUrl = (this.workTrack.mediaStreamUrl || this.workTrack.streamLowQualityUrl) as string
            this.mediaService.playMedia(this.mediaData)
          }
          break
        case 'text':
          const title = this.workTrack.title
          if (title.slice(title.lastIndexOf('.')+1) == 'vtt'){
            WebResource.getVtt(this.workTrack.mediaDownloadUrl as string).then(vtt => {
              this.coverToLyrics(vtt);
            })
          }
          break
        default:
        break

      }
    }
  }
  onTimeUpdate(){
    const currentTime = this.currentTime
    this.lyricIndex = this.lyrics.findIndex(vtt=>vtt.startTime<=currentTime && vtt.endTime>currentTime)
  }

  aboutToAppear(): void {
    this.smListener.on('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.smLine(mediaQueryResult) })
    this.mdListener.on('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.mdLine(mediaQueryResult) })
    this.lgListener.on('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.lgLine(mediaQueryResult)})
  }

  menu(){
    WebResource.getWorkTracks(this.mediaData.id).then(workTracks=>{
      AppStorage.setOrCreate<WorkTracks>(WORK_TRACKS,workTracks)
      this.dialogController.open()
    }).catch((e:BusinessError)=>{
      LogUtil.error(e.message)
    })
  }

  coverToLyrics(vtt: WebVtt) {
    this.lyrics = vtt;
    this.lyricsArray = vtt.map<LrcEntry>(data => {
      return {
        lineWords: data.subtitles[0],
        lineStartTime: data.startTime,
        lineDuration: (data.endTime - data.startTime),
        words: []
      };
    });
  }

  aboutToDisappear(): void {
    this.smListener.off('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.smLine(mediaQueryResult) })
    this.mdListener.off('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.mdLine(mediaQueryResult) })
    this.lgListener.off('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.lgLine(mediaQueryResult)})

  }



  smLine(mediaQueryResult: mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches) {
      this.smContainer = true
      this.mdContainer = false
      this.lgContainer = false
    }
  }
  mdLine(mediaQueryResult: mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches) {
      this.smContainer = false
      this.mdContainer = true
      this.lgContainer = false
    }
  }
  lgLine(mediaQueryResult: mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches) {
      this.smContainer = false
      this.mdContainer = false
      this.lgContainer = true
    }
  }

  onStateChange(state: AVCastPickerState) {
    if (state == AVCastPickerState.STATE_APPEARING) {
      console.log('The picker starts showing.')
    } else if (state == AVCastPickerState.STATE_DISAPPEARING) {
      console.log('The picker finishes presenting.')
    }
  }

  build() {
    Column() {
      if (this.smContainer){
        Swiper(){
          Column(){
            Stack(){
              this.artArea()
              this.headerArea()
            }
            .alignContent(Alignment.TopStart)
            this.titleArea()
            Row(){
              this.opArea()
            }.layoutWeight(1)
          }.height('100%').width('100%')
          Column(){
            this.lyricsArea()
            this.lyricsArea()
          }.height('100%').width('100%')
        }.height('100%').width('100%')
      }else if (this.mdContainer){
        this.headerArea()
        GridRow({
          columns:8
        }){
          GridCol({span:4}){
            this.artArea()
            this.opArea()
          }
          GridCol({span:4}){
            this.lyricsArea()
          }
        }.layoutWeight(1)
      }if (this.lgContainer){
        this.headerArea()
        GridRow({
          columns:12
        }){
          GridCol({span:4,offset:1}){
            this.artArea()
            this.opArea()
          }
          GridCol({span:6,offset:1}){
            Stack(){
              this.lyricsArea()
              this.titleArea()
            }.height('100%').width('100%').alignContent(Alignment.Top)
          }
        }.layoutWeight(1)
      }
    }
    .height('100%')
    .width('100%')
    .padding({
      top: $r('sys.float.ohos_id_default_padding_top'),
      left: $r('sys.float.ohos_id_default_padding_start'),
      right: $r('sys.float.ohos_id_default_padding_end'),
      bottom: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    })
  }

  @Builder headerArea() {
    Row(){
      SymbolGlyph($r('sys.symbol.chevron_down')).fontSize(32).onClick(()=>{
        router.back()
      })
      AVCastPicker({ normalColor: Color.Red, activeColor: Color.Blue, onStateChange: this.onStateChange })
        .width(32)
        .height(32)
    }.justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height(40)
  }

  @Builder artArea() {
    Column(){
      Image(this.mediaData.imageUrl).height(240).width(240).aspectRatio(1).objectFit(ImageFit.Cover)
    }.width('100%')
    .justifyContent(FlexAlign.Center)
    .height(400)
  }

  @Builder titleArea(){
    Row(){
      SubHeader({
        primaryTitle:this.mediaData.title,
        secondaryTitle:this.mediaData.singer,
        operationType:OperationType.ICON_GROUP,
        operationItem:[{
          value:$r('sys.symbol.heart'),
          action:()=>{
            console.info('收藏'+this.mediaData.title)
          }
        }],
        operationSymbolOptions:[{fontSize:32,fontColor:[Color.Red]}]
      })
    }
  }

  @Builder opArea(){
    Column(){
      Row(){
        SymbolGlyph(this.modeIcon).fontSize(32)
          .onClick(()=>{
            this.mediaService.changeMode()
          })
        SymbolGlyph($r('sys.symbol.arrowshape_down_to_line_fill')).fontSize(32)
        SymbolGlyph($r('sys.symbol.speaker_wave_3')).fontSize(32)
        SymbolGlyph($r('sys.symbol.dot_grid_2x2')).fontSize(32).onClick(()=>{
          this.menu()
        })
      }.justifyContent(FlexAlign.SpaceAround)
      .height(48).width('100%')
      Column(){
        Row(){
          Progress({value: this.currentTime, total:this.duration,type:ProgressType.Linear})
        }.width('100%')
        Row(){
          Text(`${parseMillisecondDuration(this.currentTime)}`)
          Text(`${parseMillisecondDuration(this.duration)}`)
        }.justifyContent(FlexAlign.SpaceBetween).width('100%')
      }.width('100%').height(48)
      Row(){
        SymbolGlyph($r('sys.symbol.backward_end_fill')).fontSize(40)
          .onClick(()=>{
            this.mediaService.playPrev()
          })
        SymbolGlyph(this.playerState == 'playing'?$r('sys.symbol.pause_round_triangle_fill'):$r('sys.symbol.play_circle_fill')).fontSize(56)
          .onClick(()=>{
            if(this.mediaData.mediaUrl?.length>0){
              this.mediaService.playMedia()
            }else{
              this.menu()
            }
          })
        SymbolGlyph($r('sys.symbol.forward_end_fill')).fontSize(40)
          .onClick(()=>{
            this.mediaService.playNext()
          })
      }.justifyContent(FlexAlign.SpaceAround).width('100%')
    }.justifyContent(FlexAlign.End)
    .width('100%')
  }

  @Builder lyricsArea() {
    Column(){
      ShiLrcView({mLrcEntryList:this.lyricsArray,isPlay:true,lyricMilliSecondsTime:this.currentTime})
      // List(){
      //   Repeat<WebVttData>(this.lyrics).each(webVttDataItem=>{
      //     Repeat<string>(webVttDataItem.item.subtitles).each(subtitle=>{
      //       ListItem(){
      //         Text(subtitle.item)
      //       }.width('100%')
      //     }).key(item=>webVttDataItem.item.index+item)
      //   }).key(item=>item.index+'')
      // }
    }.height('100%').width('100%').backgroundColor(Color.Blue)
  }

  @Builder otherArea() {

  }

}