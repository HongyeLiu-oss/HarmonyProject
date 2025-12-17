import { favoriteList, DARK_MODE_KEY, songs } from '../../constants/index'
import { songItemType } from '../../models/index'
import { AvPlayerManager } from '../../utils/AvPlayerManager'
import { preferences } from '@kit.ArkData'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct SongList {
  @StorageLink(DARK_MODE_KEY)
  darkMode: boolean = true
  @State
  favoriteSongs: songItemType[] = []
  @State
  isPlaylistCollected: boolean = false
  
  aboutToAppear() {
    this.loadFavorites()
  }
  
  // 加载收藏列表
  async loadFavorites() {
    try {
      const store = preferences.getPreferencesSync(getContext(this), { name: 'music_favorites' })
      const favoritesStr = store.getSync('favorites', '[]') as string
      const favoriteIds: string[] = JSON.parse(favoritesStr) as string[]
      
      // 根据 ID 查找完整的歌曲信息
      this.favoriteSongs = songs.filter(song => favoriteIds.includes(song.id))
      
      console.log('加载收藏歌曲:', this.favoriteSongs.length)
    } catch (e) {
      console.error('加载收藏失败:', e)
    }
  }
  
  // 收藏/取消收藏歌单
  togglePlaylistCollect() {
    this.isPlaylistCollected = !this.isPlaylistCollected
    promptAction.showToast({
      message: this.isPlaylistCollected ? '已收藏该歌单' : '已取消收藏',
      duration: 1500
    })
  }
  
  build() {
    Column() {
      // 播放页
      Column() {
        // 歌单明细
        Column() {
          // 简介
          Row({ space: 8 }) {
            Row() {
              Image($r('app.media.music_logo'))
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
            }
            .width(100)
            .aspectRatio(1)
            .borderRadius(8)
            .backgroundColor(Color.White)
            .justifyContent(FlexAlign.Center)

            Column({ space: 12 }) {
              Text('我喜欢的音乐')
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text(`${this.favoriteSongs.length} 首歌曲`)
                .fontSize(12)
                .fontColor('#ffa49a9a')
              Blank()
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          // 按钮
          Row() {
            Button() {
              Row({ space: 8 }) {
                Image(this.isPlaylistCollected ? $r('app.media.ic_favorite') : $r('app.media.ic_collect'))
                  .width(20)
                  .fillColor(this.isPlaylistCollected ? '#FF4444' : '#ec5c87')
                Text(this.isPlaylistCollected ? '已收藏' : '收藏歌单')
                  .fontColor(Color.White)
                  .fontSize(14)
              }
              .width(140)
              .height(40)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#ff353333')
            }
            .clip(true)
            .onClick(() => {
              this.togglePlaylistCollect()
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height('30%')
        .justifyContent(FlexAlign.SpaceAround)
        .radialGradient({
          center: ['80%', '-10%'],
          radius: '100%',
          colors: [['#ff865d13', 0.0], [Color.Transparent, 1.0]]
        })
        .padding(16)
        // 播放列表
        Column() {
          Row({ space: 8 }) {
            Row({ space: 8 }) {
              Image($r("app.media.ic_play"))
                .width(16)
                .fillColor('#ff5186')
              Text(`播放全部 (${this.favoriteSongs.length})`)
                .fontColor(this.darkMode ? Color.White : '#333333')
                .fontSize(14)
            }
            .onClick(() => {

            })
          }
          .width('100%')
          .padding(16)
          .border({
            width: { bottom: 1 },
            color: '#12ec5c87'
          })

          Column() {
            List() {
              ForEach(this.favoriteSongs, (item: songItemType, index: number) => {
                ListItem() {
                  Row() {
                    // 前三首
                    Row() {
                      if (index === 0) {
                        Text((index + 1).toString())
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#ffffe426')
                      } else if (index === 1) {
                        Text((index + 1).toString())
                          .fontColor($r('app.color.primary_light'))
                          .fontWeight(FontWeight.Bold)
                      } else if (index === 2) {
                        Text((index + 1).toString())
                          .fontWeight(FontWeight.Bold)
                          .fontColor($r('app.color.primary_dark'))
                      } else {
                        Text((index + 1).toString())
                          .fontColor('#ffa49a9a')
                      }
                    }
                    .width(50)
                    .aspectRatio(1)
                    .justifyContent(FlexAlign.Center)
                    // 列表
                    Row({ space: 10 }) {
                      if (index < 3) {
                        Image(item.img)
                          .width(32)
                          .aspectRatio(1)
                          .borderRadius(4)
                      }
                      Column() {
                        Text(item.name)
                          .fontSize(14)
                          .fontColor(this.darkMode ? '#ffa49a9a' : '#666666')
                        Text(item.author)
                          .fontSize(12)
                          .fontColor(Color.Gray)
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                      .justifyContent(FlexAlign.Center)
                    }
                    .layoutWeight(1)

                    Image($r('app.media.ic_more'))
                      .width(24)
                      .height(24)
                      .margin({ right: 16 })
                      .fillColor(Color.Gray)
                  }
                  .alignItems(VerticalAlign.Center)
                }
                .border({
                  width: { bottom: 1 },
                  color: '#12ec5c87'
                })
                .onClick(() => {
                  // 播放
                  AvPlayerManager.singlePlay(item)
                })
              })

              if (this.favoriteSongs.length === 0) {
                ListItem() {
                  Column({ space: 16 }) {
                    Image($r('app.media.ic_song_list'))
                      .width(80)
                      .height(80)
                      .fillColor(Color.Gray)
                      .opacity(0.5)
                    Text('还没有收藏任何歌曲')
                      .fontColor(Color.Gray)
                      .fontSize(16)
                    Text('去推荐页面收藏你喜欢的音乐吧')
                      .fontColor(Color.Gray)
                      .fontSize(14)
                  }
                  .width('100%')
                  .padding({ top: 60, bottom: 60 })
                  .justifyContent(FlexAlign.Center)
                }
              } else {
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
            }
            .layoutWeight(1)
          }
          .layoutWeight(1)
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor(this.darkMode ? '#ff353333' : '#FFFFFF')
        .borderRadius({ topLeft: 12, topRight: 12 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.darkMode ? '#121215' : '#F0F0F0')
  }
}

export default SongList