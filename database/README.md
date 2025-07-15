# LogiFlow Database Setup Guide

## Overview
This directory contains the complete MySQL database structure for the LogiFlow Transportation & Logistics platform. The database is designed to be fully compatible with phpMyAdmin and standard MySQL installations.

## Files Structure

### 1. `01_schema.sql`
- **Purpose**: Complete database schema with all tables, indexes, and constraints
- **Contains**: 11 professional tables with proper relationships
- **Features**: Optimized indexes, foreign keys, and data validation

### 2. `02_seed_data.sql`
- **Purpose**: Sample data for testing and demonstration
- **Contains**: Demo users, bookings, locations, and transactions
- **Features**: Realistic data with proper relationships

### 3. `03_procedures_functions.sql`
- **Purpose**: Stored procedures and functions for complex operations
- **Contains**: Business logic for bookings, calculations, and statistics
- **Features**: Professional database operations with error handling

## Database Tables

### Core Tables
1. **`users`** - User authentication and profiles
2. **`drivers`** - Driver-specific information and status
3. **`locations`** - Pickup and delivery addresses
4. **`bookings`** - Transportation requests and orders
5. **`booking_items`** - Detailed item information
6. **`tracking_updates`** - Real-time status updates
7. **`payments`** - Transaction records
8. **`notifications`** - User notifications
9. **`system_settings`** - Application configuration
10. **`driver_ratings`** - Driver performance ratings

### Views
- **`booking_details_view`** - Complete booking information
- **`driver_performance_view`** - Driver statistics and metrics
- **`daily_stats_view`** - Daily revenue and operational statistics

## Setup Instructions

### Option 1: phpMyAdmin Import (Recommended for MySQL2/Express)
1. Open phpMyAdmin in your browser
2. Create a new database named `logiflow_transport`
3. Select the database
4. Go to "Import" tab
5. Import files in this order:
   - `01_schema.sql`
   - `02_seed_data.sql`
   - `03_procedures_functions.sql`

### Option 2: MySQL Command Line
```bash
# Create database
mysql -u root -p -e "CREATE DATABASE logiflow_transport;"

# Import schema
mysql -u root -p logiflow_transport < database/01_schema.sql

# Import seed data
mysql -u root -p logiflow_transport < database/02_seed_data.sql

# Import procedures
mysql -u root -p logiflow_transport < database/03_procedures_functions.sql
```

### Option 3: Single File Import
You can also concatenate all files and import as one:
```bash
cat database/01_schema.sql database/02_seed_data.sql database/03_procedures_functions.sql > complete_database.sql
mysql -u root -p logiflow_transport < complete_database.sql
```

## Demo Credentials

After importing the seed data, you can use these demo accounts:

### Admin Account
- **Email**: `admin@logiflow.com`
- **Password**: `demo123`
- **Role**: Administrator

### Customer Account
- **Email**: `customer@logiflow.com`
- **Password**: `demo123`
- **Role**: Customer

### Driver Account
- **Email**: `driver@logiflow.com`
- **Password**: `demo123`
- **Role**: Driver

## Database Features

### Professional Design
- ✅ Proper normalization (3NF)
- ✅ Foreign key constraints
- ✅ Optimized indexes for performance
- ✅ Data validation and constraints
- ✅ UTF-8 character support

### Business Logic
- ✅ Automatic tracking number generation
- ✅ Dynamic pricing calculations
- ✅ Driver assignment and management
- ✅ Real-time status tracking
- ✅ Performance metrics and reporting

### Security Features
- ✅ Password hashing (bcrypt)
- ✅ Role-based access control
- ✅ Data integrity constraints
- ✅ Audit trails for all operations

## Configuration

### Backend Connection (Express + MySQL2)
Update your backend `.env` file:
```env
DB_HOST=localhost
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password
DB_NAME=logiflow_transport
DB_PORT=3306
```

### System Settings
The database includes configurable settings in the `system_settings` table:
- Pricing rates for different service types
- Business hours and operational parameters
- Feature toggles and configuration options

## Maintenance

### Regular Tasks
1. **Backup**: Regular database backups
2. **Optimization**: Run `OPTIMIZE TABLE` periodically
3. **Monitoring**: Check slow query logs
4. **Updates**: Keep MySQL version updated

### Performance Tips
- The database includes optimized indexes
- Use the provided views for complex queries
- Stored procedures handle business logic efficiently
- Connection pooling is recommended for production

## MySQL2 with Express Integration

This database is specifically optimized for:
- **MySQL2**: Latest MySQL driver for Node.js
- **Express.js**: RESTful API endpoints
- **phpMyAdmin**: Easy database management
- **Connection Pooling**: High-performance database connections

## Support

For database-related issues:
1. Check MySQL error logs
2. Verify all foreign key constraints
3. Ensure proper character encoding (UTF-8)
4. Validate data types and constraints

## Compatibility

- **MySQL**: 5.7+ (recommended 8.0+)
- **phpMyAdmin**: All versions
- **Character Set**: UTF-8 (utf8mb4)
- **Storage Engine**: InnoDB
- **Collation**: utf8mb4_unicode_ci
- **Node.js**: MySQL2 driver compatible