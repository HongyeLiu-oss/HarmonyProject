import router from '@ohos.router';
import { DifficultyId, DifficultyOption, GameResult, findDifficulty } from '../common/GameTypes';
import { AppContext, BestRecord, getBestForDifficulty } from '../common/DbService';

@Entry
@Component
struct Result {
  @State result: GameResult = {
    difficultyId: 'easy',
    durationMs: 0,
    steps: 0,
    seed: 0
  };
  @State best: BestRecord | undefined = undefined;

  aboutToAppear(): void {
    this.readParams();
    this.loadBest();
  }

  build() {
    Column({ space: 16 }) {
      Text('Maze cleared')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 32 })

      Column({ space: 6 }) {
        Text(`Difficulty: ${this.getDifficulty().name}`)
          .fontSize(18)
        Text(`Time: ${this.formatDuration(this.result.durationMs)}`)
          .fontSize(18)
        Text(`Steps: ${this.result.steps}`)
          .fontSize(18)
        Text(`Seed: ${this.result.seed}`)
          .fontSize(14)
          .opacity(0.7)
        Text(this.best ? `Best: ${this.formatDuration(this.best.bestTime)} | ${this.best.bestSteps} steps` : 'Best: none')
          .fontSize(14)
          .opacity(0.75)
      }

      Row({ space: 12 }) {
        Button('Play again')
          .type(ButtonType.Capsule)
          .onClick(() => this.restart(this.getDifficulty().id))
        Button('Back to home')
          .onClick(() => router.replaceUrl({ url: 'pages/Index' }))
      }
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .backgroundColor('#0f1624')
    .padding({ left: 24, right: 24, bottom: 24 })
  }

  private restart(id: DifficultyId) {
    router.replaceUrl({
      url: 'pages/Game',
      params: {
        difficultyId: id,
        seed: Date.now()
      }
    });
  }

  private formatDuration(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    const milliseconds = Math.floor((ms % 1000) / 10);
    const pad = (v: number, len: number = 2) => v.toString().padStart(len, '0');
    return `${pad(minutes)}:${pad(seconds)}.${pad(milliseconds)}`;
  }

  private async loadBest() {
    try {
      const context = getContext(this) as AppContext;
      const record = await getBestForDifficulty(context, this.result.difficultyId);
      this.best = record;
    } catch (err) {
      console.error('load best in result failed', JSON.stringify(err));
    }
  }
  private readParams() {
    const params = router.getParams() as Record<string, string | number | boolean>;
    const difficultyId = params ? params.difficultyId as DifficultyId : undefined;
    const durationMs = params ? Number(params.durationMs) : undefined;
    const steps = params ? Number(params.steps) : undefined;
    const seed = params ? Number(params.seed) : undefined;
    this.result = {
      difficultyId: (difficultyId as DifficultyId) ?? 'easy',
      durationMs: typeof durationMs === 'number' ? durationMs : 0,
      steps: typeof steps === 'number' ? steps : 0,
      seed: typeof seed === 'number' ? seed : 0
    };
  }

  private getDifficulty(): DifficultyOption {
    return findDifficulty(this.result.difficultyId);
  }
}
