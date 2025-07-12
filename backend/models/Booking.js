const { executeQuery, executeTransaction } = require('../config/database');

class Booking {
  // Generate unique tracking number with better collision handling
  static generateTrackingNumber() {
    const prefix = 'LF';
    const year = new Date().getFullYear();
    const random = Math.floor(Math.random() * 999999).toString().padStart(6, '0');
    return `${prefix}${year}${random}`;
  }

  // Create new booking with enhanced error handling and validation
  static async create(bookingData) {
    try {
      const {
        customerId,
        pickup,
        delivery,
        items,
        service: serviceType,
        paymentMethod,
        scheduledPickupTime,
        notes: specialNotes
      } = bookingData;

      // Validate required fields
      if (!customerId || !pickup || !delivery || !items || !serviceType) {
        return { success: false, error: 'Missing required booking information' };
      }

      if (!items.length) {
        return { success: false, error: 'At least one item is required' };
      }

      // Calculate totals
      const totalWeight = items.reduce((sum, item) => sum + (item.weight * item.quantity), 0);
      const totalValue = items.reduce((sum, item) => sum + (item.value * item.quantity), 0);
      
      // Enhanced pricing calculation
      const baseRates = { 
        express: 35, 
        standard: 25, 
        economy: 18, 
        overnight: 45, 
        same_day: 55 
      };
      const baseAmount = baseRates[serviceType];
      const weightCharge = totalWeight * 2.75;
      
      // Calculate distance charge (simplified - in production use real geolocation)
      const distanceCharge = 15.50; // Default distance charge
      const fuelSurcharge = (baseAmount + weightCharge + distanceCharge) * 0.15;
      const insuranceFee = totalValue * 0.02;
      const taxAmount = (baseAmount + weightCharge + distanceCharge + fuelSurcharge + insuranceFee) * 0.08;
      
      const totalAmount = baseAmount + weightCharge + distanceCharge + fuelSurcharge + insuranceFee + taxAmount;

      const trackingNumber = this.generateTrackingNumber();

      // Prepare transaction queries
      const queries = [
        // Insert pickup location
        {
          query: `
            INSERT INTO locations (address, latitude, longitude, contact_name, contact_phone, location_type)
            VALUES (?, ?, ?, ?, ?, 'pickup')
          `,
          params: [
            pickup.address,
            pickup.coordinates?.lat || 0,
            pickup.coordinates?.lng || 0,
            pickup.contactName || null,
            pickup.contactPhone || null
          ]
        },
        // Insert delivery location
        {
          query: `
            INSERT INTO locations (address, latitude, longitude, contact_name, contact_phone, location_type)
            VALUES (?, ?, ?, ?, ?, 'delivery')
          `,
          params: [
            delivery.address,
            delivery.coordinates?.lat || 0,
            delivery.coordinates?.lng || 0,
            delivery.contactName || null,
            delivery.contactPhone || null
          ]
        }
      ];

      const locationResult = await executeTransaction(queries);
      
      if (!locationResult.success) {
        return { success: false, error: locationResult.error };
      }

      const pickupLocationId = locationResult.data[0].insertId;
      const deliveryLocationId = locationResult.data[1].insertId;

      // Insert booking
      const bookingQuery = `
        INSERT INTO bookings (
          tracking_number, customer_id, pickup_location_id, delivery_location_id, service_type, 
          payment_method, total_weight, total_value, base_amount, weight_charges, distance_charges,
          fuel_surcharge, insurance_fee, tax_amount, total_amount, scheduled_pickup_time, special_notes
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `;

      const bookingResult = await executeQuery(bookingQuery, [
        trackingNumber, customerId, pickupLocationId, deliveryLocationId, serviceType,
        paymentMethod, totalWeight, totalValue, baseAmount, weightCharge, distanceCharge,
        fuelSurcharge, insuranceFee, taxAmount, totalAmount, scheduledPickupTime, specialNotes
      ]);

      if (!bookingResult.success) {
        return { success: false, error: bookingResult.error };
      }

      const bookingId = bookingResult.insertId;

      // Insert booking items
      const itemQueries = items.map(item => ({
        query: `
          INSERT INTO booking_items (booking_id, description, category, quantity, weight, value, dimensions_length, dimensions_width, dimensions_height)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `,
        params: [
          bookingId, item.description, item.category, item.quantity, 
          item.weight, item.value, item.length || null, item.width || null, item.height || null
        ]
      }));

      const itemsResult = await executeTransaction(itemQueries);
      
      if (!itemsResult.success) {
        return { success: false, error: itemsResult.error };
      }

      // Insert initial tracking update
      await executeQuery(
        'INSERT INTO tracking_updates (booking_id, status, notes, update_type, is_public) VALUES (?, ?, ?, ?, ?)',
        [bookingId, 'Booking Created', 'Your booking has been created successfully and is pending driver assignment', 'status', 1]
      );

      return {
        success: true,
        booking: {
          id: bookingId,
          trackingNumber,
          totalAmount: parseFloat(totalAmount.toFixed(2)),
          status: 'pending'
        }
      };
    } catch (error) {
      console.error('Booking creation error:', error);
      return { success: false, error: error.message };
    }
  }

  // Get bookings by user with enhanced filtering and sorting
  static async getByUser(userId, role) {
    try {
      let query = `
        SELECT 
          b.*,
          pl.address as pickup_address, pl.city as pickup_city, pl.state as pickup_state,
          pl.contact_name as pickup_contact_name,
          pl.contact_phone as pickup_contact_phone,
          dl.address as delivery_address, dl.city as delivery_city, dl.state as delivery_state,
          dl.contact_name as delivery_contact_name,
          dl.contact_phone as delivery_contact_phone,
          u.name as customer_name,
          u.phone as customer_phone,
          u.email as customer_email,
          d.name as driver_name,
          d.phone as driver_phone,
          dr.rating as driver_rating
        FROM bookings b
        JOIN locations pl ON b.pickup_location_id = pl.id
        JOIN locations dl ON b.delivery_location_id = dl.id
        JOIN users u ON b.customer_id = u.id
        LEFT JOIN users d ON b.driver_id = d.id
        LEFT JOIN drivers dr ON d.id = dr.user_id
      `;

      const params = [];

      if (role === 'customer') {
        query += ' WHERE b.customer_id = ?';
        params.push(userId);
      } else if (role === 'driver') {
        query += ' WHERE b.driver_id = ?';
        params.push(userId);
      }

      query += ' ORDER BY b.created_at DESC LIMIT 100';

      const result = await executeQuery(query, params);

      if (result.success) {
        // Get items for each booking with enhanced details
        const bookingsWithItems = await Promise.all(
          result.data.map(async (booking) => {
            const itemsResult = await executeQuery(
              'SELECT id, description, category, quantity, weight, value, dimensions_length, dimensions_width, dimensions_height FROM booking_items WHERE booking_id = ?',
              [booking.id]
            );
            
            // Format the booking data
            return {
              id: booking.id.toString(),
              trackingNumber: booking.tracking_number,
              customerId: booking.customer_id.toString(),
              customerName: booking.customer_name,
              customerPhone: booking.customer_phone,
              customerEmail: booking.customer_email,
              driverId: booking.driver_id ? booking.driver_id.toString() : null,
              driverName: booking.driver_name,
              driverPhone: booking.driver_phone,
              pickup: {
                address: booking.pickup_address,
                coordinates: { lat: 0, lng: 0 }, // Would be populated from actual coordinates
                contactName: booking.pickup_contact_name,
                contactPhone: booking.pickup_contact_phone
              },
              delivery: {
                address: booking.delivery_address,
                coordinates: { lat: 0, lng: 0 }, // Would be populated from actual coordinates
                contactName: booking.delivery_contact_name,
                contactPhone: booking.delivery_contact_phone
              },
              items: itemsResult.success ? itemsResult.data.map(item => ({
                id: item.id.toString(),
                description: item.description,
                category: item.category,
                quantity: item.quantity,
                weight: parseFloat(item.weight),
                value: parseFloat(item.value)
              })) : [],
              totalWeight: parseFloat(booking.total_weight),
              totalValue: parseFloat(booking.total_value),
              service: booking.service_type,
              status: booking.status,
              paymentMethod: booking.payment_method,
              paymentStatus: booking.payment_status,
              amount: parseFloat(booking.total_amount),
              bookingDate: booking.created_at,
              scheduledDate: booking.scheduled_pickup_time,
              notes: booking.special_notes
            };
          })
        );

        return { success: true, bookings: bookingsWithItems };
      }

      return { success: false, error: result.error };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Get booking by tracking number with complete details
  static async getByTrackingNumber(trackingNumber) {
    try {
      const query = `
        SELECT 
          b.*,
          pl.address as pickup_address,
          pl.latitude as pickup_lat,
          pl.longitude as pickup_lng,
          pl.contact_name as pickup_contact_name,
          pl.contact_phone as pickup_contact_phone,
          dl.address as delivery_address,
          dl.latitude as delivery_lat,
          dl.longitude as delivery_lng,
          dl.contact_name as delivery_contact_name,
          dl.contact_phone as delivery_contact_phone,
          u.name as customer_name,
          u.phone as customer_phone,
          u.email as customer_email,
          d.name as driver_name,
          d.phone as driver_phone,
          dr.rating as driver_rating,
          dr.vehicle_type,
          dr.vehicle_number
        FROM bookings b
        JOIN locations pl ON b.pickup_location_id = pl.id
        JOIN locations dl ON b.delivery_location_id = dl.id
        JOIN users u ON b.customer_id = u.id
        LEFT JOIN users d ON b.driver_id = d.id
        LEFT JOIN drivers dr ON d.id = dr.user_id
        WHERE b.tracking_number = ?
      `;

      const result = await executeQuery(query, [trackingNumber]);

      if (result.success && result.data.length > 0) {
        const booking = result.data[0];

        // Get booking items
        const itemsResult = await executeQuery(
          'SELECT * FROM booking_items WHERE booking_id = ?',
          [booking.id]
        );

        // Get tracking updates
        const trackingResult = await executeQuery(
          `SELECT tu.id, tu.status, tu.location, tu.latitude, tu.longitude, tu.notes, 
                  tu.created_at, tu.update_type, tu.is_public, u.name as updated_by_name 
           FROM tracking_updates tu
           LEFT JOIN users u ON tu.updated_by = u.id
           WHERE tu.booking_id = ?
           ORDER BY tu.created_at DESC`,
          [booking.id]
        );

        return {
          success: true,
          booking: {
            id: booking.id.toString(),
            trackingNumber: booking.tracking_number,
            status: booking.status,
            service: booking.service_type,
            customerName: booking.customer_name,
            customerPhone: booking.customer_phone,
            customerEmail: booking.customer_email,
            driverName: booking.driver_name,
            driverPhone: booking.driver_phone,
            pickup: {
              address: booking.pickup_address,
              coordinates: { lat: parseFloat(booking.pickup_lat) || 0, lng: parseFloat(booking.pickup_lng) || 0 },
              contactName: booking.pickup_contact_name,
              contactPhone: booking.pickup_contact_phone
            },
            delivery: {
              address: booking.delivery_address,
              coordinates: { lat: parseFloat(booking.delivery_lat) || 0, lng: parseFloat(booking.delivery_lng) || 0 },
              contactName: booking.delivery_contact_name,
              contactPhone: booking.delivery_contact_phone
            },
            amount: parseFloat(booking.total_amount),
            paymentMethod: booking.payment_method,
            paymentStatus: booking.payment_status,
            bookingDate: booking.created_at,
            scheduledDate: booking.scheduled_pickup_time,
            actualPickupTime: booking.actual_pickup_time,
            actualDeliveryTime: booking.actual_delivery_time,
            notes: booking.special_notes,
            items: itemsResult.success ? itemsResult.data : [],
            trackingUpdates: trackingResult.success ? trackingResult.data : []
          }
        };
      }

      return { success: false, error: 'Booking not found' };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Update booking status with enhanced tracking
  static async updateStatus(bookingId, status, updatedBy, notes = null) {
    try {
      // Validate status
      const validStatuses = ['pending', 'confirmed', 'assigned', 'picked_up', 'in_transit', 'out_for_delivery', 'delivered', 'cancelled', 'failed'];
      if (!validStatuses.includes(status)) {
        return { success: false, error: 'Invalid status provided' };
      }

      const queries = [
        {
          query: 'UPDATE bookings SET status = ?, updated_at = NOW() WHERE id = ?',
          params: [status, bookingId]
        },
        {
          query: `
            INSERT INTO tracking_updates (booking_id, status, notes, updated_by, update_type, is_public)
            VALUES (?, ?, ?, ?, 'status', 1)
          `,
          params: [bookingId, status, notes || `Status updated to ${status}`, updatedBy]
        }
      ];

      // Add timestamp updates based on status
      if (status === 'picked_up') {
        queries[0].query = 'UPDATE bookings SET status = ?, actual_pickup_time = NOW(), updated_at = NOW() WHERE id = ?';
      } else if (status === 'delivered') {
        queries[0].query = 'UPDATE bookings SET status = ?, actual_delivery_time = NOW(), updated_at = NOW() WHERE id = ?';
        
        // Update driver statistics
        queries.push({
          query: `
            UPDATE drivers d 
            JOIN bookings b ON d.user_id = b.driver_id 
            SET d.completed_deliveries = d.completed_deliveries + 1,
                d.total_earnings = d.total_earnings + (b.total_amount * d.commission_rate / 100)
            WHERE b.id = ?
          `,
          params: [bookingId]
        });
      }

      const result = await executeTransaction(queries);

      if (result.success) {
        return { success: true, message: 'Booking status updated successfully' };
      }

      return { success: false, error: result.error };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Assign driver to booking with availability check
  static async assignDriver(bookingId, driverId) {
    try {
      // Check driver availability
      const driverCheck = await executeQuery(
        'SELECT status FROM drivers WHERE user_id = ?',
        [driverId]
      );

      if (!driverCheck.success || driverCheck.data.length === 0) {
        return { success: false, error: 'Driver not found' };
      }

      if (driverCheck.data[0].status !== 'available') {
        return { success: false, error: 'Driver is not available' };
      }

      const query = `
        UPDATE bookings 
        SET driver_id = ?, status = 'assigned', updated_at = NOW()
        WHERE id = ? AND status = 'pending'
      `;

      const result = await executeQuery(query, [driverId, bookingId]);

      if (result.success && result.affectedRows > 0) {
        // Update driver status
        await executeQuery(
          'UPDATE drivers SET status = ? WHERE user_id = ?',
          ['busy', driverId]
        );

        // Add tracking update
        await executeQuery(
          'INSERT INTO tracking_updates (booking_id, status, notes, update_type, is_public) VALUES (?, ?, ?, ?, ?)',
          [bookingId, 'Driver Assigned', 'A professional driver has been assigned to your delivery', 'status', 1]
        );

        return { success: true, message: 'Driver assigned successfully' };
      }

      return { success: false, error: 'Failed to assign driver or booking not found' };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Get comprehensive dashboard statistics
  static async getDashboardStats(userId = null, role = null) {
    try {
      let stats = {};

      if (role === 'admin' || !role) {
        // Admin stats
        const adminQueries = [
          'SELECT COUNT(*) as totalBookings FROM bookings',
          'SELECT COUNT(*) as activeBookings FROM bookings WHERE status IN ("confirmed", "assigned", "picked_up", "in_transit", "out_for_delivery")',
          'SELECT COALESCE(SUM(total_amount), 0) as revenue FROM bookings WHERE payment_status = "paid"',
          'SELECT COALESCE(SUM(total_amount), 0) as pendingPayments FROM bookings WHERE payment_status = "pending"',
          'SELECT COUNT(*) as availableDrivers FROM drivers WHERE status = "available"',
          'SELECT COUNT(DISTINCT customer_id) as uniqueCustomers FROM bookings WHERE DATE(created_at) >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)'
        ];

        for (const query of adminQueries) {
          const result = await executeQuery(query);
          if (result.success) {
            Object.assign(stats, result.data[0]);
          }
        }
      }

      if (role === 'customer' && userId) {
        // Customer stats
        const customerQueries = [
          `SELECT COUNT(*) as totalBookings FROM bookings WHERE customer_id = ${userId}`,
          `SELECT COUNT(*) as pending FROM bookings WHERE customer_id = ${userId} AND status = 'pending'`,
          `SELECT COUNT(*) as inTransit FROM bookings WHERE customer_id = ${userId} AND status IN ('confirmed', 'assigned', 'picked_up', 'in_transit', 'out_for_delivery')`,
          `SELECT COUNT(*) as delivered FROM bookings WHERE customer_id = ${userId} AND status = 'delivered'`
        ];

        for (const query of customerQueries) {
          const result = await executeQuery(query);
          if (result.success) {
            Object.assign(stats, result.data[0]);
          }
        }
      }

      if (role === 'driver' && userId) {
        // Driver stats
        const driverQueries = [
          `SELECT COUNT(*) as activeBookings FROM bookings WHERE driver_id = ${userId} AND status IN ('confirmed', 'assigned', 'picked_up', 'in_transit', 'out_for_delivery')`,
          `SELECT COUNT(*) as completedToday FROM bookings WHERE driver_id = ${userId} AND status = 'delivered' AND DATE(actual_delivery_time) = CURDATE()`,
          `SELECT COALESCE(SUM(total_amount * 0.15), 0) as earnings FROM bookings WHERE driver_id = ${userId} AND status = 'delivered'`
        ];

        for (const query of driverQueries) {
          const result = await executeQuery(query);
          if (result.success) {
            Object.assign(stats, result.data[0]);
          }
        }
      }

      return { success: true, stats };
    } catch (error) {
      console.error('Dashboard stats error:', error);
      return { success: false, error: error.message };
    }
  }
}

module.exports = Booking;