import relationalStore from '@ohos.data.relationalStore'
import { Context } from '@kit.AbilityKit'

export interface FavoriteRecord {
  id: string
  name: string
  author: string
  img: string
  url: string
  createdAt?: number
}

export class DatabaseManager {
  private static store: relationalStore.RdbStore | null = null

  private static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'app.db',
    securityLevel: relationalStore.SecurityLevel.S1
  }

  private static readonly CREATE_FAVORITES_SQL =
    `CREATE TABLE IF NOT EXISTS favorites (
      id TEXT PRIMARY KEY,
      name TEXT,
      author TEXT,
      img TEXT,
      url TEXT,
      created_at INTEGER
    )`

  private static readonly CREATE_SETTINGS_SQL =
    `CREATE TABLE IF NOT EXISTS settings (
      key TEXT PRIMARY KEY,
      value TEXT
    )`

  /**
   * 初始化数据库并建表
   */
  static async init(context: Context): Promise<void> {
    if (DatabaseManager.store) {
      return
    }
    const store = await relationalStore.getRdbStore(context, DatabaseManager.STORE_CONFIG)
    await store.executeSql(DatabaseManager.CREATE_FAVORITES_SQL)
    await store.executeSql(DatabaseManager.CREATE_SETTINGS_SQL)
    DatabaseManager.store = store
  }

  private static ensureStore(): relationalStore.RdbStore {
    if (!DatabaseManager.store) {
      throw new Error('Database not initialized')
    }
    return DatabaseManager.store
  }

  // === Favorites ===
  static async upsertFavorite(record: FavoriteRecord): Promise<void> {
    const store = DatabaseManager.ensureStore()
    const now = Date.now()
    await store.executeSql(
      'REPLACE INTO favorites (id, name, author, img, url, created_at) VALUES (?, ?, ?, ?, ?, ?)',
      [
        record.id,
        record.name,
        record.author,
        record.img,
        record.url,
        record.createdAt ?? now
      ]
    )
  }

  static async listFavorites(): Promise<FavoriteRecord[]> {
    const store = DatabaseManager.ensureStore()
    const resultSet = await store.querySql('SELECT id, name, author, img, url, created_at FROM favorites ORDER BY created_at DESC')
    const list: FavoriteRecord[] = []
    if (resultSet.rowCount > 0) {
      while (!resultSet.isAtLastRow) {
        resultSet.goToNextRow()
        list.push({
          id: resultSet.getString(resultSet.getColumnIndex('id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          author: resultSet.getString(resultSet.getColumnIndex('author')),
          img: resultSet.getString(resultSet.getColumnIndex('img')),
          url: resultSet.getString(resultSet.getColumnIndex('url')),
          createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at'))
        })
      }
    }
    resultSet.close()
    return list
  }

  static async deleteFavorite(id: string): Promise<void> {
    const store = DatabaseManager.ensureStore()
    await store.executeSql('DELETE FROM favorites WHERE id = ?', [id])
  }

  // === Settings ===
  static async setSetting(key: string, value: string): Promise<void> {
    const store = DatabaseManager.ensureStore()
    await store.executeSql(
      'REPLACE INTO settings (key, value) VALUES (?, ?)',
      [key, value]
    )
  }

  static async getSetting(key: string): Promise<string | null> {
    const store = DatabaseManager.ensureStore()
    const resultSet = await store.querySql('SELECT value FROM settings WHERE key = ?', [key])
    let value: string | null = null
    if (resultSet.rowCount > 0) {
      resultSet.goToFirstRow()
      value = resultSet.getString(resultSet.getColumnIndex('value'))
    }
    resultSet.close()
    return value
  }
}

export default DatabaseManager
