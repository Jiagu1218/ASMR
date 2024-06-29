import { Article } from '../entity/Article'
import { Queue } from '@kit.ArkTS';
import { ArkTSUtils } from '@kit.ArkTS'
import { WebResource } from '../util/WebResoucre';
import { hilog } from '@kit.PerformanceAnalysisKit';
import emitter from '@ohos.events.emitter';

/**
 * 资源池
 * */
class DataSourcePool{
  private pageNum:number = 1
  private pageSize:number = 10
  private webDataSources:Queue<Article> = new Queue()
  private look:ArkTSUtils.locks.AsyncLock = ArkTSUtils.locks.AsyncLock.request('webDataSources_look')

  getData(size:number = 5):Article[]{
    const result:Article[] = []
    hilog.info(1,'asmrlog','DataSourcePool getData length length ' + this.webDataSources.length)
    for(let i = 0;i<size;i++){
      if(this.webDataSources.length<=0){
        break
      }
      if (this.webDataSources.length<(size * 2)) {
        this.getFromWeb()
      }
      result.push(this.webDataSources.pop())
    }
    return result
  }

  private async addData(...articles:Article[]):Promise<void>{
    hilog.info(1,'asmrlog','DataSourcePool addData length ' + articles.length)
    this.look.lockAsync(()=>{
      articles.forEach(item=>this.webDataSources.add(item))
    })
  }

  resetPool():void{
    this.pageNum = 1
    this.webDataSources = new Queue()
  }
  constructor(){
  }

  private async getFromWeb():Promise<void>{
    WebResource.getListHtmlResource(this.pageNum).then((result:Article[])=>{
      this.addData(...result)
      this.pageNum = this.pageNum + 1
      hilog.info(1,'asmrlog','DataSourcePool getFromWeb ' + this.pageNum)
    })
  }

  init(){
    WebResource.getListHtmlResource(this.pageNum).then((result:Article[])=>{
      this.addData(...result)
      emitter.emit("dataSourcePool_init")
      this.pageNum = this.pageNum + 1
      hilog.info(1,'asmrlog','DataSourcePool dataSourcePool_init ' + this.pageNum)
    })
  }

}
let dataSourcePool = new DataSourcePool()
export default dataSourcePool