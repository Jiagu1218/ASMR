import { WorkCard } from '../component/WorkCard'
import { LazyDataSource } from '../entity/LazyDataSource'
import { WebResource } from '../net/WebResoucre'
import { WorkInfo } from '../net/WorkInfo'
import { display, mediaquery } from '@kit.ArkUI'

@Entry
@Component
struct AsmrWork {
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
    this.oneListener.on('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.oneLine(mediaQueryResult) })
    this.twoListener.on('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.twoLine(mediaQueryResult) })
    this.threeListener.on('change',(mediaQueryResult:mediaquery.MediaQueryResult) => { this.threeLine(mediaQueryResult) })
    this.displayWidth = px2vp(display.getDefaultDisplaySync().width)
    // this.getWaterFlowColumnsTemplate(this.displayWidth)
    WebResource.getWorks().then(works=>{
      if (works.works) {
        const more = works.works as WorkInfo[]
        this.list.push(...more)
      }
    }).catch(()=>{
      console.error('An error occurred')
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
              WorkCard({work:work})
            }.width('100%')
          },(work:WorkInfo)=>work.id.toString())
        }.columnsTemplate(this.waterFlowColumnsTemplate)
        .columnsGap(16)
        .rowsGap(8)
        .height('100%')
        .width('100%')
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