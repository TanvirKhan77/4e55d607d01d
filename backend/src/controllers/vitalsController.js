const { getDb } = require('../models/database');
const { validateVitalData } = require('../utils/validation');
const { calculateRollingAverage } = require('../utils/analytics');

async function logVitals(req, res) {
    try {
        const vitalData = req.body;
        
        const validationErrors = validateVitalData(vitalData);
        if (validationErrors.length > 0) {
            return res.status(400).json({
                success: false,
                errors: validationErrors
            });
        }
        
        const db = getDb();
        const query = `
            INSERT INTO device_vitals 
            (device_id, timestamp, thermal_value, battery_level, memory_usage)
            VALUES (?, ?, ?, ?, ?)
        `;
        
        const params = [
            vitalData.device_id,
            vitalData.timestamp,
            parseInt(vitalData.thermal_value),
            parseFloat(vitalData.battery_level),
            parseFloat(vitalData.memory_usage)
        ];
        
        const result = await db.run(query, params);
        
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

async function getVitals(req, res) {
    try {
        const deviceId = req.query.device_id;
        const limit = parseInt(req.query.limit) || 100;
        
        const db = getDb();
        let query = `
            SELECT * FROM device_vitals 
            ORDER BY timestamp DESC 
            LIMIT ?
        `;
        let params = [limit];
        
        if (deviceId) {
            query = `
                SELECT * FROM device_vitals 
                WHERE device_id = ? 
                ORDER BY timestamp DESC 
                LIMIT ?
            `;
            params = [deviceId, limit];
        }
        
        const logs = await db.all(query, params);
        
        const formattedLogs = logs.map(log => ({
            ...log,
            timestamp: new Date(log.timestamp).toISOString(),
            created_at: new Date(log.created_at).toISOString()
        }));
        
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

async function getAnalytics(req, res) {
    try {
        const deviceId = req.query.device_id;
        
        if (!deviceId) {
            return res.status(400).json({
                success: false,
                error: 'device_id query parameter is required'
            });
        }
        
        const analytics = await calculateRollingAverage(deviceId);
        
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

module.exports = {
    logVitals,
    getVitals,
    getAnalytics
};
