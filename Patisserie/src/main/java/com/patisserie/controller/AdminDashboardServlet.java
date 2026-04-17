package com.patisserie.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpSession;


import com.patisserie.config.DBConfig;
import com.patisserie.model.User;

/**
 * Servlet implementation class AdminDashboardServlet
 */
@WebServlet(asyncSupported = true, urlPatterns = { "/AdminDashboardServlet" })
public class AdminDashboardServlet extends HttpServlet {
	 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        // Security: must be logged in as admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
 
        User user = (User) session.getAttribute("user");
        if (!"admin".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
 
        // Load summary stats for the dashboard
        try {
            request.setAttribute("totalUsers",    countTable("users"));
            request.setAttribute("totalOrders",   countTable("orders"));
            request.setAttribute("totalPastries", countTable("pastries"));
            request.setAttribute("totalRevenue",  sumRevenue());
        } catch (SQLException e) {
            request.setAttribute("error", "Could not load dashboard data.");
        }
 
        request.getRequestDispatcher("/WEB-INF/pages/admin-dashboard.jsp").forward(request, response);
    }
 
    private int countTable(String tableName) throws SQLException {
        String sql = "SELECT COUNT(*) FROM " + tableName;
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
 
    private double sumRevenue() throws SQLException {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE status != 'cancelled'";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getDouble(1) : 0.0;
        }
    }
}
