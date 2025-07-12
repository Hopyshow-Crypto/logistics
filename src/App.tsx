import React from 'react';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { Header } from './components/Layout/Header';
import { LoginForm } from './components/Auth/LoginForm';
import { CustomerDashboard } from './components/Customer/CustomerDashboard';
import { DriverDashboard } from './components/Driver/DriverDashboard';
import { AdminDashboard } from './components/Admin/AdminDashboard';

const AppContent: React.FC = () => {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!user) {
    return <LoginForm />;
  }

  const renderDashboard = () => {
    switch (user.role) {
      case 'admin':
        return <AdminDashboard />;
      case 'driver':
        return <DriverDashboard />;
      default:
        return <CustomerDashboard />;
    }
  };

  return (
    <div className="min-h-screen bg-gray-100">
      <Header />
      <main className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        {renderDashboard()}
      </main>
    </div>
  );
};

function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}

export default App;