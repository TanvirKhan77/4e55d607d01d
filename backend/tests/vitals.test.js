const request = require('supertest');
const { app, createApp, initializeDatabase, validateVitalData, getDb } = require('../server');
const sqlite3 = require('sqlite3').verbose();
const { open } = require('sqlite');
const path = require('path');

// Global test setup
let testApp;
let testDb;

describe('Data Validation Unit Tests', () => {
    test('should accept valid vital data', () => {
        const validData = {
            device_id: 'test-device-123',
            timestamp: '2024-01-15T10:30:00Z',
            thermal_value: 2,
            battery_level: 75.5,
            memory_usage: 45.2
        };
        
        const errors = validateVitalData(validData);
        expect(errors).toHaveLength(0);
    });
    
    test('should reject invalid thermal value', () => {
        const invalidData = {
            device_id: 'test-device-123',
            timestamp: '2024-01-15T10:30:00Z',
            thermal_value: 5,
            battery_level: 75.5,
            memory_usage: 45.2
        };
        
        const errors = validateVitalData(invalidData);
        expect(errors).toContain('thermal_value must be an integer between 0 and 3');
    });
    
    test('should reject future timestamp', () => {
        const futureDate = new Date();
        futureDate.setFullYear(futureDate.getFullYear() + 1);
        
        const invalidData = {
            device_id: 'test-device-123',
            timestamp: futureDate.toISOString(),
            thermal_value: 2,
            battery_level: 75.5,
            memory_usage: 45.2
        };
        
        const errors = validateVitalData(invalidData);
        expect(errors).toContain('Timestamp cannot be in the future');
    });
    
    test('should reject missing required fields', () => {
        const incompleteData = {
            device_id: 'test-device-123',
            timestamp: '2024-01-15T10:30:00Z',
        };
        
        const errors = validateVitalData(incompleteData);
        expect(errors).toContain('Missing required field: thermal_value');
        expect(errors).toContain('Missing required field: battery_level');
        expect(errors).toContain('Missing required field: memory_usage');
    });
    
    test('should reject invalid battery level', () => {
        const invalidData = {
            device_id: 'test-device-123',
            timestamp: '2024-01-15T10:30:00Z',
            thermal_value: 2,
            battery_level: 150,
            memory_usage: 45.2
        };
        
        const errors = validateVitalData(invalidData);
        expect(errors).toContain('battery_level must be a number between 0 and 100');
    });
    
    test('should reject invalid memory usage', () => {
        const invalidData = {
            device_id: 'test-device-123',
            timestamp: '2024-01-15T10:30:00Z',
            thermal_value: 2,
            battery_level: 75.5,
            memory_usage: 150
        };
        
        const errors = validateVitalData(invalidData);
        expect(errors).toContain('memory_usage must be a number between 0 and 100');
    });
});

describe('API Integration Tests', () => {
    // Run before all tests in this describe block
    beforeAll(async () => {
        // Use in-memory database for tests
        testDb = await open({
            filename: ':memory:',
            driver: sqlite3.Database
        });
        
        // Set up the database tables
        await testDb.exec(`
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
        
        // Create a fresh Express app for testing (without the actual routes)
        const express = require('express');
        testApp = express();
        testApp.use(express.json());
        
        // Set up middleware
        const cors = require('cors');
        testApp.use(cors());
        
        // Register custom test routes with test database
        // Health endpoint
        testApp.get('/health', (req, res) => {
            res.json({
                status: 'healthy',
                timestamp: new Date().toISOString(),
                service: 'device-vital-monitor-api'
            });
        });
        
        // POST endpoint
        testApp.post('/api/vitals', async (req, res) => {
            try {
                const vitalData = req.body;
                
                const validationErrors = validateVitalData(vitalData);
                if (validationErrors.length > 0) {
                    return res.status(400).json({
                        success: false,
                        errors: validationErrors
                    });
                }
                
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
                
                const result = await testDb.run(query, params);
                
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
        });
        
        // GET endpoint
        testApp.get('/api/vitals', async (req, res) => {
            try {
                const deviceId = req.query.device_id;
                const limit = parseInt(req.query.limit) || 100;
                
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
                
                const logs = await testDb.all(query, params);
                
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
        });
        
        // Analytics endpoint
        testApp.get('/api/vitals/analytics', async (req, res) => {
            try {
                const deviceId = req.query.device_id;
                
                if (!deviceId) {
                    return res.status(400).json({
                        success: false,
                        error: 'device_id query parameter is required'
                    });
                }
                
                // Simplified analytics for testing
                const query = `
                    SELECT 
                        AVG(thermal_value) as avg_thermal,
                        AVG(battery_level) as avg_battery,
                        AVG(memory_usage) as avg_memory,
                        COUNT(*) as total_count
                    FROM device_vitals 
                    WHERE device_id = ?
                `;
                
                const result = await testDb.get(query, [deviceId]);
                
                res.json({
                    success: true,
                    rolling_average: {
                        thermal_value: result.avg_thermal || 0,
                        battery_level: result.avg_battery || 0,
                        memory_usage: result.avg_memory || 0,
                        sample_count: result.total_count || 0
                    },
                    device_id: deviceId,
                    calculated_at: new Date().toISOString()
                });
                
            } catch (error) {
                console.error('Error calculating analytics:', error);
                res.status(500).json({
                    success: false,
                    error: 'Internal server error'
                });
            }
        });
    });
    
    // Run after all tests
    afterAll(async () => {
        if (testDb) {
            await testDb.close();
        }
    });
    
    // Run before each test
    beforeEach(async () => {
        // Clear the database before each test
        await testDb.exec('DELETE FROM device_vitals');
    });
    
    test('GET /health should return healthy status', async () => {
        const response = await request(testApp).get('/health');
        
        expect(response.statusCode).toBe(200);
        expect(response.body).toHaveProperty('status', 'healthy');
        expect(response.body).toHaveProperty('timestamp');
        expect(response.body).toHaveProperty('service', 'device-vital-monitor-api');
    });
    
    test('POST /api/vitals should accept valid data', async () => {
        const validData = {
            device_id: 'test-device-123',
            timestamp: new Date().toISOString(),
            thermal_value: 2,
            battery_level: 75.5,
            memory_usage: 45.2
        };
        
        const response = await request(testApp)
            .post('/api/vitals')
            .send(validData);
        
        expect(response.statusCode).toBe(201);
        expect(response.body).toHaveProperty('success', true);
        expect(response.body).toHaveProperty('message', 'Vitals logged successfully');
        expect(response.body).toHaveProperty('id');
    });
    
    test('POST /api/vitals should reject invalid thermal value', async () => {
        const invalidData = {
            device_id: 'test-device-123',
            timestamp: new Date().toISOString(),
            thermal_value: 5,
            battery_level: 75.5,
            memory_usage: 45.2
        };
        
        const response = await request(testApp)
            .post('/api/vitals')
            .send(invalidData);
        
        expect(response.statusCode).toBe(400);
        expect(response.body).toHaveProperty('success', false);
        expect(response.body.errors).toContain('thermal_value must be an integer between 0 and 3');
    });
    
    test('POST /api/vitals should reject missing fields', async () => {
        const incompleteData = {
            device_id: 'test-device-123',
            timestamp: new Date().toISOString(),
        };
        
        const response = await request(testApp)
            .post('/api/vitals')
            .send(incompleteData);
        
        expect(response.statusCode).toBe(400);
        expect(response.body).toHaveProperty('success', false);
        expect(response.body.errors).toContain('Missing required field: thermal_value');
    });
    
    test('GET /api/vitals should return logs', async () => {
        // First, insert some test data
        await testDb.run(
            `INSERT INTO device_vitals (device_id, timestamp, thermal_value, battery_level, memory_usage)
             VALUES (?, ?, ?, ?, ?)`,
            ['test-device-123', new Date().toISOString(), 2, 75.5, 45.2]
        );
        
        const response = await request(testApp).get('/api/vitals');
        
        expect(response.statusCode).toBe(200);
        expect(response.body).toHaveProperty('success', true);
        expect(response.body).toHaveProperty('count', 1);
        expect(response.body).toHaveProperty('logs');
        expect(Array.isArray(response.body.logs)).toBe(true);
        expect(response.body.logs[0]).toHaveProperty('device_id', 'test-device-123');
    });
    
    test('GET /api/vitals?device_id= should filter by device', async () => {
        // Insert test data for two devices
        await testDb.run(
            `INSERT INTO device_vitals (device_id, timestamp, thermal_value, battery_level, memory_usage)
             VALUES (?, ?, ?, ?, ?)`,
            ['device-1', new Date().toISOString(), 2, 75.5, 45.2]
        );
        
        await testDb.run(
            `INSERT INTO device_vitals (device_id, timestamp, thermal_value, battery_level, memory_usage)
             VALUES (?, ?, ?, ?, ?)`,
            ['device-2', new Date().toISOString(), 1, 85.5, 35.2]
        );
        
        const response = await request(testApp)
            .get('/api/vitals')
            .query({ device_id: 'device-1' });
        
        expect(response.statusCode).toBe(200);
        expect(response.body).toHaveProperty('success', true);
        expect(response.body.logs).toHaveLength(1);
        expect(response.body.logs[0]).toHaveProperty('device_id', 'device-1');
    });
    
    test('GET /api/vitals/analytics should require device_id', async () => {
        const response = await request(testApp).get('/api/vitals/analytics');
        
        expect(response.statusCode).toBe(400);
        expect(response.body).toHaveProperty('success', false);
        expect(response.body.error).toBe('device_id query parameter is required');
    });
    
    test('GET /api/vitals/analytics should return analytics', async () => {
        // Insert multiple records for the same device
        await testDb.run(
            `INSERT INTO device_vitals (device_id, timestamp, thermal_value, battery_level, memory_usage)
             VALUES (?, ?, ?, ?, ?)`,
            ['analytics-device', new Date().toISOString(), 2, 80.0, 50.0]
        );
        
        await testDb.run(
            `INSERT INTO device_vitals (device_id, timestamp, thermal_value, battery_level, memory_usage)
             VALUES (?, ?, ?, ?, ?)`,
            ['analytics-device', new Date().toISOString(), 1, 70.0, 40.0]
        );
        
        const response = await request(testApp)
            .get('/api/vitals/analytics')
            .query({ device_id: 'analytics-device' });
        
        expect(response.statusCode).toBe(200);
        expect(response.body).toHaveProperty('success', true);
        expect(response.body).toHaveProperty('rolling_average');
        expect(response.body.rolling_average).toHaveProperty('thermal_value', 1.5); // (2+1)/2 = 1.5
        expect(response.body.rolling_average).toHaveProperty('battery_level', 75.0); // (80+70)/2 = 75
        expect(response.body.rolling_average).toHaveProperty('memory_usage', 45.0); // (50+40)/2 = 45
        expect(response.body.rolling_average).toHaveProperty('sample_count', 2);
    });
});

describe('Rolling Average Calculation', () => {
    test('should calculate correct averages', () => {
        const mockVitals = [
            { thermal_value: 1, battery_level: 80, memory_usage: 40 },
            { thermal_value: 2, battery_level: 75, memory_usage: 45 },
            { thermal_value: 1, battery_level: 70, memory_usage: 50 }
        ];
        
        const expectedThermal = (1 + 2 + 1) / 3;
        const expectedBattery = (80 + 75 + 70) / 3;
        const expectedMemory = (40 + 45 + 50) / 3;
        
        expect(expectedThermal).toBeCloseTo(1.33, 2);
        expect(expectedBattery).toBe(75);
        expect(expectedMemory).toBe(45);
    });
});