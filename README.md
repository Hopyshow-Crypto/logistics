# LogiFlow - Professional Transportation & Logistics Platform

A comprehensive web application for managing transportation and logistics operations, including booking, dispatch tracking, payment processing, and administrative management.

## 🚀 Features

### Customer Features
- **Easy Booking System**: Create transportation requests with pickup/delivery locations
- **Real-time Tracking**: Track packages with live status updates
- **Multiple Payment Options**: Online payments, cash on pickup, or cash on delivery
- **Service Types**: Express, Standard, and Economy delivery options
- **Item Management**: Detailed item descriptions with categories and values

### Driver Features
- **Driver Dashboard**: Manage assigned deliveries and routes
- **Status Updates**: Update delivery status in real-time
- **Earnings Tracking**: Monitor completed deliveries and earnings
- **Navigation Integration**: Direct links to navigation apps

### Admin Features
- **Comprehensive Dashboard**: Overview of all operations and statistics
- **Booking Management**: Assign drivers and manage all bookings
- **User Management**: Handle customer and driver accounts
- **Financial Reports**: Revenue tracking and payment management

## 🛠 Technology Stack

### Frontend
- **React 18** with TypeScript
- **Tailwind CSS** for styling
- **Lucide React** for icons
- **Vite** for build tooling

### Backend
- **Node.js** with Express.js
- **MySQL** database with connection pooling
- **JWT** authentication
- **bcryptjs** for password hashing
- **Rate limiting** and security middleware

### Database
- **MySQL 8.0+** with optimized schema
- **Indexed queries** for performance
- **Transaction support** for data integrity
- **Views** for complex queries

## 📋 Prerequisites

- Node.js 16.0 or higher
- MySQL 8.0 or higher
- npm or yarn package manager

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd logiflow-transport
```

### 2. Database Setup
```bash
# Create MySQL database
mysql -u root -p
CREATE DATABASE logiflow_transport;
exit

# Import database schema
mysql -u root -p logiflow_transport < database/schema.sql
```

### 3. Backend Setup
```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env file with your database credentials
# DB_HOST=localhost
# DB_USER=root
# DB_PASSWORD=your_password
# DB_NAME=logiflow_transport
# JWT_SECRET=your_super_secret_jwt_key

# Start backend server
npm run dev
```

### 4. Frontend Setup
```bash
# Navigate to project root
cd ..

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env file
# VITE_API_URL=http://localhost:5000/api

# Start frontend development server
npm run dev
```

## 🔧 Configuration

### Environment Variables

#### Backend (.env)
```env
# Database
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=logiflow_transport
DB_PORT=3306

# JWT
JWT_SECRET=your_super_secret_jwt_key

# Server
PORT=5000
NODE_ENV=development

# CORS
FRONTEND_URL=http://localhost:5173
```

#### Frontend (.env)
```env
VITE_API_URL=http://localhost:5000/api
VITE_APP_NAME=LogiFlow Transport
```

## 📊 Database Schema

The database files are located in the `database/` folder:

- **`database/01_schema.sql`** - Complete database schema with 11 professional tables
- **`database/02_seed_data.sql`** - Sample data with demo users and realistic bookings
- **`database/03_procedures_functions.sql`** - Stored procedures and business logic functions
- **`database/README.md`** - Comprehensive setup guide and documentation

### Setup Instructions

#### Option 1: phpMyAdmin (Recommended)
1. Create database `logiflow_transport` in phpMyAdmin
2. Import files in order: `01_schema.sql` → `02_seed_data.sql` → `03_procedures_functions.sql`

#### Option 2: MySQL Command Line
```bash
mysql -u root -p -e "CREATE DATABASE logiflow_transport;"
mysql -u root -p logiflow_transport < database/01_schema.sql
mysql -u root -p logiflow_transport < database/02_seed_data.sql
mysql -u root -p logiflow_transport < database/03_procedures_functions.sql
```

## 🔐 Authentication & Security

- **JWT-based authentication** with secure token storage
- **Password hashing** using bcryptjs with salt rounds
- **Rate limiting** to prevent abuse
- **CORS protection** for cross-origin requests
- **Helmet.js** for security headers
- **Input validation** and sanitization

## 📱 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get user profile
- `PUT /api/auth/profile` - Update profile

### Bookings
- `POST /api/bookings` - Create new booking
- `GET /api/bookings` - Get user bookings
- `GET /api/bookings/track/:trackingNumber` - Track booking
- `PUT /api/bookings/:id/status` - Update booking status
- `PUT /api/bookings/:id/assign-driver` - Assign driver (admin)
- `GET /api/bookings/stats` - Dashboard statistics

## 🎨 UI/UX Features

- **Responsive Design**: Works on desktop, tablet, and mobile
- **Role-based Dashboards**: Customized interfaces for each user type
- **Real-time Updates**: Live status tracking and notifications
- **Professional Styling**: Clean, modern design with transportation theme
- **Intuitive Navigation**: Easy-to-use interface for all user levels

## 🚀 Deployment

### Production Setup
1. Set up MySQL database on production server
2. Configure environment variables for production
3. Build frontend: `npm run build`
4. Deploy backend to server (PM2 recommended)
5. Serve frontend through web server (Nginx recommended)

### Docker Deployment (Optional)
```bash
# Build and run with Docker Compose
docker-compose up -d
```

## 📈 Performance Optimizations

- **Database indexing** for fast queries
- **Connection pooling** for database efficiency
- **Rate limiting** to prevent overload
- **Optimized React components** with proper state management
- **Lazy loading** for better initial load times

## 🔄 Future Enhancements

- **Real-time GPS tracking** integration
- **Push notifications** for status updates
- **Mobile app** development
- **Advanced analytics** and reporting
- **Multi-language support**
- **Payment gateway** integration (Stripe, PayPal)
- **SMS notifications** for delivery updates

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- Email: support@logiflow.com
- Documentation: [Link to docs]
- Issues: [GitHub Issues]

---

**LogiFlow** - Streamlining transportation and logistics operations with modern technology.