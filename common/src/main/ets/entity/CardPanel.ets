export interface CardPanels extends Array<CardPanel>{

}

export interface CardPanel{
  id: string
  title: string
  image: string
  duration?:number
  durationStr?:string
  author?:string
  views?:number
  viewsStr?:string
  pageUrl?:string
  favorites?:number
  favoritesStr?:string
  comments?:number
  commentsStr?:string
  topLeftStr?:string
  topRightStr?:string
  /**
   * 图片比例
   * */
  aspectRatio?:number
}