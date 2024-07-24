export interface VideoMediaData{
  id:string
  mediaUrl:VideoUrls
  title?:string
}
export interface VideoUrls extends Array<VideoUrlData>{}
export interface VideoUrlData{
  url:string
  type?:string
  definition?:string
}