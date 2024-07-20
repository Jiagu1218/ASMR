import { media } from '@kit.MediaKit'
import { AsyncCallback, BusinessError, ErrorCallback } from '@kit.BasicServicesKit'
import { LogUtil } from '../util/LogUtil'
import { audio } from '@kit.AudioKit'
import { CURRENT_TIME, DURATION, MEDIA_SERVICE,
  PlayerMode,
  PLAY_MEDIA_DATA,
  PLAY_MODE,
  PLAY_STATE } from '../constant/AppStorageConstant'
import  MediaData  from '../entity/MediaData'




export class MediaService {
  private static instance?: MediaService
  private avPlayer?: media.AVPlayer
  private playerMode: PlayerMode = 'order'
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
      AppStorage.setOrCreate<media.AVPlayerState>(PLAY_STATE, state)
      switch(state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          LogUtil.info('AVPlayer state idle called.');
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

  addPlayData(...media:MediaData[]){
    media.forEach(mediaData=>{
      if (this.mediaDataIndex(mediaData) == -1) {
        this.playerList.push(mediaData)
        if (this.avPlayer?.state != 'playing') {
          AppStorage.setOrCreate<MediaData>(PLAY_MEDIA_DATA,mediaData)
        }
      }
    })
  }

  removePlayData(media:MediaData){
  }

  clearPlayList(){
    this.playerList.length = 0
  }

  /**
   * 媒体在列表中的位置
   * */
  private mediaDataIndex(media:MediaData):number{
    return this.playerList.findIndex(mediaData=>media.id == mediaData.id && media.source == mediaData.source && media.mediaUrl == mediaData.mediaUrl)
  }
  
  playMedia(media?:MediaData){
    if(media){
      AppStorage.setOrCreate<MediaData>(PLAY_MEDIA_DATA,media)
      if(this.mediaDataIndex(media) == -1){
        this.playerList.push(media)
      }
    }
    if (this.avPlayer?.state == 'idle' && media && media.mediaUrl?.trim().length>0) {
      this.avPlayer.url = media.mediaUrl
    }
    if (this.avPlayer?.state == 'playing'){
      this.avPlayer?.pause()
    } else if (this.avPlayer?.state != 'idle') {
      this.avPlayer?.play()
    }
  }

  playNext() {
    if (this.playerList.length <= 0) {
      return;
    }
    if (this.playerList.length > 1 && this.avPlayer?.state != 'idle'){
      this.avPlayer?.reset()
    }
    setTimeout(()=>{
      this.playerIndex = (this.playerIndex + 1) % this.playerList.length;
      this.playMedia(this.playerList[this.playerIndex]);
    },300)
  }

  playPrev() {
    if (this.playerList.length <= 0) {
      return;
    }
    if (this.playerList.length > 1 && this.avPlayer?.state != 'idle'){
      this.avPlayer?.reset()
    }
    setTimeout(()=>{
      this.playerIndex = (this.playerIndex - 1 + this.playerList.length) % this.playerList.length;
      this.playMedia(this.playerList[this.playerIndex]);
    },300)
  }


  changeMode(){
    const state = this.avPlayer?.state
    if (this.avPlayer && (state === 'prepared' || state === 'playing' || state === 'paused' || state === 'completed')) {
      const modes = ['order','random','single']
      const index = modes.indexOf(this.playerMode) + 1
      const mode = (index>= modes.length? modes[0] : modes[index]) as PlayerMode
      if (mode == 'single') {
        this.avPlayer!.loop = true
      }else {
        this.avPlayer!.loop = false
      }
      this.playerMode = mode
      AppStorage.setOrCreate<PlayerMode>(PLAY_MODE,mode)
    }
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