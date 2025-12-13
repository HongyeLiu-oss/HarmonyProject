import router from '@ohos.router';
import display from '@ohos.display';
import { DifficultyId, DifficultyOption, GameResult, findDifficulty } from '../common/GameTypes';
import { MazeData, MazeGenerator, Position } from '../common/MazeGenerator';
import { AppContext, saveBestRecord } from '../common/DbService';

type MoveDirection = 'up' | 'down' | 'left' | 'right';

@Entry
@Component
struct Game {
  @State difficulty: DifficultyOption = findDifficulty('easy');
  @State seed: number = Date.now();
  @State mazeData: MazeData = { grid: [[0]], start: { row: 0, col: 0 }, goal: { row: 0, col: 0 } };
  @State player: Position = { row: 0, col: 0 };
  @State steps: number = 0;
  @State elapsedMs: number = 0;
  @State status: 'playing' | 'finished' = 'playing';
  @State cellSize: number = 0;
  @State gridCols: number = 1;
  @State gridRows: number = 1;
  private timerId: number = -1;
  private boardSize: number = 360;
  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string | number | boolean>;
    const diffParam = params ? params.difficultyId as DifficultyId : undefined;
    const seedParam = params ? Number(params.seed) : undefined;
    this.difficulty = findDifficulty((diffParam as DifficultyId) ?? 'easy');
    if (typeof seedParam === 'number') {
      this.seed = seedParam;
    } else {
      this.seed = Date.now();
    }
    this.setupBoardSize();
    this.resetGame();
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  build() {
    Column() {
      Row({ space: 12 }) {
        Button('Back')
          .onClick(() => router.back())
        Text(`Difficulty: ${this.difficulty.name}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(`Seed: ${this.seed}`)
          .fontSize(12)
          .opacity(0.6)
      }
      .margin({ top: 12, left: 8, right: 8, bottom: 8 })

      Row({ space: 16 }) {
        Text(`Time: ${this.formatDuration(this.elapsedMs)}`)
          .fontSize(18)
        Text(`Steps: ${this.steps}`)
          .fontSize(18)
      }
      .margin({ bottom: 12, left: 12, right: 12 })

      this.renderBoard()

      this.renderControls()

      Row({ space: 12 }) {
        Button('Regenerate')
          .type(ButtonType.Capsule)
          .onClick(() => this.restartWithNewSeed())
        Button('Restart same seed')
          .onClick(() => this.resetGame())
      }
      .margin({ top: 12 })
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#0f1624')
    .padding({ left: 16, right: 16, bottom: 16 })
  }

  private setupBoardSize() {
    try {
      const info = display.getDefaultDisplaySync();
      const width = info?.width ?? 360;
      this.boardSize = Math.min(width - 32, 480);
    } catch (err) {
      this.boardSize = 360;
    }
  }

  private resetGame() {
    const generator = new MazeGenerator(this.seed);
    const maze = generator.generate(this.difficulty.rows, this.difficulty.cols);
    this.mazeData = maze;
    this.player = { row: maze.start.row, col: maze.start.col };
    this.gridRows = maze.grid.length;
    this.gridCols = maze.grid[0].length;
    this.cellSize = Math.floor(this.boardSize / this.gridCols);
    this.steps = 0;
    this.elapsedMs = 0;
    this.status = 'playing';
    this.stopTimer();
    this.startTimer();
  }

  private restartWithNewSeed() {
    this.seed = Date.now();
    this.resetGame();
  }

  private startTimer() {
    this.stopTimer();
    this.timerId = setInterval(() => {
      if (this.status === 'playing') {
        this.elapsedMs += 100;
      }
    }, 100);
  }

  private stopTimer() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  @Builder
  private renderBoard() {
    if (!this.mazeData || this.cellSize === 0) {
      Column() {
        Text('Generating maze...')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin(12)
      }
      .width('100%')
      .height('60%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      Column() {
        ForEach(this.mazeData.grid, (_rowData: number[], rowIndex?: number) => {
          Row() {
            ForEach(this.mazeData.grid[rowIndex ?? 0], (cell: number, colIndex?: number) => {
              this.renderCell(cell, rowIndex ?? 0, colIndex ?? 0);
            }, (colIndex?: number) => `c-${rowIndex}-${colIndex}`)
          }
          .height(this.cellSize)
        }, (rowData: number[], rowIndex?: number) => `r-${rowIndex}`)
      }
      .width(this.cellSize * this.gridCols)
      .height(this.cellSize * this.gridRows)
      .borderRadius(12)
      .backgroundColor('#111a2b')
      .padding(4)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private renderCell(value: number, rowIndex: number, colIndex: number) {
    Stack() {
      Text(' ')
        .width(this.cellSize)
        .height(this.cellSize)
        .backgroundColor(value === 0 ? '#dce3f5' : '#1f2a3a')
        .border({ width: 0.5, color: '#1c2434' })
      if (this.mazeData.goal.row === rowIndex && this.mazeData.goal.col === colIndex) {
        Text(' ')
          .width(this.cellSize * 0.6)
          .height(this.cellSize * 0.6)
          .backgroundColor('#5ad89a')
          .borderRadius(this.cellSize * 0.2)
      }
      if (this.player.row === rowIndex && this.player.col === colIndex) {
        Text(' ')
          .width(this.cellSize * 0.6)
          .height(this.cellSize * 0.6)
          .backgroundColor('#ffb020')
          .borderRadius(this.cellSize * 0.3)
          .border({ width: 1, color: '#1c2434' })
      }
    }
  }

  @Builder
  private renderControls() {
    Column({ space: 8 }) {
      Button('Up')
        .type(ButtonType.Capsule)
        .width(100)
        .onClick(() => this.tryMove('up'))
      Row({ space: 12 }) {
        Button('Left')
          .type(ButtonType.Capsule)
          .width(80)
          .onClick(() => this.tryMove('left'))
        Button('Down')
          .type(ButtonType.Capsule)
          .width(80)
          .onClick(() => this.tryMove('down'))
        Button('Right')
          .type(ButtonType.Capsule)
          .width(80)
          .onClick(() => this.tryMove('right'))
      }
    }
    .margin({ top: 16 })
    .alignItems(HorizontalAlign.Center)
  }

  private tryMove(direction: MoveDirection) {
    if (!this.mazeData || this.status !== 'playing') {
      return;
    }
    let nextRow = this.player.row;
    let nextCol = this.player.col;
    switch (direction) {
      case 'up':
        nextRow -= 1;
        break;
      case 'down':
        nextRow += 1;
        break;
      case 'left':
        nextCol -= 1;
        break;
      case 'right':
        nextCol += 1;
        break;
      default:
        break;
    }
    const next: Position = { row: nextRow, col: nextCol };
    if (!this.isInside(next) || !this.isPath(next)) {
      return;
    }
    this.player = next;
    this.steps += 1;

    if (this.reachedGoal(next)) {
      this.status = 'finished';
      this.stopTimer();
      const result: GameResult = {
        difficultyId: this.difficulty.id,
        durationMs: this.elapsedMs,
        steps: this.steps,
        seed: this.seed
      };
      this.persistResult(result);
      try {
        router.pushUrl({
          url: 'pages/Result',
          params: result
        });
      } catch (err) {
        console.error('router push failed', JSON.stringify(err));
      }
    }
  }

  private isInside(pos: Position): boolean {
    if (!this.mazeData) {
      return false;
    }
    const rows = this.mazeData.grid.length;
    const cols = this.mazeData.grid[0].length;
    return pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols;
  }

  private isPath(pos: Position): boolean {
    if (!this.mazeData) {
      return false;
    }
    return this.mazeData.grid[pos.row][pos.col] === 0;
  }

  private reachedGoal(pos: Position): boolean {
    if (!this.mazeData) {
      return false;
    }
    return pos.row === this.mazeData.goal.row && pos.col === this.mazeData.goal.col;
  }

  private formatDuration(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    const milliseconds = Math.floor((ms % 1000) / 10);
    const pad = (v: number, len: number = 2) => v.toString().padStart(len, '0');
    return `${pad(minutes)}:${pad(seconds)}.${pad(milliseconds)}`;
  }

  private async persistResult(result: GameResult) {
    try {
      const context = getContext(this) as AppContext;
      await saveBestRecord(context, result);
    } catch (err) {
      console.error('save result failed', JSON.stringify(err));
    }
  }
}
