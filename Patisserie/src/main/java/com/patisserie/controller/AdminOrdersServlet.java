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
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.patisserie.config.DBConfig;
import com.patisserie.model.User;

@WebServlet(asyncSupported = true, urlPatterns = { "/AdminOrdersServlet" })
public class AdminOrdersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        String statusFilter = request.getParameter("status");

        try {
            request.setAttribute("orders", getAllOrders(statusFilter));
        } catch (SQLException e) {
            request.setAttribute("error", "Could not load orders: " + e.getMessage());
        }

        request.setAttribute("statusFilter", statusFilter != null ? statusFilter : "all");
        request.getRequestDispatcher("/WEB-INF/pages/admin-orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        String action     = request.getParameter("action");
        String orderIdStr = request.getParameter("order_id");

        if ("updateStatus".equals(action) && orderIdStr != null) {
            String newStatus = request.getParameter("status");
            try {
                updateOrderStatus(Integer.parseInt(orderIdStr), newStatus);
                request.setAttribute("success", "Order #" + orderIdStr + " updated to \"" + newStatus + "\".");
            } catch (SQLException e) {
                request.setAttribute("error", "Could not update order: " + e.getMessage());
            }
        }

        doGet(request, response);
    }

    private List<Map<String, Object>> getAllOrders(String statusFilter) throws SQLException {
        String sql = "SELECT o.order_id, o.user_id, u.full_name, u.email, " +
                     "o.total_amount, o.status, o.created_at, " +
                     "oi.product_name, oi.quantity, oi.subtotal " +
                     "FROM orders o " +
                     "JOIN users u ON o.user_id = u.user_id " +
                     "JOIN order_items oi ON o.order_id = oi.order_id ";

        if (statusFilter != null && !statusFilter.isEmpty() && !"all".equals(statusFilter)) {
            sql += "WHERE o.status = ? ";
        }
        sql += "ORDER BY o.created_at DESC";

        Map<Integer, Map<String, Object>> orderMap = new LinkedHashMap<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (statusFilter != null && !statusFilter.isEmpty() && !"all".equals(statusFilter)) {
                ps.setString(1, statusFilter);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int orderId = rs.getInt("order_id");
                    if (!orderMap.containsKey(orderId)) {
                        Map<String, Object> order = new HashMap<>();
                        order.put("orderId",       orderId);
                        order.put("userId",        rs.getInt("user_id"));
                        order.put("customerName",  rs.getString("full_name"));
                        order.put("customerEmail", rs.getString("email"));
                        order.put("totalAmount",   rs.getDouble("total_amount"));
                        order.put("status",        rs.getString("status"));
                        order.put("createdAt",     rs.getString("created_at"));
                        order.put("items",         new ArrayList<Map<String, Object>>());
                        orderMap.put(orderId, order);
                    }
                    Map<String, Object> item = new HashMap<>();
                    item.put("productName", rs.getString("product_name"));
                    item.put("quantity",    rs.getInt("quantity"));
                    item.put("subtotal",    rs.getDouble("subtotal"));
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> items = (List<Map<String, Object>>) orderMap.get(orderId).get("items");
                    items.add(item);
                }
            }
        }
        return new ArrayList<>(orderMap.values());
    }

    private void updateOrderStatus(int orderId, String status) throws SQLException {
        String[] allowed = {"pending", "confirmed", "preparing", "ready", "completed", "cancelled"};
        boolean valid = false;
        for (String s : allowed) { if (s.equals(status)) { valid = true; break; } }
        if (!valid) throw new SQLException("Invalid status value.");

        String sql = "UPDATE orders SET status = ? WHERE order_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
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