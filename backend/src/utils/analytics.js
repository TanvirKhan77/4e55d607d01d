const { getDb } = require('../models/database');

// Function: Calculate rolling averages and daily statistics for a device
async function calculateRollingAverage(deviceId) {
    try {
        // Get database connection
        const db = getDb();

        // Query 1: Calculate averages of latest 10 readings for the device
        const query = `
            SELECT 
                AVG(thermal_value) as avg_thermal,
                AVG(battery_level) as avg_battery,
                AVG(memory_usage) as avg_memory,
                COUNT(*) as total_count
            FROM (
                SELECT * FROM device_vitals 
                WHERE device_id = ? 
                ORDER BY timestamp DESC 
                LIMIT 10
            )
        `;
        
        // Execute rolling average query
        const result = await db.get(query, [deviceId]);
        
        // Query 2: Get min/max stats for the last 24 hours
        const statsQuery = `
            SELECT 
                MIN(thermal_value) as min_thermal,
                MAX(thermal_value) as max_thermal,
                MIN(battery_level) as min_battery,
                MAX(battery_level) as max_battery,
                MIN(memory_usage) as min_memory,
                MAX(memory_usage) as max_memory
            FROM device_vitals 
            WHERE device_id = ?
            AND timestamp >= datetime('now', '-1 day')
        `;
        
        // Execute daily statistics query
        const stats = await db.get(statsQuery, [deviceId]);
        
        // Return formatted analytics data
        return {
            rolling_average: {
                thermal_value: result.avg_thermal || 0,
                battery_level: result.avg_battery || 0,
                memory_usage: result.avg_memory || 0,
                sample_count: result.total_count || 0
            },
            daily_stats: stats || {},
            device_id: deviceId,
            calculated_at: new Date().toISOString()
        };
    } catch (error) {
        console.error('Error calculating rolling average:', error);
        throw error;
    }
}

// Export the analytics function
module.exports = {
    calculateRollingAverage
};
