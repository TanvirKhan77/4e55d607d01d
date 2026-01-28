# Device Vital Monitor Backend

A Node.js/Express backend service for collecting and analyzing device vital statistics.

## Features

- RESTful API for device vital logging
- SQLite database for data persistence
- Analytics endpoints for data insights
- Input validation and error handling
- Health check endpoint
- Comprehensive test coverage

## Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: SQLite3
- **Testing**: Jest + Supertest
- **Development**: Nodemon

## API Endpoints

### Health Check
- `GET /health` - Server health status

### Vitals
- `POST /api/vitals` - Log device vitals
- `GET /api/vitals` - Get historical vitals (paginated)
- `GET /api/vitals/analytics` - Get analytics data

## Installation

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm run dev
```

The server will start on port 3000 by default.

## Usage

### Starting the Server

```bash
# Development mode (with auto-restart)
npm run dev

# Production mode
npm start
```

### Environment Variables

- `PORT` - Server port (default: 3000)

## API Documentation

### Log Device Vitals

**POST** `/api/vitals`

Logs device vital information to the database.

**Request Body:**
```json
{
  "device_id": "string",
  "timestamp": "ISO 8601 string",
  "thermal_value": number,
  "battery_level": number,
  "memory_usage": number
}
```

**Response:**
```json
{
  "id": number,
  "device_id": "string",
  "timestamp": "ISO 8601 string",
  "thermal_value": number,
  "battery_level": number,
  "memory_usage": number,
  "created_at": "ISO 8601 string"
}
```

### Get Historical Vitals

**GET** `/api/vitals`

Retrieves paginated historical vital data.

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 50)
- `device_id` (optional): Filter by device ID

**Response:**
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 100,
    "pages": 2
  }
}
```

### Get Analytics

**GET** `/api/vitals/analytics`

Returns aggregated analytics data.

**Response:**
```json
{
  "total_logs": number,
  "unique_devices": number,
  "avg_thermal": number,
  "avg_battery": number,
  "avg_memory": number,
  "time_range": {
    "start": "ISO 8601 string",
    "end": "ISO 8601 string"
  }
}
```

## Testing

Run the test suite:

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm test
```

Test results and coverage reports will be available in the `coverage/` directory.

## Project Structure

```
backend/
├── src/
│   ├── app.js              # Express app setup
│   ├── controllers/        # Route handlers
│   │   ├── vitalsController.js
│   │   └── healthController.js
│   ├── models/             # Database models
│   │   └── database.js
│   ├── routes/             # API routes
│   │   ├── vitals.js
│   │   └── health.js
│   └── utils/              # Utilities
│       ├── validation.js
│       └── analytics.js
├── tests/                  # Test files
│   ├── analytics.test.js
│   └── vitals.test.js
├── coverage/               # Test coverage reports
├── server.js               # Server entry point
├── package.json
└── README.md
```

## Database

The application uses SQLite3 for data persistence. The database file `vitals.db` is created automatically when the server starts.

### Schema

**vitals table:**
- `id` (INTEGER PRIMARY KEY)
- `device_id` (TEXT)
- `timestamp` (TEXT)
- `thermal_value` (REAL)
- `battery_level` (REAL)
- `memory_usage` (REAL)
- `created_at` (TEXT)

## Development

### Code Style

The project uses ESLint for code linting. Configuration is in `package.json`.

### Adding New Features

1. Create controller methods in appropriate controller files
2. Add routes in route files
3. Update validation if needed
4. Add tests for new functionality
5. Update this README

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Ensure all tests pass
6. Submit a pull request

## License

ISC