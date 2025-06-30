const { default: mongoose, mongo } = require("mongoose");

/**
 * User Model - Authentication Schema
 * 
 * Core fields for authentication:
 * - userId: Unique identifier
 * - password: For storing hashed credentials
 * 
 * For production: Consider adding email, timestamps, roles, and personal info
 */

const userSchema = new mongoose.Schema(
    {
        userId: {
            type: String,
            required: true,
            unique: true,
            trim: true
            // Primary identifier, unique to prevent duplicates, trimmed for consistency
        },
        password: {
            type: String,
            required: true,
            // Stores hashed passwords only, no length constraint for hash flexibility
        },
    }
)

// Create and export model for database operations
const User = mongoose.model("User", userSchema)
module.exports = { User };