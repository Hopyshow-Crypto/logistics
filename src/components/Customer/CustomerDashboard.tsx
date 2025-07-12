import React, { useState } from 'react';
import { Plus, Package, Clock, CheckCircle, XCircle, Search } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';
import { useBookings } from '../../hooks/useBookings';
import { BookingForm } from './BookingForm';
import { TrackingModal } from '../Tracking/TrackingModal';

export const CustomerDashboard: React.FC = () => {
  const { user } = useAuth();
  const { bookings, isLoading, createBooking } = useBookings(user?.id, user?.role);
  const [showBookingForm, setShowBookingForm] = useState(false);
  const [selectedBooking, setSelectedBooking] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-yellow-100 text-yellow-800';
      case 'confirmed': return 'bg-blue-100 text-blue-800';
      case 'picked_up': return 'bg-purple-100 text-purple-800';
      case 'in_transit': return 'bg-indigo-100 text-indigo-800';
      case 'delivered': return 'bg-green-100 text-green-800';
      case 'cancelled': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'pending': return <Clock className="h-4 w-4" />;
      case 'delivered': return <CheckCircle className="h-4 w-4" />;
      case 'cancelled': return <XCircle className="h-4 w-4" />;
      default: return <Package className="h-4 w-4" />;
    }
  };

  const handleCreateBooking = (bookingData: any) => {
    createBooking(bookingData);
    setShowBookingForm(false);
  };

  const filteredBookings = bookings.filter(booking => 
    booking.trackingNumber.toLowerCase().includes(searchTerm.toLowerCase()) ||
    booking.pickup.address.toLowerCase().includes(searchTerm.toLowerCase()) ||
    booking.delivery.address.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const stats = {
    total: bookings.length,
    pending: bookings.filter(b => b.status === 'pending').length,
    inTransit: bookings.filter(b => ['confirmed', 'picked_up', 'in_transit'].includes(b.status)).length,
    delivered: bookings.filter(b => b.status === 'delivered').length,
  };

  if (showBookingForm) {
    return (
      <BookingForm
        onSubmit={handleCreateBooking}
        onCancel={() => setShowBookingForm(false)}
      />
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">My Bookings</h1>
          <p className="text-gray-600">Track and manage your transportation requests</p>
        </div>
        <button
          onClick={() => setShowBookingForm(true)}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center space-x-2"
        >
          <Plus className="h-5 w-5" />
          <span>New Booking</span>
        </button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Bookings</p>
              <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
            </div>
            <Package className="h-8 w-8 text-blue-600" />
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Pending</p>
              <p className="text-2xl font-bold text-yellow-600">{stats.pending}</p>
            </div>
            <Clock className="h-8 w-8 text-yellow-600" />
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">In Transit</p>
              <p className="text-2xl font-bold text-indigo-600">{stats.inTransit}</p>
            </div>
            <Package className="h-8 w-8 text-indigo-600" />
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Delivered</p>
              <p className="text-2xl font-bold text-green-600">{stats.delivered}</p>
            </div>
            <CheckCircle className="h-8 w-8 text-green-600" />
          </div>
        </div>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
        <input
          type="text"
          placeholder="Search by tracking number, pickup, or delivery address..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

      {/* Bookings List */}
      <div className="bg-white rounded-lg shadow-sm border">
        <div className="px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">Recent Bookings</h2>
        </div>
        <div className="divide-y divide-gray-200">
          {isLoading ? (
            <div className="p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
              <p className="mt-2 text-gray-600">Loading bookings...</p>
            </div>
          ) : filteredBookings.length === 0 ? (
            <div className="p-8 text-center">
              <Package className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-600">No bookings found</p>
              <button
                onClick={() => setShowBookingForm(true)}
                className="mt-4 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
              >
                Create Your First Booking
              </button>
            </div>
          ) : (
            filteredBookings.map((booking) => (
              <div key={booking.id} className="p-6 hover:bg-gray-50">
                <div className="flex items-center justify-between">
                  <div className="flex-1">
                    <div className="flex items-center space-x-3 mb-2">
                      <span className="font-semibold text-gray-900">#{booking.trackingNumber}</span>
                      <span className={`inline-flex items-center space-x-1 px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(booking.status)}`}>
                        {getStatusIcon(booking.status)}
                        <span className="capitalize">{booking.status.replace('_', ' ')}</span>
                      </span>
                    </div>
                    <div className="grid md:grid-cols-2 gap-4 text-sm text-gray-600">
                      <div>
                        <p><strong>From:</strong> {booking.pickup.address}</p>
                        <p><strong>To:</strong> {booking.delivery.address}</p>
                      </div>
                      <div>
                        <p><strong>Service:</strong> {booking.service}</p>
                        <p><strong>Amount:</strong> ${booking.amount.toFixed(2)}</p>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    <button
                      onClick={() => setSelectedBooking(booking.id)}
                      className="bg-blue-100 text-blue-700 px-3 py-1 rounded-md hover:bg-blue-200 transition-colors text-sm"
                    >
                      Track
                    </button>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      </div>

      {/* Tracking Modal */}
      {selectedBooking && (
        <TrackingModal
          bookingId={selectedBooking}
          onClose={() => setSelectedBooking(null)}
        />
      )}
    </div>
  );
};