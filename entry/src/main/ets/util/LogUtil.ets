import { hilog } from '@kit.PerformanceAnalysisKit'
export namespace LogUtil{
  type Unknown = object|string|number
  export function info(format: string, ...args: Unknown[]){
    hilog.info(1,'ASMR_log',format,args)
  }
  export function error(format: string, ...args: object[]){
    hilog.error(1,'ASMR_log',format,args)
  }
  export function debug(format: string, ...args: object[]){
    hilog.debug(1,'ASMR_log',format,args)
  }
  export function warn(format: string, ...args: object[]){
    hilog.warn(1,'ASMR_log',format,args)
  }
}
