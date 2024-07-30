/**
 * 图片上文字样式
 * */
import { CardPanel } from '../entity/CardPanel'


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
export struct Card{
  @Require @Prop info:CardPanel
  build() {
    Column(){
      Stack() {
        Image(this.info.image)
          .width("100%")
          .height("100%")
          .borderRadius($r('sys.float.ohos_id_card_border_radius'))
        Column() {
          Row() {
            if (this.info.favorites||this.info.favoritesStr){
              Text(){
                SymbolSpan($r('sys.symbol.heart')).fontColor([Color.Red]).fontWeight(FontWeight.Medium)
                Span(this.info.favoritesStr?this.info.favoritesStr:this.info.favorites+'')
              }.letterSpacing(5)
              .imgText()
            }
          }
          .width("100%")
          // .height("14vp")
          .justifyContent(FlexAlign.SpaceBetween)
          Row() {
            if (this.info.views||this.info.viewsStr||this.info.duration||this.info.durationStr){
              Text(){
                if (this.info.duration||this.info.durationStr){
                  SymbolSpan($r('sys.symbol.clock')).fontWeight(FontWeight.Medium)
                  Span(this.info.durationStr?this.info.durationStr:this.info.duration+'')
                }
              }.imgText()
              Text(){
                if(this.info.views||this.info.viewsStr){
                  SymbolSpan($r('sys.symbol.eye')).fontWeight(FontWeight.Medium)
                  Span(this.info.viewsStr?this.info.viewsStr:this.info.views+'')
                    .padding({left:$r('sys.float.ohos_id_textfield_padding_horizontal')})
                }
              }.imgText()
            }
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
      .aspectRatio(this.info.aspectRatio?this.info.aspectRatio:16/9)
      // .height(200)
      Row() {
        Text(this.info.title)
          .width("100%")
          .height("100%")
          .fontSize("16fp")
          .maxLines(2)
      }
      .width("100%")
      .height("32vp")
    }

  }
}