import { media } from '@kit.MediaKit'
import { AsyncCallback, BusinessError, ErrorCallback } from '@kit.BasicServicesKit'
import { LogUtil } from '../util/LogUtil'
import { audio } from '@kit.AudioKit'

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

export interface MediaData {
  id: string
  title: string
  mediaUrl: string
  imageUrl: string
  singer: string
  from: string
}

export type PlayerMode = 'order' | 'random' | 'single'

export class MediaService {
  private static instance?: MediaService
  private avPlayer?: media.AVPlayer
  private playerMode: PlayerMode = 'single'
  private playerState: media.AVPlayerState = 'idle'
  private playerList: MediaData[] = []
  private playerIndex: number = 0
  private play?: AsyncCallback<void> = () => {
    this.avPlayer?.play()
  }
  private stop?: AsyncCallback<void> = () => {
    this.avPlayer?.stop()
  }
  private reset?: AsyncCallback<void> = () => {
    this.avPlayer?.reset()
  }
  private release?: AsyncCallback<void> = () => {
    this.avPlayer?.release()
  }
  private pause?: AsyncCallback<void> = () => {
    this.avPlayer?.pause()
  }
  private seek?: (timeMs: number, mode: media.SeekMode) => void = (timeMs: number, mode: media.SeekMode) => {
    this.avPlayer?.seek(timeMs, mode)
  }
  private onStateChange: (state: media.AVPlayerState, reason: media.StateChangeReason) => void =
    (state: media.AVPlayerState, reason: media.StateChangeReason) => {
      this.playerState = state
      AppStorage.setOrCreate<string>(PLAY_STATE, state)
      switch(state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          LogUtil.info('AVPlayer state idle called.');
          this.avPlayer?.release(); // 调用release接口销毁实例对象
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          LogUtil.info('AVPlayer state initialized called.');
          this.avPlayer?.prepare();
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          LogUtil.info('AVPlayer state prepared called.');
          this.avPlayer?.play(); // 调用播放接口开始播放
          break;
        case 'playing': // play成功调用后触发该状态机上报
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          LogUtil.info('AVPlayer state paused called.');
          break;
        case 'completed': // 播放结束后触发该状态机上报
          LogUtil.info('AVPlayer state completed called.');
          this.avPlayer?.stop(); //调用播放结束接口
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          LogUtil.info('AVPlayer state stopped called.');
          this.avPlayer?.reset(); // 调用reset接口初始化avplayer状态
          break;
        case 'released':
          LogUtil.info('AVPlayer state released called.');
          break;
        default:
          LogUtil.info('AVPlayer state unknown called.');
          break;
      }
    }

  private onTimeUpdate: (time: number) => void = (time: number) => {
    AppStorage.setOrCreate<number>(CURRENT_TIME, time)
  }

  private onDurationUpdate: (time: number) => void = (time: number) => {
    AppStorage.setOrCreate<number>(DURATION, time)
  }

  private onError: ErrorCallback = (error: BusinessError) => {
    LogUtil.error("MediaService error: " + error.message + " code: " + error.code + ' ' + error.stack)
  }

  private offTimeUpdate?: () => void
  private offStateChange?: () => void
  private onSeekDone?: (seekDoneTime: number) => void
  private offSeekDone?: () => void
  private offDurationUpdate?: () => void
  private onAudioInterrupt?: (info: audio.InterruptEvent) => void
  private offError?: () => void



  private setCallback() {
    this.avPlayer?.on('stateChange', this.onStateChange)
    this.avPlayer?.on('error', this.onError)
    this.avPlayer?.on('timeUpdate', this.onTimeUpdate)
    this.avPlayer?.on('durationUpdate', this.onDurationUpdate)
  }

  private offAllCallback() {
    this.avPlayer?.off("stateChange")
    this.avPlayer?.off("seekDone")
    this.avPlayer?.off('timeUpdate')
    this.avPlayer?.off('durationUpdate')
    this.avPlayer?.off("error")
  }


  private constructor() {
    media.createAVPlayer().then(avPlayer => {
      this.avPlayer = avPlayer
      this.setCallback()
      this.playerState = avPlayer.state
    }).catch((err: BusinessError) => {
      LogUtil.error('创建avPlayer失败：%{public}s', err.message, err)
    })
  }


  static build(): MediaService {
    if (!MediaService.instance) {
      MediaService.instance = new MediaService();
      AppStorage.setOrCreate<MediaService>(MEDIA_SERVICE, MediaService.instance)
    }
    return MediaService.instance
  }
}