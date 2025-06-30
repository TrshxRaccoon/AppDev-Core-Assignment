const bcrypt = require("bcrypt");
const { User } = require("../models/User");

/*
 * Register Controller - Creates new user accounts in the system
 */
const registerController = async (req, res) => {
    try {
        const { userId, password } = req.body;

        // Input validation - ensures both userId and password are provided
        // WHY: Prevents incomplete user records from being created
        // WHY: Provides clear feedback to client about missing information
        if(!userId || !password){
            return res.status(400).json({
                status: 400,
                message: "Please fill out all the fields",
                data: [],
                error: "Missing fields"
            });
        }

        // Check for existing users with the same userId
        // WHY: Prevents duplicate user accounts with the same identifier
        // WHY: Maintains data integrity by enforcing unique userIds
        const existingUser = await User.findOne({ userId });

        // User existence check
        // WHY: Provides clear feedback when attempting to create duplicate accounts
        // WHY: Stops the registration process early if userId is already taken
        if(existingUser){
            return res.status(400).json({
                status: 400,
                message: "User already exists with same username",
                data: [],
                error: "User already exists"
            });
        }

        // Hash the password before storing
        // WHY: Uses bcrypt's secure one-way hashing to protect user passwords
        // WHY: Salt generation adds randomness to prevent rainbow table attacks
        // WHY: Even database breaches won't expose actual user passwords
        // In the MongoDB, hashed password is stored instead of plaintext, you can see it in the database
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Create new user record with hashed password
        // WHY: Stores only the hashed password, never the plaintext version
        // WHY: Sets initial login state to maintain session tracking
        const newUser = new User({
            userId,
            password: hashedPassword,
        });

        // Save user to database
        // WHY: Persists the new user information for future authentication
        await newUser.save();
        
        // Return success response without password
        // WHY: Returns minimal user data to avoid exposing sensitive information
        // WHY: Confirms registration status to client for UI state management
        return res.status(201).json({
            status: 201,
            message: "User registered successfully",
            data: {
                userId: newUser.userId,
            },
            error: null
        });
    } catch (error) {
        // Error handling for unexpected exceptions
        // WHY: Logs full error details server-side for debugging
        // WHY: Returns generic error message to client to avoid exposing implementation details
        console.error("Register error:", error);
        return res.status(500).json({
            status: 500,
            message: "Server error during registration",
            data: [],
            error: error.message || "Something went wrong"
        });
    }
};

module.exports = { registerController };