import { PlayStateType } from '../models'
import { SONG_KEY } from '../constants'
import { AvPlayerManager } from '../utils/AvPlayerManager'

@Preview
@Component
struct PlayerNav {
  @StorageProp(SONG_KEY)
  playState: PlayStateType = new PlayStateType()

  build() {
    Row() {
      Row({ space: 10 }) {
        Image(this.playState.img)
          .width(40)
          .aspectRatio(1)
        Column() {
          Text(this.playState.name)
            .fontColor('#f403039c')
          Text(this.playState.author)
            .fontSize(12)
            .fontColor('#f403039c')
        }.alignItems(HorizontalAlign.Start)
      }.height('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: 16 }) {
        Image($r("app.media.ic_prev"))
          .width(20)
          .aspectRatio(1)
          .fillColor('#4cafc6')
          .onClick(() => {
             // 上一首
            AvPlayerManager.prevPlay()
          })

        Image(this.playState.isPlay ? $r('app.media.ic_paused') : $r('app.media.ic_play'))
          .fillColor('#4cafc6')
          .width(20)
          .height(20)
          .aspectRatio(1)
          .onClick(() => {
            // 暂停 播放
            if(this.playState.isPlay) {
              AvPlayerManager.pause()
            }else {
              AvPlayerManager.singlePlay(this.playState.playList[this.playState.playIndex])
            }
          })

        Image($r('app.media.ic_next'))
          .width(20)
          .aspectRatio(1)
          .fillColor('#4cafc6')
          .onClick(() => {
             // 下一首
            AvPlayerManager.nextPlay()
          })

      }.height('100%')
    }
    .width('100%')
    .height(60)
    .backgroundColor('#efeeee')
    .justifyContent(FlexAlign.SpaceBetween)

  }
}

export default PlayerNav
