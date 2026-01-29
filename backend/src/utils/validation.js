// Function: Validate device vital data before database insertion
function validateVitalData(data) {
    // Array to collect validation errors
    const errors = [];
    
    // Check 1: Verify all required fields are present
    const requiredFields = ['device_id', 'timestamp', 'thermal_value', 'battery_level', 'memory_usage'];
    for (const field of requiredFields) {
        if (data[field] === undefined || data[field] === null) {
            errors.push(`Missing required field: ${field}`);
        }
    }
    
    // If any required fields are missing, return early
    if (errors.length > 0) {
        return errors;
    }
    
    // Check 2: Validate thermal_value (0-3 integer scale)
    const thermal = parseInt(data.thermal_value);
    if (isNaN(thermal) || thermal < 0 || thermal > 3) {
        errors.push('thermal_value must be an integer between 0 and 3');
    }
    
    // Check 3: Validate battery_level (0-100 percentage)
    const battery = parseFloat(data.battery_level);
    if (isNaN(battery) || battery < 0 || battery > 100) {
        errors.push('battery_level must be a number between 0 and 100');
    }
    
    // Check 4: Validate memory_usage (0-100 percentage)
    const memory = parseFloat(data.memory_usage);
    if (isNaN(memory) || memory < 0 || memory > 100) {
        errors.push('memory_usage must be a number between 0 and 100');
    }
    
    // Check 5: Validate timestamp
    const timestamp = new Date(data.timestamp);
    const now = new Date();
    if (isNaN(timestamp.getTime())) {
        // Invalid date format
        errors.push('Invalid timestamp format. Use ISO8601 format');
    } else if (timestamp > now) {
        // Future timestamps not allowed
        errors.push('Timestamp cannot be in the future');
    }
    
    // Return all validation errors (empty array means valid data)
    return errors;
}

module.exports = {
    validateVitalData
};
