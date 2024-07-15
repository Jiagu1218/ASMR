import { util } from '@kit.ArkTS';
import { WebVtt, WebVttData } from '../entity/WebVttData';
import { formatTimeToDurationMs } from './DayJsUtil';
import { LogUtil } from './LogUtil';

/**
 * 读取字节流并解析 WebVTT
 * */
export function parseVttFile(fileBuffer: ArrayBuffer): WebVtt {
  try {
    const fileUint = new Uint8Array(fileBuffer)
    let textDecoder = util.TextDecoder.create('UTF-8')
    const decodeFileStr = textDecoder.decodeWithStream(fileUint)
    // 按行分割内容
    return parseVttFileStr(decodeFileStr)
  } catch (error) {
    LogUtil.error('Error reading or parsing the VTT file:', error);
    return [];
  }
}

/**
 * 读取字符串并解析 WebVTT
 * */
export function parseVttFileStr(fileString: string): WebVtt {
  let webVttDataList:WebVtt = []
  try {
    // 按行分割内容去除WEBVTT
    const paths = fileString.split('\n\n').slice(1)
    // 解析每一行
    for (const path of paths) {
      let indexFlag = false
      let webVttData:WebVttData = {
        index:0,
        startTime:0,
        endTime:0,
        start:'',
        end:'',
        subtitles:[]
      }
      for (const line of path.split('\n')) {
        if (line.trim() === '') {
          // 忽略空行
          continue;
        }
        if(!indexFlag && /\d+/.test(line)){
          webVttData.index = Number.parseInt(line)
          indexFlag = true
          LogUtil.info(`path ${line}`)
        } else if (line.includes('-->')) {
          // 解析时间戳
          const times = line.split(' --> ')

          webVttData.start = times[0]
          const startTime = formatTimeToDurationMs(times[0])
          const endTime = formatTimeToDurationMs(times[1])
          webVttData.startTime = startTime
          webVttData.endTime = endTime
          webVttData.end = times[1]
          LogUtil.info(`Start: ${times[0]}, End: ${times[1]}`)
        } else {
          // 解析文本
          webVttData.subtitles.push(line)
          LogUtil.info(`Subtitle: ${line}`);
        }
      }
      webVttDataList.push(webVttData)
      indexFlag = false
    }
  } catch (error) {
    LogUtil.error('Error reading or parsing the VTT file:', error);
  }
  return webVttDataList
}
