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

@WebServlet(asyncSupported = true, urlPatterns = { "/AdminReservationsServlet" })
public class AdminReservationsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        String statusFilter = request.getParameter("status");
        String sql = "SELECT r.reservation_id, r.guest_name, r.email, r.phone, " +
                     "r.res_date, r.res_time, r.guests, r.location, r.notes, r.status, r.created_at, " +
                     "u.full_name AS user_name " +
                     "FROM reservations r " +
                     "JOIN users u ON r.user_id = u.user_id ";
        if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("all")) {
            sql += "WHERE r.status = ? ";
        }
        sql += "ORDER BY r.res_date DESC, r.res_time DESC";

        List<String[]> list = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("all")) {
                ps.setString(1, statusFilter);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new String[]{
                    String.valueOf(rs.getInt("reservation_id")),
                    rs.getString("user_name"),
                    rs.getString("guest_name"),
                    rs.getString("email"),
                    rs.getString("phone") != null ? rs.getString("phone") : "-",
                    rs.getString("res_date"),
                    rs.getString("res_time").substring(0, 5),
                    String.valueOf(rs.getInt("guests")),
                    rs.getString("location"),
                    rs.getString("notes") != null ? rs.getString("notes") : "-",
                    rs.getString("status"),
                    rs.getString("created_at")
                });
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Could not load reservations.");
            e.printStackTrace();
        }

        // Count stats
        try (Connection conn = DBConfig.getConnection()) {
            request.setAttribute("totalRes",     count(conn, null));
            request.setAttribute("pendingRes",   count(conn, "pending"));
            request.setAttribute("confirmedRes", count(conn, "confirmed"));
            request.setAttribute("cancelledRes", count(conn, "cancelled"));
        } catch (SQLException e) { /* ignore stats error */ }

        request.setAttribute("reservations", list);
        request.setAttribute("statusFilter", statusFilter != null ? statusFilter : "all");
        request.getRequestDispatcher("/WEB-INF/pages/admin-reservations.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        String action = request.getParameter("action");
        String resId  = request.getParameter("reservationId");

        if (resId == null) { response.sendRedirect(request.getContextPath() + "/AdminReservationsServlet"); return; }

        String newStatus = null;
        if ("confirm".equals(action))   newStatus = "confirmed";
        if ("cancel".equals(action))    newStatus = "cancelled";
        if ("pending".equals(action))   newStatus = "pending";

        if (newStatus != null) {
            String sql = "UPDATE reservations SET status = ? WHERE reservation_id = ?";
            try (Connection conn = DBConfig.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, Integer.parseInt(resId));
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/AdminReservationsServlet");
    }

    private int count(Connection conn, String status) throws SQLException {
        String sql = status == null
            ? "SELECT COUNT(*) FROM reservations"
            : "SELECT COUNT(*) FROM reservations WHERE status = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            if (status != null) ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
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