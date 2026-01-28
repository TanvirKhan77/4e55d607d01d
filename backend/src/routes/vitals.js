const express = require('express');
const { logVitals, getVitals, getAnalytics } = require('../controllers/vitalsController');

const router = express.Router();

// POST /api/vitals - Log device vitals
router.post('/', logVitals);

// GET /api/vitals - Get historical logs
router.get('/', getVitals);

// GET /api/vitals/analytics - Get analytics
router.get('/analytics', getAnalytics);

module.exports = router;
