const { User } = require("../models/User");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const dotenv = require('dotenv');
dotenv.config(); // Load environment variables from .env file

/*
 * Login Controller - Authenticates users and manages authentication via JWT
 */
const loginController = async (req, res) => {
    
    const userId = req.body.userId;
    const password = req.body.password;

    // Input validation - ensures both userId and password are provided
    // WHY: Prevents unnecessary database queries with incomplete data
    // WHY: Provides clear feedback to client about missing information
    if(!userId || !password){
        return res.status(400).json({
            status: 400,
            message: "Please fill out all the fields",
            data: [],
            error: "Missing fields"
        });
    }

    try {
        // Find user in database by userId
        // WHY: Need to verify user exists before attempting authentication
        // WHY: Retrieves stored user details including hashed password for comparison
        const existingUser = await User.findOne({
            userId: userId
        });
    
        // User existence check
        // WHY: Prevents revealing if a specific userId exists in the database
        // WHY: Provides generic "not found" error rather than authentication failure
        if(!existingUser){
            return res.status(404).json({
                status: 404,
                message: "User not found",
                data: [],
                error: "User does not exist"
            });
        }
    
        // Password verification using bcrypt's secure comparison
        // WHY: Uses bcrypt.compare() which is time-constant (prevents timing attacks)
        // WHY: Never compares passwords in plaintext - always uses hashed comparison
        const isPasswordValid = await bcrypt.compare(password, existingUser.password);
        
        // Invalid password handling
        // WHY: Returns 403 Forbidden for security reasons
        // WHY: Uses generic "Invalid credentials" to avoid revealing which credential was wrong
        if(!isPasswordValid){
            return res.status(403).json({
                status: 403,
                message: "Unauthorized",
                data: [],
                error: "Invalid credentials"
            });
        }
    
        // Generate JWT token
        // WHY: Creates a secure, time-limited token containing user information
        // WHY: Uses environment variable for secret key to enhance security
        const token = jwt.sign(
            { 
                userId: existingUser.userId,
                id: existingUser._id 
            },
            process.env.JWT_SECRET || 'your-secret-key', // Should use environment variable
            { expiresIn: '2d' } // Token expires in 2 days
        );
    
        // Successful authentication response with JWT token
        // WHY: Returns the token for client to store and use in subsequent requests
        // WHY: Returns minimal user data to avoid exposing sensitive information
        return res.status(200).json({
            status: 200,
            message: "Login successful",
            data: {
                userId: existingUser.userId,
                token: token
            },
            error: null
        });
    } catch (error) {
        // Error handling for unexpected exceptions
        // WHY: Logs full error details server-side for debugging
        // WHY: Returns generic error message to client to avoid exposing implementation details
        console.error("Error : ", error);
        return res.status(500).json({
            status: 500,
            message: "Internal Server Error",
            data: [],
            error: error.message || "Something went wrong"
        });
    }
}

module.exports = { loginController };