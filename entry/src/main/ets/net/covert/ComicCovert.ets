import { DomUtils, parseDocument } from '@ohos/htmlparser2'
import { Element } from 'domhandler'
import { CardPanel, CardPanels } from '../../entity/CardPanel'
import { LogUtil } from '../../util/LogUtil'
import { url } from '@kit.ArkTS'
import { VideoMediaData, VideoUrlData, VideoUrls } from '../../entity/VideoMediaData'

/**
 * 解析播放页面（首页）
 * */
@Concurrent
export function analysisCardPanel(pageHtml: string): CardPanels {
  if (pageHtml.length==0) {
    return []
  }
  let dom = parseDocument(pageHtml).children
  const comicAlbums = DomUtils.getElements({["class"]:'thumb-overlay-albums'},dom,true)

  const result =comicAlbums.map<CardPanel>(item=>{
    const aTage = DomUtils.getElementsByTagName('a',item,true,1)[0]
    const pageUrl = DomUtils.getAttributeValue(aTage,'href')||''
    let id = ''
    try {
      id = pageUrl.split('/')[2]
    } catch (e) {
    }
    const imgTag = DomUtils.getElementsByTagName('img',aTage,true,1)
    const imageUrl = DomUtils.getAttributeValue(imgTag[0],'data-original')||DomUtils.getAttributeValue(imgTag[0],'src')||''
    const title = DomUtils.getAttributeValue(imgTag[0],'title')||''
    const likeSpan = DomUtils.getElementById(`albim_likes_${id}`,item,true)
    const likes = DomUtils.textContent(likeSpan)
    return {
      id:id,
      title:title,
      image:imageUrl,
      pageUrl:pageUrl,
      favoritesStr:likes
    }
  })
  return result.filter(cardPanel=>cardPanel.id.length>0)
}

/**
 * 解析播放页面
 * */
@Concurrent
export function analysisPlayerPage(pageHtml: string):VideoMediaData{
  const dom = parseDocument(pageHtml).children
  const player = DomUtils.getElementById('player', dom, true)
  const sources = DomUtils.getElementsByTagName('source',player,true)
  const jsonLdScript = DomUtils.getElements({['type']:'application/ld+json'},dom,true,1)

  const jsonLd = DomUtils.textContent(jsonLdScript)
  const videoUrls:VideoUrls = sources.map<VideoUrlData>(source=>{
    const src = DomUtils.getAttributeValue(source,'src')||''
    const size = DomUtils.getAttributeValue(source,'size')
    const type = DomUtils.getAttributeValue(source,'type')
    return{
      url:src,
      type:type,
      definition:size
    }
  })
  const ogDesc = DomUtils.getElements({['property']:'og:description'},dom,true,1)
  const desc = DomUtils.getAttributeValue(ogDesc[0] as Element,'content')

  //系列播放列表
  const playlistScroll = DomUtils.getElementById('playlist-scroll',dom,true)

  const relatedContent = DomUtils.getElementById('related-tabcontent',dom,true)
  return {
    id:'',
    mediaUrl:videoUrls
  }
}

/**
 * 解析番剧卡片
 * */
@Concurrent
export function analysisHentai(htmlStr:string):CardPanels {
  const dom = parseDocument(htmlStr).children
  const titleDivs = DomUtils.getElements({['class']:'home-rows-videos-title'},dom,true)
  return titleDivs.map<CardPanel>(item =>{
    const title = DomUtils.textContent(item)?.replace(/\s*|\t|\r|\n/g, '')
    const imgTag = item.prev
    const imgSrc = DomUtils.getAttributeValue(imgTag as Element,'src')||''
    const aTag = item.parent?.parent
    const pageUrl = DomUtils.getAttributeValue(aTag as Element,'href')||''
    const id = url.URL.parseURL(pageUrl).params.get('v')||''
    return {
      id:id,
      title:title,
      image:imgSrc
    }
  }).filter(cardPanel=> cardPanel.id.length > 0)
}
