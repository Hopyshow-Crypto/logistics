-- LogiFlow Transportation & Logistics Database Schema
-- Compatible with MySQL 5.7+ and phpMyAdmin
-- Professional Transportation Management System

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

-- Create database (optional - you can create this manually in phpMyAdmin)
-- CREATE DATABASE IF NOT EXISTS `logiflow_transport` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE `logiflow_transport`;

-- --------------------------------------------------------
-- Table structure for table `users`
-- --------------------------------------------------------

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('customer','driver','admin') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'customer',
  `status` enum('active','inactive','suspended') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `email_verified` tinyint(1) DEFAULT 0,
  `avatar_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `postal_code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'United States',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`),
  KEY `idx_email_verified` (`email_verified`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `drivers`
-- --------------------------------------------------------

DROP TABLE IF EXISTS `drivers`;
CREATE TABLE `drivers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `license_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `license_expiry` date DEFAULT NULL,
  `vehicle_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vehicle_number` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vehicle_model` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vehicle_year` year(4) DEFAULT NULL,
  `vehicle_color` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `insurance_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `insurance_expiry` date DEFAULT NULL,
  `status` enum('available','busy','offline','suspended') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'offline',
  `current_lat` decimal(10,8) DEFAULT NULL,
  `current_lng` decimal(11,8) DEFAULT NULL,
  `last_location_update` timestamp NULL DEFAULT NULL,
  `rating` decimal(3,2) DEFAULT 5.00,
  `total_ratings` int(11) DEFAULT 0,
  `completed_deliveries` int(11) DEFAULT 0,
  `total_earnings` decimal(10,2) DEFAULT 0.00,
  `commission_rate` decimal(5,2) DEFAULT 15.00,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `license_number` (`license_number`),
  UNIQUE KEY `vehicle_number` (`vehicle_number`),
  KEY `user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_location` (`current_lat`,`current_lng`),
  KEY `idx_rating` (`rating`),
  CONSTRAINT `drivers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `locations`
-- --------------------------------------------------------

DROP TABLE IF EXISTS `locations`;
CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `address` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `street_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `street_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `postal_code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'United States',
  `latitude` decimal(10,8) NOT NULL DEFAULT 0.00000000,
  `longitude` decimal(11,8) NOT NULL DEFAULT 0.00000000,
  `contact_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `special_instructions` text COLLATE utf8mb4_unicode_ci,
  `location_type` enum('residential','commercial','warehouse','office') COLLATE utf8mb4_unicode_ci DEFAULT 'residential',
  `access_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_coordinates` (`latitude`,`longitude`),
  KEY `idx_city_state` (`city`,`state`),
  KEY `idx_postal_code` (`postal_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `bookings`
-- --------------------------------------------------------

DROP TABLE IF EXISTS `bookings`;
CREATE TABLE `bookings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tracking_number` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_id` int(11) NOT NULL,
  `driver_id` int(11) DEFAULT NULL,
  `pickup_location_id` int(11) NOT NULL,
  `delivery_location_id` int(11) NOT NULL,
  `service_type` enum('express','standard','economy','overnight','same_day') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','confirmed','assigned','picked_up','in_transit','out_for_delivery','delivered','cancelled','failed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `priority` enum('low','normal','high','urgent') COLLATE utf8mb4_unicode_ci DEFAULT 'normal',
  `payment_method` enum('online','cash_pickup','cash_delivery','bank_transfer','check') COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_status` enum('pending','paid','failed','refunded','partial') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `total_weight` decimal(8,2) NOT NULL DEFAULT 0.00,
  `total_value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `base_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `weight_charges` decimal(10,2) DEFAULT 0.00,
  `distance_charges` decimal(10,2) DEFAULT 0.00,
  `fuel_surcharge` decimal(10,2) DEFAULT 0.00,
  `insurance_fee` decimal(10,2) DEFAULT 0.00,
  `additional_charges` decimal(10,2) DEFAULT 0.00,
  `discount_amount` decimal(10,2) DEFAULT 0.00,
  `tax_amount` decimal(10,2) DEFAULT 0.00,
  `total_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT 'USD',
  `distance_km` decimal(8,2) DEFAULT NULL,
  `estimated_duration_minutes` int(11) DEFAULT NULL,
  `scheduled_pickup_time` datetime DEFAULT NULL,
  `actual_pickup_time` datetime DEFAULT NULL,
  `estimated_delivery_time` datetime DEFAULT NULL,
  `actual_delivery_time` datetime DEFAULT NULL,
  `delivery_window_start` datetime DEFAULT NULL,
  `delivery_window_end` datetime DEFAULT NULL,
  `special_notes` text COLLATE utf8mb4_unicode_ci,
  `internal_notes` text COLLATE utf8mb4_unicode_ci,
  `requires_signature` tinyint(1) DEFAULT 0,
  `requires_id_check` tinyint(1) DEFAULT 0,
  `fragile_items` tinyint(1) DEFAULT 0,
  `temperature_controlled` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tracking_number` (`tracking_number`),
  KEY `customer_id` (`customer_id`),
  KEY `driver_id` (`driver_id`),
  KEY `pickup_location_id` (`pickup_location_id`),
  KEY `delivery_location_id` (`delivery_location_id`),
  KEY `idx_status` (`status`),
  KEY `idx_service_type` (`service_type`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_created_date` (`created_at`),
  KEY `idx_scheduled_pickup` (`scheduled_pickup_time`),
  KEY `idx_priority` (`priority`),
  CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `bookings_ibfk_3` FOREIGN KEY (`pickup_location_id`) REFERENCES `locations` (`id`),
  CONSTRAINT `bookings_ibfk_4` FOREIGN KEY (`delivery_location_id`) REFERENCES `locations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `booking_items`
-- --------------------------------------------------------

DROP TABLE IF EXISTS `booking_items`;
CREATE TABLE `booking_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `booking_id` int(11) NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('document','package','fragile','electronics','clothing','food','medical','automotive','furniture','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `weight` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `dimensions_length` decimal(8,2) DEFAULT NULL,
  `dimensions_width` decimal(8,2) DEFAULT NULL,
  `dimensions_height` decimal(8,2) DEFAULT NULL,
  `dimensions_unit` enum('cm','inch') COLLATE utf8mb4_unicode_ci DEFAULT 'cm',
  `weight_unit` enum('kg','lb') COLLATE utf8mb4_unicode_ci DEFAULT 'kg',
  `special_handling` text COLLATE utf8mb4_unicode_ci,
  `barcode` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sku` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `booking_id` (`booking_id`),
  KEY `idx_category` (`category`),
  KEY `idx_barcode` (`barcode`),
  CONSTRAINT `booking_items_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `tracking_updates`
-- --------------------------------------------------------

DROP TABLE IF EXISTS `tracking_updates`;
CREATE TABLE `tracking_updates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `booking_id` int(11) NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` text COLLATE utf8mb4_unicode_ci,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `updated_by` int(11) DEFAULT NULL,
  `update_type` enum('status','location','note','system') COLLATE utf8mb4_unicode_ci DEFAULT 'status',
  `is_public` tinyint(1) DEFAULT 1,
  `estimated_arrival` datetime DEFAULT NULL,
  `photo_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signature_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `booking_id` (`booking_id`),
  KEY `updated_by` (`updated_by`),
  KEY `idx_timestamp` (`created_at`),
  KEY `idx_status` (`status`),
  KEY `idx_public` (`is_public`),
  CONSTRAINT `tracking_updates_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tracking_updates_ibfk_2` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `payments`
-- --------------------------------------------------------

DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `booking_id` int(11) NOT NULL,
  `payment_method` enum('credit_card','debit_card','paypal','stripe','bank_transfer','cash','check','digital_wallet') COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_gateway` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gateway_transaction_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT 'USD',
  `status` enum('pending','processing','completed','failed','cancelled','refunded','partial_refund') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `gateway_response` text COLLATE utf8mb4_unicode_ci,
  `failure_reason` text COLLATE utf8mb4_unicode_ci,
  `refund_amount` decimal(10,2) DEFAULT 0.00,
  `refund_reason` text COLLATE utf8mb4_unicode_ci,
  `processed_at` datetime DEFAULT NULL,
  `refunded_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `booking_id` (`booking_id`),
  KEY `idx_transaction_id` (`transaction_id`),
  KEY `idx_gateway_transaction` (`gateway_transaction_id`),
  KEY `idx_status` (`status`),
  KEY `idx_payment_method` (`payment_method`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `notifications`
-- --------------------------------------------------------

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `type` enum('booking_created','booking_confirmed','status_update','payment_received','delivery_completed','driver_assigned','pickup_scheduled','delivery_failed','system_alert','promotion') COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `priority` enum('low','normal','high','urgent') COLLATE utf8mb4_unicode_ci DEFAULT 'normal',
  `channel` enum('in_app','email','sms','push') COLLATE utf8mb4_unicode_ci DEFAULT 'in_app',
  `sent_at` datetime DEFAULT NULL,
  `read_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `booking_id` (`booking_id`),
  KEY `idx_read_status` (`is_read`),
  KEY `idx_type` (`type`),
  KEY `idx_priority` (`priority`),
  KEY `idx_created` (`created_at`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `system_settings`
-- --------------------------------------------------------

DROP TABLE IF EXISTS `system_settings`;
CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_value` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_type` enum('string','number','boolean','json','array') COLLATE utf8mb4_unicode_ci DEFAULT 'string',
  `category` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'general',
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_public` tinyint(1) DEFAULT 0,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`),
  KEY `idx_category` (`category`),
  KEY `idx_public` (`is_public`),
  KEY `updated_by` (`updated_by`),
  CONSTRAINT `system_settings_ibfk_1` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `driver_ratings`
-- --------------------------------------------------------

DROP TABLE IF EXISTS `driver_ratings`;
CREATE TABLE `driver_ratings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `booking_id` int(11) NOT NULL,
  `driver_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `rating` tinyint(1) NOT NULL CHECK (`rating` >= 1 AND `rating` <= 5),
  `review` text COLLATE utf8mb4_unicode_ci,
  `service_quality` tinyint(1) DEFAULT NULL CHECK (`service_quality` >= 1 AND `service_quality` <= 5),
  `punctuality` tinyint(1) DEFAULT NULL CHECK (`punctuality` >= 1 AND `punctuality` <= 5),
  `communication` tinyint(1) DEFAULT NULL CHECK (`communication` >= 1 AND `communication` <= 5),
  `professionalism` tinyint(1) DEFAULT NULL CHECK (`professionalism` >= 1 AND `professionalism` <= 5),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_booking_rating` (`booking_id`),
  KEY `driver_id` (`driver_id`),
  KEY `customer_id` (`customer_id`),
  KEY `idx_rating` (`rating`),
  CONSTRAINT `driver_ratings_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `driver_ratings_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `driver_ratings_ibfk_3` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Create indexes for better performance
-- --------------------------------------------------------

CREATE INDEX idx_bookings_date_status ON bookings(created_at, status);
CREATE INDEX idx_bookings_customer_status ON bookings(customer_id, status);
CREATE INDEX idx_bookings_driver_status ON bookings(driver_id, status);
CREATE INDEX idx_users_role_status ON users(role, status);
CREATE INDEX idx_drivers_status_location ON drivers(status, current_lat, current_lng);
CREATE INDEX idx_tracking_booking_time ON tracking_updates(booking_id, created_at);
CREATE INDEX idx_payments_booking_status ON payments(booking_id, status);

COMMIT;