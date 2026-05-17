<%-- FILE LOCATION: WEB-INF/pages/orders.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/DashboardServlet");
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
    <title>My Orders – L'Atelier Sucré Pâtisserie</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2">
    <style>
        .orders-hero {
            position: relative;
            padding: calc(var(--nav-h) + 4.5rem) 0 4.5rem;
            text-align: center;
            overflow: hidden;
            background: var(--brown-dark);
        }
        .orders-hero::before {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(160deg, rgba(26,11,4,0.88) 0%, rgba(58,32,16,0.78) 45%, rgba(92,56,32,0.72) 100%);
            z-index: 1;
        }
        /* Future image slot — drop an <img> inside .orders-hero and it will fill as overlay */
        .orders-hero img.hero-img {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0.32;
            z-index: 0;
        }
        .orders-hero-content { position: relative; z-index: 2; }
        .orders-hero h1 {
            font-family: var(--font-display);
            font-size: clamp(2.2rem, 5vw, 4rem);
            font-weight: 300;
            color: #fff;
            letter-spacing: 0.06em;
            margin-bottom: 0.5rem;
        }
        .orders-hero p {
            font-family: var(--font-display);
            font-style: italic;
            color: rgba(255,255,255,0.55);
            font-size: 1rem;
            max-width: 460px;
            margin: 0 auto;
        }
        .orders-hero-line {
            width: 45px;
            height: 1px;
            background: var(--gold);
            margin: 1.2rem auto;
        }
        .orders-hero-actions {
            position: relative;
            z-index: 2;
            margin-top: 1.8rem;
        }
    </style>
</head>
<body>

<%-- Navbar --%>
<%@ include file="../includes/navbar.jsp" %>

<div class="orders-hero">
    <img class="hero-img" src="<%= request.getContextPath() %>/images/croi.jpg" alt="">
    <div class="orders-hero-content">
        <div class="section-eyebrow" style="color:var(--gold); margin-bottom:0.8rem;">L'Atelier Sucré</div>
        <h1>My Orders</h1>
        <div class="orders-hero-line"></div>
        <p>Review your basket and track your order history</p>
    </div>
    <div class="orders-hero-actions">
        <a href="<%= request.getContextPath() %>/ProductsServlet" class="btn btn-outline" style="border-color:rgba(255,255,255,0.4); color:#fff;">+ Add More Items</a>
    </div>
</div>

<div class="page-content">
    <div class="container">

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
                            <% for (Map<String, Object> order : pastOrders) {
                                   @SuppressWarnings("unchecked")
                                   java.util.List<Map<String,Object>> oItems =
                                       (java.util.List<Map<String,Object>>) order.get("items");
                                   StringBuilder itemSummary = new StringBuilder();
                                   if (oItems != null) {
                                       for (int ii = 0; ii < oItems.size(); ii++) {
                                           if (ii > 0) itemSummary.append(", ");
                                           itemSummary.append(oItems.get(ii).get("quantity"))
                                                      .append("× ").append(oItems.get(ii).get("productName"));
                                       }
                                   }
                                   String createdAt = (String) order.get("createdAt");
                                   String displayDate = createdAt != null && createdAt.length() >= 10
                                       ? createdAt.substring(0, 10) : "-";
                            %>
                            <tr>
                                <td><strong>#<%= order.get("orderId") %></strong></td>
                                <td><%= displayDate %></td>
                                <td style="font-size:0.85rem;"><%= itemSummary.toString() %></td>
                                <td><strong>&pound;<%= String.format("%.2f", (Double) order.get("totalAmount")) %></strong></td>
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

<%-- footer --%>
<%@ include file="../includes/footer.jsp" %>

</body>
</html>