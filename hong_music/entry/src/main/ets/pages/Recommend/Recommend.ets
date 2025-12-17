import { songs, DARK_MODE_KEY } from '../../constants/index'
import { songItemType } from '../../models/index'
import { preferences } from '@kit.ArkData'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct Recommend {
  @State
  topFiveSongs: songItemType[] = songs.slice(0, 5)
  @State
  scrollOffset: number = 0
  @State
  selectedSong: songItemType | null = null
  @State
  showIntroduction: boolean = false
  @State
  favoriteSongs: string[] = []
  @StorageLink(DARK_MODE_KEY)
  darkMode: boolean = true
  
  aboutToAppear() {
    this.loadFavorites()
  }
  
  // 加载收藏列表
  async loadFavorites() {
    try {
      const store = preferences.getPreferencesSync(getContext(this), { name: 'music_favorites' })
      const favoritesStr = store.getSync('favorites', '[]') as string
      this.favoriteSongs = JSON.parse(favoritesStr) as string[]
    } catch (e) {
      console.error('加载收藏失败:', e)
    }
  }
  
  // 切换收藏状态
  async toggleFavorite(songId: string) {
    const index = this.favoriteSongs.indexOf(songId)
    let isAdding = false
    
    if (index > -1) {
      this.favoriteSongs.splice(index, 1)
      isAdding = false
    } else {
      this.favoriteSongs.push(songId)
      isAdding = true
    }
    
    try {
      const store = preferences.getPreferencesSync(getContext(this), { name: 'music_favorites' })
      store.putSync('favorites', JSON.stringify(this.favoriteSongs))
      await store.flush()
      
      // 显示提示
      promptAction.showToast({
        message: isAdding ? '已添加到收藏' : '已取消收藏',
        duration: 1500
      })
      
      console.log('当前收藏列表:', this.favoriteSongs)
    } catch (e) {
      console.error('保存收藏失败:', e)
      promptAction.showToast({
        message: '操作失败，请重试',
        duration: 1500
      })
    }
  }
  
  // 判断是否已收藏
  isFavorite(songId: string): boolean {
    return this.favoriteSongs.includes(songId)
  }
  @Builder
  PageTitle() {
    Row() {
      Text('音乐资讯')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.darkMode ? Color.White : Color.Black)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 8 })
  }

  @Builder
  SwiperComponent() {
    Row() {
      Swiper() {
        ForEach(this.topFiveSongs, (item: songItemType) => {
          Stack({ alignContent: Alignment.Bottom }) {
            Image(item.img)
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            // 渐变遮罩
            Column()
              .width('100%')
              .height(80)
              .linearGradient({
                angle: 180,
                colors: [[0x00000000, 0.0], [0xFF000000, 1.0]]
              })
            // 歌曲信息
            Column() {
              Text(item.name)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text(item.author)
                .fontSize(14)
                .fontColor('#CCCCCC')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .padding(16)
            .width('100%')
          }
          .borderRadius(8)
          .clip(true)
        })
      }
      .margin(8)
      .autoPlay(true)
      .indicator(true)

    }
    .width('100%')
    .padding(12)
  }

  @Builder
  TitleBar(title: string, subtitle: string = '') {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.darkMode ? Color.White : Color.Black)
      if (subtitle) {
        Text(subtitle)
          .fontSize(14)
          .fontColor(this.darkMode ? '#AAAAAA' : '#666666')
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({ left: 12, right: 12, top: 16, bottom: 12 })
  }

  build() {
    Scroll() {
      Column() {
        // 页面标题
        this.PageTitle()
        
        // 轮播图 - 热门推荐
        this.SwiperComponent()
        
        // 每日推荐
        Column() {
          this.TitleBar('每日推荐', '精选五首热门单曲')
          Row() {
            Scroll() {
              Row({ space: 10 }) {
                ForEach(this.topFiveSongs, (item: songItemType) => {
                  Column() {
                    Stack({ alignContent: Alignment.TopEnd }) {
                      Image(item.img)
                        .width('100%')
                        .aspectRatio(1)
                        .objectFit(ImageFit.Cover)
                      
                      // 收藏按钮
                      Image(this.isFavorite(item.id) ? $r('app.media.ic_favorite') : $r('app.media.ic_like'))
                        .width(24)
                        .height(24)
                        .fillColor(this.isFavorite(item.id) ? '#FF4444' : Color.White)
                        .margin(8)
                        .onClick(() => {
                          this.toggleFavorite(item.id)
                        })
                    }

                    Column({ space: 4 }) {
                      Text(item.name)
                        .width('100%')
                        .fontSize(15)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.darkMode ? Color.White : Color.Black)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      
                      Text(item.author)
                        .width('100%')
                        .fontSize(13)
                        .fontColor(this.darkMode ? '#CCCCCC' : '#666666')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      
                      Row({ space: 4 }) {
                        Image($r('app.media.ic_play'))
                          .width(10)
                          .height(10)
                          .fillColor(this.darkMode ? '#888888' : '#999999')
                        Text('热度 9999+')
                          .fontSize(11)
                          .fontColor(this.darkMode ? '#888888' : '#999999')
                      }
                      .width('100%')
                      .margin({ top: 2 })
                    }
                    .padding(12)
                    .alignItems(HorizontalAlign.Start)
                    .backgroundColor(this.darkMode ? '#2A2A2A' : '#F8F8F8')
                  }
                  .width('40%')
                  .borderRadius(8)
                  .clip(true)
                  .onClick(() => {
                    this.selectedSong = item
                    this.showIntroduction = true
                  })
                })
              }
            }
            .width('100%')
            .scrollable(ScrollDirection.Horizontal)
            .scrollBarWidth(0)
          }
          .padding({
            left: 8,
            right: 8
          })
          
          // 简介弹窗
          if (this.showIntroduction && this.selectedSong) {
            Column() {
              Row() {
                Text('歌曲简介')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.darkMode ? Color.White : Color.Black)
                  .layoutWeight(1)
                
                Image($r('app.media.ic_close'))
                  .width(24)
                  .height(24)
                  .fillColor(this.darkMode ? Color.White : Color.Black)
                  .onClick(() => {
                    this.showIntroduction = false
                  })
              }
              .width('100%')
              .padding(16)
              .justifyContent(FlexAlign.SpaceBetween)
              
              Divider().color(this.darkMode ? '#444444' : '#DDDDDD')
              
              Column({ space: 12 }) {
                Row() {
                  Image(this.selectedSong.img)
                    .width(80)
                    .height(80)
                    .borderRadius(8)
                  
                  Column({ space: 8 }) {
                    Text(this.selectedSong.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.darkMode ? Color.White : Color.Black)
                    Text(this.selectedSong.author)
                      .fontSize(14)
                      .fontColor(this.darkMode ? '#CCCCCC' : '#666666')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  .margin({ left: 12 })
                }
                .width('100%')
                
                Column({ space: 8 }) {
                  Text('专辑信息')
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.darkMode ? '#CCCCCC' : '#333333')
                  
                  Text(`这首歌曲由 ${this.selectedSong.author} 演唱，旋律优美动听，歌词饱含深情，深受听众喜爱。作为热门单曲，播放量已突破千万，是音乐榜单上的常客。`)
                    .fontSize(14)
                    .fontColor(this.darkMode ? '#AAAAAA' : '#666666')
                    .lineHeight(22)
                  
                  Row({ space: 16 }) {
                    Row({ space: 4 }) {
                      Image($r('app.media.ic_play'))
                        .width(16)
                        .height(16)
                        .fillColor(this.darkMode ? '#888888' : '#999999')
                      Text('1000万+')
                        .fontSize(12)
                        .fontColor(this.darkMode ? '#888888' : '#999999')
                    }
                    Row({ space: 4 }) {
                      Image($r('app.media.ic_like'))
                        .width(16)
                        .height(16)
                        .fillColor(this.darkMode ? '#888888' : '#999999')
                      Text('50万+')
                        .fontSize(12)
                        .fontColor(this.darkMode ? '#888888' : '#999999')
                    }
                  }
                  .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ top: 8 })
              }
              .padding(16)
              .width('100%')
            }
            .backgroundColor(this.darkMode ? '#1E1E1E' : '#FFFFFF')
            .borderRadius({ topLeft: 16, topRight: 16 })
            .width('100%')
            .margin({ top: 16 })
            .animation({
              duration: 300,
              curve: Curve.EaseInOut
            })
          }
        }
      }.width('100%')
    }.height('100%')
  }
}

export default Recommend