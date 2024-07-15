/**
 * WebVtt片段数据
 * */
export interface WebVttData{
  /**
   * 下标
   * */
  index:number
  /**
   * 开始时间
   * */
  startTime:number
  /**
   * 结束时间
   * */
  endTime:number
  /**
   * 开始时间
   * */
  start:string
  /**
   * 结束时间
   * */
  end:string
  /**
   * 字幕内容
   * */
  subtitles:string[]
}

/**
 * WebVtt数据
 * */
export interface WebVtt extends Array<WebVttData> {

}