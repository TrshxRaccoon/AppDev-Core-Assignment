/**
 * Health Check Controller
 * 
 * Simple endpoint that verifies service availability with:
 * - 200 OK status response
 * - Standardized status message
 * 
 * Used by monitoring tools, load balancers, and deployment verification
 * Should remain lightweight for minimal resource usage
 */

const healthCheckController = async (req, res) => {
    // Return 200 status with standardized response format
    return res.status(200).json({
        status: 200,
        message: "Server is running",
        data: [],
        error: null
    });
}

module.exports = healthCheckController;