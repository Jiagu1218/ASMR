import { WorkInfo } from './WorkInfo'
/**
 * 作品信息列表（ ASMR300）
 * */
export interface Works {
  works: WorkInfo[]
  pagination: Pagination
}


/**
 * 分页信息
 * */
export interface Pagination {
  currentPage: number
  pageSize: number
  totalCount: number
}
