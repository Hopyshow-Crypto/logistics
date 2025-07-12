export interface User {
  id: string;
  email: string;
  name: string;
  phone: string;
  role: 'customer' | 'driver' | 'admin';
  createdAt: string;
}

export interface Location {
  address: string;
  coordinates: {
    lat: number;
    lng: number;
  };
  contactName?: string;
  contactPhone?: string;
}

export interface Booking {
  id: string;
  customerId: string;
  customerName: string;
  customerPhone: string;
  pickup: Location;
  delivery: Location;
  items: BookingItem[];
  totalWeight: number;
  totalValue: number;
  service: 'express' | 'standard' | 'economy';
  status: 'pending' | 'confirmed' | 'picked_up' | 'in_transit' | 'delivered' | 'cancelled';
  driverId?: string;
  driverName?: string;
  paymentMethod: 'online' | 'cash_pickup' | 'cash_delivery';
  paymentStatus: 'pending' | 'paid' | 'refunded';
  amount: number;
  bookingDate: string;
  scheduledDate: string;
  trackingNumber: string;
  notes?: string;
}

export interface BookingItem {
  id: string;
  description: string;
  weight: number;
  value: number;
  quantity: number;
  category: 'document' | 'package' | 'fragile' | 'electronics' | 'other';
}

export interface Driver {
  id: string;
  name: string;
  email: string;
  phone: string;
  licenseNumber: string;
  vehicleType: string;
  vehicleNumber: string;
  status: 'available' | 'busy' | 'offline';
  currentLocation?: {
    lat: number;
    lng: number;
  };
  rating: number;
  completedDeliveries: number;
}

export interface TrackingUpdate {
  id: string;
  bookingId: string;
  status: string;
  location: string;
  timestamp: string;
  notes?: string;
  driverName?: string;
}