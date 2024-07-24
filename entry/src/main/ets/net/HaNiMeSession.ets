import { rcp } from '@kit.RemoteCommunicationKit'
import { CardPanels } from '../entity/CardPanel'
import { BusinessError } from '@kit.BasicServicesKit'
import { LogUtil } from '../util/LogUtil'
import { taskpool, url } from '@kit.ArkTS'
import { analysisCardPanel, analysisHentai, analysisPlayerPage } from './covert/HaNiMeCovert'
import { VideoMediaData } from '../entity/VideoMediaData'

export class HaNiMeSession{
  private static instance?:HaNiMeSession
  private session?:rcp.Session
  private constructor(){
    this.session = this.createSession()
  }

  private createSession():rcp.Session{
    return rcp.createSession({
      baseAddress:'https://hanime1.me',
      headers:{
        "user-agent":'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36'
      },
      requestConfiguration: {
        dns:{
          dnsOverHttps:{
            url:'https://cloudflare-dns.com/dns-query'
          }
        },
        transfer:{
          serviceType:'browser'
        }
      },
      connectionConfiguration:{
        maxConnectionsPerHost:50,
        maxTotalConnections:100
      }
    })
  }
  public static build():HaNiMeSession{
    if (HaNiMeSession.instance == null){
      if (HaNiMeSession.instance == null){
        HaNiMeSession.instance = new HaNiMeSession()
      }
    }
    return HaNiMeSession.instance
  }

  public static close():void{
    HaNiMeSession.instance?.session?.close()
  }

  /**
   * 获取首页信息
   * */
  public home():Promise<CardPanels>{
    return this.session!.get('/').then((rep: rcp.Response) => {
      if (rep.statusCode == 200) {
        const body = rep.toString()||''
        return taskpool.execute(analysisCardPanel,body).then(result=>{
          return result as CardPanels
        })
      }
      return []
    })
  }

  /**
   * 获取视频页面信息
   * */
  public playerPage(id:string):Promise<VideoMediaData>{
    return this.session!.get(`/watch?v=${id}`).then((rep: rcp.Response) => {
      if (rep.statusCode == 200) {
        const body = rep.toString()||''
        return taskpool.execute(analysisPlayerPage,body).then(result=>{
          const data = result as VideoMediaData
          data.id = id
          return data
        })
      }
      return {
        id:id,
        mediaUrl:[]
      }
    })
  }

  /**
   * 获取视频评论
   * */
  public videoComments(videoId:string){
    this.session!.get(`/loadComment?id=${videoId}&type=video`).then((rep: rcp.Response) => {
      if (rep.statusCode == 200) {
        const body = rep.toString()||''
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    })
  }

  public hentai(param:HaNiMeQueryParam):Promise<CardPanels>{
    const params = this.buildParam(param)
    return this.session!.get('/search?'+params).then((rep: rcp.Response) => {
      if (rep.statusCode == 200) {
        const body = rep.toString()||''
        return taskpool.execute(analysisHentai,body).then(result=>{
          return result as CardPanels
        })
      }
      return []
    })
  }

  private buildParam(param:HaNiMeQueryParam):string {
    const params = new url.URLParams()
    params.append('genre',param.genre)
    if (param.page) {
      params.append('page',param.page.toString())
    }
    if (param.query) {
      params.append('query',param.query)
    }
    if (param.sort) {
      params.append('sort',param.sort)
    }
    if (param.year) {
      params.append('year',param.year)
    }
    if (param.month) {
      params.append('year',param.month)
    }
    return params.toString()
  }
}

export interface HaNiMeQueryParam{
  /**
   * 类型
   * */
  genre:string
  /**
   * 页码
   * */
  page?:number
  /**
   * 搜索关键字
   * */
  query?:string
  /**
   * 排序
   * */
  sort?:string
  /**
   * 年份
   * */
  year?:string
  /**
   * 月份
   * */
  month?:string
}