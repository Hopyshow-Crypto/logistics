const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const { authenticateToken, requireRole } = require('../middleware/auth');

// Create new booking
router.post('/', authenticateToken, async (req, res) => {
  try {
    const bookingData = {
      ...req.body,
      customerId: req.user.userId
    };

    // Validation
    if (!bookingData.pickup || !bookingData.delivery || !bookingData.items || !bookingData.serviceType) {
      return res.status(400).json({
        success: false,
        error: 'Missing required booking information'
      });
    }

    if (!bookingData.items.length) {
      return res.status(400).json({
        success: false,
        error: 'At least one item is required'
      });
    }

    const result = await Booking.create(bookingData);

    if (result.success) {
      res.status(201).json({
        success: true,
        message: 'Booking created successfully',
        booking: result.booking
      });
    } else {
      res.status(400).json({
        success: false,
        error: result.error
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// Get user's bookings
router.get('/', authenticateToken, async (req, res) => {
  try {
    const result = await Booking.getByUser(req.user.userId, req.user.role);

    if (result.success) {
      res.json({
        success: true,
        bookings: result.bookings
      });
    } else {
      res.status(400).json({
        success: false,
        error: result.error
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// Get booking by tracking number
router.get('/track/:trackingNumber', async (req, res) => {
  try {
    const { trackingNumber } = req.params;

    const result = await Booking.getByTrackingNumber(trackingNumber);

    if (result.success) {
      res.json({
        success: true,
        booking: result.booking
      });
    } else {
      res.status(404).json({
        success: false,
        error: result.error
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// Update booking status
router.put('/:id/status', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { status, notes } = req.body;

    if (!status) {
      return res.status(400).json({
        success: false,
        error: 'Status is required'
      });
    }

    // Validate status
    const validStatuses = ['pending', 'confirmed', 'picked_up', 'in_transit', 'delivered', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid status'
      });
    }

    const result = await Booking.updateStatus(id, status, req.user.userId, notes);

    if (result.success) {
      res.json({
        success: true,
        message: result.message
      });
    } else {
      res.status(400).json({
        success: false,
        error: result.error
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// Assign driver to booking (admin only)
router.put('/:id/assign-driver', authenticateToken, requireRole(['admin']), async (req, res) => {
  try {
    const { id } = req.params;
    const { driverId } = req.body;

    if (!driverId) {
      return res.status(400).json({
        success: false,
        error: 'Driver ID is required'
      });
    }

    const result = await Booking.assignDriver(id, driverId);

    if (result.success) {
      res.json({
        success: true,
        message: result.message
      });
    } else {
      res.status(400).json({
        success: false,
        error: result.error
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// Get dashboard statistics
router.get('/stats', authenticateToken, async (req, res) => {
  try {
    const result = await Booking.getDashboardStats(req.user.userId, req.user.role);

    if (result.success) {
      res.json({
        success: true,
        stats: result.stats
      });
    } else {
      res.status(400).json({
        success: false,
        error: result.error
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

module.exports = router;