import { Card } from '../component/Card';
import { Article } from '../entity/Article';
import { LazyDataSource } from '../entity/LazyDataSource';
import { WebResource } from '../util/WebResoucre';
import { SwipeRefresher } from '@ohos.arkui.advanced.SwipeRefresher';
import { ExpandGroup } from '../component/ExpandGroup';
import { hilog } from '@kit.PerformanceAnalysisKit';
import dataSourcePool from '../pool/DataSourcePool';
import { emitter } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State list: LazyDataSource<Article> = new LazyDataSource()
  @State @Watch('sourcesChange') sources: string[] = []
  @State sourcesIndex: number = 0
  @State page: number = 1
  @State src: string = ''
  @State title: string = ''
  @State previewUri: string = ''
  @State loading: boolean = false
  videoController: VideoController = new VideoController()

  sourcesChange() {
    this.sourcesIndex = 0
  }

  async getListData() {
    this.loading = true
    let list = await WebResource.getListHtmlResource(this.page)

    if (list != null) {
      this.page++
      this.list.push(...list)
    }
    this.loading = false
  }

  aboutToAppear(): void {
    // this.getListData()
    emitter.once("dataSourcePool_init",()=>{
      setTimeout(()=>{
        this.getData()
      },100)
    })
  }
  async getData(){
    let data:Article[]
      data = await dataSourcePool.getData(10)
    this.list.push(...data)
    hilog.info(1,'asmrlog','页面aboutToAppear '+data.length)
  }

  build() {
    RelativeContainer() {
      List({ space: 8 }) {
        LazyForEach(this.list, (item: Article) => {
          ListItem() {
            Card({
              src: item.imgUrl,
              fav: item.fav,
              duration: item.duration,
              views: item.views,
              title: item.title
            })
          }.onClick(async () => {
            console.log(item.rjCode, item.pageUrl)

            this.videoController.reset()
            this.sources = await WebResource.getSource(item.pageUrl)
            if (this.sources?.length > 0) {
              this.src = this.sources[0]
            }
            this.title = item.title
            this.previewUri = item.imgUrl
          })
        }, (item: Article, index) => index + item.rjCode)
        if (this.loading) {
          ListItem() {
            SwipeRefresher({ content: '加载中', isLoading: true })
          }
        }
      }
      .lanes(1)
      .cachedCount(2)
      .height('100%')
      .width('100%')
      .onReachEnd(async () => {
        const data = await dataSourcePool.getData(10)
        this.list.push(...data)
      })

      if (this.src?.length > 0) {
        Column(){
          Video({ src: this.src, previewUri: this.previewUri, controller: this.videoController })
            .onFinish(() => {
              this.sourcesIndex < this.sources.length ? this.src = this.sources[++this.sourcesIndex] : ''
            })
            .onError(() => {
              console.error("播放出错")
            })
            .autoPlay(true)
            .height('30%')
          ExpandGroup({data:{ imageUrl:this.previewUri,groupName:this.title,resources:this.sources}})
        }
      }

    }
    .height('100%')
    .padding({
      top: $r('sys.float.ohos_id_default_padding_top'),
      left: $r('sys.float.ohos_id_default_padding_start'),
      right: $r('sys.float.ohos_id_default_padding_end'),
      bottom: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    })
  }
}