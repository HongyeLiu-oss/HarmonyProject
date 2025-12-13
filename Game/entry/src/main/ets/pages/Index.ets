import router from '@ohos.router';
import { DIFFICULTIES, DifficultyId, DifficultyOption } from '../common/GameTypes';
import { AppContext, BestRecord, getAllBestRecords } from '../common/DbService';

interface BestMap {
  easy?: BestRecord;
  normal?: BestRecord;
  hard?: BestRecord;
}

  @Entry
  @Component
  struct Index {
  @State selectedDifficulty: DifficultyId = 'easy';
  @State bestMap: BestMap = { easy: undefined, normal: undefined, hard: undefined };

  aboutToAppear(): void {
    this.loadBest();
  }

  build() {
    Column() {
      Text("Maze Runner")
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 32, bottom: 12 })

      Text("Pick a difficulty. A random maze will be generated. Use arrows to reach the goal.")
        .fontSize(14)
        .opacity(0.8)
        .margin({ bottom: 16, left: 12, right: 12 })
        .textAlign(TextAlign.Center)

      Column() {
        ForEach(DIFFICULTIES, (item: DifficultyOption) => this.renderDifficulty(item, this.getBest(item.id), item.id === this.selectedDifficulty), (item: DifficultyOption) => item.id)
      }
      .margin({ left: 12, right: 12 })

      Button("Start")
        .type(ButtonType.Capsule)
        .fontSize(18)
        .margin({ top: 24 })
        .onClick(() => this.startGame())

      Button("Best Records")
        .margin({ top: 12 })
        .onClick(() => this.viewResults())
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0f1624')
    .padding({ left: 20, right: 20, bottom: 20 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private renderDifficulty(item: DifficultyOption, best?: BestRecord, isSelected: boolean = false) {
    Row() {
      Column({ space: 4 }) {
        Text(item.name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        Text(item.description)
          .fontSize(14)
          .opacity(0.7)
        Text(`Size: ${item.rows} x ${item.cols}`)
          .fontSize(12)
          .opacity(0.6)
        Text(best ? `Best: ${this.formatDuration(best.bestTime)} | ${best.bestSteps} steps` : 'Best: none')
          .fontSize(12)
          .opacity(0.65)
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Radio({ value: item.id, group: 'difficulty' })
        .checked(isSelected)
        .onChange(() => this.selectedDifficulty = item.id)
    }
    .padding(14)
    .margin({ bottom: 12 })
    .borderRadius(12)
    .backgroundColor(isSelected ? '#1f2a3a' : '#151d2c')
  }

  private startGame() {
    const selected = DIFFICULTIES.find(item => item.id === this.selectedDifficulty) ?? DIFFICULTIES[0];
    router.pushUrl({
      url: 'pages/Game',
      params: {
        difficultyId: selected.id,
        seed: Date.now()
      }
    });
  }

  private viewResults() {
    const best = this.getBest(this.selectedDifficulty);
    router.pushUrl({
      url: 'pages/Result',
      params: {
        fromHome: true,
        difficultyId: this.selectedDifficulty,
        durationMs: best ? best.bestTime : 0,
        steps: best ? best.bestSteps : 0,
        seed: best ? best.seed : 0
      }
    });
  }

  private async loadBest() {
    try {
      const context = getContext(this) as AppContext;
      const records = await getAllBestRecords(context);
      const map: BestMap = { easy: undefined, normal: undefined, hard: undefined };
      records.forEach(item => {
        switch (item.difficultyId) {
          case 'easy':
            map.easy = item;
            break;
          case 'normal':
            map.normal = item;
            break;
          case 'hard':
            map.hard = item;
            break;
          default:
            break;
        }
      });
      this.bestMap = map;
    } catch (err) {
      console.error('load best records failed', JSON.stringify(err));
    }
  }

  private formatDuration(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    const milliseconds = Math.floor((ms % 1000) / 10);
    const pad = (v: number, len: number = 2) => v.toString().padStart(len, '0');
    return `${pad(minutes)}:${pad(seconds)}.${pad(milliseconds)}`;
  }

  private getBest(id: DifficultyId): BestRecord | undefined {
    switch (id) {
      case 'easy':
        return this.bestMap.easy;
      case 'normal':
        return this.bestMap.normal;
      case 'hard':
        return this.bestMap.hard;
      default:
        return undefined;
    }
  }
}
