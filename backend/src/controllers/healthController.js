// GET endpoint: Returns health status of the API service
function getHealth(req, res) {
    // Send JSON response with health info
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        service: 'device-vital-monitor-api'
    });
}

// Export the function for use in routes
module.exports = {
    getHealth
};
