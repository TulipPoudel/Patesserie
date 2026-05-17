package com.patisserie.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.patisserie.config.DBConfig;
import com.patisserie.model.User;

@WebServlet(asyncSupported = true, urlPatterns = { "/AdminUsersServlet" })
public class AdminUsersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT user_id, full_name, email, phone, role, failed_attempts, is_locked, created_at FROM users ORDER BY created_at DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            List<String[]> users = new ArrayList<>();
            while (rs.next()) {
                users.add(new String[]{
                    String.valueOf(rs.getInt("user_id")),
                    rs.getString("full_name"),
                    rs.getString("email"),
                    rs.getString("phone") != null ? rs.getString("phone") : "-",
                    rs.getString("role"),
                    String.valueOf(rs.getInt("failed_attempts")),
                    rs.getBoolean("is_locked") ? "Locked" : "Active",
                    rs.getString("created_at")
                });
            }
            request.setAttribute("users", users);

        } catch (SQLException e) {
            request.setAttribute("error", "Could not load users: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/pages/admin-users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        String action = request.getParameter("action");
        int targetId  = Integer.parseInt(request.getParameter("user_id"));

        HttpSession session = request.getSession(false);
        User admin = (User) session.getAttribute("user");

        try {
            if ("delete".equals(action)) {
                if (targetId == admin.getUserId()) {
                    request.setAttribute("error", "You cannot delete your own account.");
                } else {
                    deleteUser(targetId);
                    request.setAttribute("success", "User deleted successfully.");
                }
            } else if ("unlock".equals(action)) {
                unlockUser(targetId);
                request.setAttribute("success", "User account unlocked.");
            } else if ("changeRole".equals(action)) {
                // NEW: promote/demote users
                if (targetId == admin.getUserId()) {
                    request.setAttribute("error", "You cannot change your own role.");
                } else {
                    String newRole = request.getParameter("role");
                    if ("admin".equals(newRole) || "customer".equals(newRole)) {
                        changeUserRole(targetId, newRole);
                        request.setAttribute("success", "User role updated to \"" + newRole + "\".");
                    } else {
                        request.setAttribute("error", "Invalid role specified.");
                    }
                }
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        doGet(request, response);
    }

    private void deleteUser(int userId) throws SQLException {
        String sql = "DELETE FROM users WHERE user_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    private void unlockUser(int userId) throws SQLException {
        String sql = "UPDATE users SET is_locked = false, failed_attempts = 0 WHERE user_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    private void changeUserRole(int userId, String role) throws SQLException {
        String sql = "UPDATE users SET role = ? WHERE user_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return false;
        }
        User user = (User) session.getAttribute("user");
        if (!"admin".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/DashboardServlet");
            return false;
        }
        return true;
    }
}