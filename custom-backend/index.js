// Import required packages and modules
const app = require('./src/app');             // Import the Express app from app.js
const mongoose = require('mongoose');         // Import Mongoose - a library to work with MongoDB
const express = require('express');           // Import Express - a web framework for Node.js

/**
 * Environment Configuration
 * - Security: Hides sensitive credentials (DB passwords, API keys)
 * - Enables different configs across environments
 * - Separates configuration from code
 * 
 * Note: Always include .env in .gitignore
 */
const dotenv = require('dotenv');             // Load environment variables package
dotenv.config();                              // Initialize environment variables

// Importing necessary modules and initializing the Express application
// Importing the database connection function and routes

const connectDB = require('./src/db/connectDB'); // Import database connection function
const { HealthCheckRoute } = require('./src/routes/healthcheck.route'); // Import health check routes
const { AuthRouter } = require('./src/routes/auth.route'); // Import authentication routes
const PORT = process.env.PORT || 3000;        // Get the port from environment variables or use 3000 as default
const taskRoutes = require("./src/routes/task.route");

/**
 * Express Middleware Setup
 * - Configures request parsers for JSON and form data
 * - Sets up static file serving
 * - Order matters: middleware executes sequentially
 */
app.use(express.json());                      // Enable parsing JSON bodies in requests
app.use(express.urlencoded({ extended: true })); // Enable parsing URL-encoded bodies (form data)
app.use(express.static('public'));            // Serve static files from the 'public' directory

/**
 * API Routes
 * - Maps URLs to route handlers
 * - Organizes endpoints by resource type
 * - Follows REST principles for API structure
 */
app.use('/api', HealthCheckRoute);            // Any request to '/api' will be handled by HealthCheckRoute
app.use('/api/user', AuthRouter);             // Any request to '/api/user' will be handled by AuthRouter
app.use('/api/task', taskRoutes);

/**
 * Server Initialization and Database Connection
 * 
 * This section:
 * 1. Establishes connection to the MongoDB database
 * 2. Starts the Express server only after successful database connection
 * 3. Implements error handling for database connection failures
 * 
 * WHY: We connect to DB first before starting the server because:
 * - Ensures data availability - app can access data as soon as it starts handling requests
 * - Prevents runtime errors from failed DB operations in request handlers
 * - Provides better error handling - can exit gracefully if DB connection fails
 * 
 * NOTE: The Promise-based approach allows for clean sequential execution and proper error handling
 */
connectDB()                                   // Call the function to connect to MongoDB
    .then(() => {                             // If connection is successful...
        app.listen(PORT, () => {              // Start the Express server on the specified port
            console.log(`Server is running on port ${PORT}`);   // Log a success message to console
            console.log(`http://localhost:${PORT}`);            // Log the local URL to access the server
        });
    })
    .catch((error) => {                       // If connection fails...
        console.error('Error connecting to the database:', error); // Log the error to console
    });
