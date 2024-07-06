import { media } from '@kit.MediaKit'
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit'
import { LogUtil } from '../util/LogUtil'
import { audio } from '@kit.AudioKit'

export interface MediaData{
  id:string
  title:string
  mediaUrl:string
  imageUrl:string
  singer:string
  from:string
}
export type PlayerMode = 'order'|'random'|'single'
export class MediaService{
  private static instance?:MediaService
  private avPlayer?:media.AVPlayer
  private playerMode:PlayerMode = 'single'
  private playerState:media.AVPlayerState = 'idle'
  private playerList:MediaData[] = []
  private playerIndex:number = 0

  private play?:AsyncCallback<void> = ()=>{this.avPlayer?.play()}
  private stop?:AsyncCallback<void> = ()=>{this.avPlayer?.stop()}
  private reset?:AsyncCallback<void> = ()=>{this.avPlayer?.reset()}
  private release?:AsyncCallback<void> = ()=>{this.avPlayer?.release()}
  private pause?:AsyncCallback<void> = ()=>{this.avPlayer?.pause()}
  private seek?:(timeMs:number,mode:media.SeekMode)=>void = (timeMs:number,mode:media.SeekMode)=>{this.avPlayer?.seek(timeMs,mode)}

  private onStateChange?: (state: string, reason: media.StateChangeReason)=>void
  private offStateChange?:()=>void = ()=>{this.avPlayer?.off("stateChange")}
  private onSeekDone?:(seekDoneTime:number) =>void
  private offSeekDone?:()=>void = ()=>{this.avPlayer?.off("seekDone")}
  private onTimeUpdate?:(time:number) =>void
  private offTimeUpdate?:()=>void = ()=>{this.avPlayer?.off('timeUpdate')}
  private onDurationUpdate?:(time:number) =>void
  private offDurationUpdate?:()=>void = ()=>{this.avPlayer?.off('durationUpdate')}
  private onAudioInterrupt?:(info: audio.InterruptEvent)=>void
  private onError?:AsyncCallback<void>
  private offError?:()=>void = ()=>{this.avPlayer?.off("error")}



  private constructor() {
    media.createAVPlayer().then(avPlayer=>{
      this.avPlayer = avPlayer
      this.playerState = avPlayer.state
    }).catch((err:BusinessError)=>{
      LogUtil.error('创建avPlayer失败：%{public}s',err.message,err)
    })
  }

  static build():MediaService{
    if (!MediaService.instance) {
      MediaService.instance = new MediaService();
      AppStorage.setOrCreate<MediaService>("mediaService",MediaService.instance)
    }
    return MediaService.instance
  }

}