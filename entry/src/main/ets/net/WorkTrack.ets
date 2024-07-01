
export interface WorkTracks extends Array<WorkTrack>{

}
/**
 * 作品文件信息（ ASMR300）
 * */
export interface WorkTrack {
  /**
   * 类型
   * */
  type: string
  /**
   * 标题
   * */
  title: string
  /**
   *
   * */
  children?: WorkTracks
  /**
   * 格式为:id/文件id?
   * */
  hash?: string
  /**
   * 作品信息
   * */
  work?: Work
  /**
   * 作品名称
   * */
  workTitle?: string
  /**
   * 媒体流地址
   * */
  mediaStreamUrl?: string
  /**
   * 下载地址
   * */
  mediaDownloadUrl?: string
  /**
   * 低质量源地址
   * */
  streamLowQualityUrl?: string
  /**
   * 时长
   * */
  duration?: number
  /**
   * 文件大小
   * */
  size?: number
}

/**
 * 作品信息
 * */
interface Work {
  /**
   * id(区RJ0后面的数字)
   * */
  id: number
  /**
   * rjCode(RJ0*****)
   * */
  source_id: string
  /**
   * 来源
   * */
  source_type: string
}