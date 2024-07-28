import { DomUtils, parseDocument } from '@ohos/htmlparser2'
import { Element } from 'domhandler'
import { url } from '@kit.ArkTS'
import { VideoMediaData, VideoUrlData, VideoUrls } from '../../entity/VideoMediaData'
import { CardPanel, CardPanels } from 'common'

/**
 * 解析播放页面（首页）
 * */
@Concurrent
export function analysisCardPanel(pageHtml: string): CardPanels {
  if (pageHtml.length==0) {
    return []
  }
  let dom = parseDocument(pageHtml).children
  const homeRows = DomUtils.getElementById('home-rows-wrapper', dom, true)
  const videoDiv = DomUtils.getElements({["class"]:'home-rows-videos-div'},homeRows,true)

  const result =videoDiv.map<CardPanel>(item=>{
    const pageUrl = DomUtils.getAttributeValue(item.parent as Element,'href')||''
    let id = ''
    try {
      id = url.URL.parseURL(pageUrl).params.get('v') || ''
    } catch (e) {
    }
    const imgTag = DomUtils.getElementsByTagName('img',item,true,1)
    const imageUrl = DomUtils.getAttributeValue(imgTag[0],'src')||''
    const titleDiv = DomUtils.getElements({['class']:'home-rows-videos-title'},item,true,1)
    const title = DomUtils.textContent(titleDiv[0])?.replace(/\s*|\t|\r|\n/g, '')
    return {
      id:id,
      title:title,
      image:imageUrl,
      pageUrl:pageUrl
    }
  })
  const cardPanel = DomUtils.getElements({['class']:'card-mobile-panel inner'},dom,true)
  for (let item of cardPanel){
    const parentClass = DomUtils.getAttributeValue(item.parent as Element,'class')
    if('multiple-link-wrapper search-doujin-videos home-doujin-videos hidden-xs' == parentClass) {
      const title = DomUtils.getAttributeValue(item.parent as Element, 'title')||''
      const aTag = DomUtils.getElementsByTagName('a',item.parent,true,1)
      const pageUrl = DomUtils.getAttributeValue(aTag[0], 'href')||''
      let id = ''
      try {
        id = url.URL.parseURL(pageUrl).params.get('v') || ''
      } catch (e) {
        continue
      }
      const durationAndViews = DomUtils.getElements({ ['class']: 'card-mobile-duration' }, item, true)
      if (durationAndViews.length == 0) {
        continue
      }
      const duration = DomUtils.textContent(durationAndViews[0])?.replace(/\s*|\t|\r|\n/g, '')
      const views = DomUtils.textContent(durationAndViews[1])?.replace(/\s*|\t|\r|\n/g, '')
      const imgTag = DomUtils.getElementsByTagName('img',item,true)
      if (imgTag.length==2) {
        const imageUrl = DomUtils.getAttributeValue(imgTag[1],'src')||''
        result.push({
          id: id,
          title: title,
          image: imageUrl,
          durationStr: duration,
          viewsStr:views,
          pageUrl:pageUrl
        })
      }
    }
  }
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
