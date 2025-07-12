import React from 'react';
import { LogOut, User, Truck, Package } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';

export const Header: React.FC = () => {
  const { user, logout } = useAuth();

  const getRoleIcon = () => {
    switch (user?.role) {
      case 'admin':
        return <User className="h-5 w-5" />;
      case 'driver':
        return <Truck className="h-5 w-5" />;
      default:
        return <Package className="h-5 w-5" />;
    }
  };

  const getRoleName = () => {
    switch (user?.role) {
      case 'admin':
        return 'Administrator';
      case 'driver':
        return 'Driver';
      default:
        return 'Customer';
    }
  };

  return (
    <header className="bg-white shadow-sm border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center">
            <div className="flex items-center space-x-2">
              <Truck className="h-8 w-8 text-blue-600" />
              <h1 className="text-xl font-bold text-gray-900">LogiFlow</h1>
            </div>
          </div>
          
          {user && (
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2 px-3 py-1 bg-blue-50 rounded-full">
                {getRoleIcon()}
                <span className="text-sm font-medium text-blue-700">{getRoleName()}</span>
              </div>
              <div className="text-sm text-gray-600">
                {user.name}
              </div>
              <button
                onClick={logout}
                className="flex items-center space-x-1 text-sm text-gray-500 hover:text-red-600 transition-colors"
              >
                <LogOut className="h-4 w-4" />
                <span>Logout</span>
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};