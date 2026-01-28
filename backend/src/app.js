const express = require('express');
const cors = require('cors');
const vitalsRoutes = require('./routes/vitals');
const healthRoutes = require('./routes/health');

function createApp() {
    const app = express();
    
    // Middleware
    app.use(cors());
    app.use(express.json());
    
    // Routes
    app.use('/api/vitals', vitalsRoutes);
    app.use('/health', healthRoutes);
    
    return app;
}

module.exports = {
    createApp
};
