package com.patisserie.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.patisserie.model.User;

/**
 * Servlet implementation class OrderServlet
 * Manages the session-based shopping cart and order placement.
 *
 * Cart structure: session attribute "cart" = List<Map<String,Object>>
 * Each map has keys: productId, productName, price (Double), quantity (Integer), subtotal (Double)
 */
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

        // TODO: load past orders from DB and attach as request attribute
        // User user = (User) session.getAttribute("user");
        // List<Map<String,Object>> pastOrders = orderService.getByUser(user.getUserId());
        // request.setAttribute("pastOrders", pastOrders);

        request.getRequestDispatcher("/WEB-INF/pages/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

    // ── Cart helpers ──────────────────────────────────────────────────────────

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

        // Check if already in cart — just increment quantity
        for (Map<String, Object> item : cart) {
            if (productId.equals(item.get("productId"))) {
                int newQty = (Integer) item.get("quantity") + quantity;
                item.put("quantity", newQty);
                item.put("subtotal", price * newQty);
                return;
            }
        }

        // New item
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

        // TODO: persist order to database
        // User user = (User) session.getAttribute("user");
        // orderService.placeOrder(user.getUserId(), cart);

        // Clear cart after successful checkout
        session.removeAttribute("cart");

        request.setAttribute("success", "Order placed successfully! We'll have it ready for you soon.");
        request.getRequestDispatcher("/WEB-INF/pages/orders.jsp").forward(request, response);
    }
}