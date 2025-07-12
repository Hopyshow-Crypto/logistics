import { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { Booking } from '../types';

export const useBookings = (userId?: string, role?: string) => {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchBookings = async () => {
      try {
        const result = await apiService.getBookings();
        
        if (result.success && result.data) {
          setBookings(result.data.bookings || []);
        } else {
          console.error('Failed to fetch bookings:', result.error);
          setBookings([]);
        }
      } catch (error) {
        console.error('Error fetching bookings:', error);
        setBookings([]);
      } finally {
        setIsLoading(false);
      }
    };

    if (apiService.isAuthenticated()) {
      fetchBookings();
    } else {
      setIsLoading(false);
    }
  }, [userId, role]);

  const createBooking = async (bookingData: Omit<Booking, 'id' | 'trackingNumber'>) => {
    try {
      const result = await apiService.createBooking(bookingData);
      
      if (result.success && result.data) {
        // Refresh bookings list
        const bookingsResult = await apiService.getBookings();
        if (bookingsResult.success && bookingsResult.data) {
          setBookings(bookingsResult.data.bookings || []);
        }
        
        return result.data.booking;
      } else {
        throw new Error(result.error || 'Failed to create booking');
      }
    } catch (error) {
      console.error('Error creating booking:', error);
      throw error;
    }
  };

  const updateBookingStatus = async (bookingId: string, status: Booking['status'], notes?: string) => {
    try {
      const result = await apiService.updateBookingStatus(bookingId, status, notes);
      
      if (result.success) {
        // Update local state
        setBookings(prev => 
          prev.map(booking => 
            booking.id === bookingId 
              ? { ...booking, status }
              : booking
          )
        );
      } else {
        throw new Error(result.error || 'Failed to update booking status');
      }
    } catch (error) {
      console.error('Error updating booking status:', error);
      throw error;
    }
  };

  return {
    bookings,
    isLoading,
    createBooking,
    updateBookingStatus
  };
};