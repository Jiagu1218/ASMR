/**
 * 视频详细页信息
 * */
export interface VideoDetail{
  /**
   * 视频主体信息
   * */
  video: VideoData
  /**
   * 分p，剧集
   * */
  parts: VideoData[]
  /**
   * 相关推荐视频信息
   * */
  recommends?: VideoData[]
  /**
   * 评论信息
   * */
  comments?: Comment[]
}

/**
 * 评论信息
 * */
export interface Comment{
  id:string
  comment:string
  like?:string
  author?:string
  header?:string
  replyTo?:string
  reply?:Comment[]

}

/**
 * 视频信息
 * */
export interface VideoData{
  id: string
  title: string
  url?: string
  image?: string
  pageUrl?: string
  duration?: number
  durationStr?:string
  aspectRatio?: number
}