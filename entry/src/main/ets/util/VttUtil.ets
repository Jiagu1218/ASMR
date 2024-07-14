import { util } from '@kit.ArkTS';
import { LogUtil } from './LogUtil';

// 读取字节流并解析 WebVTT 文件
export function parseVttFile(fileBuffer: ArrayBuffer): void {
  try {
    const fileUint = new Uint8Array(fileBuffer)
    let textDecoder = util.TextDecoder.create('UTF-8')
    const decodeFileStr = textDecoder.decodeWithStream(fileUint)
    // 按行分割内容
    parseVttFileStr(decodeFileStr)
  } catch (error) {
    LogUtil.error('Error reading or parsing the VTT file:', error);
  }
}

export function parseVttFileStr(fileString: string): void {
  try {
    // 按行分割内容去除WEBVTT
    const paths = fileString.split('\n\n').slice(1)
    // 解析每一行
    for (const path of paths) {
      let indexFlag = false
      for (const line of path.split('\n')) {
        if (line.trim() === '') {
          // 忽略空行
          continue;
        }
        if(!indexFlag && /\d+/.test(line)){
          const index = line
          indexFlag = true
          LogUtil.info(`path ${index}`)
        } else if (line.includes('-->')) {
          // 解析时间戳
          const times = line.split(' --> ')
          LogUtil.info(`Start: ${times[0]}, End: ${times[1]}`)
        } else {
          // 解析文本
          LogUtil.info(`Subtitle: ${line}`);
        }
      }
      indexFlag = false
    }
  } catch (error) {
    LogUtil.error('Error reading or parsing the VTT file:', error);
  }
}
