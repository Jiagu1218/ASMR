/**
 * 媒体信息
 * */
export interface MediaData {
  id: string
  /**
   * 标题
   * */
  title: string
  /**
   * 时长
   * */
  duration: number
  /**
   * 媒体地址
   * */
  mediaUrl: string
  /**
   * 封面图片地址
   * */
  imageUrl: string
  /**
   * 歌手
   * */
  singer: string
  /**
   * 来源
   * */
  source?: string
}
