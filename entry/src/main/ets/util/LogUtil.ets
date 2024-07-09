import { hilog } from '@kit.PerformanceAnalysisKit'
export namespace LogUtil{
  export function info(format: string, ...args: ESObject[]){
    hilog.info(1,'ASMR_log',format,args)
  }
  export function error(format: string, ...args: ESObject[]){
    hilog.error(1,'ASMR_log',format,args)
  }
  export function debug(format: string, ...args: ESObject[]){
    hilog.debug(1,'ASMR_log',format,args)
  }
  export function warn(format: string, ...args: ESObject[]){
    hilog.warn(1,'ASMR_log',format,args)
  }
}
