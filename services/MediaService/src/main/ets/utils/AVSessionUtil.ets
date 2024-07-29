import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MediaData } from '../entity/MediaData';
import { media } from '@kit.MediaKit';
import { common, wantAgent } from '@kit.AbilityKit';
import { LogUtil } from 'common';

export namespace AVSessionUtil {
  export async function createAVSession(context: common.UIAbilityContext):Promise<avSession.AVSession>{
    return avSession.createAVSession(context, 'ASMR_AUDIO_SESSION', 'audio').then(session=>{
      session?.activate().then(()=>{
        LogUtil.info(`媒体会话激活`)
      })
      let wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: context.abilityInfo.bundleName,
            abilityName: context.abilityInfo.name
          }
        ],
        operationType: wantAgent.OperationType.START_ABILITIES,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      }
      wantAgent.getWantAgent(wantAgentInfo).then((agent) => {
        session.setLaunchAbility(agent).catch((e:BusinessError)=>{
          LogUtil.error(`媒体会话setLaunchAbility失败${e.message}`,e)
        })
      })
      return session
    })
  }

  export function coverToMetaData(mediaData:MediaData):avSession.AVMetadata{
    return {
      assetId: mediaData.id, // 由应用指定，用于标识应用媒体库里的媒体
      title: mediaData.title,
      mediaImage: mediaData.imageUrl,
      artist: mediaData.singer,
      duration:mediaData.duration
    }
  }

  export function coverToPlayBackState(playState:media.AVPlayerState):avSession.PlaybackState{
    switch (playState){
      case 'idle': return avSession.PlaybackState.PLAYBACK_STATE_IDLE
      case 'initialized': return avSession.PlaybackState.PLAYBACK_STATE_INITIAL
      case 'prepared': return avSession.PlaybackState.PLAYBACK_STATE_PREPARE
      case 'playing': return avSession.PlaybackState.PLAYBACK_STATE_PLAY
      case 'paused': return avSession.PlaybackState.PLAYBACK_STATE_PAUSE
      case 'stopped': return avSession.PlaybackState.PLAYBACK_STATE_STOP
      case 'completed': return avSession.PlaybackState.PLAYBACK_STATE_COMPLETED
      case 'released': return avSession.PlaybackState.PLAYBACK_STATE_RELEASED
      case 'error': return avSession.PlaybackState.PLAYBACK_STATE_ERROR
      default: return avSession.PlaybackState.PLAYBACK_STATE_ERROR
    }
  }

  export async function setAVSessionInfo(session:avSession.AVSession,mediaData:MediaData,playState:media.AVPlayerState) {
    // 设置必要的媒体信息
    setAVMataData(session,mediaData)
    // 简单设置一个播放状态
    setAVPlaybackState(session,playState)
  }
  export async function setAVPlaybackState(session:avSession.AVSession,playState:media.AVPlayerState){
    // 简单设置一个播放状态 - 暂停 未收藏
    let playbackState: avSession.AVPlaybackState = {
      state:coverToPlayBackState(playState),
      isFavorite:false
    };
    session.setAVPlaybackState(playbackState, (err) => {
      if (err) {
        LogUtil.error(`Failed to set AVPlaybackState. Code: ${err.code}, message: ${err.message}`);
      } else {
        LogUtil.info(`SetAVPlaybackState successfully`);
      }
    });
  }

  export async function setAVPlaybackStatePosition(session:avSession.AVSession,currentTime:number){
    session.setAVPlaybackState({
      position: {
        elapsedTime: currentTime,
        updateTime: new Date().getTime()
      }
    }, (err) => {
      if (err) {
        LogUtil.error(`Failed to set AVPlaybackState. Code: ${err.code}, message: ${err.message}`);
      } else {
        LogUtil.info(`SetAVPlaybackState successfully`);
      }
    });
  }

  export async function setAVMataData(session:avSession.AVSession,mediaData:MediaData){
    // 设置必要的媒体信息
    let metadata: avSession.AVMetadata = coverToMetaData(mediaData)
    session.setAVMetadata(metadata).then(() => {
      LogUtil.info(`SetAVMetadata successfully`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`Failed to set AVMetadata. Code: ${err.code}, message: ${err.message}`);
    });
  }
}