import dayjs from 'dayjs'
import 'dayjs/locale/zh-cn'
import customParseFormat from 'dayjs/plugin/customParseFormat'
import duration from 'dayjs/plugin/duration'

dayjs.extend(duration)
dayjs.extend(customParseFormat)

export namespace DayJsUtil {
  /**
   * 将时长转换为时间格式
   * @param duration 时长(秒)
   * @returns time 'H:m:ss'
   * */
  export function parseSecondDuration(seconds: number): string {
    return parseMillisecondDuration(seconds * 1000)
  }

  /**
   * 将时长转换为时间格式
   * @param duration 时长(毫秒)
   * @returns time 'H:m:ss'
   * */
  export function parseMillisecondDuration(duration: number): string {
    const result = dayjs.duration(duration, 'milliseconds').format('H:m:ss')
    if (result.startsWith('0:')) {
      return result.slice(2)
    }
    return result
  }

  /**
   * 将HH:mm:ss.SSS格式的时间字符串转换成ms为单位的时长
   * @param time 时间字符串（HH:mm:ss.SSS）
   * @returns duration
   * */
  export function formatTimeToDurationMs(time: string): number {
    const timeArray = time.split(':');
    const hour = parseInt(timeArray[0]);
    const minute = parseInt(timeArray[1]);
    const secondAndMs = timeArray[2].split('.')
    const second = parseFloat(secondAndMs[0])
    const ms = parseInt(secondAndMs[1])
    return hour * 3600000 + minute * 60000 + second * 1000 + ms;
  }
}