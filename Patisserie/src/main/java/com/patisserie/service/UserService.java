package com.patisserie.service;
 
 
import com.patisserie.config.DBConfig;
import com.patisserie.model.User;
 
import java.security.MessageDigest;
import java.sql.*;
 
public class UserService {
 
    private static final int MAX_FAILED = 5;
 
    // Converts plain text password to hash
    public String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Hashing failed", e);
        }
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
                if (rs.getString("password").equals(hashPassword(password))) {
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
            ps.setString(3, hashPassword(password));
            ps.setString(4, phone);
            ps.executeUpdate();
            return true;
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
 