import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { DomUtils, parseDocument } from '@ohos/htmlparser2';
import { Article } from '../entity/Article';
import { taskpool, url } from '@kit.ArkTS';
import { LogUtil } from '../util/LogUtil';
import { Works } from './Works';
import { WorkTracks } from './WorkTrack';
import { parseVttFileStr } from '../util/VttUtil';
import { WebVtt } from '../entity/WebVttData';
import { Element } from 'domhandler';
import { CardPanel, CardPanels } from '../entity/CardPanel';
import { HaNiMeSession } from './HaNiMeSession';
import { VideoMediaData } from '../entity/VideoMediaData';

//TODO 替换axios 为 rcp
export namespace WebResource {

  export function getListHtmlResource(page: number = 1): Promise<Article[]> {
    return axios.get<string>(`https://www.hentaiasmr.moe/page/${page}`).then((res: AxiosResponse<string>) => {
      if (res.status == 200) {
        return taskpool.execute(analysisArticleList, res.data).then(result => {
          return result as Array<Article>
        })
      }
      return []
    })
  }

  @Concurrent
  function analysisArticleList(listHtml: string): Array<Article> {
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
        let fav =
          DomUtils.innerText(DomUtils.getChildren(DomUtils.getElements({ ["class"]: "heart-icon" }, aTag, true, 1)[0]))
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

  export async function getSource(url: string): Promise<string[]> {
    return axios.get<string>(url).then((res: AxiosResponse<string>) => {
      if (res.status == 200) {
        return taskpool.execute(analysisMediaSource, res.data).then(result => {
          return result as string[]
        })
      }
      return []
    })
  }

  @Concurrent
  function analysisMediaSource(pageHtml: string): string[] {
    let dom = parseDocument(pageHtml)
    //多p列表
    let playList = DomUtils.getElements({ ["class"]: "playlist-item" }, dom, true)
    if (playList?.length > 0) {
      return playList.map<string>(item => {
        return item["attribs"]['data-src'] as string
      })
    } else {
      //单p
      let source = DomUtils.getElementsByTagName('source', dom, true, 1);
      if (source != null && source.length > 0) {
        return [source[0].attribs["src"]]
      }
      return []
    }
  }

  export function getWorks(page: number = 1, order: string = 'create_date',
    sort: 'asc' | 'desc' = 'desc'): Promise<Works> {
    return axios.get<Works>(`https://api.asmr-200.com/api/works`, {
      params: { page, order, sort }
    }).then((res: AxiosResponse<Works>) => {
      if (res.status == 200) {
        return res.data
      }
      return {}
    })
  }

  export async function getWorkTracks(rjCode: string): Promise<WorkTracks> {
    const code = rjCode.replace('RJ0', '').replace('rj0', '').replace('RJ', '').replace('rj', '')
    return axios.get<WorkTracks>(`https://api.asmr-200.com/api/tracks/${code}`, {
      params: { v: 1 }
    }).then((res: AxiosResponse<WorkTracks>) => {
      if (res.status == 200) {
        return res.data
      }
      return []
    })
  }


  export async function getJmComic() {
    axios.get<string>('https://www.cartoon18.com/').then((res: AxiosResponse<string>) => {
      if (res.status == 200) {
        let dom = parseDocument(res.data)
        const comics = DomUtils.getElements({ ["class"]: "p-b-15 p-l-5 p-r-5" }, dom, true)
        console.info('getJmComic', comics)
      }
    }).catch((e: AxiosError) => {
      console.error('getJmComic', e)
    })
  }

  export async function getHaNiMe():Promise<CardPanels>{
    const session = rcp.createSession({
      baseAddress:'https://hanime1.me',
      headers:{
        "user-agent":'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36'
      },
      requestConfiguration: {
        dns:{
          dnsOverHttps:{
            url:'https://dns.twnic.tw/dns-query'
          }
        },
        transfer:{
          serviceType:'browser'
        }
      }
    })
    return session.get('/').then((rep: rcp.Response) => {
      if (rep.statusCode == 200) {
        const body = rep.toString()||''
        return taskpool.execute(analysisCardPanel,body).then(result => {
          return result as CardPanels
        })
      }
      return []
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
      return []
    }).finally(()=>{
      session.close()
    });
  }

  @Concurrent
  function analysisCardPanel(pageHtml: string): CardPanels {
    if (pageHtml.length==0) {
      return []
    }
    let dom = parseDocument(pageHtml).children
    const homeRows = DomUtils.getElementById('home-rows-wrapper', dom, true)
    const videoDiv = DomUtils.getElements({["class"]:'home-rows-videos-div'},homeRows,true)

    const result =videoDiv.map<CardPanel>(item=>{
      const pageUrl = url.URL.parseURL(DomUtils.getAttributeValue(item.parent as Element,'href'))
      const id = pageUrl.params.get('v')||''
      const imgTag = DomUtils.getElementsByTagName('img',item,true,1)
      const imageUrl = DomUtils.getAttributeValue(imgTag[0],'src')||''
      const titleDiv = DomUtils.getElements({['class']:'home-rows-videos-title'},item,true,1)
      const title = DomUtils.textContent(titleDiv[0])
      LogUtil.info(`title:${title} imgUrl:${imageUrl} pageUrl:${pageUrl}`)
      return {
        id:id,
        title:title,
        image:imageUrl,
        pageUrl:pageUrl.toString()
      }
    })
    const cardPanel = DomUtils.getElements({['class']:'card-mobile-panel inner'},dom,true)
    for (let item of cardPanel){
      const parentClass = DomUtils.getAttributeValue(item.parent as Element,'class')
      if('multiple-link-wrapper search-doujin-videos home-doujin-videos hidden-xs' == parentClass) {
        const title = DomUtils.getAttributeValue(item.parent as Element, 'title')||''
        const aTag = DomUtils.getElementsByTagName('a',item.parent,true,1)
        const pageUrl = DomUtils.getAttributeValue(aTag[0], 'href')
        const durationAndViews = DomUtils.getElements({ ['class']: 'card-mobile-duration' }, item, true)
        if (durationAndViews.length == 0) {
          continue
        }
        const duration = DomUtils.textContent(durationAndViews[0])?.replace(/\s*|\t|\r|\n/g, '')
        const views = DomUtils.textContent(durationAndViews[1])?.replace(/\s*|\t|\r|\n/g, '')
        const imgTag = DomUtils.getElementsByTagName('img',item,true)
        if (imgTag.length==2) {
          const imageUrl = DomUtils.getAttributeValue(imgTag[1],'src')||''
          LogUtil.info(`title:${title} duration:${duration} views:${views} imgUrl:${imageUrl} pageUrl:${pageUrl}`)
          result.push({
            id: title,
            title: title,
            image: imageUrl,
            durationStr: duration,
            viewsStr:views,
            pageUrl:pageUrl
          })
        }
      }
    }
    return result
  }

  export async function getDBMsin() {
    axios.get<string>('https://db.msin.jp/?njp').then((res: AxiosResponse<string>) => {
      if (res.status == 200) {
        res.performanceTiming
        let dom = parseDocument(res.data)
        //DomUtils.getElementById 不支持tag为root的节点 dom的tag为root
        const bottomContent = DomUtils.getElementById('bottom_content', dom.children, true)
        console.info('getJmComic', bottomContent)
        LogUtil.info(`axios花费时长${res.performanceTiming?.totalTiming}`)
      }
    }).catch((e: AxiosError) => {
      console.error('getJmComic', e)
    })

  }

  export async function getVtt(url: string): Promise<WebVtt> {
    return axios.get<string>(url).then((res: AxiosResponse<string>) => {
      if (res.status == 200) {
        console.info('getJmComic', res.data)
        return parseVttFileStr(res.data)
      }
      return []
    }).catch((e: AxiosError) => {
      console.error('getVtt', e)
      return []
    })
  }

  export async function getHaNiMeHomeData():Promise<CardPanels>{
    return HaNiMeSession.build().home()
  }
  export async function getHaNiMeVideoData(id:string):Promise<VideoMediaData>{
    return HaNiMeSession.build().playerPage(id)
  }
}