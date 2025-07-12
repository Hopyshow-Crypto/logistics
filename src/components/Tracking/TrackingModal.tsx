import React from 'react';
import { X, MapPin, Clock, User, Phone } from 'lucide-react';
import { useBookings } from '../../hooks/useBookings';

interface TrackingModalProps {
  bookingId: string;
  onClose: () => void;
}

export const TrackingModal: React.FC<TrackingModalProps> = ({ bookingId, onClose }) => {
  const { bookings } = useBookings();
  const booking = bookings.find(b => b.id === bookingId);

  if (!booking) return null;

  const trackingSteps = [
    { status: 'pending', label: 'Booking Created', time: booking.bookingDate },
    { status: 'confirmed', label: 'Booking Confirmed', time: booking.status !== 'pending' ? booking.bookingDate : null },
    { status: 'picked_up', label: 'Package Picked Up', time: ['picked_up', 'in_transit', 'delivered'].includes(booking.status) ? booking.bookingDate : null },
    { status: 'in_transit', label: 'In Transit', time: ['in_transit', 'delivered'].includes(booking.status) ? booking.bookingDate : null },
    { status: 'delivered', label: 'Delivered', time: booking.status === 'delivered' ? booking.bookingDate : null },
  ];

  const getCurrentStepIndex = () => {
    switch (booking.status) {
      case 'pending': return 0;
      case 'confirmed': return 1;
      case 'picked_up': return 2;
      case 'in_transit': return 3;
      case 'delivered': return 4;
      default: return 0;
    }
  };

  const currentStep = getCurrentStepIndex();

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center p-6 border-b border-gray-200">
          <div>
            <h2 className="text-xl font-bold text-gray-900">Track Package</h2>
            <p className="text-gray-600">#{booking.trackingNumber}</p>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            <X className="h-6 w-6" />
          </button>
        </div>

        <div className="p-6 space-y-6">
          {/* Current Status */}
          <div className="bg-blue-50 p-4 rounded-lg">
            <div className="flex items-center space-x-3">
              <div className="bg-blue-600 text-white p-2 rounded-full">
                <MapPin className="h-5 w-5" />
              </div>
              <div>
                <h3 className="font-semibold text-blue-900">
                  {booking.status === 'delivered' ? 'Package Delivered' : 
                   booking.status === 'in_transit' ? 'Package In Transit' :
                   booking.status === 'picked_up' ? 'Package Picked Up' :
                   booking.status === 'confirmed' ? 'Booking Confirmed' : 'Booking Pending'}
                </h3>
                <p className="text-blue-700 text-sm">
                  {new Date(booking.bookingDate).toLocaleString()}
                </p>
              </div>
            </div>
          </div>

          {/* Progress Steps */}
          <div className="space-y-4">
            <h3 className="font-semibold text-gray-900">Tracking Progress</h3>
            <div className="space-y-4">
              {trackingSteps.map((step, index) => (
                <div key={step.status} className="flex items-center space-x-4">
                  <div className={`w-8 h-8 rounded-full flex items-center justify-center ${
                    index <= currentStep 
                      ? 'bg-green-600 text-white' 
                      : 'bg-gray-200 text-gray-400'
                  }`}>
                    {index <= currentStep ? (
                      <div className="w-3 h-3 bg-white rounded-full"></div>
                    ) : (
                      <div className="w-3 h-3 bg-gray-400 rounded-full"></div>
                    )}
                  </div>
                  <div className="flex-1">
                    <p className={`font-medium ${index <= currentStep ? 'text-gray-900' : 'text-gray-400'}`}>
                      {step.label}
                    </p>
                    {step.time && (
                      <p className="text-sm text-gray-500">
                        {new Date(step.time).toLocaleString()}
                      </p>
                    )}
                  </div>
                  <div className={`w-2 h-8 ${index < trackingSteps.length - 1 ? 'border-l-2' : ''} ${
                    index < currentStep ? 'border-green-600' : 'border-gray-200'
                  }`}></div>
                </div>
              ))}
            </div>
          </div>

          {/* Package Details */}
          <div className="grid md:grid-cols-2 gap-6">
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900">Pickup Details</h3>
              <div className="bg-green-50 p-4 rounded-lg">
                <div className="flex items-start space-x-3">
                  <MapPin className="h-5 w-5 text-green-600 mt-0.5" />
                  <div>
                    <p className="font-medium text-green-900">{booking.pickup.address}</p>
                    {booking.pickup.contactName && (
                      <p className="text-sm text-green-700 flex items-center space-x-1">
                        <User className="h-4 w-4" />
                        <span>{booking.pickup.contactName}</span>
                      </p>
                    )}
                    {booking.pickup.contactPhone && (
                      <p className="text-sm text-green-700 flex items-center space-x-1">
                        <Phone className="h-4 w-4" />
                        <span>{booking.pickup.contactPhone}</span>
                      </p>
                    )}
                  </div>
                </div>
              </div>
            </div>

            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900">Delivery Details</h3>
              <div className="bg-blue-50 p-4 rounded-lg">
                <div className="flex items-start space-x-3">
                  <MapPin className="h-5 w-5 text-blue-600 mt-0.5" />
                  <div>
                    <p className="font-medium text-blue-900">{booking.delivery.address}</p>
                    {booking.delivery.contactName && (
                      <p className="text-sm text-blue-700 flex items-center space-x-1">
                        <User className="h-4 w-4" />
                        <span>{booking.delivery.contactName}</span>
                      </p>
                    )}
                    {booking.delivery.contactPhone && (
                      <p className="text-sm text-blue-700 flex items-center space-x-1">
                        <Phone className="h-4 w-4" />
                        <span>{booking.delivery.contactPhone}</span>
                      </p>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Driver Info */}
          {booking.driverName && (
            <div className="bg-gray-50 p-4 rounded-lg">
              <h3 className="font-semibold text-gray-900 mb-2">Driver Information</h3>
              <div className="flex items-center space-x-3">
                <div className="bg-gray-300 rounded-full p-2">
                  <User className="h-5 w-5 text-gray-600" />
                </div>
                <div>
                  <p className="font-medium text-gray-900">{booking.driverName}</p>
                  <p className="text-sm text-gray-600">Your assigned driver</p>
                </div>
              </div>
            </div>
          )}

          {/* Items List */}
          <div className="space-y-4">
            <h3 className="font-semibold text-gray-900">Package Items</h3>
            <div className="space-y-2">
              {booking.items.map((item, index) => (
                <div key={item.id} className="bg-gray-50 p-3 rounded-lg">
                  <div className="flex justify-between items-start">
                    <div>
                      <p className="font-medium text-gray-900">{item.description}</p>
                      <p className="text-sm text-gray-600">
                        {item.quantity}x | {item.weight}kg | ${item.value}
                      </p>
                    </div>
                    <span className="text-xs bg-gray-200 text-gray-700 px-2 py-1 rounded">
                      {item.category}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Service Details */}
          <div className="grid md:grid-cols-2 gap-4 pt-4 border-t border-gray-200">
            <div>
              <p className="text-sm text-gray-600">Service Type</p>
              <p className="font-medium text-gray-900 capitalize">{booking.service}</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Total Amount</p>
              <p className="font-medium text-gray-900">${booking.amount.toFixed(2)}</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Payment Method</p>
              <p className="font-medium text-gray-900 capitalize">{booking.paymentMethod.replace('_', ' ')}</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Payment Status</p>
              <p className={`font-medium capitalize ${
                booking.paymentStatus === 'paid' ? 'text-green-600' : 'text-yellow-600'
              }`}>
                {booking.paymentStatus}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};