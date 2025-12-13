export type DifficultyId = 'easy' | 'normal' | 'hard';

export interface DifficultyOption {
  id: DifficultyId;
  name: string;
  description: string;
  rows: number; // 逻辑迷宫行数（不含墙）
  cols: number; // 逻辑迷宫列数（不含墙）
}

export interface GameResult {
  difficultyId: DifficultyId;
  durationMs: number;
  steps: number;
  seed: number;
}

export const DIFFICULTIES: DifficultyOption[] = [
  { id: 'easy', name: '新手', description: '尺寸小，练手', rows: 6, cols: 6 },
  { id: 'normal', name: '进阶', description: '中等尺寸，适中难度', rows: 8, cols: 8 },
  { id: 'hard', name: '挑战', description: '更大尺寸，路径更长', rows: 10, cols: 10 },
];

export function findDifficulty(id: DifficultyId): DifficultyOption {
  const found = DIFFICULTIES.find(item => item.id === id);
  return found ?? DIFFICULTIES[0];
}
