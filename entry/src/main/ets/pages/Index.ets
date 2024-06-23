import { Card } from '../component/Card';
import { Article } from '../entity/Article';
import { LazyDataSource } from '../entity/LazyDataSource';
import { WebResource } from '../util/WebResoucre';

@Entry
@Component
struct Index {
  @State list:LazyDataSource<Article> = new LazyDataSource()
  @State @Watch('sourcesChange') sources:string[] = []
  @State sourcesIndex:number = 0
  @State page:number = 1
  @State src:string = ''
  @State previewUri:string = ''

  videoController:VideoController = new VideoController()

  sourcesChange(){
    this.sourcesIndex = 0
  }

  async getListData(){
      let list = await WebResource.getListHtmlResource(this.page)
      if(list != null ){
        this.page++
        this.list.push(...list)
      }
  }

  aboutToAppear(): void {
    this.getListData()
  }

  build() {
    RelativeContainer() {
      List({}){
        LazyForEach(this.list,(item:Article)=>{
          ListItem(){
            Card({src:item.imgUrl,fav:item.fav,duration:item.duration,views:item.views,title:item.title})
          }.onClick(async ()=>{
            console.log(item.rjCode,item.pageUrl)
            this.videoController.reset()
            this.sources = await WebResource.getSource(item.pageUrl)
            if(this.sources?.length>0){
              this.src = this.sources[0]
            }
            this.previewUri = item.imgUrl
          })
        },(item:Article,index)=>index + item.rjCode)
      }.lanes(1)
      .cachedCount(2)
      .height('100%')
      .width('100%')
      .onReachEnd(()=>{
        this.getListData()
      })
      if (this.src?.length>0){
        Video({src:this.src,previewUri:this.previewUri,controller:this.videoController})
          .onFinish(()=>{
            this.sourcesIndex < this.sources.length ?this.src = this.sources[++this.sourcesIndex]:''
          })
          .onError(()=>{
            console.error("播放出错")
          })
          .autoPlay(true)
          .height('30%')
      }
    }
    .height('100%')
    .width('100%')
    .padding({
      top:$r('sys.float.ohos_id_default_padding_top'),
      left:$r('sys.float.ohos_id_default_padding_start'),
      right:$r('sys.float.ohos_id_default_padding_end'),
      bottom:$r('sys.float.ohos_id_default_padding_bottom_flexible'),
    })
  }
}