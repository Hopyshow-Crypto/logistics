const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

class ApiService {
  private getAuthHeaders(): HeadersInit {
    const token = localStorage.getItem('auth_token');
    return {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` })
    };
  }

  private async handleResponse<T>(response: Response): Promise<ApiResponse<T>> {
    try {
      const data = await response.json();
      
      if (!response.ok) {
        return {
          success: false,
          error: data.error || 'An error occurred'
        };
      }
      
      return {
        success: true,
        data: data.data || data,
        message: data.message
      };
    } catch (error) {
      return {
        success: false,
        error: 'Network error or invalid response'
      };
    }
  }

  // Authentication endpoints
  async login(email: string, password: string): Promise<ApiResponse<{ user: any; token: string }>> {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });

    const result = await this.handleResponse<{ user: any; token: string }>(response);
    
    if (result.success && result.data?.token) {
      localStorage.setItem('auth_token', result.data.token);
      localStorage.setItem('user', JSON.stringify(result.data.user));
    }
    
    return result;
  }

  async register(userData: {
    email: string;
    password: string;
    name: string;
    phone: string;
    role?: string;
  }): Promise<ApiResponse<{ userId: number }>> {
    const response = await fetch(`${API_BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userData)
    });

    return this.handleResponse<{ userId: number }>(response);
  }

  async getProfile(): Promise<ApiResponse<any>> {
    const response = await fetch(`${API_BASE_URL}/auth/profile`, {
      headers: this.getAuthHeaders()
    });

    return this.handleResponse(response);
  }

  async updateProfile(profileData: { name: string; phone: string }): Promise<ApiResponse> {
    const response = await fetch(`${API_BASE_URL}/auth/profile`, {
      method: 'PUT',
      headers: this.getAuthHeaders(),
      body: JSON.stringify(profileData)
    });

    return this.handleResponse(response);
  }

  logout(): void {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user');
  }

  // Booking endpoints
  async createBooking(bookingData: any): Promise<ApiResponse<{ booking: any }>> {
    const response = await fetch(`${API_BASE_URL}/bookings`, {
      method: 'POST',
      headers: this.getAuthHeaders(),
      body: JSON.stringify(bookingData)
    });

    return this.handleResponse<{ booking: any }>(response);
  }

  async getBookings(): Promise<ApiResponse<{ bookings: any[] }>> {
    const response = await fetch(`${API_BASE_URL}/bookings`, {
      headers: this.getAuthHeaders()
    });

    return this.handleResponse<{ bookings: any[] }>(response);
  }

  async trackBooking(trackingNumber: string): Promise<ApiResponse<{ booking: any }>> {
    const response = await fetch(`${API_BASE_URL}/bookings/track/${trackingNumber}`);

    return this.handleResponse<{ booking: any }>(response);
  }

  async updateBookingStatus(
    bookingId: string, 
    status: string, 
    notes?: string
  ): Promise<ApiResponse> {
    const response = await fetch(`${API_BASE_URL}/bookings/${bookingId}/status`, {
      method: 'PUT',
      headers: this.getAuthHeaders(),
      body: JSON.stringify({ status, notes })
    });

    return this.handleResponse(response);
  }

  async assignDriver(bookingId: string, driverId: string): Promise<ApiResponse> {
    const response = await fetch(`${API_BASE_URL}/bookings/${bookingId}/assign-driver`, {
      method: 'PUT',
      headers: this.getAuthHeaders(),
      body: JSON.stringify({ driverId })
    });

    return this.handleResponse(response);
  }

  async getDashboardStats(): Promise<ApiResponse<{ stats: any }>> {
    const response = await fetch(`${API_BASE_URL}/bookings/stats`, {
      headers: this.getAuthHeaders()
    });

    return this.handleResponse<{ stats: any }>(response);
  }

  // Utility method to check if user is authenticated
  isAuthenticated(): boolean {
    return !!localStorage.getItem('auth_token');
  }

  // Get stored user data
  getStoredUser(): any {
    const userData = localStorage.getItem('user');
    return userData ? JSON.parse(userData) : null;
  }
}

export const apiService = new ApiService();
export default apiService;