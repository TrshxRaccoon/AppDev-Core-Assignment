const mongoose = require('mongoose');
const dotenv = require('dotenv');
dotenv.config();

/**
 * Database Connection Module
 * 
 * Handles MongoDB connection with:
 * - Environment variable configuration
 * - Connection establishment
 * - Error handling with process termination
 */

const connectDB = async () => {
    try{
        // Connect using environment variables for security
        const connection = await mongoose.connect(process.env.MONGODB_URI);
        // console.log(`MongoDB connected: ${connection.connection.host}`);
    } catch (error) {
        // Critical error handling - terminate process on connection failure
        console.error(`Error connecting to MongoDB: ${error.message}`);
        process.exit(1);
    }
};

module.exports = connectDB;