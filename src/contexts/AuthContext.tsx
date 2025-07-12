import React, { createContext, useContext, useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { User } from '../types';

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<boolean>;
  register: (userData: Omit<User, 'id' | 'createdAt'>) => Promise<boolean>;
  logout: () => void;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Check for stored user session and validate token
    const initializeAuth = async () => {
      if (apiService.isAuthenticated()) {
        const storedUser = apiService.getStoredUser();
        if (storedUser) {
          // Validate token by fetching profile
          const result = await apiService.getProfile();
          if (result.success) {
            setUser(result.data);
          } else {
            // Token is invalid, clear storage
            apiService.logout();
          }
        }
      }
      setIsLoading(false);
    };

    initializeAuth();
  }, []);

  const login = async (email: string, password: string): Promise<boolean> => {
    try {
      const result = await apiService.login(email, password);
      
      if (result.success && result.data) {
        setUser(result.data.user);
        return true;
      }
      
      return false;
    } catch (error) {
      console.error('Login error:', error);
      return false;
    }
  };

  const register = async (userData: Omit<User, 'id' | 'createdAt'>): Promise<boolean> => {
    try {
      const result = await apiService.register({
        email: userData.email,
        password: 'temp_password', // This should come from the form
        name: userData.name,
        phone: userData.phone,
        role: userData.role
      });
      
      return result.success;
    } catch (error) {
      console.error('Registration error:', error);
      return false;
    }
  };

  const logout = () => {
    apiService.logout();
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, register, logout, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
};