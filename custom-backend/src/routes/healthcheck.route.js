/**
 * Health Check Route
 * 
 * Endpoints for system status verification used by:
 * - External services, monitoring tools
 * - Load balancers, DevOps teams
 * 
 * Note: Should be lightweight and fast, avoiding DB connections
 */

// Import health check controller (separates route from business logic)
const healthCheckController = require('../controllers/healthcheck.controller');

// Create router instance for modular route handling
const HealthCheckRoute = require('express').Router();

// GET endpoint for system status verification
HealthCheckRoute.get('/healthCheck', healthCheckController);

// Export routes for mounting in main app
module.exports = { HealthCheckRoute };