import { media } from '@kit.MediaKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { AsyncCallback, BusinessError, ErrorCallback } from '@kit.BasicServicesKit';
import { audio } from '@kit.AudioKit';

import MediaData from '../entity/MediaData';
import { createAVSession, setAVMataData, setAVPlaybackState, setAVPlaybackStatePosition } from '../util/AVSessionUtil';
import { common } from '@kit.AbilityKit';
import { AppStorageConstants, LogUtil } from 'common';


export class MediaService {
  private static instance?: MediaService
  private context?: common.UIAbilityContext
  private avPlayer?: media.AVPlayer
  private avSession?:AVSessionManager.AVSession
  private playerMode: AppStorageConstants.PlayerMode = 'order'
  private playerState: media.AVPlayerState = 'idle'
  private playerList: MediaData[] = []
  private mediaData?:MediaData
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
      AppStorage.setOrCreate<media.AVPlayerState>(AppStorageConstants.PLAY_STATE, state)
      setAVPlaybackState(this.avSession!,state)
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
          setAVMataData(this.avSession!,this.mediaData!)
          this.avPlayer?.play(); // 调用播放接口开始播放
          setAVPlaybackStatePosition(this.avSession!,0)
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
    AppStorage.setOrCreate<number>(AppStorageConstants.CURRENT_TIME, time)
  }

  private onDurationUpdate: (time: number) => void = (time: number) => {
    this.mediaData!.duration = time
    setAVMataData(this.avSession!,this.mediaData!)
    AppStorage.setOrCreate<number>(AppStorageConstants.DURATION, time)
  }

  private onError: ErrorCallback = (error: BusinessError) => {
    LogUtil.error("MediaService error: " + error.message + " code: " + error.code + ' ' + error.stack)
  }

  private offTimeUpdate?: () => void
  private offStateChange?: () => void
  private onSeekDone: (seekDoneTime: number) => void = (seekDoneTime: number)=>{
    setAVPlaybackStatePosition(this.avSession!,seekDoneTime)
  }
  private offSeekDone?: () => void
  private offDurationUpdate?: () => void
  private onAudioInterrupt?: (info: audio.InterruptEvent) => void
  private offError?: () => void



  private setCallback() {
    this.avPlayer?.on('stateChange', this.onStateChange)
    this.avPlayer?.on('error', this.onError)
    this.avPlayer?.on('timeUpdate', this.onTimeUpdate)
    this.avPlayer?.on('durationUpdate', this.onDurationUpdate)
    this.avPlayer?.on('seekDone',this.onSeekDone)
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
          AppStorage.setOrCreate<MediaData>(AppStorageConstants.PLAY_MEDIA_DATA,mediaData)
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
  
  async playMedia(media?:MediaData){
    if(media){
      if(!this.mediaData){
        this.mediaData = media
        AppStorage.setOrCreate<MediaData>(AppStorageConstants.PLAY_MEDIA_DATA,media)
      }
      if(this.mediaDataIndex(media) == -1){
        this.playerList.push(media)
      }
      if (this.avPlayer?.state == 'idle' && media.mediaUrl?.trim().length>0) {
        this.avPlayer.url = media.mediaUrl
        this.mediaData = media
        AppStorage.setOrCreate<MediaData>(AppStorageConstants.PLAY_MEDIA_DATA,media)
      }
    } else {
      if (this.avPlayer?.state == 'playing'){
        this.avPlayer?.pause()
      } else if (this.avPlayer?.state != 'idle') {
        this.avPlayer?.play()
      }
    }
  }

  async playNext() {
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

  async playPrev() {
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
      const mode = (index>= modes.length? modes[0] : modes[index]) as AppStorageConstants.PlayerMode
      if (mode == 'single') {
        this.avPlayer!.loop = true
      }else {
        this.avPlayer!.loop = false
      }
      this.playerMode = mode
      AppStorage.setOrCreate<AppStorageConstants.PlayerMode>(AppStorageConstants.PLAY_MODE,mode)
    }
  }

  createSession(context: common.UIAbilityContext){
    createAVSession(context).then(avSession=>{
      avSession.on('play', ()=>{this.playMedia()});
      avSession.on('pause',()=>{this.playMedia()});
      avSession.on('playNext',()=>{this.playNext()});
      avSession.on('playPrevious', ()=>{this.playPrev()});
      avSession.on('seek',(time: number)=>{this.avPlayer?.seek(time)})
      this.avSession = avSession
    }).catch((e:BusinessError)=>{
      LogUtil.error(`创建媒体会话avSession失败：${e.message}`,e)
    })
  }

  private constructor(context: common.UIAbilityContext) {
    this.context = context
    media.createAVPlayer().then(avPlayer => {
      this.avPlayer = avPlayer
      this.setCallback()
      this.createSession(context)
      this.playerState = avPlayer.state
    }).catch((err: BusinessError) => {
      LogUtil.error('创建avPlayer失败：%{public}s', err.message, err)
    })

  }


  static build(context: common.UIAbilityContext): MediaService {
    if (!MediaService.instance) {
      MediaService.instance = new MediaService(context);
      AppStorage.setOrCreate<MediaService>(AppStorageConstants.MEDIA_SERVICE, MediaService.instance)
    }
    return MediaService.instance
  }

  static close(){
    MediaService.instance?.avPlayer?.release()
    MediaService.instance?.avSession?.destroy()
    MediaService.instance = undefined;

  }
}