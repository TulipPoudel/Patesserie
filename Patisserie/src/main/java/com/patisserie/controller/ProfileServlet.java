package com.patisserie.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;

import com.patisserie.config.DBConfig;
import com.patisserie.model.User;
import com.patisserie.service.UserService;

/**
 * ProfileServlet - allows logged-in users to view and update their profile
 * (full name, phone number, and password).
 *
 * GET  → show profile page
 * POST → update profile details
 */
@WebServlet(asyncSupported = true, urlPatterns = { "/ProfileServlet" })
public class ProfileServlet extends HttpServlet {

    private final UserService userService = new UserService();

    // ── GET: show profile ─────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(request, response);
    }

    // ── POST: handle profile updates ──────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User user   = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        try {
            if ("updateProfile".equals(action)) {
                updateProfile(request, user, session);

            } else if ("changePassword".equals(action)) {
                changePassword(request, user);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(request, response);
    }

    // ── Update name and phone ─────────────────────────────────────────────────
    private void updateProfile(HttpServletRequest request, User user, HttpSession session)
            throws SQLException {

        String fullName = request.getParameter("fullName");
        String phone    = request.getParameter("phone");

        // Basic validation
        if (fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Full name cannot be empty.");
            return;
        }
        if (!fullName.matches("[a-zA-Z\\s'\\-]+")) {
            request.setAttribute("error", "Full name should only contain letters and spaces.");
            return;
        }

        String sql = "UPDATE users SET full_name = ?, phone = ? WHERE user_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName.trim());
            ps.setString(2, phone != null ? phone.trim() : null);
            ps.setInt(3, user.getUserId());
            ps.executeUpdate();
        }

        // Update session so navbar reflects new name immediately
        user.setFullName(fullName.trim());
        user.setPhone(phone != null ? phone.trim() : null);
        session.setAttribute("user", user);

        request.setAttribute("success", "Profile updated successfully!");
    }

    // ── Change password ───────────────────────────────────────────────────────
    private void changePassword(HttpServletRequest request, User user)
            throws SQLException {

        String currentPassword = request.getParameter("currentPassword");
        String newPassword     = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate current password
        String currentHash = userService.hashPassword(currentPassword);
        String sql = "SELECT password FROM users WHERE user_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, user.getUserId());
            ResultSet rs = ps.executeQuery();
            if (!rs.next() || !rs.getString("password").equals(currentHash)) {
                request.setAttribute("error", "Current password is incorrect.");
                return;
            }
        }

        // Validate new password
        if (newPassword == null || newPassword.length() < 6) {
            request.setAttribute("error", "New password must be at least 6 characters.");
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New passwords do not match.");
            return;
        }

        // Update password
        String updateSql = "UPDATE users SET password = ? WHERE user_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setString(1, userService.hashPassword(newPassword));
            ps.setInt(2, user.getUserId());
            ps.executeUpdate();
        }

        request.setAttribute("success", "Password changed successfully!");
    }
}