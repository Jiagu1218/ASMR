import { WorkCard } from '../component/WorkCard'

import { WebResource } from '../net/WebResoucre'
import { WorkInfo } from '../net/WorkInfo'
import { display, mediaquery, router } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'
import { HaNiMeSession } from '../net/HaNiMeSession'
import { ComicSession } from '../net/ComicSession'
import { AppStorageConstants, LazyDataSource, LogUtil } from 'common'
import { MediaService } from 'MediaService'

@Entry
@Component
struct AsmrWork {
  pageNum:number = 1
  @StorageLink(AppStorageConstants.MEDIA_SERVICE) mediaService:MediaService = MediaService.build(getContext(this)  as common.UIAbilityContext)
  @State useWaterFlows:boolean = true
  displayWidth:number = 720
  @State waterFlowColumnsTemplate:string = '1fr '
  oneListener:mediaquery.MediaQueryListener = mediaquery.matchMediaSync('screen and (width < 520vp)')
  twoListener:mediaquery.MediaQueryListener = mediaquery.matchMediaSync('screen and (width >= 520vp) and (width < 840vp)')
  threeListener:mediaquery.MediaQueryListener = mediaquery.matchMediaSync('screen and (width >= 840vp)')
  oneLine(mediaQueryResult: mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches) {
      this.waterFlowColumnsTemplate = '1fr'
    }
  }
  twoLine(mediaQueryResult: mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches) {
      this.waterFlowColumnsTemplate = '1fr 1fr'
    }
  }
  threeLine(mediaQueryResult: mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches) {
      this.waterFlowColumnsTemplate = '1fr 1fr 1fr'
    }
  }
  getWaterFlowColumnsTemplate(width:number){
    if (width < 520 ) {
      this.waterFlowColumnsTemplate = '1fr'
      return
    }
    if (width>= 520 && width < 840) {
      this.waterFlowColumnsTemplate = '1fr 1fr'
      return
    }
    if (width>= 840) {
      this.waterFlowColumnsTemplate = '1fr 1fr 1fr'
      return
    }
  }

  /**
   * 列表数据
   * */
  @State list: LazyDataSource<WorkInfo> = new LazyDataSource()
  aboutToAppear(): void {
    // HaNiMeSession.build().home().then(result =>{
    //   LogUtil.info('HaNiMeSession home:'+JSON.stringify(result))
    // }).catch((e:BusinessError)=>{
    //   LogUtil.error('HaNiMeSession home'+e.message)
    // })
    // HaNiMeSession.build().playerPage('91015').then(result =>{
    //   LogUtil.info('playerPage:'+JSON.stringify(result))
    // }).catch((e:BusinessError)=>{
    //   LogUtil.error('playerPage')
    // })
    // HaNiMeSession.build().hentai({genre:'泡麵番'}).then(result =>{
    //   LogUtil.info('hentai:'+JSON.stringify(result))
    // }).catch((e:BusinessError)=>{
    //   LogUtil.error('hentai')
    // })
    ComicSession.build().home().then(result =>{
      LogUtil.info('ComicSession home:'+JSON.stringify(result))
    }).catch((e:BusinessError)=>{
      LogUtil.error('ComicSession home'+e.message)
    })
    this.oneListener.on('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.oneLine(mediaQueryResult) })
    this.twoListener.on('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.twoLine(mediaQueryResult) })
    this.threeListener.on('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.threeLine(mediaQueryResult) })
    this.displayWidth = px2vp(display.getDefaultDisplaySync().width)
    this.getWorks()
  }

  getWorks():void{
    WebResource.getWorks(this.pageNum).then(works=>{
      if (works.works) {
        this.pageNum++
        const more = works.works as WorkInfo[]
        this.list.push(...more)
      }
    }).catch((e:BusinessError)=>{
      console.error('An error occurred',e)
    })
  }

  aboutToDisappear(): void {
    this.oneListener.off('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.oneLine(mediaQueryResult) })
    this.twoListener.off('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.twoLine(mediaQueryResult) })
    this.threeListener.off('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.threeLine(mediaQueryResult) })
  }
  build() {
    Column(){
      if (this.useWaterFlows) {
        WaterFlow(){
          LazyForEach(this.list,(work:WorkInfo)=>{
            FlowItem(){
              WorkCard({work:work}).onClick(()=>{
                LogUtil.info('Work card',work.source_id)
                this.mediaService.addPlayData({
                  id:work.source_id,
                  title:work.title,
                  duration:work.duration,
                  imageUrl:work.mainCoverUrl,
                  mediaUrl:'',
                  singer:work.name
                })
                router.pushUrl({url:'pages/Player'})
              })
            }.width('100%')
          },(work:WorkInfo)=>work.id.toString())
        }.columnsTemplate(this.waterFlowColumnsTemplate)
        .columnsGap(16)
        .rowsGap(8)
        .height('100%')
        .width('100%')
        .cachedCount(3)
        .onReachEnd(()=>{
          this.getWorks()
        })
      }else {
        List({space:24}){
          LazyForEach(this.list,(work:WorkInfo)=>{
            ListItem(){
              WorkCard({work:work})
            }
          },(work:WorkInfo)=>work.id.toString())
        }.width('100%').height('100%')
      }
    }.height('100%')
    .padding({
      top: $r('sys.float.ohos_id_default_padding_top'),
      left: $r('sys.float.ohos_id_default_padding_start'),
      right: $r('sys.float.ohos_id_default_padding_end'),
      bottom: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    })

  }
}