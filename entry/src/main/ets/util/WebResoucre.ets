import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { DomUtils, parseDocument } from '@ohos/htmlparser2';
import { Article } from '../entity/Article'
import { taskpool } from '@kit.ArkTS'
import { LogUtil } from './LogUtil';

export namespace WebResource {
  export function getListHtmlResource(page: number = 1): Promise<Article[]> {
    return axios.get<string>(`https://www.hentaiasmr.moe/page/${page}`).then((res: AxiosResponse<string>) => {
      if (res.status == 200) {
        return taskpool.execute(analysisArticleList,res.data).then(result=>{
          return result as Array<Article>
        })
      }
      return []
    })
  }
  @Concurrent
  function analysisArticleList(listHtml:string):Array<Article>{
    let dom = parseDocument(listHtml)
    LogUtil.info('开始analysisArticleList')
    let articles = DomUtils.getElementsByTagName('article', dom);
    return articles.map<Article>((article) => {
      let aTags = DomUtils.getElementsByTagName("a", article, true, 1);
      if (aTags != null && aTags.length > 0) {
        let aTag = aTags[0]
        let att = aTag.attribs
        //跳转页面链接
        let pageUrl = att["href"]
        //标题
        let title = att["title"]
        //图片链接
        let imgUrl = DomUtils.getElementsByTagName("img", aTag, true, 1)[0].attribs["data-src"];
        //观看数
        let views = DomUtils.innerText(DomUtils.getElements({ ["class"]: "views" }, aTag, true, 1));
        //时长
        let duration = DomUtils.innerText(DomUtils.getElements({ ["class"]: "duration" }, aTag, true, 1))
        //收藏数
        let fav = DomUtils.innerText(DomUtils.getChildren(DomUtils.getElements({ ["class"]: "heart-icon" }, aTag, true, 1)[0]))
        //rj编号
        let rjCode = DomUtils.innerText(DomUtils.getElements({ ["class"]: "rjcodes" }, aTag, true, 1))
        return {
          title,
          pageUrl,
          imgUrl,
          views,
          duration,
          fav,
          rjCode
        }
      }
      return {
        title: "",
        pageUrl: "",
        imgUrl: "",
        views: "",
        duration: "",
        fav: "",
        rjCode: ""
      }
    })
  }

  export async function getSource(url: string):Promise<string[]>{
    return axios.get<string>(url).then((res: AxiosResponse<string>) => {
      if (res.status == 200) {
        return taskpool.execute(analysisMediaSource,res.data).then(result=>{
          return result as string[]
        })
      }
      return []
    })
  }

  @Concurrent
  function analysisMediaSource(pageHtml:string):string[]{
    let dom = parseDocument(pageHtml)
    //多p列表
    let playList = DomUtils.getElements({ ["class"]: "playlist-item" }, dom,true)
    if(playList?.length>0){
      return playList.map<string>(item=>{
        return item["attribs"]['data-src'] as string
      })
    }else {
      //单p
      let source = DomUtils.getElementsByTagName('source', dom, true, 1);
      if (source != null && source.length > 0) {
        return [source[0].attribs["src"]]
      }
      return []
    }
  }
}