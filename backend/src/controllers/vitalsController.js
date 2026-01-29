const { getDb } = require('../models/database');
const { validateVitalData } = require('../utils/validation');
const { calculateRollingAverage } = require('../utils/analytics');

// POST endpoint: Log new device vital readings
async function logVitals(req, res) {
    try {
        // Extract data from request body
        const vitalData = req.body;
        
        // Validate incoming data
        const validationErrors = validateVitalData(vitalData);
        if (validationErrors.length > 0) {
            return res.status(400).json({
                success: false,
                errors: validationErrors
            });
        }
        
        // Get database connection
        const db = getDb();
        const query = `
            INSERT INTO device_vitals 
            (device_id, timestamp, thermal_value, battery_level, memory_usage)
            VALUES (?, ?, ?, ?, ?)
        `;
        
        // Prepare parameters for SQL query
        const params = [
            vitalData.device_id,
            vitalData.timestamp,
            parseInt(vitalData.thermal_value),
            parseFloat(vitalData.battery_level),
            parseFloat(vitalData.memory_usage)
        ];
        
        // Execute database insert
        const result = await db.run(query, params);
        
        // Return success response
        res.status(201).json({
            success: true,
            message: 'Vitals logged successfully',
            id: result.lastID
        });
        
    } catch (error) {
        console.error('Error logging vitals:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
}

// GET endpoint: Retrieve device vital logs
async function getVitals(req, res) {
    try {
        // Extract query parameters
        const deviceId = req.query.device_id;
        const limit = parseInt(req.query.limit) || 100;
        
        // Get database connection
        const db = getDb();
        let query = `
            SELECT * FROM device_vitals 
            ORDER BY timestamp DESC 
            LIMIT ?
        `;
        let params = [limit];
        
        // Modify query if specific device_id is requested
        if (deviceId) {
            query = `
                SELECT * FROM device_vitals 
                WHERE device_id = ? 
                ORDER BY timestamp DESC 
                LIMIT ?
            `;
            params = [deviceId, limit];
        }
        
        // Execute database query
        const logs = await db.all(query, params);
        
        // Format timestamp fields for consistent ISO string format
        const formattedLogs = logs.map(log => ({
            ...log,
            timestamp: new Date(log.timestamp).toISOString(),
            created_at: new Date(log.created_at).toISOString()
        }));
        
        // Return successful response with logs
        res.json({
            success: true,
            count: formattedLogs.length,
            logs: formattedLogs
        });
        
    } catch (error) {
        console.error('Error fetching vitals:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
}

// GET endpoint: Get analytics for a specific device
async function getAnalytics(req, res) {
    try {
        // Extract required query parameter
        const deviceId = req.query.device_id;
        
        // Validate required parameter
        if (!deviceId) {
            return res.status(400).json({
                success: false,
                error: 'device_id query parameter is required'
            });
        }
        
        // Calculate rolling averages and other analytics
        const analytics = await calculateRollingAverage(deviceId);
        
        // Return analytics data
        res.json({
            success: true,
            ...analytics
        });
        
    } catch (error) {
        console.error('Error calculating analytics:', error);
        res.status(500).json({
            success: false,
            error: 'Internal server error'
        });
    }
}

// Export all controller functions
module.exports = {
    logVitals,
    getVitals,
    getAnalytics
};
