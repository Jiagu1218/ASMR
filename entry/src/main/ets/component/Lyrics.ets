import { NodeController, FrameNode, RenderNode, DrawContext } from '@kit.ArkUI'
import { UIContext } from '@kit.ArkUI'
import { drawing } from '@kit.ArkGraphics2D'
import { text } from '@kit.ArkGraphics2D'
import { image } from '@kit.ImageKit'
import { common2D } from '@kit.ArkGraphics2D'

class LyricsRendererNode extends RenderNode{
  private content:string
  constructor(content:string) {
    super()
    this.content = content
  }
  async draw(context: DrawContext){
    // 设置画笔和画刷样式
    let pen = new drawing.Pen()
    let pen_color : common2D.Color = { alpha: 0xFF, red: 0x00, green: 0x00, blue: 0x00 }
    pen.setColor(pen_color)
    context.canvas.attachPen(pen)

    // 创建一个画刷Brush对象，Brush对象用于形状的填充
    let brush = new drawing.Brush()
    let brush_color : common2D.Color = { alpha: 0xFF, red: 0x00, green: 0xFF, blue: 0x00 }
    brush.setColor(brush_color)
    context.canvas.attachPen(pen)

    //字体颜色，字重，字体大小等属性由此设置
    let myTextStyle: text.TextStyle = {
      color: { alpha: 255, red: 255, green: 0, blue: 0 },
    };
    //断词类型，换行策略，文本方向以及对齐方式由此设置
    let myParagraphStyle: text.ParagraphStyle = {
      textStyle: myTextStyle,
      align: 3,
      //wordBreak:text.WordBreak.NORMAL 文本断词类型
    };
    let fontCollection = new text.FontCollection();
    let ParagraphGraphBuilder = new text.ParagraphBuilder(myParagraphStyle, fontCollection);
    //更新文本样式
    ParagraphGraphBuilder.pushStyle(myTextStyle);
    //添加文本
    ParagraphGraphBuilder.addText(this.content);
    //生成段落
    let paragraph = ParagraphGraphBuilder.build();
    // 布局
    paragraph.layoutSync(600);
    //绘制文本
    paragraph.paint(context.canvas, 0, 0);
  }
}

class LyricsNodeController extends NodeController{
  private rootNode: FrameNode | null = null;
  makeNode(uiContext: UIContext): FrameNode | null {
    this.rootNode = new FrameNode(uiContext)
    if (this.rootNode == null) {
      return this.rootNode
    }
    const renderNode = this.rootNode.getRenderNode()
    if (renderNode != null) {
      //设置组件的布局大小和位置
      renderNode.frame = { x: 50, y: 50, width: 500, height: 500 }
      //设置组件的轴心坐标
      renderNode.pivot = { x: 275, y: 275 }
    }
    return this.rootNode
  }

  /**
   * 添加节点
   * */
  addNode(node: RenderNode): void {
    if (this.rootNode == null) {
      return
    }
    const renderNode = this.rootNode.getRenderNode()
    if (renderNode != null) {
      renderNode.appendChild(node)
    }
  }

  /**
   * 删除节点
   * */
  clearNodes(): void {
    if (this.rootNode == null) {
      return
    }
    const renderNode = this.rootNode.getRenderNode()
    if (renderNode != null) {
      renderNode.clearChildren()
    }
  }

}

@Component
export struct Lyrics{
  @State controller:LyricsNodeController = new LyricsNodeController()
  @State node:LyricsRendererNode = new LyricsRendererNode('设置画笔和画刷样式')
  test(){
    // 定义newNode的像素格式
    //设置组件的布局大小和位置
    this.node.frame = { x: 50, y: 50, width: 500, height: 500 }
    //设置组件的轴心坐标
    this.node.pivot = { x: 275, y: 275 }
  }
  build() {
    Column() {
      Row() {
        NodeContainer(this.controller)
          .height('100%').width('100%')
        Button("Draw Text")
          .margin({ bottom: 200, right: 12 })
          .onClick(() => {
            // this.controller.clearNodes()
            this.test()
            this.controller.addNode(this.node)
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .shadow(ShadowStyle.OUTER_DEFAULT_SM)
      .alignItems(VerticalAlign.Bottom)
      .layoutWeight(1)
    }
  }
}