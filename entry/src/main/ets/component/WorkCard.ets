import { Tag, WorkInfo } from '../net/WorkInfo'
import { LengthMetrics } from '@ohos.arkui.node'
import { TestDialog } from './TestDialog'

/**
 * 图片上文字样式
 * */
@Extend(Text) function imgText(){
  .padding({
    left:$r('sys.float.ohos_id_textfield_padding_horizontal'),
    right:$r('sys.float.ohos_id_textfield_padding_horizontal'),
    top:$r('sys.float.ohos_id_textfield_padding_vertical'),
    bottom:$r('sys.float.ohos_id_textfield_padding_vertical')
  })
  .borderRadius($r('sys.float.corner_radius_level5'))
  .backgroundColor('rgba(128,128,128,0.5)')
  .fontColor(Color.White)
  .fontWeight(FontWeight.Bolder)
  .fontSize("14fp")
}

@Preview
@Component
export struct WorkCard{

  dialogController: CustomDialogController = new CustomDialogController({
    builder: TestDialog(),
  })

  @Require @Prop work:WorkInfo
  //   = {
  //   "id": 1204312,
  //   "title": "【我慢イキ】まんこ屋本舗★まんチョイス#02「ふみか21歳のおまんこ」〜当店は女性のアクメは禁止のおまんこ貸し出しサービスです〜【アクメナビ搭載】",
  //   "circle_id": 62300,
  //   "name": "072LABOプッシー",
  //   "nsfw": true,
  //   "release": "2024-06-06",
  //   "dl_count": 503,
  //   "price": 176,
  //   "review_count": 2,
  //   "rate_count": 60,
  //   "rate_average_2dp": 4.75,
  //   "rate_count_detail": [
  //     {
  //       "review_point": 1,
  //       "count": 0,
  //       "ratio": 0
  //     },
  //     {
  //       "review_point": 2,
  //       "count": 0,
  //       "ratio": 0
  //     },
  //     {
  //       "review_point": 3,
  //       "count": 5,
  //       "ratio": 8
  //     },
  //     {
  //       "review_point": 4,
  //       "count": 5,
  //       "ratio": 8
  //     },
  //     {
  //       "review_point": 5,
  //       "count": 50,
  //       "ratio": 83
  //     }
  //   ],
  //   "rank": [
  //     {
  //       "term": "day",
  //       "category": "voice",
  //       "rank": 24,
  //       "rank_date": "2024-06-07"
  //     }
  //   ],
  //   "has_subtitle": false,
  //   "create_date": "2024-06-29",
  //   "vas": [
  //     {
  //       "id": "6c6b5d46-4bf4-5785-bff0-86f989d265c8",
  //       "name": "秋山はるる"
  //     }
  //   ],
  //   "tags": [
  //     {
  //       "id": 68,
  //       "i18n": {
  //         "en-us": {
  //           "name": "Dirty Talk",
  //           "history": []
  //         },
  //         "ja-jp": {
  //           "name": "淫語"
  //         },
  //         "zh-cn": {
  //           "name": "淫语",
  //           "history": []
  //         }
  //       },
  //       "name": "淫语"
  //     },
  //     {
  //       "id": 114,
  //       "i18n": {
  //         "en-us": {
  //           "name": "Coercion / Compulsion",
  //           "censored": "Ordered / Compelled"
  //         },
  //         "ja-jp": {
  //           "name": "強制/無理矢理",
  //           "censored": "命令/無理矢理"
  //         },
  //         "zh-cn": {
  //           "name": "强制/硬上",
  //           "censored": "强行"
  //         }
  //       },
  //       "name": "强制/硬上"
  //     },
  //     {
  //       "id": 128,
  //       "i18n": {
  //         "en-us": {
  //           "name": "Internal Cumshot",
  //           "history": []
  //         },
  //         "ja-jp": {
  //           "name": "中出し"
  //         },
  //         "zh-cn": {
  //           "name": "内射/中出",
  //           "history": []
  //         }
  //       },
  //       "name": "内射/中出"
  //     },
  //     {
  //       "id": 142,
  //       "i18n": {
  //         "en-us": {
  //           "name": "Naughty / Lewd",
  //           "history": []
  //         },
  //         "ja-jp": {
  //           "name": "淫乱"
  //         },
  //         "zh-cn": {
  //           "name": "淫乱"
  //         }
  //       },
  //       "name": "淫乱"
  //     },
  //     {
  //       "id": 496,
  //       "i18n": {
  //         "en-us": {
  //           "name": "Binaural"
  //         },
  //         "ja-jp": {
  //           "name": "バイノーラル/ダミヘ"
  //         },
  //         "zh-cn": {
  //           "name": "双声道立体声/人头麦",
  //           "history": [
  //             {
  //               "name": "环绕音",
  //               "deprecatedAt": 1712218463247
  //             }
  //           ]
  //         }
  //       },
  //       "name": "环绕音"
  //     },
  //     {
  //       "id": 500,
  //       "i18n": {
  //         "en-us": {
  //           "name": "Ear Licking",
  //           "history": []
  //         },
  //         "ja-jp": {
  //           "name": "耳舐め"
  //         },
  //         "zh-cn": {
  //           "name": "舔耳",
  //           "history": []
  //         }
  //       },
  //       "name": "舔耳"
  //     },
  //     {
  //       "id": 514,
  //       "i18n": {
  //         "en-us": {
  //           "name": "Guided Masturbation",
  //           "history": []
  //         },
  //         "ja-jp": {
  //           "name": "オナサポ"
  //         },
  //         "zh-cn": {
  //           "name": "辅助自慰",
  //           "history": [
  //             {
  //               "name": "自慰帮手",
  //               "deprecatedAt": 1712218463248
  //             }
  //           ]
  //         }
  //       },
  //       "name": "自慰帮手"
  //     }
  //   ],
  //   "language_editions": [
  //     {
  //       "lang": "JPN",
  //       "label": "日本語",
  //       "workno": "RJ01204312",
  //       "edition_id": 23984,
  //       "edition_type": "language",
  //       "display_order": 1
  //     },
  //     {
  //       "lang": "CHI_HANS",
  //       "label": "簡体中文",
  //       "workno": "RJ01208365",
  //       "edition_id": 23984,
  //       "edition_type": "language",
  //       "display_order": 5
  //     }
  //   ],
  //   "original_workno": undefined,
  //   "other_language_editions_in_db": [],
  //   "translation_info": {
  //     "lang": undefined,
  //     "is_child": false,
  //     "is_parent": false,
  //     "is_original": true,
  //     "is_volunteer": false,
  //     "child_worknos": [],
  //     "parent_workno": undefined,
  //     "original_workno": undefined,
  //     "is_translation_agree": true,
  //     "translation_bonus_langs": [],
  //     "is_translation_bonus_child": false,
  //     "production_trade_price_rate": 80
  //   },
  //   "work_attributes": "RG62300,adl,male,SOU,JPN,SND,TRI,DLP,REV,142",
  //   "age_category_string": "adult",
  //   "duration": 1822,
  //   "source_type": "DLSITE",
  //   "source_id": "RJ01204312",
  //   "source_url": "https://www.dlsite.com/maniax/work/=/product_id/RJ01204312.html",
  //   "userRating": undefined,
  //   "circle": {
  //     "id": 62300,
  //     "name": "072LABOプッシー",
  //     "source_id": "RG62300",
  //     "source_type": "DLSITE"
  //   },
  //   "samCoverUrl": "https://api.asmr-200.com/api/cover/1204312.jpg?type=sam",
  //   "thumbnailCoverUrl": "https://api.asmr-200.com/api/cover/1204312.jpg?type=240x240",
  //   "mainCoverUrl": "https://api.asmr-200.com/api/cover/1204312.jpg?type=main"
  // }

  build() {
    Column({space:8}){
      Stack() {
        Image(this.work.mainCoverUrl)
          .width("100%")
          .height("100%")
          .borderRadius($r('sys.float.ohos_id_card_border_radius'))
        Column() {
          Row() {
            Text(){
              SymbolSpan($r('sys.symbol.heart')).fontColor([Color.Red]).fontWeight(FontWeight.Medium)
              Span(this.work.source_id)
            }
            .imgText()
          }
          .width("100%")
          // .height("14vp")
          .justifyContent(FlexAlign.SpaceBetween)
          Row() {
            Text(){
              SymbolSpan($r('sys.symbol.clock')).fontWeight(FontWeight.Medium)
              Span(`${this.work.duration}`)
            }.imgText()
            Text(){
              SymbolSpan($r('sys.symbol.calendar')).fontWeight(FontWeight.Medium)
              Span(this.work.release).padding({left:$r('sys.float.ohos_id_textfield_padding_horizontal')})
            }.imgText()
          }
          // .linearGradient({ colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.8)', 1]] })
          .width("100%")
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: "20vp", bottom: "20vp", left: "20vp", right: "20vp" })
      }
      .borderRadius($r('sys.float.ohos_id_card_border_radius'))
      .shadow({ radius: 4, color: "rgba(0, 0, 30,0.85)" })
      .width("100%")
      .aspectRatio(16/9)
      Row() {
        Text(this.work.title)
          .width("100%")
          .fontSize("16fp")
          .maxLines(2)
      }
      .width("100%")
      .height("40vp")
      Row(){
        Text(this.work.name).fontColor(Color.Gray)
          .onClick(()=>{
            console.info('搜索社团',`$circle:${this.work.name}$`)
          })
      }.width("100%")
      Row({space:16}){
        Row(){
          Rating({rating:this.work.rate_average_2dp,}).stars(5.00).stepSize(0.01)
            .onChange(rate=>{
              console.info('打分',rate)
            })
          Text(`(${this.work.rate_count})`).fontColor(Color.Gray)
        }
        Text(){
          SymbolSpan($r('sys.symbol.message_on_message')).fontWeight(FontWeight.Bold)
          Span(`(${this.work.review_count})`).fontColor(Color.Gray)
        }
        Row(){
          SymbolGlyph($r('sys.symbol.arrow_right_up_and_square')).fontWeight(FontWeight.Bold)
          Hyperlink('this.work.source_url',this.work.source_type)
        }
      }.width("100%")
      Row({space:16}){
        Text(`${this.work.price} JPY`).fontWeight(FontWeight.Bolder).fontColor(Color.Red).fontSize(20)
        Text(`销量 ${this.work.dl_count}`)
        if(this.work.has_subtitle){
          Text('带字幕').borderWidth(1).borderColor(Color.Blue).fontColor(Color.Blue).borderRadius($r('sys.float.corner_radius_level2')).fontSize(12)
        }
        if(this.work?.language_editions?.length>0){
          Text('多语种').borderWidth(1).borderColor(Color.Blue).fontColor(Color.Blue).borderRadius($r('sys.float.corner_radius_level2')).fontSize(12)
        }
      }.width("100%")
      Flex({space:{main:LengthMetrics.vp(16),cross:LengthMetrics.vp(8)},wrap:FlexWrap.Wrap}){
        Repeat<Tag>(this.work.tags).each(tag =>{
          Text(tag.item.name).fontColor(Color.White).backgroundColor(Color.Gray)
            .borderRadius($r('sys.float.corner_radius_level8')).padding(8)
            .onClick(()=>{
              console.info('标签',tag.item.name)
            })
        }).key(item=>item.id.toString())
      }.width('100%')
    }
  }
}