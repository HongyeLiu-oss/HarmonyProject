export interface Position {
  row: number;
  col: number;
}

export interface MazeData {
  grid: number[][]; // 0: path, 1: wall
  start: Position;
  goal: Position;
}

class SeededRandom {
  private seed: number;

  constructor(seed: number) {
    this.seed = seed >>> 0;
    if (this.seed === 0) {
      this.seed = 1;
    }
  }

  next(): number {
    // 32-bit LCG
    this.seed = (1664525 * this.seed + 1013904223) % 0x100000000;
    return this.seed / 0x100000000;
  }

  shuffle<T>(array: T[]): T[] {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(this.next() * (i + 1));
      const temp = array[i];
      array[i] = array[j];
      array[j] = temp;
    }
    return array;
  }
}

export class MazeGenerator {
  private rand: SeededRandom;

  constructor(seed: number) {
    this.rand = new SeededRandom(seed);
  }

  generate(rows: number, cols: number): MazeData {
    const gridRows = rows * 2 + 1;
    const gridCols = cols * 2 + 1;
    const grid: number[][] = [];
    for (let i = 0; i < gridRows; i++) {
      grid.push(Array(gridCols).fill(1));
    }

    const start: Position = { row: 1, col: 1 };
    const goal: Position = { row: gridRows - 2, col: gridCols - 2 };

    grid[start.row][start.col] = 0;

    const stack: Position[] = [start];
    const directions: Position[] = [
      { row: -2, col: 0 },
      { row: 2, col: 0 },
      { row: 0, col: -2 },
      { row: 0, col: 2 }
    ];

    while (stack.length > 0) {
      const current = stack[stack.length - 1];
      const neighbors: Position[] = [];

      for (const dir of directions) {
        const nr = current.row + dir.row;
        const nc = current.col + dir.col;
        if (nr > 0 && nr < gridRows - 1 && nc > 0 && nc < gridCols - 1 && grid[nr][nc] === 1) {
          neighbors.push({ row: nr, col: nc });
        }
      }

      if (neighbors.length === 0) {
        stack.pop();
        continue;
      }

      this.rand.shuffle(neighbors);
      const next = neighbors[0];
      const wallRow = (current.row + next.row) / 2;
      const wallCol = (current.col + next.col) / 2;
      grid[wallRow][wallCol] = 0;
      grid[next.row][next.col] = 0;
      stack.push(next);
    }

    // 确保起点和终点为通路
    grid[start.row][start.col] = 0;
    grid[goal.row][goal.col] = 0;

    return { grid, start, goal };
  }
}
