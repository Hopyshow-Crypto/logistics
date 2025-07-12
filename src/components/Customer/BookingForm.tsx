import React, { useState } from 'react';
import { MapPin, Package, CreditCard, Calendar, Plus, Minus } from 'lucide-react';
import { Booking, BookingItem } from '../../types';
import { useAuth } from '../../contexts/AuthContext';

interface BookingFormProps {
  onSubmit: (booking: Omit<Booking, 'id' | 'trackingNumber'>) => void;
  onCancel: () => void;
}

export const BookingForm: React.FC<BookingFormProps> = ({ onSubmit, onCancel }) => {
  const { user } = useAuth();
  const [items, setItems] = useState<Omit<BookingItem, 'id'>[]>([
    { description: '', weight: 0, value: 0, quantity: 1, category: 'package' }
  ]);
  
  const [formData, setFormData] = useState({
    pickup: {
      address: '',
      contactName: '',
      contactPhone: ''
    },
    delivery: {
      address: '',
      contactName: '',
      contactPhone: ''
    },
    service: 'standard' as const,
    paymentMethod: 'online' as const,
    scheduledDate: '',
    notes: ''
  });

  const addItem = () => {
    setItems([...items, { description: '', weight: 0, value: 0, quantity: 1, category: 'package' }]);
  };

  const removeItem = (index: number) => {
    setItems(items.filter((_, i) => i !== index));
  };

  const updateItem = (index: number, field: keyof Omit<BookingItem, 'id'>, value: any) => {
    const updatedItems = [...items];
    updatedItems[index] = { ...updatedItems[index], [field]: value };
    setItems(updatedItems);
  };

  const calculateTotal = () => {
    const baseRates = { express: 30, standard: 20, economy: 15 };
    const weightTotal = items.reduce((sum, item) => sum + (item.weight * item.quantity), 0);
    const baseRate = baseRates[formData.service];
    return baseRate + (weightTotal * 2.5);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    const bookingItems: BookingItem[] = items.map((item, index) => ({
      ...item,
      id: `item_${index}`
    }));

    const totalWeight = items.reduce((sum, item) => sum + (item.weight * item.quantity), 0);
    const totalValue = items.reduce((sum, item) => sum + (item.value * item.quantity), 0);

    const booking: Omit<Booking, 'id' | 'trackingNumber'> = {
      customerId: user!.id,
      customerName: user!.name,
      customerPhone: user!.phone,
      pickup: {
        address: formData.pickup.address,
        coordinates: { lat: 0, lng: 0 }, // In production, get from geocoding
        contactName: formData.pickup.contactName,
        contactPhone: formData.pickup.contactPhone
      },
      delivery: {
        address: formData.delivery.address,
        coordinates: { lat: 0, lng: 0 }, // In production, get from geocoding
        contactName: formData.delivery.contactName,
        contactPhone: formData.delivery.contactPhone
      },
      items: bookingItems,
      totalWeight,
      totalValue,
      service: formData.service,
      status: 'pending',
      paymentMethod: formData.paymentMethod,
      paymentStatus: formData.paymentMethod === 'online' ? 'paid' : 'pending',
      amount: calculateTotal(),
      bookingDate: new Date().toISOString(),
      scheduledDate: formData.scheduledDate,
      notes: formData.notes
    };

    onSubmit(booking);
  };

  return (
    <div className="bg-white rounded-lg shadow-lg p-6">
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Create New Booking</h2>
        <p className="text-gray-600">Fill in the details for your transportation request</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Pickup Information */}
        <div className="bg-green-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold text-green-800 mb-4 flex items-center">
            <MapPin className="h-5 w-5 mr-2" />
            Pickup Information
          </h3>
          <div className="grid md:grid-cols-2 gap-4">
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Pickup Address *
              </label>
              <input
                type="text"
                required
                value={formData.pickup.address}
                onChange={(e) => setFormData(prev => ({
                  ...prev,
                  pickup: { ...prev.pickup, address: e.target.value }
                }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                placeholder="Enter pickup address"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Contact Name
              </label>
              <input
                type="text"
                value={formData.pickup.contactName}
                onChange={(e) => setFormData(prev => ({
                  ...prev,
                  pickup: { ...prev.pickup, contactName: e.target.value }
                }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                placeholder="Contact person name"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Contact Phone
              </label>
              <input
                type="tel"
                value={formData.pickup.contactPhone}
                onChange={(e) => setFormData(prev => ({
                  ...prev,
                  pickup: { ...prev.pickup, contactPhone: e.target.value }
                }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                placeholder="Contact phone number"
              />
            </div>
          </div>
        </div>

        {/* Delivery Information */}
        <div className="bg-blue-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold text-blue-800 mb-4 flex items-center">
            <MapPin className="h-5 w-5 mr-2" />
            Delivery Information
          </h3>
          <div className="grid md:grid-cols-2 gap-4">
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Delivery Address *
              </label>
              <input
                type="text"
                required
                value={formData.delivery.address}
                onChange={(e) => setFormData(prev => ({
                  ...prev,
                  delivery: { ...prev.delivery, address: e.target.value }
                }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Enter delivery address"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Contact Name
              </label>
              <input
                type="text"
                value={formData.delivery.contactName}
                onChange={(e) => setFormData(prev => ({
                  ...prev,
                  delivery: { ...prev.delivery, contactName: e.target.value }
                }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Contact person name"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Contact Phone
              </label>
              <input
                type="tel"
                value={formData.delivery.contactPhone}
                onChange={(e) => setFormData(prev => ({
                  ...prev,
                  delivery: { ...prev.delivery, contactPhone: e.target.value }
                }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Contact phone number"
              />
            </div>
          </div>
        </div>

        {/* Items */}
        <div className="bg-orange-50 p-4 rounded-lg">
          <h3 className="text-lg font-semibold text-orange-800 mb-4 flex items-center">
            <Package className="h-5 w-5 mr-2" />
            Items to Transport
          </h3>
          {items.map((item, index) => (
            <div key={index} className="bg-white p-4 rounded-lg mb-4 border">
              <div className="flex justify-between items-center mb-3">
                <h4 className="font-medium text-gray-900">Item {index + 1}</h4>
                {items.length > 1 && (
                  <button
                    type="button"
                    onClick={() => removeItem(index)}
                    className="text-red-600 hover:text-red-800"
                  >
                    <Minus className="h-4 w-4" />
                  </button>
                )}
              </div>
              <div className="grid md:grid-cols-4 gap-3">
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Description *
                  </label>
                  <input
                    type="text"
                    required
                    value={item.description}
                    onChange={(e) => updateItem(index, 'description', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500"
                    placeholder="Describe the item"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Category
                  </label>
                  <select
                    value={item.category}
                    onChange={(e) => updateItem(index, 'category', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500"
                  >
                    <option value="package">Package</option>
                    <option value="document">Document</option>
                    <option value="fragile">Fragile</option>
                    <option value="electronics">Electronics</option>
                    <option value="other">Other</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Quantity
                  </label>
                  <input
                    type="number"
                    min="1"
                    value={item.quantity}
                    onChange={(e) => updateItem(index, 'quantity', parseInt(e.target.value))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Weight (kg)
                  </label>
                  <input
                    type="number"
                    step="0.1"
                    min="0"
                    value={item.weight}
                    onChange={(e) => updateItem(index, 'weight', parseFloat(e.target.value))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Value ($)
                  </label>
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    value={item.value}
                    onChange={(e) => updateItem(index, 'value', parseFloat(e.target.value))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500"
                  />
                </div>
              </div>
            </div>
          ))}
          <button
            type="button"
            onClick={addItem}
            className="flex items-center space-x-2 text-orange-600 hover:text-orange-800 font-medium"
          >
            <Plus className="h-4 w-4" />
            <span>Add Another Item</span>
          </button>
        </div>

        {/* Service and Payment */}
        <div className="grid md:grid-cols-2 gap-6">
          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Service Type</h3>
            <div className="space-y-3">
              {[
                { value: 'express', label: 'Express (Same Day)', price: '$30 base' },
                { value: 'standard', label: 'Standard (1-2 Days)', price: '$20 base' },
                { value: 'economy', label: 'Economy (3-5 Days)', price: '$15 base' }
              ].map((service) => (
                <label key={service.value} className="flex items-center space-x-3 cursor-pointer">
                  <input
                    type="radio"
                    name="service"
                    value={service.value}
                    checked={formData.service === service.value}
                    onChange={(e) => setFormData(prev => ({ ...prev, service: e.target.value as any }))}
                    className="text-blue-600 focus:ring-blue-500"
                  />
                  <div>
                    <div className="font-medium text-gray-900">{service.label}</div>
                    <div className="text-sm text-gray-500">{service.price}</div>
                  </div>
                </label>
              ))}
            </div>
          </div>

          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Payment Method</h3>
            <div className="space-y-3">
              {[
                { value: 'online', label: 'Pay Online (Card/Digital)' },
                { value: 'cash_pickup', label: 'Cash at Pickup' },
                { value: 'cash_delivery', label: 'Cash on Delivery' }
              ].map((method) => (
                <label key={method.value} className="flex items-center space-x-3 cursor-pointer">
                  <input
                    type="radio"
                    name="paymentMethod"
                    value={method.value}
                    checked={formData.paymentMethod === method.value}
                    onChange={(e) => setFormData(prev => ({ ...prev, paymentMethod: e.target.value as any }))}
                    className="text-blue-600 focus:ring-blue-500"
                  />
                  <span className="text-gray-900">{method.label}</span>
                </label>
              ))}
            </div>
          </div>
        </div>

        {/* Scheduling and Notes */}
        <div className="grid md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Preferred Pickup Date & Time
            </label>
            <input
              type="datetime-local"
              value={formData.scheduledDate}
              onChange={(e) => setFormData(prev => ({ ...prev, scheduledDate: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Special Notes
            </label>
            <textarea
              value={formData.notes}
              onChange={(e) => setFormData(prev => ({ ...prev, notes: e.target.value }))}
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Any special instructions..."
            />
          </div>
        </div>

        {/* Total and Actions */}
        <div className="bg-gray-50 p-4 rounded-lg">
          <div className="flex justify-between items-center mb-4">
            <span className="text-lg font-semibold text-gray-900">Estimated Total:</span>
            <span className="text-2xl font-bold text-blue-600">${calculateTotal().toFixed(2)}</span>
          </div>
          <p className="text-sm text-gray-600">
            * Final price may vary based on actual distance and additional services
          </p>
        </div>

        <div className="flex space-x-4">
          <button
            type="button"
            onClick={onCancel}
            className="flex-1 bg-gray-300 text-gray-700 py-3 px-4 rounded-md hover:bg-gray-400 transition-colors font-medium"
          >
            Cancel
          </button>
          <button
            type="submit"
            className="flex-1 bg-blue-600 text-white py-3 px-4 rounded-md hover:bg-blue-700 transition-colors font-medium"
          >
            Create Booking
          </button>
        </div>
      </form>
    </div>
  );
};