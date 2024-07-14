/**
 * 当前avplayer状态
 * */
export const PLAY_STATE:string = 'playerState'
/**
 * 当前播放时长
 * */
export const CURRENT_TIME:string ='currentTime'
/**
 * 当前媒体时长
 * */
export const DURATION:string ='duration'
/**
 * 媒体服务
 * */
export const MEDIA_SERVICE:string ='mediaService'
/**
 * 播放模式
 * */
export const PLAY_MODE:string ='playMode'
/**
 * 播放列表下表
 * */
export const PLAY_INDEX:string ='playIndex'
/**
 * 播放媒体数据
 * */
export const PLAY_MEDIA_DATA:string ='playMediaData'

export type PlayerMode = 'order' | 'random' | 'single'

/**
 * 资源池初始化完成消息
 * */
export const DATA_SOURCE_POOL_INIT_FINISH:string ='dataSourcePool_init_finish'