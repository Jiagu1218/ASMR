import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import MediaData from '../entity/MediaData';
import { LogUtil } from './LogUtil';
import { media } from '@kit.MediaKit';

export async function createAVSession(context: Context):Promise<avSession.AVSession>{
  return avSession.createAVSession(context, 'ASMR_AUDIO_SESSION', 'audio');
}

export function coverToMetaData(mediaData:MediaData):avSession.AVMetadata{
  return {
    assetId: mediaData.id, // 由应用指定，用于标识应用媒体库里的媒体
    title: mediaData.title,
    mediaImage: mediaData.imageUrl,
    artist: mediaData.singer
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
  // 播放器逻辑··· 引发媒体信息与播放状态的变更
  // 设置必要的媒体信息
  let metadata: avSession.AVMetadata = coverToMetaData(mediaData)
  session.setAVMetadata(metadata).then(() => {
    LogUtil.info(`SetAVMetadata successfully`);
  }).catch((err: BusinessError) => {
    LogUtil.error(`Failed to set AVMetadata. Code: ${err.code}, message: ${err.message}`);
  });
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
  // 设置一个播放列表
  let queueItemDescription_1: avSession.AVMediaDescription = {
    assetId: '001',
    title: 'music_name',
    subtitle: 'music_sub_name',
    description: 'music_description',
    mediaImage: "PIXELMAP_OBJECT",
    extras: {'extras':'any'}
  };
  let queueItem_1: avSession.AVQueueItem = {
    itemId: 1,
    description: queueItemDescription_1
  };
  let queueItemDescription_2: avSession.AVMediaDescription = {
    assetId: '002',
    title: 'music_name',
    subtitle: 'music_sub_name',
    description: 'music_description',
    mediaImage: "PIXELMAP_OBJECT",
    extras: {'extras':'any'}
  };
  let queueItem_2: avSession.AVQueueItem = {
    itemId: 2,
    description: queueItemDescription_2
  };
  let queueItemsArray = [queueItem_1, queueItem_2];
  session.setAVQueueItems(queueItemsArray).then(() => {
    LogUtil.info(`SetAVQueueItems successfully`);
  }).catch((err: BusinessError) => {
    LogUtil.error(`Failed to set AVQueueItem, error code: ${err.code}, error message: ${err.message}`);
  });
  // 设置媒体播放列表名称
  let queueTitle = 'QUEUE_TITLE';
  session.setAVQueueTitle(queueTitle).then(() => {
    LogUtil.info(`SetAVQueueTitle successfully`);
  }).catch((err: BusinessError) => {
    LogUtil.info(`Failed to set AVQueueTitle, error code: ${err.code}, error message: ${err.message}`);
  });
}