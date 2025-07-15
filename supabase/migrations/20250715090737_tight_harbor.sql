-- LogiFlow Transportation & Logistics - Sample Data
-- Professional demo data for testing and development

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

USE `logiflow_transport`;

-- --------------------------------------------------------
-- Insert System Settings
-- --------------------------------------------------------

INSERT INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `category`, `description`, `is_public`) VALUES
('company_name', 'LogiFlow Transport', 'string', 'company', 'Company name displayed throughout the application', 1),
('company_email', 'info@logiflow.com', 'string', 'company', 'Primary company contact email', 1),
('company_phone', '+1-800-LOGIFLOW', 'string', 'company', 'Primary company contact phone', 1),
('company_address', '123 Logistics Ave, Transport City, TC 12345', 'string', 'company', 'Company headquarters address', 1),
('base_rate_express', '35.00', 'number', 'pricing', 'Base rate for express delivery service', 0),
('base_rate_standard', '25.00', 'number', 'pricing', 'Base rate for standard delivery service', 0),
('base_rate_economy', '18.00', 'number', 'pricing', 'Base rate for economy delivery service', 0),
('base_rate_overnight', '45.00', 'number', 'pricing', 'Base rate for overnight delivery service', 0),
('base_rate_same_day', '55.00', 'number', 'pricing', 'Base rate for same day delivery service', 0),
('rate_per_kg', '2.75', 'number', 'pricing', 'Additional rate per kilogram', 0),
('rate_per_km', '1.25', 'number', 'pricing', 'Rate per kilometer for distance calculation', 0),
('fuel_surcharge_rate', '0.15', 'number', 'pricing', 'Fuel surcharge percentage', 0),
('insurance_rate', '0.02', 'number', 'pricing', 'Insurance rate percentage of item value', 0),
('tax_rate', '0.08', 'number', 'pricing', 'Tax rate percentage', 0),
('max_package_weight', '50.00', 'number', 'limits', 'Maximum package weight in kg', 1),
('max_package_value', '10000.00', 'number', 'limits', 'Maximum package value in USD', 1),
('business_hours_start', '06:00', 'string', 'operations', 'Business hours start time', 1),
('business_hours_end', '22:00', 'string', 'operations', 'Business hours end time', 1),
('default_currency', 'USD', 'string', 'general', 'Default currency for transactions', 1),
('timezone', 'America/New_York', 'string', 'general', 'Default timezone', 0),
('driver_commission_rate', '15.00', 'number', 'driver', 'Default driver commission percentage', 0),
('auto_assign_drivers', 'true', 'boolean', 'operations', 'Automatically assign available drivers', 0),
('require_signature', 'false', 'boolean', 'operations', 'Require signature for all deliveries', 1),
('enable_real_time_tracking', 'true', 'boolean', 'features', 'Enable real-time GPS tracking', 1),
('enable_sms_notifications', 'true', 'boolean', 'features', 'Enable SMS notifications', 1),
('enable_email_notifications', 'true', 'boolean', 'features', 'Enable email notifications', 1);

-- --------------------------------------------------------
-- Insert Demo Users (Passwords are hashed for 'demo123')
-- --------------------------------------------------------

INSERT INTO `users` (`email`, `password_hash`, `name`, `phone`, `role`, `status`, `email_verified`, `address`, `city`, `state`, `postal_code`) VALUES
('admin@logiflow.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3bp.Gm.F5e', 'System Administrator', '+1-555-0001', 'admin', 'active', 1, '123 Admin Street', 'New York', 'NY', '10001'),
('customer@logiflow.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3bp.Gm.F5e', 'John Customer', '+1-555-0002', 'customer', 'active', 1, '456 Customer Ave', 'Los Angeles', 'CA', '90210'),
('driver@logiflow.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3bp.Gm.F5e', 'Mike Driver', '+1-555-0003', 'driver', 'active', 1, '789 Driver Blvd', 'Chicago', 'IL', '60601'),
('sarah.johnson@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3bp.Gm.F5e', 'Sarah Johnson', '+1-555-0104', 'customer', 'active', 1, '321 Oak Street', 'Houston', 'TX', '77001'),
('robert.wilson@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3bp.Gm.F5e', 'Robert Wilson', '+1-555-0105', 'driver', 'active', 1, '654 Pine Road', 'Phoenix', 'AZ', '85001'),
('emily.davis@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3bp.Gm.F5e', 'Emily Davis', '+1-555-0106', 'customer', 'active', 1, '987 Maple Lane', 'Philadelphia', 'PA', '19101'),
('david.brown@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3bp.Gm.F5e', 'David Brown', '+1-555-0107', 'driver', 'active', 1, '147 Cedar Ave', 'San Antonio', 'TX', '78201'),
('lisa.garcia@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3bp.Gm.F5e', 'Lisa Garcia', '+1-555-0108', 'customer', 'active', 1, '258 Birch Street', 'San Diego', 'CA', '92101'),
('james.martinez@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3bp.Gm.F5e', 'James Martinez', '+1-555-0109', 'driver', 'active', 1, '369 Elm Drive', 'Dallas', 'TX', '75201'),
('maria.rodriguez@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3bp.Gm.F5e', 'Maria Rodriguez', '+1-555-0110', 'customer', 'active', 1, '741 Willow Way', 'San Jose', 'CA', '95101');

-- --------------------------------------------------------
-- Insert Driver Information
-- --------------------------------------------------------

INSERT INTO `drivers` (`user_id`, `license_number`, `license_expiry`, `vehicle_type`, `vehicle_number`, `vehicle_model`, `vehicle_year`, `vehicle_color`, `insurance_number`, `insurance_expiry`, `status`, `current_lat`, `current_lng`, `rating`, `total_ratings`, `completed_deliveries`, `total_earnings`, `commission_rate`) VALUES
(3, 'DL123456789', '2025-12-31', 'Van', 'LF-001', 'Ford Transit', 2022, 'White', 'INS-001-2024', '2024-12-31', 'available', 41.8781, -87.6298, 4.85, 47, 156, 2340.50, 15.00),
(5, 'DL987654321', '2025-08-15', 'Truck', 'LF-002', 'Chevrolet Express', 2021, 'Blue', 'INS-002-2024', '2024-11-30', 'available', 33.4484, -112.0740, 4.92, 38, 124, 1860.75, 15.00),
(7, 'DL456789123', '2025-10-20', 'Van', 'LF-003', 'Mercedes Sprinter', 2023, 'Silver', 'INS-003-2024', '2024-10-31', 'busy', 29.4241, -98.4936, 4.78, 29, 89, 1335.25, 15.00),
(9, 'DL789123456', '2025-06-30', 'Pickup Truck', 'LF-004', 'Ford F-150', 2022, 'Black', 'INS-004-2024', '2024-09-30', 'available', 32.7157, -117.1611, 4.95, 52, 178, 2670.00, 15.00);

-- --------------------------------------------------------
-- Insert Sample Locations
-- --------------------------------------------------------

INSERT INTO `locations` (`address`, `street_number`, `street_name`, `city`, `state`, `postal_code`, `country`, `latitude`, `longitude`, `contact_name`, `contact_phone`, `location_type`) VALUES
('123 Main Street, New York, NY 10001', '123', 'Main Street', 'New York', 'NY', '10001', 'United States', 40.7589, -73.9851, 'John Smith', '+1-555-1001', 'commercial'),
('456 Broadway, Los Angeles, CA 90210', '456', 'Broadway', 'Los Angeles', 'CA', '90210', 'United States', 34.0522, -118.2437, 'Jane Doe', '+1-555-1002', 'residential'),
('789 State Street, Chicago, IL 60601', '789', 'State Street', 'Chicago', 'IL', '60601', 'United States', 41.8781, -87.6298, 'Bob Johnson', '+1-555-1003', 'office'),
('321 Oak Avenue, Houston, TX 77001', '321', 'Oak Avenue', 'Houston', 'TX', '77001', 'United States', 29.7604, -95.3698, 'Alice Brown', '+1-555-1004', 'residential'),
('654 Pine Road, Phoenix, AZ 85001', '654', 'Pine Road', 'Phoenix', 'AZ', '85001', 'United States', 33.4484, -112.0740, 'Charlie Wilson', '+1-555-1005', 'warehouse'),
('987 Elm Street, Philadelphia, PA 19101', '987', 'Elm Street', 'Philadelphia', 'PA', '19101', 'United States', 39.9526, -75.1652, 'Diana Davis', '+1-555-1006', 'commercial'),
('147 Cedar Lane, San Antonio, TX 78201', '147', 'Cedar Lane', 'San Antonio', 'TX', '78201', 'United States', 29.4241, -98.4936, 'Frank Garcia', '+1-555-1007', 'residential'),
('258 Maple Drive, San Diego, CA 92101', '258', 'Maple Drive', 'San Diego', 'CA', '92101', 'United States', 32.7157, -117.1611, 'Grace Martinez', '+1-555-1008', 'office'),
('369 Birch Way, Dallas, TX 75201', '369', 'Birch Way', 'Dallas', 'TX', '75201', 'United States', 32.7767, -96.7970, 'Henry Rodriguez', '+1-555-1009', 'commercial'),
('741 Willow Street, San Jose, CA 95101', '741', 'Willow Street', 'San Jose', 'CA', '95101', 'United States', 37.3382, -121.8863, 'Ivy Lopez', '+1-555-1010', 'residential');

-- --------------------------------------------------------
-- Insert Sample Bookings
-- --------------------------------------------------------

INSERT INTO `bookings` (`tracking_number`, `customer_id`, `driver_id`, `pickup_location_id`, `delivery_location_id`, `service_type`, `status`, `priority`, `payment_method`, `payment_status`, `total_weight`, `total_value`, `base_amount`, `weight_charges`, `distance_charges`, `fuel_surcharge`, `tax_amount`, `total_amount`, `distance_km`, `estimated_duration_minutes`, `scheduled_pickup_time`, `actual_pickup_time`, `estimated_delivery_time`, `special_notes`, `requires_signature`, `fragile_items`) VALUES
('LF2024001001', 2, 3, 1, 2, 'express', 'delivered', 'high', 'online', 'paid', 5.50, 250.00, 35.00, 15.13, 45.20, 6.78, 8.17, 110.28, 36.16, 180, '2024-01-15 09:00:00', '2024-01-15 09:15:00', '2024-01-15 12:00:00', 'Handle with care - electronics', 1, 1),
('LF2024001002', 4, 5, 3, 4, 'standard', 'in_transit', 'normal', 'cash_delivery', 'pending', 12.30, 150.00, 25.00, 33.83, 28.50, 4.28, 7.33, 98.94, 22.80, 240, '2024-01-16 14:00:00', '2024-01-16 14:10:00', '2024-01-16 18:00:00', 'Business delivery - office hours only', 0, 0),
('LF2024001003', 6, NULL, 5, 6, 'economy', 'pending', 'low', 'online', 'paid', 8.75, 75.00, 18.00, 24.06, 15.75, 2.36, 4.82, 64.99, 12.60, 300, '2024-01-17 10:00:00', NULL, '2024-01-17 16:00:00', 'Standard package delivery', 0, 0),
('LF2024001004', 8, 7, 7, 8, 'overnight', 'picked_up', 'urgent', 'online', 'paid', 3.25, 500.00, 45.00, 8.94, 52.30, 7.85, 9.13, 123.22, 41.84, 120, '2024-01-18 16:00:00', '2024-01-18 16:05:00', '2024-01-19 08:00:00', 'Overnight delivery required', 1, 0),
('LF2024001005', 10, 9, 9, 10, 'same_day', 'confirmed', 'high', 'cash_pickup', 'pending', 15.60, 320.00, 55.00, 42.90, 18.25, 2.74, 9.51, 128.40, 14.60, 480, '2024-01-19 08:00:00', NULL, '2024-01-19 17:00:00', 'Same day delivery - time sensitive', 1, 0);

-- --------------------------------------------------------
-- Insert Booking Items
-- --------------------------------------------------------

INSERT INTO `booking_items` (`booking_id`, `description`, `category`, `quantity`, `weight`, `value`, `dimensions_length`, `dimensions_width`, `dimensions_height`, `special_handling`) VALUES
(1, 'Laptop Computer', 'electronics', 1, 2.50, 150.00, 35.0, 25.0, 3.0, 'Fragile - Handle with care'),
(1, 'Wireless Mouse', 'electronics', 2, 0.15, 50.00, 12.0, 8.0, 4.0, 'Small electronics'),
(2, 'Office Supplies Box', 'package', 3, 4.10, 50.00, 40.0, 30.0, 20.0, 'Standard office items'),
(3, 'Clothing Package', 'clothing', 1, 1.75, 75.00, 50.0, 35.0, 15.0, 'Soft goods'),
(4, 'Legal Documents', 'document', 1, 0.25, 500.00, 32.0, 24.0, 2.0, 'Confidential - signature required'),
(5, 'Medical Equipment', 'medical', 1, 8.60, 200.00, 60.0, 40.0, 25.0, 'Medical device - temperature sensitive');

-- --------------------------------------------------------
-- Insert Tracking Updates
-- --------------------------------------------------------

INSERT INTO `tracking_updates` (`booking_id`, `status`, `location`, `latitude`, `longitude`, `notes`, `updated_by`, `update_type`, `is_public`) VALUES
(1, 'Booking Created', 'New York, NY', 40.7589, -73.9851, 'Booking created and payment confirmed', 2, 'status', 1),
(1, 'Driver Assigned', 'New York, NY', 40.7589, -73.9851, 'Driver Mike Driver assigned to delivery', 1, 'status', 1),
(1, 'Package Picked Up', '123 Main Street, New York, NY', 40.7589, -73.9851, 'Package collected from pickup location', 3, 'status', 1),
(1, 'Delivered', '456 Broadway, Los Angeles, CA', 34.0522, -118.2437, 'Package delivered successfully', 3, 'status', 1),
(2, 'Booking Created', 'Chicago, IL', 41.8781, -87.6298, 'Standard delivery booking created', 4, 'status', 1),
(2, 'Driver Assigned', 'Chicago, IL', 41.8781, -87.6298, 'Driver Robert Wilson assigned', 1, 'status', 1),
(2, 'Package Picked Up', '789 State Street, Chicago, IL', 41.8781, -87.6298, 'Package collected successfully', 5, 'status', 1),
(3, 'Booking Created', 'Phoenix, AZ', 33.4484, -112.0740, 'Economy delivery scheduled', 6, 'status', 1),
(4, 'Booking Created', 'San Antonio, TX', 29.4241, -98.4936, 'Overnight delivery requested', 8, 'status', 1),
(4, 'Driver Assigned', 'San Antonio, TX', 29.4241, -98.4936, 'Driver David Brown assigned for overnight delivery', 1, 'status', 1),
(4, 'Package Picked Up', '147 Cedar Lane, San Antonio, TX', 29.4241, -98.4936, 'Overnight package collected', 7, 'status', 1),
(5, 'Booking Created', 'Dallas, TX', 32.7767, -96.7970, 'Same day delivery booking', 10, 'status', 1),
(5, 'Driver Assigned', 'Dallas, TX', 32.7767, -96.7970, 'Driver James Martinez assigned for same day delivery', 1, 'status', 1);

-- --------------------------------------------------------
-- Insert Payment Records
-- --------------------------------------------------------

INSERT INTO `payments` (`booking_id`, `payment_method`, `payment_gateway`, `transaction_id`, `gateway_transaction_id`, `amount`, `status`, `processed_at`) VALUES
(1, 'credit_card', 'stripe', 'TXN_001_2024', 'pi_1234567890abcdef', 110.28, 'completed', '2024-01-15 08:45:00'),
(3, 'paypal', 'paypal', 'TXN_003_2024', 'PAY-1234567890ABCDEF', 64.99, 'completed', '2024-01-17 09:30:00'),
(4, 'credit_card', 'stripe', 'TXN_004_2024', 'pi_abcdef1234567890', 123.22, 'completed', '2024-01-18 15:45:00');

-- --------------------------------------------------------
-- Insert Notifications
-- --------------------------------------------------------

INSERT INTO `notifications` (`user_id`, `booking_id`, `type`, `title`, `message`, `is_read`, `priority`) VALUES
(2, 1, 'delivery_completed', 'Package Delivered', 'Your package #LF2024001001 has been delivered successfully', 1, 'normal'),
(4, 2, 'status_update', 'Package In Transit', 'Your package #LF2024001002 is currently in transit', 0, 'normal'),
(6, 3, 'booking_created', 'Booking Confirmed', 'Your booking #LF2024001003 has been created', 1, 'normal'),
(8, 4, 'pickup_scheduled', 'Pickup Scheduled', 'Your package #LF2024001004 is scheduled for pickup', 0, 'high'),
(10, 5, 'driver_assigned', 'Driver Assigned', 'Driver James Martinez has been assigned to your delivery', 0, 'normal');

COMMIT;