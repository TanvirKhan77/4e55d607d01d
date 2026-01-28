function validateVitalData(data) {
    const errors = [];
    
    const requiredFields = ['device_id', 'timestamp', 'thermal_value', 'battery_level', 'memory_usage'];
    for (const field of requiredFields) {
        if (data[field] === undefined || data[field] === null) {
            errors.push(`Missing required field: ${field}`);
        }
    }
    
    if (errors.length > 0) {
        return errors;
    }
    
    const thermal = parseInt(data.thermal_value);
    if (isNaN(thermal) || thermal < 0 || thermal > 3) {
        errors.push('thermal_value must be an integer between 0 and 3');
    }
    
    const battery = parseFloat(data.battery_level);
    if (isNaN(battery) || battery < 0 || battery > 100) {
        errors.push('battery_level must be a number between 0 and 100');
    }
    
    const memory = parseFloat(data.memory_usage);
    if (isNaN(memory) || memory < 0 || memory > 100) {
        errors.push('memory_usage must be a number between 0 and 100');
    }
    
    const timestamp = new Date(data.timestamp);
    const now = new Date();
    if (isNaN(timestamp.getTime())) {
        errors.push('Invalid timestamp format. Use ISO8601 format');
    } else if (timestamp > now) {
        errors.push('Timestamp cannot be in the future');
    }
    
    return errors;
}

module.exports = {
    validateVitalData
};
