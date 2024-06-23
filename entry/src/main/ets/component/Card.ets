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
export struct Card{
  @Prop src:string = 'https://www.hentaiasmr.moe/wp-content/uploads/2024/06/1ryxyicd_o.jpg'
  @Prop fav:string = '1'
  @Prop views:string = '100'
  @Prop duration:string = '15:00'
  @Prop title:string = '熟れた女20熟したバニーさんに搾り取られたい'
  build() {
    Column(){
      Stack() {
        Image(this.src)
          .width("100%")
          .height("100%")
          .borderRadius($r('sys.float.ohos_id_card_border_radius'))
        Column() {
          Row() {
            Text(){
              SymbolSpan($r('sys.symbol.heart')).fontColor([Color.Red]).fontWeight(FontWeight.Medium)
              Span(this.fav)
            }.letterSpacing(5)
            .imgText()
          }
          .width("100%")
          // .height("14vp")
          .justifyContent(FlexAlign.SpaceBetween)
          Row() {
            Text(){
              SymbolSpan($r('sys.symbol.clock')).fontWeight(FontWeight.Medium)
              Span(this.duration)
            }.imgText()
            Text(){
              SymbolSpan($r('sys.symbol.eye')).fontWeight(FontWeight.Medium)
              Span(this.views).padding({left:$r('sys.float.ohos_id_textfield_padding_horizontal')})
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
      // .height(200)
      Row() {
        Text(this.title)
          .width("100%")
          .height("100%")
          .fontSize("16fp")
      }
      .width("100%")
      .height("32vp")
    }

  }
}