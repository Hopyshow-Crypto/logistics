-- LogiFlow Transportation & Logistics - Stored Procedures and Functions
-- Professional database procedures for common operations

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
DELIMITER $$

-- --------------------------------------------------------
-- Function to generate unique tracking numbers
-- --------------------------------------------------------

DROP FUNCTION IF EXISTS `generate_tracking_number`$$
CREATE FUNCTION `generate_tracking_number`() 
RETURNS VARCHAR(20) 
READS SQL DATA 
DETERMINISTIC
BEGIN
    DECLARE new_tracking_number VARCHAR(20);
    DECLARE tracking_exists INT DEFAULT 1;
    DECLARE counter INT DEFAULT 0;
    
    WHILE tracking_exists = 1 AND counter < 100 DO
        SET new_tracking_number = CONCAT(
            'LF',
            DATE_FORMAT(NOW(), '%Y'),
            LPAD(FLOOR(RAND() * 999999), 6, '0')
        );
        
        SELECT COUNT(*) INTO tracking_exists 
        FROM bookings 
        WHERE tracking_number = new_tracking_number;
        
        SET counter = counter + 1;
    END WHILE;
    
    RETURN new_tracking_number;
END$$

-- --------------------------------------------------------
-- Function to calculate delivery charges
-- --------------------------------------------------------

DROP FUNCTION IF EXISTS `calculate_delivery_charges`$$
CREATE FUNCTION `calculate_delivery_charges`(
    service_type_param VARCHAR(20),
    weight_param DECIMAL(8,2),
    distance_param DECIMAL(8,2),
    value_param DECIMAL(10,2)
) 
RETURNS DECIMAL(10,2) 
READS SQL DATA 
DETERMINISTIC
BEGIN
    DECLARE base_rate DECIMAL(10,2) DEFAULT 0;
    DECLARE weight_rate DECIMAL(10,2) DEFAULT 0;
    DECLARE distance_rate DECIMAL(10,2) DEFAULT 0;
    DECLARE fuel_rate DECIMAL(5,4) DEFAULT 0;
    DECLARE insurance_rate DECIMAL(5,4) DEFAULT 0;
    DECLARE tax_rate DECIMAL(5,4) DEFAULT 0;
    
    DECLARE weight_charges DECIMAL(10,2) DEFAULT 0;
    DECLARE distance_charges DECIMAL(10,2) DEFAULT 0;
    DECLARE fuel_surcharge DECIMAL(10,2) DEFAULT 0;
    DECLARE insurance_fee DECIMAL(10,2) DEFAULT 0;
    DECLARE tax_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE total_amount DECIMAL(10,2) DEFAULT 0;
    
    -- Get rates from system settings
    SELECT 
        CAST(CASE 
            WHEN service_type_param = 'express' THEN 
                (SELECT setting_value FROM system_settings WHERE setting_key = 'base_rate_express')
            WHEN service_type_param = 'standard' THEN 
                (SELECT setting_value FROM system_settings WHERE setting_key = 'base_rate_standard')
            WHEN service_type_param = 'economy' THEN 
                (SELECT setting_value FROM system_settings WHERE setting_key = 'base_rate_economy')
            WHEN service_type_param = 'overnight' THEN 
                (SELECT setting_value FROM system_settings WHERE setting_key = 'base_rate_overnight')
            WHEN service_type_param = 'same_day' THEN 
                (SELECT setting_value FROM system_settings WHERE setting_key = 'base_rate_same_day')
            ELSE 25.00
        END AS DECIMAL(10,2)),
        CAST((SELECT setting_value FROM system_settings WHERE setting_key = 'rate_per_kg') AS DECIMAL(10,2)),
        CAST((SELECT setting_value FROM system_settings WHERE setting_key = 'rate_per_km') AS DECIMAL(10,2)),
        CAST((SELECT setting_value FROM system_settings WHERE setting_key = 'fuel_surcharge_rate') AS DECIMAL(5,4)),
        CAST((SELECT setting_value FROM system_settings WHERE setting_key = 'insurance_rate') AS DECIMAL(5,4)),
        CAST((SELECT setting_value FROM system_settings WHERE setting_key = 'tax_rate') AS DECIMAL(5,4))
    INTO base_rate, weight_rate, distance_rate, fuel_rate, insurance_rate, tax_rate;
    
    -- Calculate charges
    SET weight_charges = weight_param * weight_rate;
    SET distance_charges = distance_param * distance_rate;
    SET fuel_surcharge = (base_rate + weight_charges + distance_charges) * fuel_rate;
    SET insurance_fee = value_param * insurance_rate;
    
    -- Calculate subtotal
    SET total_amount = base_rate + weight_charges + distance_charges + fuel_surcharge + insurance_fee;
    
    -- Calculate tax
    SET tax_amount = total_amount * tax_rate;
    
    -- Final total
    SET total_amount = total_amount + tax_amount;
    
    RETURN ROUND(total_amount, 2);
END$$

-- --------------------------------------------------------
-- Procedure to create a new booking with all related data
-- --------------------------------------------------------

DROP PROCEDURE IF EXISTS `create_booking`$$
CREATE PROCEDURE `create_booking`(
    IN p_customer_id INT,
    IN p_pickup_address TEXT,
    IN p_pickup_lat DECIMAL(10,8),
    IN p_pickup_lng DECIMAL(11,8),
    IN p_pickup_contact_name VARCHAR(255),
    IN p_pickup_contact_phone VARCHAR(20),
    IN p_delivery_address TEXT,
    IN p_delivery_lat DECIMAL(10,8),
    IN p_delivery_lng DECIMAL(11,8),
    IN p_delivery_contact_name VARCHAR(255),
    IN p_delivery_contact_phone VARCHAR(20),
    IN p_service_type VARCHAR(20),
    IN p_payment_method VARCHAR(20),
    IN p_scheduled_pickup_time DATETIME,
    IN p_special_notes TEXT,
    IN p_items JSON,
    OUT p_booking_id INT,
    OUT p_tracking_number VARCHAR(20),
    OUT p_total_amount DECIMAL(10,2)
)
BEGIN
    DECLARE pickup_location_id INT;
    DECLARE delivery_location_id INT;
    DECLARE total_weight DECIMAL(8,2) DEFAULT 0;
    DECLARE total_value DECIMAL(10,2) DEFAULT 0;
    DECLARE calculated_amount DECIMAL(10,2);
    DECLARE distance_km DECIMAL(8,2) DEFAULT 0;
    DECLARE item_count INT DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Generate tracking number
    SET p_tracking_number = generate_tracking_number();
    
    -- Insert pickup location
    INSERT INTO locations (address, latitude, longitude, contact_name, contact_phone)
    VALUES (p_pickup_address, p_pickup_lat, p_pickup_lng, p_pickup_contact_name, p_pickup_contact_phone);
    SET pickup_location_id = LAST_INSERT_ID();
    
    -- Insert delivery location
    INSERT INTO locations (address, latitude, longitude, contact_name, contact_phone)
    VALUES (p_delivery_address, p_delivery_lat, p_delivery_lng, p_delivery_contact_name, p_delivery_contact_phone);
    SET delivery_location_id = LAST_INSERT_ID();
    
    -- Calculate distance (simplified - in production use proper geolocation)
    SET distance_km = ROUND(
        6371 * ACOS(
            COS(RADIANS(p_pickup_lat)) * 
            COS(RADIANS(p_delivery_lat)) * 
            COS(RADIANS(p_delivery_lng) - RADIANS(p_pickup_lng)) + 
            SIN(RADIANS(p_pickup_lat)) * 
            SIN(RADIANS(p_delivery_lat))
        ), 2
    );
    
    -- Calculate totals from items JSON
    SET item_count = JSON_LENGTH(p_items);
    SET i = 0;
    
    WHILE i < item_count DO
        SET total_weight = total_weight + 
            (JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', i, '].weight'))) * 
             JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', i, '].quantity'))));
        SET total_value = total_value + 
            (JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', i, '].value'))) * 
             JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', i, '].quantity'))));
        SET i = i + 1;
    END WHILE;
    
    -- Calculate total amount
    SET calculated_amount = calculate_delivery_charges(p_service_type, total_weight, distance_km, total_value);
    SET p_total_amount = calculated_amount;
    
    -- Insert booking
    INSERT INTO bookings (
        tracking_number, customer_id, pickup_location_id, delivery_location_id,
        service_type, payment_method, total_weight, total_value, total_amount,
        distance_km, scheduled_pickup_time, special_notes
    ) VALUES (
        p_tracking_number, p_customer_id, pickup_location_id, delivery_location_id,
        p_service_type, p_payment_method, total_weight, total_value, calculated_amount,
        distance_km, p_scheduled_pickup_time, p_special_notes
    );
    
    SET p_booking_id = LAST_INSERT_ID();
    
    -- Insert booking items
    SET i = 0;
    WHILE i < item_count DO
        INSERT INTO booking_items (
            booking_id, description, category, quantity, weight, value
        ) VALUES (
            p_booking_id,
            JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', i, '].description'))),
            JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', i, '].category'))),
            JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', i, '].quantity'))),
            JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', i, '].weight'))),
            JSON_UNQUOTE(JSON_EXTRACT(p_items, CONCAT('$[', i, '].value')))
        );
        SET i = i + 1;
    END WHILE;
    
    -- Insert initial tracking update
    INSERT INTO tracking_updates (booking_id, status, notes, update_type)
    VALUES (p_booking_id, 'Booking Created', 'Your booking has been created successfully', 'status');
    
    COMMIT;
END$$

-- --------------------------------------------------------
-- Procedure to update booking status with tracking
-- --------------------------------------------------------

DROP PROCEDURE IF EXISTS `update_booking_status`$$
CREATE PROCEDURE `update_booking_status`(
    IN p_booking_id INT,
    IN p_new_status VARCHAR(50),
    IN p_updated_by INT,
    IN p_notes TEXT,
    IN p_location TEXT,
    IN p_latitude DECIMAL(10,8),
    IN p_longitude DECIMAL(11,8)
)
BEGIN
    DECLARE current_status VARCHAR(50);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Get current status
    SELECT status INTO current_status FROM bookings WHERE id = p_booking_id;
    
    -- Update booking status and timestamps
    CASE p_new_status
        WHEN 'picked_up' THEN
            UPDATE bookings 
            SET status = p_new_status, actual_pickup_time = NOW(), updated_at = NOW()
            WHERE id = p_booking_id;
        WHEN 'delivered' THEN
            UPDATE bookings 
            SET status = p_new_status, actual_delivery_time = NOW(), updated_at = NOW()
            WHERE id = p_booking_id;
        ELSE
            UPDATE bookings 
            SET status = p_new_status, updated_at = NOW()
            WHERE id = p_booking_id;
    END CASE;
    
    -- Insert tracking update
    INSERT INTO tracking_updates (
        booking_id, status, location, latitude, longitude, notes, updated_by, update_type
    ) VALUES (
        p_booking_id, p_new_status, p_location, p_latitude, p_longitude, 
        COALESCE(p_notes, CONCAT('Status updated to ', p_new_status)), p_updated_by, 'status'
    );
    
    -- Update driver statistics if delivered
    IF p_new_status = 'delivered' THEN
        UPDATE drivers d
        JOIN bookings b ON d.user_id = b.driver_id
        SET d.completed_deliveries = d.completed_deliveries + 1,
            d.total_earnings = d.total_earnings + (b.total_amount * d.commission_rate / 100)
        WHERE b.id = p_booking_id;
    END IF;
    
    COMMIT;
END$$

-- --------------------------------------------------------
-- Procedure to assign driver to booking
-- --------------------------------------------------------

DROP PROCEDURE IF EXISTS `assign_driver_to_booking`$$
CREATE PROCEDURE `assign_driver_to_booking`(
    IN p_booking_id INT,
    IN p_driver_id INT,
    IN p_assigned_by INT
)
BEGIN
    DECLARE driver_status VARCHAR(20);
    DECLARE booking_status VARCHAR(50);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Check driver availability
    SELECT d.status INTO driver_status 
    FROM drivers d 
    JOIN users u ON d.user_id = u.id 
    WHERE u.id = p_driver_id;
    
    -- Check booking status
    SELECT status INTO booking_status FROM bookings WHERE id = p_booking_id;
    
    IF driver_status != 'available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Driver is not available';
    END IF;
    
    IF booking_status != 'pending' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Booking is not in pending status';
    END IF;
    
    -- Assign driver and update status
    UPDATE bookings 
    SET driver_id = p_driver_id, status = 'confirmed', updated_at = NOW()
    WHERE id = p_booking_id;
    
    -- Update driver status
    UPDATE drivers 
    SET status = 'busy' 
    WHERE user_id = p_driver_id;
    
    -- Insert tracking update
    INSERT INTO tracking_updates (booking_id, status, notes, updated_by, update_type)
    VALUES (p_booking_id, 'Driver Assigned', 
            CONCAT('Driver assigned to delivery'), p_assigned_by, 'status');
    
    COMMIT;
END$$

-- --------------------------------------------------------
-- Function to get driver performance metrics
-- --------------------------------------------------------

DROP FUNCTION IF EXISTS `get_driver_rating`$$
CREATE FUNCTION `get_driver_rating`(p_driver_id INT) 
RETURNS DECIMAL(3,2) 
READS SQL DATA 
DETERMINISTIC
BEGIN
    DECLARE avg_rating DECIMAL(3,2) DEFAULT 5.00;
    
    SELECT COALESCE(AVG(rating), 5.00) INTO avg_rating
    FROM driver_ratings 
    WHERE driver_id = p_driver_id;
    
    RETURN ROUND(avg_rating, 2);
END$$

-- --------------------------------------------------------
-- Procedure to calculate and update driver ratings
-- --------------------------------------------------------

DROP PROCEDURE IF EXISTS `update_driver_rating`$$
CREATE PROCEDURE `update_driver_rating`(
    IN p_driver_id INT
)
BEGIN
    DECLARE new_rating DECIMAL(3,2);
    DECLARE rating_count INT;
    
    -- Calculate new average rating
    SELECT COALESCE(AVG(rating), 5.00), COUNT(*)
    INTO new_rating, rating_count
    FROM driver_ratings 
    WHERE driver_id = p_driver_id;
    
    -- Update driver record
    UPDATE drivers 
    SET rating = new_rating, total_ratings = rating_count
    WHERE user_id = p_driver_id;
END$$

-- --------------------------------------------------------
-- Procedure to get dashboard statistics
-- --------------------------------------------------------

DROP PROCEDURE IF EXISTS `get_dashboard_stats`$$
CREATE PROCEDURE `get_dashboard_stats`(
    IN p_user_id INT,
    IN p_user_role VARCHAR(20),
    IN p_date_from DATE,
    IN p_date_to DATE
)
BEGIN
    IF p_user_role = 'admin' THEN
        SELECT 
            COUNT(*) as total_bookings,
            COUNT(CASE WHEN status IN ('confirmed', 'assigned', 'picked_up', 'in_transit', 'out_for_delivery') THEN 1 END) as active_bookings,
            COUNT(CASE WHEN status = 'delivered' THEN 1 END) as completed_bookings,
            COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_bookings,
            SUM(CASE WHEN payment_status = 'paid' THEN total_amount ELSE 0 END) as total_revenue,
            SUM(CASE WHEN payment_status = 'pending' THEN total_amount ELSE 0 END) as pending_revenue,
            AVG(total_amount) as avg_booking_value,
            COUNT(DISTINCT customer_id) as unique_customers,
            COUNT(DISTINCT driver_id) as active_drivers
        FROM bookings 
        WHERE DATE(created_at) BETWEEN p_date_from AND p_date_to;
        
    ELSEIF p_user_role = 'customer' THEN
        SELECT 
            COUNT(*) as total_bookings,
            COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_bookings,
            COUNT(CASE WHEN status IN ('confirmed', 'assigned', 'picked_up', 'in_transit', 'out_for_delivery') THEN 1 END) as active_bookings,
            COUNT(CASE WHEN status = 'delivered' THEN 1 END) as completed_bookings,
            SUM(total_amount) as total_spent,
            AVG(total_amount) as avg_booking_value
        FROM bookings 
        WHERE customer_id = p_user_id 
        AND DATE(created_at) BETWEEN p_date_from AND p_date_to;
        
    ELSEIF p_user_role = 'driver' THEN
        SELECT 
            COUNT(*) as total_assignments,
            COUNT(CASE WHEN status IN ('confirmed', 'assigned', 'picked_up', 'in_transit', 'out_for_delivery') THEN 1 END) as active_deliveries,
            COUNT(CASE WHEN status = 'delivered' THEN 1 END) as completed_deliveries,
            COUNT(CASE WHEN status = 'delivered' AND DATE(actual_delivery_time) = CURDATE() THEN 1 END) as deliveries_today,
            SUM(CASE WHEN status = 'delivered' THEN total_amount * 0.15 ELSE 0 END) as total_earnings,
            AVG(CASE WHEN status = 'delivered' THEN total_amount END) as avg_delivery_value
        FROM bookings 
        WHERE driver_id = p_user_id 
        AND DATE(created_at) BETWEEN p_date_from AND p_date_to;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------
-- Create triggers for automatic updates
-- --------------------------------------------------------

-- Trigger to update driver rating when new rating is added
DELIMITER $$
CREATE TRIGGER `update_driver_rating_trigger` 
AFTER INSERT ON `driver_ratings`
FOR EACH ROW
BEGIN
    CALL update_driver_rating(NEW.driver_id);
END$$
DELIMITER ;

-- Trigger to create notification when booking status changes
DELIMITER $$
CREATE TRIGGER `booking_status_notification` 
AFTER UPDATE ON `bookings`
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO notifications (user_id, booking_id, type, title, message, priority)
        VALUES (
            NEW.customer_id,
            NEW.id,
            'status_update',
            CONCAT('Booking Status Updated - #', NEW.tracking_number),
            CONCAT('Your booking status has been updated to: ', NEW.status),
            CASE 
                WHEN NEW.status = 'delivered' THEN 'high'
                WHEN NEW.status = 'cancelled' THEN 'high'
                ELSE 'normal'
            END
        );
    END IF;
END$$
DELIMITER ;