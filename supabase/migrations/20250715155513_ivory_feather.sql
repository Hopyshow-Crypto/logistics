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
    DECLARE weight_rate DECIMAL(10,2) DEFAULT 2.75;
    DECLARE distance_rate DECIMAL(10,2) DEFAULT 1.25;
    DECLARE fuel_rate DECIMAL(5,4) DEFAULT 0.15;
    DECLARE insurance_rate DECIMAL(5,4) DEFAULT 0.02;
    DECLARE tax_rate DECIMAL(5,4) DEFAULT 0.08;
    
    DECLARE weight_charges DECIMAL(10,2) DEFAULT 0;
    DECLARE distance_charges DECIMAL(10,2) DEFAULT 0;
    DECLARE fuel_surcharge DECIMAL(10,2) DEFAULT 0;
    DECLARE insurance_fee DECIMAL(10,2) DEFAULT 0;
    DECLARE tax_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE total_amount DECIMAL(10,2) DEFAULT 0;
    
    -- Set base rate based on service type
    CASE service_type_param
        WHEN 'express' THEN SET base_rate = 35.00;
        WHEN 'standard' THEN SET base_rate = 25.00;
        WHEN 'economy' THEN SET base_rate = 18.00;
        WHEN 'overnight' THEN SET base_rate = 45.00;
        WHEN 'same_day' THEN SET base_rate = 55.00;
        ELSE SET base_rate = 25.00;
    END CASE;
    
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
            'Driver assigned to delivery', p_assigned_by, 'status');
    
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
-- Create useful views for reporting and queries
-- --------------------------------------------------------

-- View for booking details with all related information
CREATE OR REPLACE VIEW `booking_details_view` AS
SELECT 
    b.id,
    b.tracking_number,
    b.status,
    b.service_type,
    b.priority,
    b.total_amount,
    b.payment_status,
    b.created_at,
    b.scheduled_pickup_time,
    b.actual_delivery_time,
    c.name as customer_name,
    c.email as customer_email,
    c.phone as customer_phone,
    d.name as driver_name,
    d.phone as driver_phone,
    pl.address as pickup_address,
    pl.city as pickup_city,
    pl.state as pickup_state,
    dl.address as delivery_address,
    dl.city as delivery_city,
    dl.state as delivery_state,
    COUNT(bi.id) as item_count,
    SUM(bi.quantity) as total_items,
    b.total_weight,
    b.distance_km
FROM bookings b
JOIN users c ON b.customer_id = c.id
LEFT JOIN users d ON b.driver_id = d.id
JOIN locations pl ON b.pickup_location_id = pl.id
JOIN locations dl ON b.delivery_location_id = dl.id
LEFT JOIN booking_items bi ON b.id = bi.booking_id
GROUP BY b.id;

-- View for driver performance statistics
CREATE OR REPLACE VIEW `driver_performance_view` AS
SELECT 
    d.id as driver_id,
    u.name as driver_name,
    u.email as driver_email,
    u.phone as driver_phone,
    d.status,
    d.vehicle_type,
    d.vehicle_number,
    d.rating,
    d.total_ratings,
    d.completed_deliveries,
    d.total_earnings,
    COUNT(CASE WHEN b.status IN ('confirmed', 'assigned', 'picked_up', 'in_transit', 'out_for_delivery') THEN 1 END) as active_bookings,
    COUNT(CASE WHEN b.status = 'delivered' AND DATE(b.actual_delivery_time) = CURDATE() THEN 1 END) as deliveries_today,
    COUNT(CASE WHEN b.status = 'delivered' AND WEEK(b.actual_delivery_time) = WEEK(CURDATE()) THEN 1 END) as deliveries_this_week,
    AVG(CASE WHEN b.status = 'delivered' THEN b.total_amount END) as avg_delivery_value
FROM drivers d
JOIN users u ON d.user_id = u.id
LEFT JOIN bookings b ON d.user_id = b.driver_id
GROUP BY d.id;

-- View for daily revenue and statistics
CREATE OR REPLACE VIEW `daily_stats_view` AS
SELECT 
    DATE(created_at) as date,
    COUNT(*) as total_bookings,
    COUNT(CASE WHEN status = 'delivered' THEN 1 END) as completed_bookings,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_bookings,
    SUM(CASE WHEN payment_status = 'paid' THEN total_amount ELSE 0 END) as revenue,
    SUM(CASE WHEN payment_status = 'pending' THEN total_amount ELSE 0 END) as pending_revenue,
    AVG(total_amount) as avg_booking_value,
    SUM(total_weight) as total_weight_shipped
FROM bookings
GROUP BY DATE(created_at)
ORDER BY date DESC;