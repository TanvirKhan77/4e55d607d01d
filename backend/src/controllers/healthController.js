function getHealth(req, res) {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        service: 'device-vital-monitor-api'
    });
}

module.exports = {
    getHealth
};
