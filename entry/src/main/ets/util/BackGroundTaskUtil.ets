import { common, WantAgent, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BACKGROUND_TASK, PLAY_STATE } from '../constant/AppStorageConstant';
import { LogUtil } from './LogUtil';
import { media } from '@kit.MediaKit';
/**
 * 开启后台长时任务
 * */
export function startBackGroundTask(context: common.UIAbilityContext){
  if(AppStorage.get<media.AVPlayerState>(PLAY_STATE) != 'playing'){
    return
  }
  let wantAgentInfo: wantAgent.WantAgentInfo = {
    // 点击通知后，将要执行的动作列表
    // 添加需要被拉起应用的bundleName和abilityName
    wants: [
      {
        bundleName: context.abilityInfo.bundleName,
        abilityName: context.abilityInfo.name
      }
    ],
    // 指定点击通知栏消息后的动作是拉起ability
    actionType: wantAgent.OperationType.START_ABILITY,
    // 使用者自定义的一个私有值
    requestCode: 0,
    // 点击通知后，动作执行属性
    actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
  };

  // 通过wantAgent模块下getWantAgent方法获取WantAgent对象
  wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
    backgroundTaskManager.startBackgroundRunning(context,
      backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(() => {
        AppStorage.setOrCreate<boolean>(BACKGROUND_TASK,true)
        LogUtil.info(`Succeeded in operationing startBackgroundRunning.`);
      }).catch((err: BusinessError) => {
        LogUtil.error(`Failed to operation startBackgroundRunning. Code is ${err.code}, message is ${err.message}`);
      });
  });
}

/**
 * 关闭后台长时任务
 * */
export function stopBackGroundTask(context: common.UIAbilityContext){
  const task = AppStorage.get<boolean>(BACKGROUND_TASK)
  if (task == true) {
    backgroundTaskManager.stopBackgroundRunning(context).then(() => {
      AppStorage.setOrCreate<boolean>(BACKGROUND_TASK,false)
      LogUtil.info(`Succeeded in operationing stopBackgroundRunning.`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`Failed to operation stopBackgroundRunning. Code is ${err.code}, message is ${err.message}`);
    });
  }
}