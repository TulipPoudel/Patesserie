<%-- FILE LOCATION: WEB-INF/pages/admin-users.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    List<String[]> users = (List<String[]>) request.getAttribute("users");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users – La Farine Admin</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<nav class="navbar">
    <div class="container">
        <a href="<%= request.getContextPath() %>/AdminDashboardServlet" class="navbar-brand">
            La Farine <span>Admin Panel</span>
        </a>
        <div class="navbar-links">
            <a href="<%= request.getContextPath() %>/AdminDashboardServlet">Dashboard</a>
            <a href="<%= request.getContextPath() %>/AdminPastriesServlet">Manage Menu</a>
            <a href="<%= request.getContextPath() %>/AdminUsersServlet" class="active">Manage Users</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </div>
    </div>
</nav>

<div class="page-content">
    <div class="container">

        <h1>Manage Users</h1>
        <p style="color:#888; margin-bottom:1.5rem;">View, unlock, or remove user accounts.</p>

        <%-- Alerts --%>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>

        <div class="card">
            <div class="card-body">
                <h3 style="margin-bottom:1rem;">&#128101; All Users (<%= users != null ? users.size() : 0 %>)</h3>

                <% if (users == null || users.isEmpty()) { %>
                    <p style="color:#888; text-align:center; padding:2rem;">No users found.</p>
                <% } else { %>
                <div style="overflow-x:auto;">
                <table style="width:100%; border-collapse:collapse; font-size:0.9rem;">
                    <thead>
                        <tr style="background:#f9f6f0; border-bottom:2px solid #eee;">
                            <th style="padding:0.8rem; text-align:left;">ID</th>
                            <th style="padding:0.8rem; text-align:left;">Name</th>
                            <th style="padding:0.8rem; text-align:left;">Email</th>
                            <th style="padding:0.8rem; text-align:left;">Phone</th>
                            <th style="padding:0.8rem; text-align:left;">Role</th>
                            <th style="padding:0.8rem; text-align:left;">Status</th>
                            <th style="padding:0.8rem; text-align:left;">Joined</th>
                            <th style="padding:0.8rem; text-align:left;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (String[] u : users) {
                           String uid      = u[0];
                           String uname    = u[1];
                           String uemail   = u[2];
                           String uphone   = u[3];
                           String urole    = u[4];
                           String ufailed  = u[5];
                           String ustatus  = u[6];
                           String ujoined  = u[7] != null ? u[7].substring(0,10) : "-";
                           boolean isCurrentAdmin = uid.equals(String.valueOf(user.getUserId()));
                    %>
                        <tr style="border-bottom:1px solid #f0ebe3;">
                            <td style="padding:0.8rem; color:#aaa;">#<%= uid %></td>
                            <td style="padding:0.8rem;"><strong><%= uname %></strong></td>
                            <td style="padding:0.8rem;"><%= uemail %></td>
                            <td style="padding:0.8rem;"><%= uphone %></td>
                            <td style="padding:0.8rem;">
                                <% if ("admin".equals(urole)) { %>
                                    <span style="background:#5c3d2e; color:white; padding:0.2rem 0.6rem; border-radius:20px; font-size:0.8rem;">Admin</span>
                                <% } else { %>
                                    <span style="background:#e8f4fd; color:#2980b9; padding:0.2rem 0.6rem; border-radius:20px; font-size:0.8rem;">Customer</span>
                                <% } %>
                            </td>
                            <td style="padding:0.8rem;">
                                <% if ("Locked".equals(ustatus)) { %>
                                    <span style="color:#dc3545; font-weight:600;">&#128274; Locked</span>
                                <% } else { %>
                                    <span style="color:green;">&#10003; Active</span>
                                <% } %>
                                <% if (!"0".equals(ufailed)) { %><br><small style="color:#aaa;"><%= ufailed %> failed attempts</small><% } %>
                            </td>
                            <td style="padding:0.8rem; color:#888;"><%= ujoined %></td>
                            <td style="padding:0.8rem;">
                                <% if (!isCurrentAdmin) { %>
                                    <% if ("Locked".equals(ustatus)) { %>
                                        <form action="<%= request.getContextPath() %>/AdminUsersServlet" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="unlock">
                                            <input type="hidden" name="user_id" value="<%= uid %>">
                                            <button type="submit" class="btn btn-outline btn-sm">Unlock</button>
                                        </form>
                                    <% } %>
                                    <form action="<%= request.getContextPath() %>/AdminUsersServlet" method="post" style="display:inline;" onsubmit="return confirm('Delete user <%= uname %>? This cannot be undone.');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="user_id" value="<%= uid %>">
                                        <button type="submit" class="btn btn-sm" style="background:#dc3545; color:white; border:none;">Delete</button>
                                    </form>
                                <% } else { %>
                                    <span style="color:#aaa; font-size:0.85rem;">You</span>
                                <% } %>
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
</div>

<footer class="footer">
    <div class="container"><p>&copy; 2025 La Farine Pâtisserie</p></div>
</footer>
</body>
</html>