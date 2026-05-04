<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
<%@ page import="jakarta.servlet.http.Cookie" %>
<%
    // Security check - if not logged in, go to login
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    // If not admin, send to customer dashboard
    if (!"admin".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/DashboardServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard – La Farine</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<%-- Navbar --%>
<nav class="navbar">
    <div class="container">
        <a href="<%= request.getContextPath() %>/AdminDashboardServlet" class="navbar-brand">
            La Farine <span>Admin Panel</span>
        </a>
        <div class="navbar-links">
            <a href="<%= request.getContextPath() %>/AdminDashboardServlet" class="active">Dashboard</a>
            <a href="<%= request.getContextPath() %>/AdminPastriesServlet">Manage Menu</a>
			<a href="<%= request.getContextPath() %>/AdminUsersServlet">Manage Users</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </div>
    </div>
</nav>

<div class="page-content">
    <div class="container">

        <div style="margin-bottom: 1.5rem;">
            <h1>Admin Dashboard</h1>
            <p style="color: #888;">
                Welcome, <strong><%= user.getFullName() %></strong> &mdash; Admin Panel
            </p>
        </div>

        <%-- Error message if any --%>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>

        <%-- Stats row --%>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-number">
                    <%= request.getAttribute("totalUsers") != null ? request.getAttribute("totalUsers") : 0 %>
                </div>
                <div class="stat-label">Registered Users</div>
            </div>

            <div class="stat-card">
                <div class="stat-number">
                    <%= request.getAttribute("totalOrders") != null ? request.getAttribute("totalOrders") : 0 %>
                </div>
                <div class="stat-label">Total Orders</div>
            </div>

            <div class="stat-card">
                <div class="stat-number">
                    <%= request.getAttribute("totalPastries") != null ? request.getAttribute("totalPastries") : 0 %>
                </div>
                <div class="stat-label">Menu Items</div>
            </div>

            <div class="stat-card" style="border-color: var(--green);">
                <div class="stat-number">
                    &pound;<%= request.getAttribute("totalRevenue") != null
                        ? String.format("%.0f", (Double) request.getAttribute("totalRevenue"))
                        : "0" %>
                </div>
                <div class="stat-label">Total Revenue</div>
            </div>
        </div>

        <%-- Session and cookie info - good for your demo --%>
        <div class="card" style="max-width: 500px; margin-bottom: 2rem;">
            <div class="card-body">
                <h3 style="margin-bottom: 0.8rem;">Session &amp; Cookie Info</h3>
                <table style="width: 100%; font-size: 0.88rem;">
                    <tr>
                        <td style="padding: 0.4rem 0; color: #888; width: 40%;">Admin name:</td>
                        <td><strong><%= user.getFullName() %></strong></td>
                    </tr>
                    <tr>
                        <td style="padding: 0.4rem 0; color: #888;">Email:</td>
                        <td><%= user.getEmail() %></td>
                    </tr>
                    <tr>
                        <td style="padding: 0.4rem 0; color: #888;">Role:</td>
                        <td><span class="badge badge-confirmed">admin</span></td>
                    </tr>
                    <tr>
                        <td style="padding: 0.4rem 0; color: #888;">Session ID:</td>
                        <td style="font-size: 0.75rem; color: #aaa;">
                            <%= session.getId().substring(0, 20) %>...
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 0.4rem 0; color: #888;">Remember Me cookie:</td>
                        <td>
                            <%
                                Cookie[] cookies = request.getCookies();
                                boolean hasCookie = false;
                                if (cookies != null) {
                                    for (Cookie c : cookies) {
                                        if ("rememberedEmail".equals(c.getName()) && !c.getValue().isEmpty()) {
                                            hasCookie = true;
                                        }
                                    }
                                }
                            %>
                            <%= hasCookie ? "&#10003; Active" : "Not set" %>
                        </td>
                    </tr>
                </table>
            </div>
        </div>

    </div>
</div>

<footer class="footer">
    <div class="container">
        <p>&copy; 2025 La Farine P&acirc;tisserie &mdash; Admin</p>
    </div>
</footer>
</body>
</html>