const { createApp } = require('./src/app');
const { initializeDatabase, getDb } = require('./src/models/database');
const { validateVitalData } = require('./src/utils/validation');

const app = createApp();

// Export functions for testing
module.exports = {
    app,
    createApp,
    initializeDatabase,
    getDb,
    validateVitalData
};

// Only start the server if this file is run directly
if (require.main === module) {
    const PORT = process.env.PORT || 3000;
    
    async function startServer() {
        try {
            await initializeDatabase();
            
            app.listen(PORT, () => {
                console.log(`Server running on port ${PORT}`);
                console.log(`Health check: http://localhost:${PORT}/health`);
            });
            
            return { app };
        } catch (error) {
            console.error('Failed to start server:', error);
            process.exit(1);
        }
    }
    
    startServer();
}