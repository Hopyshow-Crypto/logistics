const { executeQuery } = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

class User {
  // Create new user
  static async create(userData) {
    const { email, password, name, phone, role = 'customer' } = userData;
    
    try {
      // Hash password
      const saltRounds = 12;
      const passwordHash = await bcrypt.hash(password, saltRounds);
      
      const query = `
        INSERT INTO users (email, password_hash, name, phone, role)
        VALUES (?, ?, ?, ?, ?)
      `;
      
      const result = await executeQuery(query, [email, passwordHash, name, phone, role]);
      
      if (result.success) {
        return { success: true, userId: result.data.insertId };
      }
      
      return { success: false, error: result.error };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Authenticate user
  static async authenticate(email, password) {
    try {
      const query = `
        SELECT id, email, password_hash, name, phone, role, status
        FROM users 
        WHERE email = ? AND status = 'active'
      `;
      
      const result = await executeQuery(query, [email]);
      
      if (!result.success || result.data.length === 0) {
        return { success: false, error: 'Invalid credentials' };
      }
      
      const user = result.data[0];
      const isValidPassword = await bcrypt.compare(password, user.password_hash);
      
      if (!isValidPassword) {
        return { success: false, error: 'Invalid credentials' };
      }
      
      // Generate JWT token
      const token = jwt.sign(
        { userId: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET || 'your-secret-key',
        { expiresIn: '24h' }
      );
      
      // Remove password hash from response
      delete user.password_hash;
      
      return { 
        success: true, 
        user, 
        token 
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Get user by ID
  static async findById(userId) {
    try {
      const query = `
        SELECT id, email, name, phone, role, status, created_at
        FROM users 
        WHERE id = ?
      `;
      
      const result = await executeQuery(query, [userId]);
      
      if (result.success && result.data.length > 0) {
        return { success: true, user: result.data[0] };
      }
      
      return { success: false, error: 'User not found' };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Update user profile
  static async updateProfile(userId, updateData) {
    try {
      const { name, phone } = updateData;
      
      const query = `
        UPDATE users 
        SET name = ?, phone = ?, updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `;
      
      const result = await executeQuery(query, [name, phone, userId]);
      
      if (result.success) {
        return { success: true, message: 'Profile updated successfully' };
      }
      
      return { success: false, error: result.error };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Get all users (admin only)
  static async getAll(filters = {}) {
    try {
      let query = `
        SELECT id, email, name, phone, role, status, created_at
        FROM users
      `;
      
      const conditions = [];
      const params = [];
      
      if (filters.role) {
        conditions.push('role = ?');
        params.push(filters.role);
      }
      
      if (filters.status) {
        conditions.push('status = ?');
        params.push(filters.status);
      }
      
      if (conditions.length > 0) {
        query += ' WHERE ' + conditions.join(' AND ');
      }
      
      query += ' ORDER BY created_at DESC';
      
      const result = await executeQuery(query, params);
      
      if (result.success) {
        return { success: true, users: result.data };
      }
      
      return { success: false, error: result.error };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Update user status
  static async updateStatus(userId, status) {
    try {
      const query = `
        UPDATE users 
        SET status = ?, updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `;
      
      const result = await executeQuery(query, [status, userId]);
      
      if (result.success) {
        return { success: true, message: 'User status updated successfully' };
      }
      
      return { success: false, error: result.error };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
}

module.exports = User;