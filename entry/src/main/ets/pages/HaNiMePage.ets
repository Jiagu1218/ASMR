import { display, mediaquery, router } from '@kit.ArkUI'

import { HaNiMeSession } from '../net/HaNiMeSession'
import { BusinessError } from '@kit.BasicServicesKit'
import { WebResource } from '../net/WebResoucre'

import { VideoMediaData } from '../entity/VideoMediaData'
import { Card, CardPanel, CardPanels, LazyDataSource, LogUtil } from 'common'

@Entry
@Component
struct HaNiMePage {
  pageNum: number = 1
  @State useWaterFlows: boolean = true
  @State videoData: VideoMediaData|null = null
  @State VideoUrl:string = ''
  displayWidth: number = 720
  @State waterFlowColumnsTemplate: string = '1fr '
  private videoController:VideoController = new VideoController()
  oneListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('screen and (width < 520vp)')
  twoListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('screen and (width >= 520vp) and (width < 840vp)')
  threeListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('screen and (width >= 840vp)')

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

  getWaterFlowColumnsTemplate(width: number) {
    if (width < 520) {
      this.waterFlowColumnsTemplate = '1fr'
      return
    }
    if (width >= 520 && width < 840) {
      this.waterFlowColumnsTemplate = '1fr 1fr'
      return
    }
    if (width >= 840) {
      this.waterFlowColumnsTemplate = '1fr 1fr 1fr'
      return
    }
  }

  /**
   * 列表数据
   * */
  @State list: LazyDataSource<CardPanel> = new LazyDataSource()

  aboutToAppear(): void {

    this.oneListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.oneLine(mediaQueryResult)
    })
    this.twoListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.twoLine(mediaQueryResult)
    })
    this.threeListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.threeLine(mediaQueryResult)
    })
    this.displayWidth = px2vp(display.getDefaultDisplaySync().width)
    // this.getHentai()
    this.getHome()
  }

  getHome() {
    HaNiMeSession.build().home().then(result => {
      this.list.push(...result)
      LogUtil.info('HaNiMeSession home:' + JSON.stringify(result))
    }).catch((e: BusinessError) => {
      LogUtil.error('HaNiMeSession home' + e.message)
    })
  }

  getHentai() {
    HaNiMeSession.build().hentai({genre:'裏番',page:this.pageNum}).then((result: CardPanels) => {
      this.list.push(...result)
      this.pageNum++
    }).catch((error: BusinessError) => {
      LogUtil.info(error.message)
    })
  }

  aboutToDisappear(): void {
    this.oneListener.off('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.oneLine(mediaQueryResult)
    })
    this.twoListener.off('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.twoLine(mediaQueryResult)
    })
    this.threeListener.off('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.threeLine(mediaQueryResult)
    })
  }

  build() {
    Stack() {
      if (this.useWaterFlows) {
        WaterFlow() {
          LazyForEach(this.list, (item: CardPanel) => {
            FlowItem() {
              Card({info:item})
                .onClick(()=>{
                  WebResource.getHaNiMeVideoData(item.id).then(videoData =>{
                    this.videoData = videoData
                  }).catch((e: BusinessError) =>{
                    LogUtil.error(e.message)
                  })
                })
            }.width('100%')
          }, (item: CardPanel) => item.id)
        }
        .columnsTemplate(this.waterFlowColumnsTemplate)
        .columnsGap(16)
        .rowsGap(8)
        .height('100%')
        .width('100%')
        .cachedCount(3)
        .onReachEnd(()=>{
          this.getHentai()
        })
      } else {
        List({ space: 24 }) {
          LazyForEach(this.list, (item: CardPanel) => {
            ListItem() {
              Card({info:item})
                .onClick(()=>{
                  WebResource.getHaNiMeVideoData(item.id).then(videoData =>{
                    this.videoData = videoData
                  }).catch((e: BusinessError) =>{
                    LogUtil.error(e.message)
                  })
                })
            }
          }, (item: CardPanel) => item.id)
        }.width('100%').height('100%')
        .onReachEnd(()=>{
          this.getHentai()
        })
      }
      if (this.videoData) {
        Column(){
          if (this.VideoUrl.length > 0) {
            Video({src:this.VideoUrl,controller:this.videoController}).width('100%').aspectRatio(16/9)
          }
          Row({space:16}){
            Button('关闭').onClick(()=>{
              this.videoController.reset()
              this.VideoUrl = ''
              this.videoData = null
            })
            Repeat(this.videoData.mediaUrl).each(item=>{
              Button(item.item.definition).onClick(()=>{
                this.videoController.reset()
                this.VideoUrl = item.item.url
              })
            }).key(item=>item.url)
          }
        }
      }
    }.height('100%')
    .padding({
      top: $r('sys.float.ohos_id_default_padding_top'),
      left: $r('sys.float.ohos_id_default_padding_start'),
      right: $r('sys.float.ohos_id_default_padding_end'),
      bottom: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    })
    .alignContent(Alignment.Top)
  }
}