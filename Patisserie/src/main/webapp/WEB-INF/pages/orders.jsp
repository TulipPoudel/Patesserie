<%-- FILE LOCATION: WEB-INF/pages/orders.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }

    // Cart items from session (List of Maps with keys: productName, price, quantity, subtotal)
    List<Map<String, Object>> cartItems = (List<Map<String, Object>>) session.getAttribute("cart");
    double cartTotal = 0;
    if (cartItems != null) {
        for (Map<String, Object> item : cartItems) {
            cartTotal += (Double) item.get("subtotal");
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Orders – La Farine Pâtisserie</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<%-- Navbar --%>
<nav class="navbar">
    <div class="container">
        <a href="<%= request.getContextPath() %>/DashboardServlet" class="navbar-brand">
            La Farine <span>Pâtisserie</span>
        </a>
        <div class="navbar-links">
            <a href="<%= request.getContextPath() %>/DashboardServlet">Dashboard</a>
            <a href="<%= request.getContextPath() %>/ProductsServlet">Menu</a>
            <a href="<%= request.getContextPath() %>/ReservationServlet">Reserve Table</a>
            <a href="<%= request.getContextPath() %>/OrderServlet" class="active">
                My Orders
                <% if (cartItems != null && !cartItems.isEmpty()) { %>
                    <span class="cart-badge"><%= cartItems.size() %></span>
                <% } %>
            </a>
            <a href="<%= request.getContextPath() %>/LocationServlet">Locations</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </div>
    </div>
</nav>

<div class="page-content">
    <div class="container">

        <div class="page-header">
            <div>
                <h1>&#128203; My Orders</h1>
                <p style="color:#888; margin-top:0.3rem;">Review your basket and past orders</p>
            </div>
            <a href="<%= request.getContextPath() %>/ProductsServlet" class="btn btn-outline">&#43; Add More Items</a>
        </div>

        <%-- Success / error messages --%>
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success">&#10003; <%= request.getAttribute("success") %></div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>

        <%-- Current basket --%>
        <h2 class="section-title">&#128722; Current Basket</h2>

        <% if (cartItems == null || cartItems.isEmpty()) { %>
            <div class="empty-state" style="margin-bottom:2.5rem;">
                <h3>&#127859; Your basket is empty</h3>
                <p>Head over to our menu and add some delicious items!</p>
                <a href="<%= request.getContextPath() %>/ProductsServlet" class="btn btn-primary" style="margin-top:1rem;">Browse Menu</a>
            </div>
        <% } else { %>
            <div class="cart-layout">
                <%-- Items list --%>
                <div class="cart-items">
                    <div class="table-wrapper">
                        <table>
                            <thead>
                                <tr>
                                    <th>Item</th>
                                    <th>Unit Price</th>
                                    <th>Qty</th>
                                    <th>Subtotal</th>
                                    <th>Remove</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, Object> item : cartItems) { %>
                                <tr>
                                    <td><strong><%= item.get("productName") %></strong></td>
                                    <td>&pound;<%= String.format("%.2f", (Double) item.get("price")) %></td>
                                    <td>
                                        <form action="<%= request.getContextPath() %>/OrderServlet" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="updateQty">
                                            <input type="hidden" name="productId" value="<%= item.get("productId") %>">
                                            <input type="number" name="quantity" value="<%= item.get("quantity") %>"
                                                   min="1" max="20" class="qty-input"
                                                   onchange="this.form.submit()">
                                        </form>
                                    </td>
                                    <td><strong>&pound;<%= String.format("%.2f", (Double) item.get("subtotal")) %></strong></td>
                                    <td>
                                        <form action="<%= request.getContextPath() %>/OrderServlet" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="remove">
                                            <input type="hidden" name="productId" value="<%= item.get("productId") %>">
                                            <button type="submit" class="btn btn-danger btn-sm">&#10005;</button>
                                        </form>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <%-- Order summary --%>
                <div class="cart-summary">
                    <div class="card">
                        <div class="card-body">
                            <h3 style="margin-bottom:1rem;">Order Summary</h3>
                            <table style="width:100%; font-size:0.9rem;">
                                <tr>
                                    <td style="padding:0.4rem 0; color:#888;">Subtotal</td>
                                    <td style="text-align:right;">&pound;<%= String.format("%.2f", cartTotal) %></td>
                                </tr>
                                <tr>
                                    <td style="padding:0.4rem 0; color:#888;">Service charge</td>
                                    <td style="text-align:right;">&pound;0.00</td>
                                </tr>
                                <tr>
                                    <td colspan="2"><hr style="border:none; border-top:1px solid #e5ddd4; margin:0.6rem 0;"></td>
                                </tr>
                            </table>
                            <div class="cart-total">&pound;<%= String.format("%.2f", cartTotal) %></div>
                            <form action="<%= request.getContextPath() %>/OrderServlet" method="post">
                                <input type="hidden" name="action" value="checkout">
                                <button type="submit" class="btn btn-primary btn-block">Place Order</button>
                            </form>
                            <form action="<%= request.getContextPath() %>/OrderServlet" method="post" style="margin-top:0.6rem;">
                                <input type="hidden" name="action" value="clearCart">
                                <button type="submit" class="btn btn-outline btn-block btn-sm">Clear Basket</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        <% } %>

        <%-- Past orders --%>
        <div style="margin-top:2.5rem;">
            <h2 class="section-title">&#128200; Order History</h2>

            <% List<Map<String, Object>> pastOrders = (List<Map<String, Object>>) request.getAttribute("pastOrders"); %>
            <% if (pastOrders == null || pastOrders.isEmpty()) { %>
                <div class="empty-state">
                    <h3>No past orders</h3>
                    <p>Your completed orders will appear here.</p>
                </div>
            <% } else { %>
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Order #</th>
                                <th>Date</th>
                                <th>Items</th>
                                <th>Total</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> order : pastOrders) { %>
                            <tr>
                                <td><strong>#<%= order.get("orderId") %></strong></td>
                                <td><%= order.get("orderDate") %></td>
                                <td><%= order.get("itemSummary") %></td>
                                <td><strong>&pound;<%= String.format("%.2f", (Double) order.get("total")) %></strong></td>
                                <td>
                                    <span class="badge badge-<%= order.get("status") %>">
                                        <%= order.get("status") %>
                                    </span>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>

    </div>
</div>

<footer class="footer">
    <div class="container">
        <p>&copy; 2025 La Farine Pâtisserie</p>
    </div>
</footer>
</body>
</html>