import { momentList, DARK_MODE_KEY } from '../../constants/index'
import { momentListType } from '../../models/index'

@Entry
@Component
struct Moment {
  @StorageLink(DARK_MODE_KEY)
  darkMode: boolean = true
  
  build() {
    Column() {
      Row() {
        Text('互动广场')
          .fontColor(this.darkMode ? '#eaeaec' : '#333333')
      }
      .padding(24)
      .width('100%')
      Row() {
        List({ space: 12 }) {
          ForEach(momentList, (item: momentListType) => {
            ListItem() {
              Row({ space: 12 }) {
                Row() {
                  Image(item.avatar)
                    .borderRadius(40)
                    .width(40)
                }
                Column({ space: 12 }) {
                  // 作者
                  Text(item.author)
                    .fontColor(this.darkMode ? '#e9e9e7' : '#333333')
                  // 内容
                  Text(item.content)
                    .fontColor(this.darkMode ? '#aaa9af' : '#666666')
                    .fontSize(12)
                  // 音乐卡片
                  Row() {
                    Image(item.song.img)
                      .width(60)
                      .aspectRatio(1)
                    Column({ space: 10 }) {
                      Text(item.song.name)
                        .fontColor(this.darkMode ? '#f4f4f6' : '#333333')
                        .fontSize(12)
                      Text(item.song.author)
                        .fontColor(this.darkMode ? '#a8a8ad' : '#666666')
                        .fontSize(10)
                    }
                    .layoutWeight(1)
                    .height(60)
                    .alignItems(HorizontalAlign.Start)
                    .justifyContent(FlexAlign.SpaceBetween)
                    .padding(12)
                    Image($r("app.media.ic_single_play"))
                      .width(20)
                      .fillColor(this.darkMode ? '#ececec' : '#666666')
                      .margin({ right: 12 })
                  }
                  .backgroundColor(this.darkMode ? '#46474c' : '#F0F0F0')
                  .width('100%')
                  .borderRadius(8)
                  .clip(true)
                  .onClick(()=>{
                     // 播放
                  })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .alignItems(VerticalAlign.Top)
              .padding({
                top: 24,
                bottom: 24
              })
              .borderWidth({
                bottom: 1
              })
              .borderColor(this.darkMode ? '#292931' : '#E0E0E0')
            }
          })
          ListItem() {
            Row() {
              Text('我是有底线的~')
                .fontColor(Color.Gray)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding(16)
          }
        }
        .width('100%')
        .height('100%')
        .padding({ right: 32, left: 16})

      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}

export default Moment