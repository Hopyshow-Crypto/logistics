import React, { useState } from 'react';
import { MapPin, Clock, CheckCircle, Navigation, Phone } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';
import { useBookings } from '../../hooks/useBookings';

export const DriverDashboard: React.FC = () => {
  const { user } = useAuth();
  const { bookings, isLoading, updateBookingStatus } = useBookings(user?.id, user?.role);
  const [selectedBooking, setSelectedBooking] = useState<string | null>(null);

  const myBookings = bookings.filter(b => b.driverId === user?.id);
  const activeBookings = myBookings.filter(b => ['confirmed', 'picked_up', 'in_transit'].includes(b.status));
  const completedToday = myBookings.filter(b => 
    b.status === 'delivered' && 
    new Date(b.bookingDate).toDateString() === new Date().toDateString()
  );

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'confirmed': return 'bg-blue-100 text-blue-800';
      case 'picked_up': return 'bg-purple-100 text-purple-800';
      case 'in_transit': return 'bg-indigo-100 text-indigo-800';
      case 'delivered': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const handleStatusUpdate = (bookingId: string, newStatus: any) => {
    updateBookingStatus(bookingId, newStatus);
  };

  const getNextAction = (status: string) => {
    switch (status) {
      case 'confirmed': return { action: 'picked_up', label: 'Mark as Picked Up' };
      case 'picked_up': return { action: 'in_transit', label: 'Start Transit' };
      case 'in_transit': return { action: 'delivered', label: 'Mark as Delivered' };
      default: return null;
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Driver Dashboard</h1>
          <p className="text-gray-600">Manage your assigned deliveries</p>
        </div>
        <div className="flex items-center space-x-4">
          <div className="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-medium">
            Online
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Active Deliveries</p>
              <p className="text-2xl font-bold text-blue-600">{activeBookings.length}</p>
            </div>
            <MapPin className="h-8 w-8 text-blue-600" />
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Completed Today</p>
              <p className="text-2xl font-bold text-green-600">{completedToday.length}</p>
            </div>
            <CheckCircle className="h-8 w-8 text-green-600" />
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Earnings</p>
              <p className="text-2xl font-bold text-purple-600">
                ${myBookings.filter(b => b.status === 'delivered').reduce((sum, b) => sum + (b.amount * 0.15), 0).toFixed(2)}
              </p>
            </div>
            <Clock className="h-8 w-8 text-purple-600" />
          </div>
        </div>
      </div>

      {/* Active Deliveries */}
      <div className="bg-white rounded-lg shadow-sm border">
        <div className="px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">Active Deliveries</h2>
        </div>
        <div className="divide-y divide-gray-200">
          {isLoading ? (
            <div className="p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
              <p className="mt-2 text-gray-600">Loading deliveries...</p>
            </div>
          ) : activeBookings.length === 0 ? (
            <div className="p-8 text-center">
              <MapPin className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-600">No active deliveries</p>
              <p className="text-sm text-gray-500 mt-1">Check back later for new assignments</p>
            </div>
          ) : (
            activeBookings.map((booking) => {
              const nextAction = getNextAction(booking.status);
              return (
                <div key={booking.id} className="p-6">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-3">
                        <span className="font-semibold text-gray-900">#{booking.trackingNumber}</span>
                        <span className={`inline-flex px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(booking.status)}`}>
                          {booking.status.replace('_', ' ')}
                        </span>
                      </div>
                      
                      <div className="grid md:grid-cols-2 gap-4 mb-4">
                        <div className="bg-green-50 p-3 rounded-lg">
                          <div className="flex items-start space-x-2">
                            <MapPin className="h-4 w-4 text-green-600 mt-0.5" />
                            <div>
                              <p className="text-sm font-medium text-green-900">Pickup</p>
                              <p className="text-sm text-green-700">{booking.pickup.address}</p>
                              {booking.pickup.contactPhone && (
                                <p className="text-xs text-green-600 flex items-center space-x-1 mt-1">
                                  <Phone className="h-3 w-3" />
                                  <span>{booking.pickup.contactPhone}</span>
                                </p>
                              )}
                            </div>
                          </div>
                        </div>
                        
                        <div className="bg-blue-50 p-3 rounded-lg">
                          <div className="flex items-start space-x-2">
                            <MapPin className="h-4 w-4 text-blue-600 mt-0.5" />
                            <div>
                              <p className="text-sm font-medium text-blue-900">Delivery</p>
                              <p className="text-sm text-blue-700">{booking.delivery.address}</p>
                              {booking.delivery.contactPhone && (
                                <p className="text-xs text-blue-600 flex items-center space-x-1 mt-1">
                                  <Phone className="h-3 w-3" />
                                  <span>{booking.delivery.contactPhone}</span>
                                </p>
                              )}
                            </div>
                          </div>
                        </div>
                      </div>

                      <div className="flex items-center space-x-4 text-sm text-gray-600">
                        <span><strong>Customer:</strong> {booking.customerName}</span>
                        <span><strong>Service:</strong> {booking.service}</span>
                        <span><strong>Items:</strong> {booking.items.length}</span>
                      </div>
                    </div>
                    
                    <div className="flex flex-col space-y-2 ml-4">
                      <button className="bg-blue-100 text-blue-700 px-3 py-1 rounded-md hover:bg-blue-200 transition-colors text-sm flex items-center space-x-1">
                        <Navigation className="h-4 w-4" />
                        <span>Navigate</span>
                      </button>
                      {nextAction && (
                        <button
                          onClick={() => handleStatusUpdate(booking.id, nextAction.action)}
                          className="bg-green-600 text-white px-3 py-1 rounded-md hover:bg-green-700 transition-colors text-sm"
                        >
                          {nextAction.label}
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>

      {/* Recent Completed Deliveries */}
      <div className="bg-white rounded-lg shadow-sm border">
        <div className="px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">Recent Completed Deliveries</h2>
        </div>
        <div className="divide-y divide-gray-200">
          {myBookings.filter(b => b.status === 'delivered').slice(0, 5).map((booking) => (
            <div key={booking.id} className="p-4">
              <div className="flex items-center justify-between">
                <div>
                  <span className="font-medium text-gray-900">#{booking.trackingNumber}</span>
                  <p className="text-sm text-gray-600">{booking.pickup.address} → {booking.delivery.address}</p>
                </div>
                <div className="text-right">
                  <p className="text-sm font-medium text-green-600">
                    +${(booking.amount * 0.15).toFixed(2)}
                  </p>
                  <p className="text-xs text-gray-500">Commission</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};