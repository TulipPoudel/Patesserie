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

@WebServlet(asyncSupported = true, urlPatterns = { "/ReservationServlet" })
public class ReservationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/DashboardServlet");
            return;
        }

        User user = (User) session.getAttribute("user");
        loadReservations(request, user.getUserId());
        request.getRequestDispatcher("/WEB-INF/pages/reservation.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/DashboardServlet");
            return;
        }

        User user   = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        if ("book".equals(action)) {
            String guestName = request.getParameter("guestName");
            String email     = request.getParameter("email");
            String phone     = request.getParameter("phone");
            String date      = request.getParameter("date");
            String time      = request.getParameter("time");
            String guests    = request.getParameter("guests");
            String location  = request.getParameter("location");
            String notes     = request.getParameter("notes");

            if (date == null || date.isEmpty() || time == null || time.isEmpty()
                    || guests == null || guests.isEmpty() || location == null || location.isEmpty()) {
                request.setAttribute("error", "Please fill in all required fields.");
                loadReservations(request, user.getUserId());
                request.getRequestDispatcher("/WEB-INF/pages/reservation.jsp").forward(request, response);
                return;
            }

            String sql = "INSERT INTO reservations (user_id, guest_name, email, phone, res_date, res_time, guests, location, notes, status) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')";
            try (Connection conn = DBConfig.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, user.getUserId());
                ps.setString(2, guestName);
                ps.setString(3, email);
                ps.setString(4, phone);
                ps.setDate(5, Date.valueOf(date));
                ps.setTime(6, Time.valueOf(time + ":00"));
                ps.setInt(7, Integer.parseInt(guests));
                ps.setString(8, location);
                ps.setString(9, notes);
                ps.executeUpdate();
                request.setAttribute("success", "Reservation confirmed for " + guests +
                    " guest(s) at " + location + " on " + date + " at " + time + ". We look forward to seeing you!");
            } catch (SQLException e) {
                request.setAttribute("error", "Could not save your reservation. Please try again.");
                e.printStackTrace();
            }

        } else if ("cancel".equals(action)) {
            String resId = request.getParameter("reservationId");
            if (resId != null) {
                String sql = "UPDATE reservations SET status = 'cancelled' WHERE reservation_id = ? AND user_id = ?";
                try (Connection conn = DBConfig.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, Integer.parseInt(resId));
                    ps.setInt(2, user.getUserId());
                    ps.executeUpdate();
                    request.setAttribute("success", "Reservation cancelled successfully.");
                } catch (SQLException e) {
                    request.setAttribute("error", "Could not cancel reservation.");
                    e.printStackTrace();
                }
            }
        }

        loadReservations(request, user.getUserId());
        request.getRequestDispatcher("/WEB-INF/pages/reservation.jsp").forward(request, response);
    }

    private void loadReservations(HttpServletRequest request, int userId) {
        String sql = "SELECT reservation_id, guest_name, res_date, res_time, guests, location, notes, status, created_at " +
                     "FROM reservations WHERE user_id = ? ORDER BY res_date DESC, res_time DESC";
        List<String[]> list = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new String[]{
                    String.valueOf(rs.getInt("reservation_id")),
                    rs.getString("guest_name"),
                    rs.getString("res_date"),
                    rs.getString("res_time").substring(0, 5),
                    String.valueOf(rs.getInt("guests")),
                    rs.getString("location"),
                    rs.getString("notes") != null ? rs.getString("notes") : "",
                    rs.getString("status"),
                    rs.getString("created_at")
                });
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        request.setAttribute("reservations", list);
    }
}