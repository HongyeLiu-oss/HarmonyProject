
import dataRdb from '@ohos.data.rdb';
import common from '@ohos.app.ability.common';
import { DifficultyId, GameResult } from './GameTypes';

export type AppContext = common.Context;

export interface BestRecord {
  difficultyId: DifficultyId;
  bestTime: number;
  bestSteps: number;
  seed: number;
  updatedAt: number;
}

const STORE_CONFIG: dataRdb.StoreConfig = {
  name: 'maze_records.db'
};

const CREATE_SQL = `
  CREATE TABLE IF NOT EXISTS best_record (
    difficulty TEXT PRIMARY KEY,
    best_time INTEGER,
    best_steps INTEGER,
    seed INTEGER,
    updated_at INTEGER
  )
`;
let cachedStore: dataRdb.RdbStore | null = null;

async function getStore(context: AppContext): Promise<dataRdb.RdbStore> {
  if (cachedStore) {
    return cachedStore as dataRdb.RdbStore;
  }
  const store: dataRdb.RdbStore = await dataRdb.getRdbStore(context, STORE_CONFIG, 1);
  await store.executeSql(CREATE_SQL);
  cachedStore = store;
  return store;
}

export async function saveBestRecord(context: AppContext, result: GameResult): Promise<void> {
  const store: dataRdb.RdbStore = await getStore(context);
  const existing = await getBestForDifficulty(context, result.difficultyId);

  const isBetter = !existing || result.durationMs < existing.bestTime || (
    result.durationMs === existing.bestTime && result.steps < existing.bestSteps
  );

  if (!isBetter) {
    return;
  }

  const now = Date.now();
  const sql = `
    INSERT OR REPLACE INTO best_record (difficulty, best_time, best_steps, seed, updated_at)
    VALUES (?, ?, ?, ?, ?)
  `;
  await store.executeSql(sql, [result.difficultyId, result.durationMs, result.steps, result.seed, now]);
}
export async function getBestForDifficulty(context: AppContext, difficultyId: DifficultyId): Promise<BestRecord | undefined> {
  const store: dataRdb.RdbStore = await getStore(context);
  const sql = `
    SELECT difficulty, best_time, best_steps, seed, updated_at
    FROM best_record
    WHERE difficulty = ?
  `;
  const resultSet = await store.querySql(sql, [difficultyId]);
  let record: BestRecord | undefined = undefined;

  if (resultSet.goToFirstRow()) {
    const diff = resultSet.getString(resultSet.getColumnIndex('difficulty')) as DifficultyId;
    record = {
      difficultyId: diff,
      bestTime: resultSet.getLong(resultSet.getColumnIndex('best_time')),
      bestSteps: resultSet.getLong(resultSet.getColumnIndex('best_steps')),
      seed: resultSet.getLong(resultSet.getColumnIndex('seed')),
      updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at')),
    };
  }
  resultSet.close();
  return record;
}
export async function getAllBestRecords(context: AppContext): Promise<BestRecord[]> {
  const store: dataRdb.RdbStore = await getStore(context);
  const sql = `
    SELECT difficulty, best_time, best_steps, seed, updated_at
    FROM best_record
  `;
  const resultSet = await store.querySql(sql);
  const records: BestRecord[] = [];
  while (resultSet.goToNextRow()) {
    const diff = resultSet.getString(resultSet.getColumnIndex('difficulty')) as DifficultyId;
    records.push({
      difficultyId: diff,
      bestTime: resultSet.getLong(resultSet.getColumnIndex('best_time')),
      bestSteps: resultSet.getLong(resultSet.getColumnIndex('best_steps')),
      seed: resultSet.getLong(resultSet.getColumnIndex('seed')),
      updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at')),
    });
  }
  resultSet.close();
  return records;
}
