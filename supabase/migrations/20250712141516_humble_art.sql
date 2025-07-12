-- Transportation & Logistics Database Schema
-- Created for LogiFlow Platform

-- Create database
CREATE DATABASE IF NOT EXISTS logiflow_transport;
USE logiflow_transport;

-- Users table for authentication and user management
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    role ENUM('customer', 'driver', 'admin') NOT NULL DEFAULT 'customer',
    status ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_status (status)
);

-- Drivers table for additional driver information
CREATE TABLE drivers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    license_number VARCHAR(50) UNIQUE NOT NULL,
    vehicle_type VARCHAR(100) NOT NULL,
    vehicle_number VARCHAR(20) NOT NULL,
    vehicle_model VARCHAR(100),
    vehicle_year YEAR,
    status ENUM('available', 'busy', 'offline') NOT NULL DEFAULT 'offline',
    current_lat DECIMAL(10, 8) NULL,
    current_lng DECIMAL(11, 8) NULL,
    rating DECIMAL(3, 2) DEFAULT 5.00,
    completed_deliveries INT DEFAULT 0,
    total_earnings DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_location (current_lat, current_lng)
);

-- Locations table for pickup and delivery addresses
CREATE TABLE locations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    address TEXT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    contact_name VARCHAR(255),
    contact_phone VARCHAR(20),
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_coordinates (latitude, longitude)
);

-- Bookings table for transportation requests
CREATE TABLE bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tracking_number VARCHAR(20) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    driver_id INT NULL,
    pickup_location_id INT NOT NULL,
    delivery_location_id INT NOT NULL,
    service_type ENUM('express', 'standard', 'economy') NOT NULL,
    status ENUM('pending', 'confirmed', 'picked_up', 'in_transit', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
    payment_method ENUM('online', 'cash_pickup', 'cash_delivery') NOT NULL,
    payment_status ENUM('pending', 'paid', 'refunded') NOT NULL DEFAULT 'pending',
    total_weight DECIMAL(8, 2) NOT NULL,
    total_value DECIMAL(10, 2) NOT NULL,
    base_amount DECIMAL(10, 2) NOT NULL,
    additional_charges DECIMAL(10, 2) DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL,
    distance_km DECIMAL(8, 2),
    estimated_duration_minutes INT,
    scheduled_pickup_time DATETIME,
    actual_pickup_time DATETIME NULL,
    estimated_delivery_time DATETIME,
    actual_delivery_time DATETIME NULL,
    special_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (pickup_location_id) REFERENCES locations(id),
    FOREIGN KEY (delivery_location_id) REFERENCES locations(id),
    INDEX idx_tracking (tracking_number),
    INDEX idx_customer (customer_id),
    INDEX idx_driver (driver_id),
    INDEX idx_status (status),
    INDEX idx_created_date (created_at)
);

-- Booking items table for detailed item information
CREATE TABLE booking_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    description TEXT NOT NULL,
    category ENUM('document', 'package', 'fragile', 'electronics', 'other') NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    weight DECIMAL(8, 2) NOT NULL,
    value DECIMAL(10, 2) NOT NULL,
    dimensions VARCHAR(100),
    special_handling TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    INDEX idx_booking (booking_id),
    INDEX idx_category (category)
);

-- Tracking updates table for real-time status tracking
CREATE TABLE tracking_updates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    location TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    notes TEXT,
    updated_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_booking (booking_id),
    INDEX idx_timestamp (created_at)
);

-- Payments table for transaction records
CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    payment_method ENUM('credit_card', 'debit_card', 'paypal', 'bank_transfer', 'cash') NOT NULL,
    payment_gateway VARCHAR(50),
    transaction_id VARCHAR(100),
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    gateway_response TEXT,
    processed_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    INDEX idx_booking (booking_id),
    INDEX idx_transaction (transaction_id),
    INDEX idx_status (status)
);

-- Notifications table for user notifications
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    booking_id INT,
    type ENUM('booking_created', 'status_update', 'payment_received', 'delivery_completed', 'system') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_read_status (is_read),
    INDEX idx_created (created_at)
);

-- System settings table for application configuration
CREATE TABLE system_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    description TEXT,
    updated_by INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_key (setting_key)
);

-- Insert default system settings
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('base_rate_express', '30.00', 'Base rate for express delivery service'),
('base_rate_standard', '20.00', 'Base rate for standard delivery service'),
('base_rate_economy', '15.00', 'Base rate for economy delivery service'),
('rate_per_kg', '2.50', 'Additional rate per kilogram'),
('rate_per_km', '1.50', 'Rate per kilometer for distance calculation'),
('max_package_weight', '50.00', 'Maximum package weight in kg'),
('business_hours_start', '08:00', 'Business hours start time'),
('business_hours_end', '18:00', 'Business hours end time'),
('company_name', 'LogiFlow Transport', 'Company name'),
('company_email', 'info@logiflow.com', 'Company contact email'),
('company_phone', '+1-800-LOGIFLOW', 'Company contact phone');

-- Create indexes for better performance
CREATE INDEX idx_bookings_date_status ON bookings(created_at, status);
CREATE INDEX idx_users_role_status ON users(role, status);
CREATE INDEX idx_drivers_status_location ON drivers(status, current_lat, current_lng);

-- Create views for common queries
CREATE VIEW booking_details AS
SELECT 
    b.id,
    b.tracking_number,
    b.status,
    b.service_type,
    b.total_amount,
    b.payment_status,
    b.created_at,
    b.scheduled_pickup_time,
    b.actual_delivery_time,
    u.name as customer_name,
    u.email as customer_email,
    u.phone as customer_phone,
    d.name as driver_name,
    d.phone as driver_phone,
    pl.address as pickup_address,
    dl.address as delivery_address,
    COUNT(bi.id) as item_count,
    SUM(bi.quantity) as total_items
FROM bookings b
JOIN users u ON b.customer_id = u.id
LEFT JOIN users d ON b.driver_id = d.id
JOIN locations pl ON b.pickup_location_id = pl.id
JOIN locations dl ON b.delivery_location_id = dl.id
LEFT JOIN booking_items bi ON b.id = bi.booking_id
GROUP BY b.id;

-- Create view for driver statistics
CREATE VIEW driver_stats AS
SELECT 
    d.id,
    d.user_id,
    u.name,
    d.status,
    d.rating,
    d.completed_deliveries,
    d.total_earnings,
    COUNT(CASE WHEN b.status IN ('confirmed', 'picked_up', 'in_transit') THEN 1 END) as active_bookings,
    COUNT(CASE WHEN b.status = 'delivered' AND DATE(b.actual_delivery_time) = CURDATE() THEN 1 END) as deliveries_today
FROM drivers d
JOIN users u ON d.user_id = u.id
LEFT JOIN bookings b ON d.user_id = b.driver_id
GROUP BY d.id;