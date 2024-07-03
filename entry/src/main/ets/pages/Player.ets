import { AVCastPicker, AVCastPickerState } from '@kit.AVSessionKit';
import { OperationType, SubHeader } from '@ohos.arkui.advanced.SubHeader'
import { mediaquery } from '@kit.ArkUI';

@Preview
@Entry
@Component
struct Player {
  smListener:mediaquery.MediaQueryListener = mediaquery.matchMediaSync('screen and (width < 520vp)')
  mdListener:mediaquery.MediaQueryListener = mediaquery.matchMediaSync('screen and (width >= 520vp) and (width < 840vp)')
  lgListener:mediaquery.MediaQueryListener = mediaquery.matchMediaSync('screen and (width >= 840vp)')

  @State title: string = '超塩対応彼氏持ちギャルをパパ呼び愛娘にする話'
  @State author: string = 'alist'
  @State duration: number = 100
  @State artImage: string = 'http://i0.hdslb.com/bfs/archive/60edd7256f0f49dbd272f8984481a2962f9519a4.jpg@672w_378h_1c_!web-home-common-cover'
  @State smContainer:boolean = true
  @State mdContainer:boolean = false
  @State lgContainer:boolean = false
  aboutToAppear(): void {
    this.smListener.on('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.smLine(mediaQueryResult) })
    this.mdListener.on('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.mdLine(mediaQueryResult) })
    this.lgListener.on('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.lgLine(mediaQueryResult)})
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
      SymbolGlyph($r('sys.symbol.chevron_down')).fontSize(32)
      AVCastPicker({ normalColor: Color.Red, activeColor: Color.Blue, onStateChange: this.onStateChange })
        .width(32)
        .height(32)
    }.justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height(40)
  }

  @Builder artArea() {
    Column(){
      Image(this.artImage).height(320).width(320).aspectRatio(1).objectFit(ImageFit.Cover)
    }.width('100%')
    .justifyContent(FlexAlign.Center)
    .height(400)
  }

  @Builder titleArea(){
    Row(){
      SubHeader({
        primaryTitle:this.title,
        secondaryTitle:this.author,
        operationType:OperationType.ICON_GROUP,
        operationItem:[{
          value:$r('sys.symbol.heart'),
          action:()=>{
            console.info('收藏'+this.title)
          }
        }],
        operationSymbolOptions:[{fontSize:32,fontColor:[Color.Red]}]
      })
    }
  }

  @Builder opArea(){
    Column(){
      Row(){
        SymbolGlyph($r('sys.symbol.repeat')).fontSize(32)
        SymbolGlyph($r('sys.symbol.arrowshape_down_to_line_fill')).fontSize(32)
        SymbolGlyph($r('sys.symbol.speaker_wave_3')).fontSize(32)
        SymbolGlyph($r('sys.symbol.dot_grid_2x2')).fontSize(32)
      }.justifyContent(FlexAlign.SpaceAround)
      .height(48).width('100%')
      Column(){
        Row(){
          Progress({value: 0, total:this.duration,type:ProgressType.Linear})
        }.width('100%')
        Row(){
          Text(`00:00`)
          Text(`00:00`)
        }.justifyContent(FlexAlign.SpaceBetween).width('100%')
      }.width('100%').height(48)
      Row(){
        SymbolGlyph($r('sys.symbol.backward_end_fill')).fontSize(40)
        SymbolGlyph($r('sys.symbol.pause_round_triangle_fill')).fontSize(56)
        SymbolGlyph($r('sys.symbol.forward_end_fill')).fontSize(40)
      }.justifyContent(FlexAlign.SpaceAround).width('100%')
    }.justifyContent(FlexAlign.End)
    .width('100%')
  }

  @Builder lyricsArea() {
    Column(){

    }.height('100%').width('100%').backgroundColor(Color.Red)
  }

  @Builder otherArea() {

  }
}