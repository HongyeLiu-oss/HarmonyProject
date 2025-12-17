import { preferences } from '@kit.ArkData'
import router from '@ohos.router'
import { DARK_MODE_KEY } from '../../constants'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct Mine {
  @State
  username: string = '宏'
  @StorageLink(DARK_MODE_KEY)
  darkMode: boolean = true
  @State
  favoriteCount: number = 0
  
  aboutToAppear() {
    this.loadFavoriteCount()
    this.loadSettings()
  }
  
  onPageShow() {
    // 页面显示时重新加载收藏数量
    this.loadFavoriteCount()
  }
  
  // 加载收藏数量
  async loadFavoriteCount() {
    try {
      const store = preferences.getPreferencesSync(getContext(this), { name: 'MusicLover' })
      const favoritesStr = store.getSync('favorites', '[]') as string
      const favorites: string[] = JSON.parse(favoritesStr) as string[]
      this.favoriteCount = favorites.length
    } catch (e) {
      console.error('加载收藏列表失败:', e)
    }
  }
  
  // 加载设置
  async loadSettings() {
    try {
      const store = preferences.getPreferencesSync(getContext(this), { name: 'user_settings' })
      this.username = store.getSync('username', '宏') as string
      this.darkMode = store.getSync('darkMode', true) as boolean
    } catch (e) {
      console.error('加载设置失败:', e)
    }
  }
  
  // 保存设置
  async saveSettings() {
    try {
      const store = preferences.getPreferencesSync(getContext(this), { name: 'user_settings' })
      store.putSync('username', this.username)
      store.putSync('darkMode', this.darkMode)
      await store.flush()
    } catch (e) {
      console.error('保存设置失败:', e)
    }
  }
  
  // 切换深色模式
  async toggleDarkMode() {
    this.darkMode = !this.darkMode
    try {
      const store = preferences.getPreferencesSync(getContext(this), { name: 'user_settings' })
      store.putSync('darkMode', this.darkMode)
      await store.flush()
    } catch (e) {
      console.error('保存深色模式失败:', e)
    }
  }
  
  // 退出登录
  logout() {
    router.pushUrl({
      url: 'pages/Login'
    })
  }
  
  // 查看收藏列表
  async showFavorites() {
    try {
      const store = preferences.getPreferencesSync(getContext(this), { name: 'music_favorites' })
      const favoritesStr = store.getSync('favorites', '[]') as string
      const favorites: string[] = JSON.parse(favoritesStr) as string[]
      
      if (favorites.length === 0) {
        promptAction.showToast({
          message: '您还没有收藏任何歌曲',
          duration: 2000
        })
      } else {
        promptAction.showToast({
          message: `您已收藏 ${favorites.length} 首歌曲\n收藏列表: ${favorites.join(', ')}`,
          duration: 3000
        })
      }
    } catch (e) {
      console.error('查看收藏失败:', e)
    }
  }

  build() {
    Column() {
      // 顶部用户信息区
      Column({ space: 16 }) {
        // 用户头像
        Image($r('app.media.music_logo'))
          .width(80)
          .height(80)
          .borderRadius(40)
          .objectFit(ImageFit.Cover)
          .border({ width: 2, color: this.darkMode ? '#555555' : '#DDDDDD' })
        
        // 用户名
        Text(this.username)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.darkMode ? Color.White : Color.Black)
        
        // 欢迎语
        Text('欢迎回来，尽情享受音乐')
          .fontSize(14)
          .fontColor(this.darkMode ? '#AAAAAA' : '#666666')
      }
      .width('100%')
      .padding({ top: 60, bottom: 40 })
      
      // 设置列表
      Column() {
        // 我的收藏
        Row() {
          Row({ space: 12 }) {
            Image($r('app.media.ic_favorite'))
              .width(20)
              .height(20)
              .fillColor('#FF4444')
            Text('我的收藏')
              .fontSize(16)
              .fontColor(this.darkMode ? Color.White : Color.Black)
          }
          .layoutWeight(1)
          
          Row({ space: 8 }) {
            Text(`${this.favoriteCount} 首`)
              .fontSize(14)
              .fontColor(this.darkMode ? '#AAAAAA' : '#999999')
            Text('>')
              .fontSize(16)
              .fontColor(this.darkMode ? '#AAAAAA' : '#999999')
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .backgroundColor(this.darkMode ? '#2A2A2A' : '#FFFFFF')
        .borderRadius(12)
        .onClick(() => {
          this.showFavorites()
        })
        .margin({ bottom: 12 })
        
        // 深色模式
        Row() {
          Row({ space: 12 }) {
            Image($r('app.media.ic_auto'))
              .width(20)
              .height(20)
              .fillColor(this.darkMode ? '#FFD700' : '#666666')
            Text('深色模式')
              .fontSize(16)
              .fontColor(this.darkMode ? Color.White : Color.Black)
          }
          .layoutWeight(1)
          
          Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
            .selectedColor('#007AFF')
            .onChange((isOn: boolean) => {
              this.toggleDarkMode()
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .backgroundColor(this.darkMode ? '#2A2A2A' : '#FFFFFF')
        .borderRadius(12)
        
        // 退出登录
        Row() {
          Row({ space: 12 }) {
            Image($r('app.media.ic_close'))
              .width(20)
              .height(20)
              .fillColor(this.darkMode ? '#FF6B6B' : '#FF4444')
            Text('退出登录')
              .fontSize(16)
              .fontColor(this.darkMode ? Color.White : Color.Black)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .backgroundColor(this.darkMode ? '#2A2A2A' : '#FFFFFF')
        .borderRadius(12)
        .margin({ top: 12 })
        .onClick(() => {
          this.logout()
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.darkMode ? '#3c3f41' : '#F5F5F5')
  }
}

export default Mine