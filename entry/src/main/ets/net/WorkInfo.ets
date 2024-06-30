/**
 * 作品信息（ ASMR300）
 * */
export interface WorkInfo {
  /**
   * id
   * */
  id: number
  /**
   * 标题
   * */
  title: string
  /**
   * 社团id
   * */
  circle_id: number
  /**
   * 社团名称
   * */
  name: string
  nsfw: boolean
  /**
   * 发售日期
   * */
  release: string
  /**
   * DL上的销量
   * */
  dl_count: number
  /**
   * 售价（日元JPY）
   * */
  price: number
  /**
   * 评论数
   * */
  review_count: number
  /**
   * 评分人数
   * */
  rate_count: number
  /**
   * 平均分（满分5.00）
   * */
  rate_average_2dp: number
  /**
   * 评分明细
   * */
  rate_count_detail: RateCountDetail[]
  /**
   * 排名
   * */
  rank?: Rank[]
  /**
   * 是否有字幕
   * */
  has_subtitle: boolean
  /**
   * 创建时间
   * */
  create_date: string
  /**
   * 声优
   * */
  vas: Va[]
  /**
   * 标签
   * */
  tags: Tag[]
  /**
   * 多语种
   * */
  language_editions: LanguageEdition[]
  /**
   * 原rjCode 多语种版本对应的原始rjCode
   * */
  original_workno?: string
  /**
   * 其它在数据库里的版本信息
   * */
  other_language_editions_in_db: OtherLanguageEditionsInDb[]
  translation_info: TranslationInfo
  work_attributes: string
  age_category_string: string
  duration: number
  /**
   * 来源
   * */
  source_type: string
  /**
   * rjCode
   * */
  source_id: string
  /**
   * 来源链接
   * */
  source_url: string
  /**
   * 用户评分
   * */
  userRating: number
  /**
   * 社团
   * */
  circle: Circle
  /**
   * 封面 URL?
   * */
  samCoverUrl: string
  /**
   * 缩略图封面 URL
   * */
  thumbnailCoverUrl: string
  /**
   * 封面URL
   * */
  mainCoverUrl: string
}

/**
 * 评分明显
 * */
export interface RateCountDetail {
  /**
   * 审查点
   * */
  review_point: number
  /**
   * 个数
   * */
  count: number
  /**
   * 比例
   * */
  ratio: number
}

/**
 * 排名
 * */
export interface Rank {
  /**
   * 排名期限
   * */
  term: string
  /**
   * 分类
   * */
  category: string
  /**
   * 名次
   * */
  rank: number
  /**
   * 排名时间
   * */
  rank_date: string
}

/**
 * 声优
 * */
export interface Va {
  /**
   * id
   * */
  id: string
  /**
   * 声优名称
   * */
  name: string
}

/**
 * 标签
 * */
export interface Tag {
  /**
   * id
   * */
  id: number
  /**
   * 国际化
   * */
  i18n: I18n
  /**
   * 标签名称
   * */
  name: string
}

/**
 * 国际化信息
 * */
export interface I18n {
  /**
   * 英文
   * */
  "en-us": I18nInfo
  /**
   * 日文
   * */
  "ja-jp": I18nInfo
  /**
   * 中文
   * */
  "zh-cn": I18nInfo
}

/**
 * 国际化
 * */
export interface I18nInfo {
  name?: string
  history?: History[]
  censored?: string
}

export interface History {
  name: string
  deprecatedAt: number
}

/**
 * 语种
 * */
export interface LanguageEdition {
  /**
   * 语种
   * */
  lang: string
  /**
   * 语种
   * */
  label: string
  /**
   * rjCode
   * */
  workno: string
  edition_id: number
  edition_type: string
  /**
   * 显示顺序
   * */
  display_order: number
}

/**
 * 其它在数据库里的语种版本信息
 * */
export interface OtherLanguageEditionsInDb {
  id: number
  /**
   * 语种版本
   * */
  lang: string
  /**
   * 标题
   * */
  title: string
  /**
   * rjCode
   * */
  source_id: string
  /**
   * 是否为原版本
   * */
  is_original: boolean
  /**
   * 来源
   * */
  source_type: string
}

export interface TranslationInfo {
  lang?: string
  is_child: boolean
  is_parent: boolean
  is_original: boolean
  is_volunteer: boolean
  child_worknos: object[]
  parent_workno?: string
  original_workno?: string
  is_translation_agree: boolean
  translation_bonus_langs: object[]
  is_translation_bonus_child: boolean
  production_trade_price_rate: number
}

/**
 * 社团
 * */
interface Circle {
  /**
   * id
   * */
  id: number
  /**
   * 社团名称
   * */
  name: string
  /**
   * 来源id
   * */
  source_id: string
  /**
   * 来源
   * */
  source_type: string
}

