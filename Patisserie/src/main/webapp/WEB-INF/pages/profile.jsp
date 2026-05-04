<%-- FILE LOCATION: WEB-INF/pages/profile.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
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
    <title>My Profile – La Farine Pâtisserie</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<nav class="navbar">
    <div class="container">
        <a href="<%= request.getContextPath() %>/DashboardServlet" class="navbar-brand">
            La Farine <span>Pâtisserie</span>
        </a>
        <div class="navbar-links">
            <a href="<%= request.getContextPath() %>/DashboardServlet">Dashboard</a>
            <a href="<%= request.getContextPath() %>/ProductsServlet">Menu</a>
            <a href="<%= request.getContextPath() %>/ReservationServlet">Reserve Table</a>
            <a href="<%= request.getContextPath() %>/OrderServlet">My Orders</a>
            <a href="<%= request.getContextPath() %>/ProfileServlet" class="active">Profile</a>
            <a href="<%= request.getContextPath() %>/LocationServlet">Locations</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </div>
    </div>
</nav>

<div class="page-content">
    <div class="container" style="max-width:600px;">

        <h1>&#128100; My Profile</h1>
        <p style="color:#888; margin-bottom:1.5rem;">Update your personal details and password.</p>

        <%-- Alerts --%>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>

        <%-- UPDATE PROFILE FORM --%>
        <div class="card" style="margin-bottom:1.5rem;">
            <div class="card-body">
                <h3 style="margin-bottom:1rem;">Personal Details</h3>
                <form action="<%= request.getContextPath() %>/ProfileServlet" method="post">
                    <input type="hidden" name="action" value="updateProfile">

                    <div style="margin-bottom:1rem;">
                        <label style="display:block; margin-bottom:0.3rem; font-size:0.85rem; color:#888;">Full Name *</label>
                        <input type="text" name="fullName" value="<%= user.getFullName() %>" required
                               style="width:100%; padding:0.7rem; border:1px solid #ddd; border-radius:8px; font-size:0.95rem;">
                    </div>

                    <div style="margin-bottom:1rem;">
                        <label style="display:block; margin-bottom:0.3rem; font-size:0.85rem; color:#888;">Email (cannot be changed)</label>
                        <input type="email" value="<%= user.getEmail() %>" disabled
                               style="width:100%; padding:0.7rem; border:1px solid #eee; border-radius:8px; background:#f9f9f9; color:#aaa; font-size:0.95rem;">
                    </div>

                    <div style="margin-bottom:1rem;">
                        <label style="display:block; margin-bottom:0.3rem; font-size:0.85rem; color:#888;">Phone Number</label>
                        <input type="tel" name="phone" value="<%= user.getPhone() != null ? user.getPhone() : "" %>"
                               placeholder="e.g. 07700000000"
                               style="width:100%; padding:0.7rem; border:1px solid #ddd; border-radius:8px; font-size:0.95rem;">
                    </div>

                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </form>
            </div>
        </div>

        <%-- CHANGE PASSWORD FORM --%>
        <div class="card">
            <div class="card-body">
                <h3 style="margin-bottom:1rem;">&#128274; Change Password</h3>
                <form action="<%= request.getContextPath() %>/ProfileServlet" method="post">
                    <input type="hidden" name="action" value="changePassword">

                    <div style="margin-bottom:1rem;">
                        <label style="display:block; margin-bottom:0.3rem; font-size:0.85rem; color:#888;">Current Password *</label>
                        <input type="password" name="currentPassword" required
                               style="width:100%; padding:0.7rem; border:1px solid #ddd; border-radius:8px; font-size:0.95rem;">
                    </div>

                    <div style="margin-bottom:1rem;">
                        <label style="display:block; margin-bottom:0.3rem; font-size:0.85rem; color:#888;">New Password * (min. 6 characters)</label>
                        <input type="password" name="newPassword" minlength="6" required
                               style="width:100%; padding:0.7rem; border:1px solid #ddd; border-radius:8px; font-size:0.95rem;">
                    </div>

                    <div style="margin-bottom:1rem;">
                        <label style="display:block; margin-bottom:0.3rem; font-size:0.85rem; color:#888;">Confirm New Password *</label>
                        <input type="password" name="confirmPassword" required
                               style="width:100%; padding:0.7rem; border:1px solid #ddd; border-radius:8px; font-size:0.95rem;">
                    </div>

                    <button type="submit" class="btn btn-outline">Change Password</button>
                </form>
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