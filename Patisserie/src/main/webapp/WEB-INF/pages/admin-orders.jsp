<%-- FILE LOCATION: WEB-INF/pages/admin-orders.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User, java.util.List, java.util.Map" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) { response.sendRedirect(request.getContextPath() + "/LoginServlet"); return; }
    String ctx = request.getContextPath();
    List<Map<String, Object>> orders = (List<Map<String, Object>>) request.getAttribute("orders");
    String statusFilter = (String) request.getAttribute("statusFilter");
    if (statusFilter == null) statusFilter = "all";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Orders – L'Atelier Sucré Admin</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=2">
    <style>
        body { display:flex; flex-direction:column; min-height:100vh; background:var(--cream); }
        .admin-shell { display:flex; flex:1; padding-top:var(--nav-h); }
        .admin-sidebar { width:240px; min-height:calc(100vh - var(--nav-h)); background:var(--brown-dark); color:var(--cream); display:flex; flex-direction:column; position:fixed; top:var(--nav-h); left:0; bottom:0; z-index:100; overflow-y:auto; }
        .sidebar-brand { padding:1.8rem 1.5rem 1.2rem; border-bottom:1px solid rgba(255,255,255,0.08); }
        .sidebar-brand .sb-title { font-family:var(--font-display); font-size:1.1rem; color:var(--gold-light); letter-spacing:0.03em; }
        .sidebar-brand .sb-sub { font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.15em; color:rgba(255,255,255,0.4); text-transform:uppercase; margin-top:2px; }
        .sidebar-section { padding:1.2rem 0 0.5rem; }
        .sidebar-label { font-family:var(--font-ui); font-size:0.6rem; letter-spacing:0.18em; text-transform:uppercase; color:rgba(255,255,255,0.3); padding:0 1.5rem 0.5rem; }
        .sidebar-link { display:flex; align-items:center; gap:0.75rem; padding:0.7rem 1.5rem; color:rgba(255,255,255,0.65); font-family:var(--font-ui); font-size:0.82rem; letter-spacing:0.05em; text-decoration:none; transition:all 0.2s; }
        .sidebar-link:hover { background:rgba(255,255,255,0.07); color:var(--gold-light); }
        .sidebar-link.active { background:rgba(201,168,76,0.15); color:var(--gold-light); border-left:3px solid var(--gold); }
        .sidebar-link .icon { font-size:1rem; width:20px; text-align:center; }
        .sidebar-footer { margin-top:auto; padding:1.2rem 1.5rem; border-top:1px solid rgba(255,255,255,0.08); font-family:var(--font-ui); font-size:0.78rem; color:rgba(255,255,255,0.4); }
        .admin-topbar { position:fixed; top:0; left:0; right:0; height:var(--nav-h); background:var(--brown-dark); display:flex; align-items:center; justify-content:space-between; padding:0 2rem; z-index:200; }
        .tb-brand { font-family:var(--font-display); font-size:1.1rem; color:var(--gold-light); text-decoration:none; }
        .tb-brand span { font-size:0.7rem; color:rgba(255,255,255,0.4); font-family:var(--font-ui); letter-spacing:0.1em; margin-left:0.5rem; }
        .tb-right { display:flex; align-items:center; gap:1.5rem; }
        .tb-user { font-family:var(--font-ui); font-size:0.8rem; color:rgba(255,255,255,0.6); }
        .tb-logout { font-family:var(--font-ui); font-size:0.78rem; color:var(--gold-light); text-decoration:none; border:1px solid rgba(201,168,76,0.4); padding:0.3rem 0.9rem; border-radius:20px; transition:all 0.2s; }
        .tb-logout:hover { background:rgba(201,168,76,0.15); }
        .admin-main { flex:1; margin-left:240px; padding:2rem 2.5rem; }
        .admin-page-header { margin-bottom:2rem; }
        .admin-page-header h1 { font-family:var(--font-display); font-size:2rem; color:var(--brown-dark); }
        .admin-page-header p { color:var(--gray); font-family:var(--font-ui); font-size:0.85rem; margin-top:0.3rem; }
        .admin-card { background:white; border-radius:var(--radius); box-shadow:0 2px 12px rgba(0,0,0,0.06); padding:1.5rem; margin-bottom:1.5rem; }
        .admin-card-title { font-family:var(--font-display); font-size:1.1rem; color:var(--brown-dark); margin-bottom:1.2rem; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:0.75rem; }
        .admin-table { width:100%; border-collapse:collapse; font-family:var(--font-ui); font-size:0.83rem; }
        .admin-table th { text-align:left; padding:0.7rem 0.9rem; border-bottom:2px solid var(--gold-pale); color:var(--brown-mid); font-size:0.72rem; letter-spacing:0.08em; text-transform:uppercase; }
        .admin-table td { padding:0.75rem 0.9rem; border-bottom:1px solid var(--gray-light); vertical-align:top; }
        .admin-table tr:last-child td { border-bottom:none; }
        .admin-table tr:hover td { background:var(--parchment); }
        .table-wrap { overflow-x:auto; }
        .badge-pending   { background:#fff3e0; color:#e65100; padding:0.2rem 0.65rem; border-radius:20px; font-size:0.72rem; font-family:var(--font-ui); }
        .badge-confirmed { background:#e3f2fd; color:#1565c0; padding:0.2rem 0.65rem; border-radius:20px; font-size:0.72rem; font-family:var(--font-ui); }
        .badge-preparing { background:#f3e5f5; color:#6a1b9a; padding:0.2rem 0.65rem; border-radius:20px; font-size:0.72rem; font-family:var(--font-ui); }
        .badge-ready     { background:#e8f5e9; color:#2e7d32; padding:0.2rem 0.65rem; border-radius:20px; font-size:0.72rem; font-family:var(--font-ui); }
        .badge-completed { background:#e8f5e9; color:#1b5e20; padding:0.2rem 0.65rem; border-radius:20px; font-size:0.72rem; font-family:var(--font-ui); }
        .badge-cancelled { background:#fce8e8; color:var(--red); padding:0.2rem 0.65rem; border-radius:20px; font-size:0.72rem; font-family:var(--font-ui); }
        .status-select { padding:0.25rem 0.5rem; border:1px solid var(--gray-light); border-radius:6px; font-family:var(--font-ui); font-size:0.78rem; color:var(--brown-dark); background:white; cursor:pointer; }
        .btn-save { background:var(--brown); color:white; border:none; padding:0.3rem 0.8rem; border-radius:20px; font-family:var(--font-ui); font-size:0.72rem; cursor:pointer; transition:all 0.2s; }
        .btn-save:hover { background:var(--brown-dark); }
        .filter-tabs { display:flex; gap:0.5rem; flex-wrap:wrap; margin-bottom:1.2rem; }
        .filter-tab { padding:0.35rem 1rem; border-radius:20px; font-family:var(--font-ui); font-size:0.78rem; text-decoration:none; border:1px solid var(--gray-light); color:var(--gray); transition:all 0.2s; }
        .filter-tab:hover { border-color:var(--gold); color:var(--brown); }
        .filter-tab.active { background:var(--brown); color:white; border-color:var(--brown); }
        .alert-ok  { background:#e8f5e9; color:#2e7d32; padding:0.9rem 1.2rem; border-radius:var(--radius); margin-bottom:1.2rem; font-family:var(--font-ui); font-size:0.85rem; }
        .alert-err { background:#fce8e8; color:var(--red); padding:0.9rem 1.2rem; border-radius:var(--radius); margin-bottom:1.2rem; font-family:var(--font-ui); font-size:0.85rem; }
        .items-list { font-size:0.78rem; color:var(--gray); margin:0; padding:0; list-style:none; }
        .items-list li { margin-bottom:0.15rem; }
    </style>
</head>
<body>

<nav class="admin-topbar">
    <a href="<%= ctx %>/AdminDashboardServlet" class="tb-brand">L'Atelier Sucré <span>Admin Panel</span></a>
    <div class="tb-right">
        <span class="tb-user"><%= user.getFullName() %></span>
        <a href="<%= ctx %>/LogoutServlet" class="tb-logout">Sign Out</a>
    </div>
</nav>

<div class="admin-shell">
    <aside class="admin-sidebar">
        <div class="sidebar-brand">
            <div class="sb-title">L'Atelier Sucré</div>
            <div class="sb-sub">Admin Panel</div>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-label">Main</div>
            <a href="<%= ctx %>/AdminDashboardServlet" class="sidebar-link">Dashboard</a>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-label">Manage</div>
            <a href="<%= ctx %>/AdminPastriesServlet" class="sidebar-link">Menu Items</a>
            <a href="<%= ctx %>/AdminUsersServlet" class="sidebar-link">Users</a>
            <a href="<%= ctx %>/AdminOrdersServlet" class="sidebar-link active">Orders</a>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-label">Store</div>
            <a href="<%= ctx %>/DashboardServlet" class="sidebar-link">View Store</a>
        </div>
        <div class="sidebar-footer">Signed in as<br><strong style="color:var(--gold-light);"><%= user.getEmail() %></strong></div>
    </aside>

    <main class="admin-main">
        <div class="admin-page-header">
            <h1>Orders</h1>
            <p>View and manage all customer orders.</p>
        </div>

        <% if (request.getAttribute("error")   != null) { %><div class="alert-err">⚠ <%= request.getAttribute("error") %></div><% } %>
        <% if (request.getAttribute("success") != null) { %><div class="alert-ok">✓ <%= request.getAttribute("success") %></div><% } %>

        <%-- Status filter tabs --%>
        <div class="filter-tabs">
            <a href="<%= ctx %>/AdminOrdersServlet" class="filter-tab <%= "all".equals(statusFilter) ? "active" : "" %>">All</a>
            <a href="<%= ctx %>/AdminOrdersServlet?status=pending"   class="filter-tab <%= "pending".equals(statusFilter)   ? "active" : "" %>">Pending</a>
            <a href="<%= ctx %>/AdminOrdersServlet?status=confirmed" class="filter-tab <%= "confirmed".equals(statusFilter) ? "active" : "" %>">Confirmed</a>
            <a href="<%= ctx %>/AdminOrdersServlet?status=preparing" class="filter-tab <%= "preparing".equals(statusFilter) ? "active" : "" %>">Preparing</a>
            <a href="<%= ctx %>/AdminOrdersServlet?status=ready"     class="filter-tab <%= "ready".equals(statusFilter)     ? "active" : "" %>">Ready</a>
            <a href="<%= ctx %>/AdminOrdersServlet?status=completed" class="filter-tab <%= "completed".equals(statusFilter) ? "active" : "" %>">Completed</a>
            <a href="<%= ctx %>/AdminOrdersServlet?status=cancelled" class="filter-tab <%= "cancelled".equals(statusFilter) ? "active" : "" %>">Cancelled</a>
        </div>

        <div class="admin-card">
            <div class="admin-card-title">
                <span>Orders (<%= orders != null ? orders.size() : 0 %>)</span>
            </div>

            <% if (orders == null || orders.isEmpty()) { %>
                <p style="color:var(--gray); font-family:var(--font-ui); font-size:0.9rem; padding:1rem 0;">No orders found.</p>
            <% } else { %>
            <div class="table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Date</th>
                            <th>Customer</th>
                            <th>Items</th>
                            <th>Total</th>
                            <th>Status</th>
                            <th>Update</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (Map<String, Object> order : orders) {
                           int orderId = (Integer) order.get("orderId");
                           String createdAt = (String) order.get("createdAt");
                           String displayDate = createdAt != null && createdAt.length() >= 10 ? createdAt.substring(0, 10) : "-";
                           String ostatus = (String) order.get("status");
                           @SuppressWarnings("unchecked")
                           List<Map<String,Object>> oItems = (List<Map<String,Object>>) order.get("items");
                    %>
                        <tr>
                            <td style="color:var(--gray); font-size:0.8rem;"><strong>#<%= orderId %></strong></td>
                            <td style="color:var(--gray); font-size:0.82rem;"><%= displayDate %></td>
                            <td>
                                <strong style="font-family:var(--font-display); font-size:0.95rem;"><%= order.get("customerName") %></strong><br>
                                <span style="color:var(--gray); font-size:0.78rem;"><%= order.get("customerEmail") %></span>
                            </td>
                            <td>
                                <ul class="items-list">
                                <% if (oItems != null) { for (Map<String,Object> it : oItems) { %>
                                    <li><%= it.get("quantity") %>× <%= it.get("productName") %></li>
                                <% } } %>
                                </ul>
                            </td>
                            <td><strong>&pound;<%= String.format("%.2f", (Double) order.get("totalAmount")) %></strong></td>
                            <td><span class="badge-<%= ostatus %>"><%= ostatus %></span></td>
                            <td>
                                <form action="<%= ctx %>/AdminOrdersServlet" method="post" style="display:flex; gap:0.4rem; align-items:center;">
                                    <input type="hidden" name="action"   value="updateStatus">
                                    <input type="hidden" name="order_id" value="<%= orderId %>">
                                    <select name="status" class="status-select">
                                        <option value="pending"   <%= "pending".equals(ostatus)   ? "selected" : "" %>>Pending</option>
                                        <option value="confirmed" <%= "confirmed".equals(ostatus) ? "selected" : "" %>>Confirmed</option>
                                        <option value="preparing" <%= "preparing".equals(ostatus) ? "selected" : "" %>>Preparing</option>
                                        <option value="ready"     <%= "ready".equals(ostatus)     ? "selected" : "" %>>Ready</option>
                                        <option value="completed" <%= "completed".equals(ostatus) ? "selected" : "" %>>Completed</option>
                                        <option value="cancelled" <%= "cancelled".equals(ostatus) ? "selected" : "" %>>Cancelled</option>
                                    </select>
                                    <button type="submit" class="btn-save">Save</button>
                                </form>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
    </main>
</div>

</body>
</html>