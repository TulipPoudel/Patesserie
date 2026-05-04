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

@WebServlet(asyncSupported = true, urlPatterns = { "/AdminPastriesServlet" })
public class AdminPastriesServlet extends HttpServlet {

    // ── GET: load all pastries joined with category name ──────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT p.pastry_id, p.name, p.description, p.price, " +
                         "p.category_id, c.category_name, p.is_available " +
                         "FROM pastries p JOIN categories c ON p.category_id = c.category_id " +
                         "ORDER BY c.category_name, p.name";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            List<String[]> pastries = new ArrayList<>();
            while (rs.next()) {
                pastries.add(new String[]{
                    String.valueOf(rs.getInt("pastry_id")),   // [0]
                    rs.getString("name"),                      // [1]
                    rs.getString("description"),               // [2]
                    String.format("%.2f", rs.getDouble("price")), // [3]
                    String.valueOf(rs.getInt("category_id")),  // [4]
                    rs.getString("category_name"),             // [5]
                    String.valueOf(rs.getInt("is_available"))  // [6]
                });
            }
            request.setAttribute("pastries", pastries);

            // Categories for dropdowns
            String catSql = "SELECT category_id, category_name FROM categories ORDER BY category_name";
            ResultSet catRs = conn.prepareStatement(catSql).executeQuery();
            List<String[]> categories = new ArrayList<>();
            while (catRs.next()) {
                categories.add(new String[]{
                    String.valueOf(catRs.getInt("category_id")),
                    catRs.getString("category_name")
                });
            }
            request.setAttribute("categories", categories);

        } catch (SQLException e) {
            request.setAttribute("error", "Could not load pastries: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/pages/admin-pastries.jsp").forward(request, response);
    }

    // ── POST: create / update / delete ────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        String action = request.getParameter("action");
        try {
            if ("create".equals(action)) {
                createPastry(request);
                request.setAttribute("success", "Item added successfully!");
            } else if ("update".equals(action)) {
                updatePastry(request);
                request.setAttribute("success", "Item updated successfully!");
            } else if ("delete".equals(action)) {
                deletePastry(request);
                request.setAttribute("success", "Item deleted successfully!");
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        doGet(request, response);
    }

    private void createPastry(HttpServletRequest request) throws SQLException {
        String sql = "INSERT INTO pastries (name, description, price, category_id, is_available) VALUES (?,?,?,?,?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, request.getParameter("name"));
            ps.setString(2, request.getParameter("description"));
            ps.setDouble(3, Double.parseDouble(request.getParameter("price")));
            ps.setInt(4, Integer.parseInt(request.getParameter("category_id")));
            ps.setInt(5, "on".equals(request.getParameter("is_available")) ? 1 : 0);
            ps.executeUpdate();
        }
    }

    private void updatePastry(HttpServletRequest request) throws SQLException {
        String sql = "UPDATE pastries SET name=?, description=?, price=?, category_id=?, is_available=? WHERE pastry_id=?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, request.getParameter("name"));
            ps.setString(2, request.getParameter("description"));
            ps.setDouble(3, Double.parseDouble(request.getParameter("price")));
            ps.setInt(4, Integer.parseInt(request.getParameter("category_id")));
            ps.setInt(5, "on".equals(request.getParameter("is_available")) ? 1 : 0);
            ps.setInt(6, Integer.parseInt(request.getParameter("pastry_id")));
            ps.executeUpdate();
        }
    }

    private void deletePastry(HttpServletRequest request) throws SQLException {
        String sql = "DELETE FROM pastries WHERE pastry_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(request.getParameter("pastry_id")));
            ps.executeUpdate();
        }
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet"); return false;
        }
        User user = (User) session.getAttribute("user");
        if (!"admin".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/DashboardServlet"); return false;
        }
        return true;
    }
}