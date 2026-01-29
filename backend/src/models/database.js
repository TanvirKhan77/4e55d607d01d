const sqlite3 = require('sqlite3').verbose();
const { open } = require('sqlite');
const path = require('path');

// Global database connection variable
let db = null;

// Function: Initialize the SQLite database
async function initializeDatabase(dbPath = null) {
    // Use provided path or default to vitals.db in project root
    const databasePath = dbPath || path.join(__dirname, '../../vitals.db');
    
    // Open database connection
    db = await open({
        filename: databasePath,
        driver: sqlite3.Database
    });

    // Create main table for storing device vitals
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

    // Create index for faster queries by device and timestamp
    await db.exec(`
        CREATE INDEX IF NOT EXISTS idx_device_timestamp 
        ON device_vitals(device_id, timestamp)
    `);

    // Log initialization success
    console.log('Database initialized at:', databasePath);
    return db;
}

// Function: Get the database connection
// Returns: Active database connection or null if not initialized
function getDb() {
    return db;
}

// Export database functions
module.exports = {
    initializeDatabase, // Function to set up database and tables
    getDb               // Function to access database connection
};
