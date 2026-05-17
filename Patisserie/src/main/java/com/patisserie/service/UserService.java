package com.patisserie.service;

import com.patisserie.config.DBConfig;
import com.patisserie.model.User;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;

public class UserService {

    private static final int MAX_FAILED = 5;

    // ✅ BCrypt hashing (replaces SHA-256)
    public String hashPassword(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt(12));
    }

    // ✅ BCrypt verification
    public boolean checkPassword(String plain, String hashed) {
        return BCrypt.checkpw(plain, hashed);
    }

    // Fetch user by email (used for cookie auto-login)
    public User getUserByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ? AND is_locked = false";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapUser(rs);
        }
        return null;
    }

    // Returns User if credentials correct, null if wrong
    public User login(String email, String password) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                if (rs.getBoolean("is_locked")) return null;
                // ✅ BCrypt comparison instead of hash equality check
                if (checkPassword(password, rs.getString("password"))) {
                    resetAttempts(email);
                    return mapUser(rs);
                } else {
                    incrementAttempts(email, rs.getInt("failed_attempts"));
                }
            }
        }
        return null;
    }

    // Returns true if registered OK, false if email already exists
    public boolean register(String fullName, String email, String password, String phone)
            throws SQLException {
        if (emailExists(email)) return false;
        String sql = "INSERT INTO users (full_name, email, password, role, phone) VALUES (?,?,?,'customer',?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, hashPassword(password)); // ✅ BCrypt hash stored
            ps.setString(4, phone);
            ps.executeUpdate();
            return true;
        }
    }

    // ✅ Phone uniqueness check (required by coursework spec)
    public boolean phoneExists(String phone) throws SQLException {
        String sql = "SELECT user_id FROM users WHERE phone = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            return ps.executeQuery().next();
        }
    }

    public boolean isLocked(String email) throws SQLException {
        String sql = "SELECT is_locked FROM users WHERE email = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getBoolean("is_locked");
        }
    }

    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT user_id FROM users WHERE email = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            return ps.executeQuery().next();
        }
    }

    private void incrementAttempts(String email, int current) throws SQLException {
        int next = current + 1;
        String sql = "UPDATE users SET failed_attempts=?, is_locked=? WHERE email=?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, next);
            ps.setBoolean(2, next >= MAX_FAILED);
            ps.setString(3, email);
            ps.executeUpdate();
        }
    }

    private void resetAttempts(String email) throws SQLException {
        String sql = "UPDATE users SET failed_attempts=0, is_locked=false WHERE email=?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        }
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setRole(rs.getString("role"));
        user.setPhone(rs.getString("phone"));
        return user;
    }
}