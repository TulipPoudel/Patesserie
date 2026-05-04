<%-- FILE LOCATION: WEB-INF/pages/dashboard.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
<%@ page import="jakarta.servlet.http.Cookie" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard – La Farine Pâtisserie</title>
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
            <a href="<%= request.getContextPath() %>/DashboardServlet" class="active">Dashboard</a>
            <a href="<%= request.getContextPath() %>/ProductsServlet">Menu</a>
            <a href="<%= request.getContextPath() %>/ReservationServlet">Reserve Table</a>
            <a href="<%= request.getContextPath() %>/OrderServlet">My Orders</a>
            <a href="<%= request.getContextPath() %>/ProfileServlet">Profile</a>
            <a href="<%= request.getContextPath() %>/LocationServlet">Locations</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </div>
    </div>
</nav>

<div class="page-content">
    <div class="container">

        <%-- Cookie: Welcome back banner --%>
        <% if (request.getAttribute("welcomeBack") != null) { %>
            <div class="alert alert-info">
                &#128075; Welcome back, <strong><%= request.getAttribute("welcomeBack") %></strong>!
                Good to see you again.
            </div>
        <% } else { %>
            <div class="alert alert-success">
                &#127881; Welcome, <strong><%= user.getFullName() %></strong>!
                You are now logged in.
            </div>
        <% } %>

        <h1>My Dashboard</h1>
        <p style="color:#888; margin-bottom:2rem">
            Hello <%= user.getFullName() %>, here's everything you can do at La Farine.
        </p>

        <%-- Quick action cards --%>
        <div class="stats-grid">

            <div class="stat-card">
                <div style="font-size:2rem; margin-bottom:0.5rem">&#127859;</div>
                <div class="stat-label" style="font-size:1rem; font-weight:600; color:var(--brown)">Browse Menu</div>
                <p style="font-size:0.82rem; margin:0.4rem 0 0.8rem">
                    Explore our fresh pastries and add items to your cart.
                </p>
                <a href="<%= request.getContextPath() %>/ProductsServlet" class="btn btn-primary btn-sm">Go to Menu</a>
            </div>

            <div class="stat-card" style="border-color:var(--green)">
                <div style="font-size:2rem; margin-bottom:0.5rem">&#128203;</div>
                <div class="stat-label" style="font-size:1rem; font-weight:600; color:var(--brown)">My Orders</div>
                <p style="font-size:0.82rem; margin:0.4rem 0 0.8rem">
                    View your basket and past orders.
                </p>
                <a href="<%= request.getContextPath() %>/OrderServlet" class="btn btn-green btn-sm">View Orders</a>
            </div>

            <div class="stat-card" style="border-color:#7a6a1e">
                <div style="font-size:2rem; margin-bottom:0.5rem">&#127860;</div>
                <div class="stat-label" style="font-size:1rem; font-weight:600; color:var(--brown)">Reserve a Table</div>
                <p style="font-size:0.82rem; margin:0.4rem 0 0.8rem">
                    Book a table for yourself or a group.
                </p>
                <a href="<%= request.getContextPath() %>/ReservationServlet" class="btn btn-gold btn-sm">Book Now</a>
            </div>

            <div class="stat-card" style="border-color:var(--brown-light)">
                <div style="font-size:2rem; margin-bottom:0.5rem">&#128100;</div>
                <div class="stat-label" style="font-size:1rem; font-weight:600; color:var(--brown)">My Profile</div>
                <p style="font-size:0.82rem; margin:0.4rem 0 0.8rem">
                    Update your name, phone, and password.
                </p>
                <a href="<%= request.getContextPath() %>/ProfileServlet" class="btn btn-outline btn-sm">Edit Profile</a>
            </div>

        </div>

        <%-- Session info panel --%>
        <div class="card" style="max-width:500px; margin-top:2rem">
            <div class="card-body">
                <h3 style="margin-bottom:0.8rem">&#128274; Your Session Info</h3>
                <table style="width:100%; font-size:0.88rem">
                    <tr>
                        <td style="padding:0.4rem 0; color:#888; width:40%">Logged in as:</td>
                        <td><strong><%= user.getFullName() %></strong></td>
                    </tr>
                    <tr>
                        <td style="padding:0.4rem 0; color:#888">Email:</td>
                        <td><%= user.getEmail() %></td>
                    </tr>
                    <tr>
                        <td style="padding:0.4rem 0; color:#888">Role:</td>
                        <td><%= user.getRole() %></td>
                    </tr>
                    <tr>
                        <td style="padding:0.4rem 0; color:#888">Session ID:</td>
                        <td style="font-size:0.78rem; color:#aaa"><%= session.getId().substring(0,16) %>...</td>
                    </tr>
                    <tr>
                        <td style="padding:0.4rem 0; color:#888">Remember Me:</td>
                        <td>
                            <%
                                Cookie[] cookies = request.getCookies();
                                boolean hasRemember = false;
                                if (cookies != null) {
                                    for (Cookie c : cookies) {
                                        if ("rememberedEmail".equals(c.getName()) && !c.getValue().isEmpty()) {
                                            hasRemember = true;
                                        }
                                    }
                                }
                            %>
                            <%= hasRemember ? "&#10003; Cookie active (7 days)" : "Not set" %>
                        </td>
                    </tr>
                </table>
            </div>
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