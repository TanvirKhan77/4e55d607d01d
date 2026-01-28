const sqlite3 = require('sqlite3').verbose();
const { open } = require('sqlite');
const path = require('path');

let db = null;

async function initializeDatabase(dbPath = null) {
    const databasePath = dbPath || path.join(__dirname, '../../vitals.db');
    
    db = await open({
        filename: databasePath,
        driver: sqlite3.Database
    });

    await db.exec(`
        CREATE TABLE IF NOT EXISTS device_vitals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id TEXT NOT NULL,
            timestamp DATETIME NOT NULL,
            thermal_value INTEGER NOT NULL,
            battery_level REAL NOT NULL,
            memory_usage REAL NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `);

    await db.exec(`
        CREATE INDEX IF NOT EXISTS idx_device_timestamp 
        ON device_vitals(device_id, timestamp)
    `);

    console.log('Database initialized at:', databasePath);
    return db;
}

function getDb() {
    return db;
}

module.exports = {
    initializeDatabase,
    getDb
};
