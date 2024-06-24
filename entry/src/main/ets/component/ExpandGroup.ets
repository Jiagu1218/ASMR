import { ExpandGroupData } from '../entity/ExpandGroupData';
/**
 * 可展开的群组
 * */
@Preview
@Component
export struct ExpandGroup {
  @State expand: boolean = true;
  @Require @Prop data:ExpandGroupData = {
    imageUrl:'http://i0.hdslb.com/bfs/archive/60edd7256f0f49dbd272f8984481a2962f9519a4.jpg@672w_378h_1c_!web-home-common-cover',
    groupName: '超塩対応彼氏持ちギャルをパパ呼び愛娘にする話',
    resources: ['http://www.hentaiasmr.moe/1.mp3']
  }
  build() {
    Column(){
      Row({space:16}){
        Image(this.data.imageUrl).width(96).aspectRatio(16/9)
        Text(this.data.groupName)
          .maxLines(2)
          .layoutWeight(1)
          //行间距
          .lineSpacing({value:8,unit:1})
        SymbolGlyph(this.expand?$r('sys.symbol.chevron_up'):$r('sys.symbol.chevron_down')).fontSize(24).width(48).onClick(()=>this.expand = !this.expand)
      }.height(72)
      .padding({
        left:$r('sys.float.ohos_id_piece_padding_horizontal'),
        right:$r('sys.float.ohos_id_piece_padding_horizontal'),
        top:$r('sys.float.ohos_id_piece_padding_vertical'),
        bottom:$r('sys.float.ohos_id_piece_padding_vertical')
      })
      if (this.expand){
        ForEach(this.data.resources,(item:string)=>{
          Row(){
            Text(item.substring(item.lastIndexOf('/')+1)).maxLines(1)
          }.padding({left:24})
          .height(48)
        },(item:string)=>item)
      }
    }.width('100%')
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }
}