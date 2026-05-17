package com.patisserie.util;

/**
 * Utility class for common validation methods used across the application.
 */
public class ValidationUtil {

    // Validates basic email format (must contain @ and a domain)
    public static boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) return false;
        return email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");
    }

    // Validates phone: digits only, 7–15 characters
    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) return false;
        return phone.matches("^\\d{7,15}$");
    }

    // Full name must not contain numbers
    public static boolean isValidFullName(String name) {
        if (name == null || name.trim().isEmpty()) return false;
        return !name.matches(".*\\d.*");
    }

    // Password must be at least 6 characters
    public static boolean isValidPassword(String password) {
        if (password == null) return false;
        return password.length() >= 6;
    }

    // Checks if a string is null or empty
    public static boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}