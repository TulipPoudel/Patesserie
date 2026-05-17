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
import java.util.List;
import java.util.Map;

import com.patisserie.config.DBConfig;
import com.patisserie.model.User;

@WebServlet(asyncSupported = true, urlPatterns = { "/OrderServlet" })
public class OrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            List<Map<String, Object>> pastOrders = getPastOrders(user.getUserId());
            request.setAttribute("pastOrders", pastOrders);
        } catch (SQLException e) {
            request.setAttribute("error", "Could not load past orders.");
        }

        request.getRequestDispatcher("/WEB-INF/pages/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Fix: guests redirected to login instead of NPE
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String action = request.getParameter("action");

        switch (action == null ? "" : action) {

            case "add":
                addToCart(request, session);
                response.sendRedirect(request.getContextPath() + "/OrderServlet");
                break;

            case "remove":
                removeFromCart(request, session);
                response.sendRedirect(request.getContextPath() + "/OrderServlet");
                break;

            case "updateQty":
                updateQuantity(request, session);
                response.sendRedirect(request.getContextPath() + "/OrderServlet");
                break;

            case "clearCart":
                session.removeAttribute("cart");
                response.sendRedirect(request.getContextPath() + "/OrderServlet");
                break;

            case "checkout":
                checkout(request, response, session);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/OrderServlet");
        }
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> getCart(HttpSession session) {
        List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }
        return cart;
    }

    private void addToCart(HttpServletRequest request, HttpSession session) {
        String productId   = request.getParameter("productId");
        String productName = request.getParameter("productName");
        String priceStr    = request.getParameter("price");
        String qtyStr      = request.getParameter("quantity");

        if (productId == null || productName == null || priceStr == null) return;

        double price    = Double.parseDouble(priceStr);
        int    quantity = (qtyStr != null && !qtyStr.isEmpty()) ? Integer.parseInt(qtyStr) : 1;
        if (quantity < 1) quantity = 1;

        List<Map<String, Object>> cart = getCart(session);

        for (Map<String, Object> item : cart) {
            if (productId.equals(item.get("productId"))) {
                int newQty = (Integer) item.get("quantity") + quantity;
                item.put("quantity", newQty);
                item.put("subtotal", price * newQty);
                return;
            }
        }

        Map<String, Object> item = new HashMap<>();
        item.put("productId",   productId);
        item.put("productName", productName);
        item.put("price",       price);
        item.put("quantity",    quantity);
        item.put("subtotal",    price * quantity);
        cart.add(item);
    }

    private void removeFromCart(HttpServletRequest request, HttpSession session) {
        String productId = request.getParameter("productId");
        if (productId == null) return;
        List<Map<String, Object>> cart = getCart(session);
        cart.removeIf(item -> productId.equals(item.get("productId")));
    }

    private void updateQuantity(HttpServletRequest request, HttpSession session) {
        String productId = request.getParameter("productId");
        String qtyStr    = request.getParameter("quantity");
        if (productId == null || qtyStr == null) return;

        int qty = Integer.parseInt(qtyStr);
        if (qty < 1) qty = 1;

        List<Map<String, Object>> cart = getCart(session);
        for (Map<String, Object> item : cart) {
            if (productId.equals(item.get("productId"))) {
                item.put("quantity", qty);
                item.put("subtotal", (Double) item.get("price") * qty);
                break;
            }
        }
    }

    private void checkout(HttpServletRequest request, HttpServletResponse response,
                          HttpSession session) throws ServletException, IOException {

        List<Map<String, Object>> cart = getCart(session);
        if (cart.isEmpty()) {
            request.setAttribute("error", "Your basket is empty — add items before checking out.");
            request.getRequestDispatcher("/WEB-INF/pages/orders.jsp").forward(request, response);
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            persistOrder(user.getUserId(), cart);
            session.removeAttribute("cart");
            request.setAttribute("success", "Order placed successfully! We'll have it ready for you soon.");
        } catch (SQLException e) {
            request.setAttribute("error", "Could not place order. Please try again.");
        }

        try {
            request.setAttribute("pastOrders", getPastOrders(user.getUserId()));
        } catch (SQLException ignored) {}

        request.getRequestDispatcher("/WEB-INF/pages/orders.jsp").forward(request, response);
    }

    private void persistOrder(int userId, List<Map<String, Object>> cart) throws SQLException {
        double total = cart.stream().mapToDouble(i -> (Double) i.get("subtotal")).sum();

        String insertOrder = "INSERT INTO orders (user_id, total_amount, status, created_at) VALUES (?, ?, 'pending', NOW())";
        String insertItem  = "INSERT INTO order_items (order_id, product_id, product_name, price, quantity, subtotal) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int orderId;
                try (PreparedStatement ps = conn.prepareStatement(insertOrder, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, userId);
                    ps.setDouble(2, total);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (!rs.next()) throw new SQLException("Failed to retrieve order ID.");
                        orderId = rs.getInt(1);
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(insertItem)) {
                    for (Map<String, Object> item : cart) {
                        ps.setInt(1, orderId);
                        ps.setInt(2, Integer.parseInt((String) item.get("productId")));
                        ps.setString(3, (String) item.get("productName"));
                        ps.setDouble(4, (Double) item.get("price"));
                        ps.setInt(5, (Integer) item.get("quantity"));
                        ps.setDouble(6, (Double) item.get("subtotal"));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }

                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private List<Map<String, Object>> getPastOrders(int userId) throws SQLException {
        String sql = "SELECT o.order_id, o.total_amount, o.status, o.created_at, " +
                     "       oi.product_name, oi.price, oi.quantity, oi.subtotal " +
                     "FROM orders o " +
                     "JOIN order_items oi ON o.order_id = oi.order_id " +
                     "WHERE o.user_id = ? " +
                     "ORDER BY o.created_at DESC";

        Map<Integer, Map<String, Object>> orderMap = new java.util.LinkedHashMap<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int orderId = rs.getInt("order_id");
                    if (!orderMap.containsKey(orderId)) {
                        Map<String, Object> order = new HashMap<>();
                        order.put("orderId",     orderId);
                        order.put("totalAmount", rs.getDouble("total_amount"));
                        order.put("status",      rs.getString("status"));
                        order.put("createdAt",   rs.getString("created_at"));
                        order.put("items",       new ArrayList<Map<String, Object>>());
                        orderMap.put(orderId, order);
                    }
                    Map<String, Object> item = new HashMap<>();
                    item.put("productName", rs.getString("product_name"));
                    item.put("price",       rs.getDouble("price"));
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
}