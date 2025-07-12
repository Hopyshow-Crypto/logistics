const mysql = require('mysql2/promise');
require('dotenv').config();

// Professional MySQL Database Configuration
// Compatible with phpMyAdmin and standard MySQL installations
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'logiflow_transport',
  port: process.env.DB_PORT || 3306,
  charset: 'utf8mb4',
  collation: 'utf8mb4_unicode_ci',
  waitForConnections: true,
  connectionLimit: 20,
  queueLimit: 0,
  acquireTimeout: 60000,
  timeout: 60000,
  reconnect: true,
  multipleStatements: false,
  dateStrings: false,
  supportBigNumbers: true,
  bigNumberStrings: false
};

// Create optimized connection pool for production use
const pool = mysql.createPool(dbConfig);

// Enhanced connection testing with detailed error reporting
const testConnection = async () => {
  try {
    const connection = await pool.getConnection();
    
    // Test basic connectivity
    const [rows] = await connection.execute('SELECT 1 as test');
    
    // Check database exists and has tables
    const [tables] = await connection.execute(`
      SELECT COUNT(*) as table_count 
      FROM information_schema.tables 
      WHERE table_schema = ?
    `, [dbConfig.database]);
    
    console.log('✅ Database connected successfully');
    console.log(`📊 Database: ${dbConfig.database}`);
    console.log(`📋 Tables found: ${tables[0].table_count}`);
    
    connection.release();
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:');
    console.error(`   Host: ${dbConfig.host}:${dbConfig.port}`);
    console.error(`   Database: ${dbConfig.database}`);
    console.error(`   User: ${dbConfig.user}`);
    console.error(`   Error: ${error.message}`);
    
    if (error.code === 'ER_ACCESS_DENIED_ERROR') {
      console.error('   💡 Check your username and password');
    } else if (error.code === 'ER_BAD_DB_ERROR') {
      console.error('   💡 Database does not exist. Please create it first.');
    } else if (error.code === 'ECONNREFUSED') {
      console.error('   💡 MySQL server is not running or wrong host/port');
    }
    
    return false;
  }
};

// Enhanced query execution with detailed error handling and logging
const executeQuery = async (query, params = []) => {
  const startTime = Date.now();
  
  try {
    const [rows] = await pool.execute(query, params);
    
    const executionTime = Date.now() - startTime;
    
    // Log slow queries (over 1 second)
    if (executionTime > 1000) {
      console.warn(`⚠️  Slow query detected (${executionTime}ms):`, query.substring(0, 100) + '...');
    }
    
    return { 
      success: true, 
      data: rows,
      executionTime,
      affectedRows: rows.affectedRows || 0,
      insertId: rows.insertId || null
    };
  } catch (error) {
    console.error('❌ Database query error:');
    console.error(`   Query: ${query.substring(0, 200)}${query.length > 200 ? '...' : ''}`);
    console.error(`   Params: ${JSON.stringify(params)}`);
    console.error(`   Error: ${error.message}`);
    console.error(`   Code: ${error.code}`);
    
    return { 
      success: false, 
      error: error.message,
      code: error.code,
      sqlState: error.sqlState
    };
  }
};

// Enhanced transaction handling with rollback and detailed logging
const executeTransaction = async (queries) => {
  const connection = await pool.getConnection();
  const startTime = Date.now();
  
  try {
    await connection.beginTransaction();
    console.log(`🔄 Starting transaction with ${queries.length} queries`);
    
    const results = [];
    for (let i = 0; i < queries.length; i++) {
      const { query, params } = queries[i];
      const [rows] = await connection.execute(query, params);
      results.push(rows);
      console.log(`   ✓ Query ${i + 1}/${queries.length} completed`);
    }
    
    await connection.commit();
    
    const executionTime = Date.now() - startTime;
    console.log(`✅ Transaction completed successfully (${executionTime}ms)`);
    
    return { 
      success: true, 
      data: results,
      executionTime,
      queriesExecuted: queries.length
    };
  } catch (error) {
    await connection.rollback();
    
    const executionTime = Date.now() - startTime;
    console.error(`❌ Transaction failed and rolled back (${executionTime}ms):`, error.message);
    
    return { 
      success: false, 
      error: error.message,
      code: error.code,
      executionTime
    };
  } finally {
    connection.release();
  }
};

// Get database statistics and health information
const getDatabaseStats = async () => {
  try {
    const [stats] = await pool.execute(`
      SELECT 
        (SELECT COUNT(*) FROM users) as total_users,
        (SELECT COUNT(*) FROM bookings) as total_bookings,
        (SELECT COUNT(*) FROM bookings WHERE status = 'pending') as pending_bookings,
        (SELECT COUNT(*) FROM drivers WHERE status = 'available') as available_drivers,
        (SELECT COUNT(*) FROM tracking_updates WHERE DATE(created_at) = CURDATE()) as todays_updates
    `);
    
    return { success: true, stats: stats[0] };
  } catch (error) {
    return { success: false, error: error.message };
  }
};

// Close all connections gracefully
const closeConnections = async () => {
  try {
    await pool.end();
    console.log('📴 Database connections closed gracefully');
  } catch (error) {
    console.error('❌ Error closing database connections:', error.message);
  }
};

module.exports = {
  pool,
  testConnection,
  executeQuery,
  executeTransaction,
  getDatabaseStats,
  closeConnections
};