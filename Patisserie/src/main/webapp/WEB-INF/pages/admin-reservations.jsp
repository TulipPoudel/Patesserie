<%-- FILE LOCATION: WEB-INF/pages/admin-reservations.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/LoginServlet"); return; }
    if (!"admin".equals(user.getRole())) { response.sendRedirect(request.getContextPath() + "/DashboardServlet"); return; }
    String ctx = request.getContextPath();
    List<String[]> reservations = (List<String[]>) request.getAttribute("reservations");
    String statusFilter = (String) request.getAttribute("statusFilter");
    int totalRes     = request.getAttribute("totalRes")     != null ? (int) request.getAttribute("totalRes")     : 0;
    int pendingRes   = request.getAttribute("pendingRes")   != null ? (int) request.getAttribute("pendingRes")   : 0;
    int confirmedRes = request.getAttribute("confirmedRes") != null ? (int) request.getAttribute("confirmedRes") : 0;
    int cancelledRes = request.getAttribute("cancelledRes") != null ? (int) request.getAttribute("cancelledRes") : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservations – Admin</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=2">
    <style>
        body { display:flex; flex-direction:column; min-height:100vh; background:var(--cream); }
        .admin-shell { display:flex; flex:1; padding-top:var(--nav-h); }
        .admin-sidebar {
            width:240px; min-height:calc(100vh - var(--nav-h));
            background:var(--brown-dark); color:var(--cream);
            display:flex; flex-direction:column;
            position:fixed; top:var(--nav-h); left:0; bottom:0;
            z-index:100; overflow-y:auto;
        }
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
        .admin-main { margin-left:240px; flex:1; padding:2.5rem 2rem; max-width:calc(100vw - 240px); }
        .admin-topbar { position:fixed; top:0; left:0; right:0; height:var(--nav-h); background:var(--brown-dark); z-index:200; display:flex; align-items:center; justify-content:space-between; padding:0 2rem; }
        .admin-topbar .tb-brand { font-family:var(--font-display); font-size:1.2rem; color:var(--gold-light); letter-spacing:0.04em; text-decoration:none; }
        .admin-topbar .tb-brand span { font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.15em; text-transform:uppercase; color:rgba(255,255,255,0.4); margin-left:0.6rem; }
        .admin-topbar .tb-right { display:flex; align-items:center; gap:1.2rem; }
        .admin-topbar .tb-user { font-family:var(--font-ui); font-size:0.8rem; color:rgba(255,255,255,0.6); letter-spacing:0.04em; }
        .admin-topbar .tb-logout { font-family:var(--font-ui); font-size:0.75rem; letter-spacing:0.1em; text-transform:uppercase; color:var(--gold-light); text-decoration:none; padding:0.4rem 1rem; border:1px solid rgba(201,168,76,0.4); border-radius:20px; transition:all 0.2s; }
        .admin-topbar .tb-logout:hover { background:rgba(201,168,76,0.15); }
        .admin-stats { display:grid; grid-template-columns:repeat(4,1fr); gap:1.2rem; margin-bottom:2rem; }
        .admin-stat-card { background:var(--warm-white); border-radius:var(--radius); padding:1.4rem 1.6rem; box-shadow:var(--shadow); border-top:3px solid var(--gold); }
        .admin-stat-card.green { border-top-color:var(--green); }
        .admin-stat-card.red   { border-top-color:var(--red); }
        .admin-stat-card.brown { border-top-color:var(--brown); }
        .stat-icon { font-size:1.4rem; margin-bottom:0.6rem; }
        .stat-val { font-family:var(--font-display); font-size:2.2rem; font-weight:500; color:var(--brown-dark); line-height:1; }
        .stat-lbl { font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.14em; text-transform:uppercase; color:var(--gray); margin-top:0.3rem; }
        .filter-bar { display:flex; gap:0.6rem; margin-bottom:1.5rem; flex-wrap:wrap; }
        .filter-btn { font-family:var(--font-ui); font-size:0.75rem; letter-spacing:0.08em; text-transform:uppercase; padding:0.45rem 1.1rem; border-radius:20px; border:1px solid var(--gray-light); background:var(--warm-white); color:var(--gray); text-decoration:none; transition:all 0.2s; }
        .filter-btn:hover, .filter-btn.active { background:var(--brown-dark); color:var(--gold-light); border-color:var(--brown-dark); }
        .admin-table { width:100%; border-collapse:collapse; font-size:0.87rem; }
        .admin-table th { font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.12em; text-transform:uppercase; color:var(--gray); padding:0.6rem 1rem; border-bottom:2px solid var(--gray-light); text-align:left; }
        .admin-table td { padding:0.85rem 1rem; border-bottom:1px solid var(--gray-light); color:var(--brown-dark); vertical-align:middle; }
        .admin-table tr:last-child td { border-bottom:none; }
        .admin-table tr:hover td { background:var(--parchment); }
        .badge-pending   { background:#fff8e1; color:#f59e0b; padding:0.2rem 0.7rem; border-radius:20px; font-size:0.72rem; font-family:var(--font-ui); font-weight:600; }
        .badge-confirmed { background:#e8f5e9; color:#2e7d32; padding:0.2rem 0.7rem; border-radius:20px; font-size:0.72rem; font-family:var(--font-ui); font-weight:600; }
        .badge-cancelled { background:#fce8e8; color:#c62828; padding:0.2rem 0.7rem; border-radius:20px; font-size:0.72rem; font-family:var(--font-ui); font-weight:600; }
        .action-form { display:inline; }
    </style>
</head>
<body>

<nav class="admin-topbar">
    <a href="<%= ctx %>/AdminDashboardServlet" class="tb-brand">
        L'Atelier Sucré <span>Admin Panel</span>
    </a>
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
            <a href="<%= ctx %>/AdminDashboardServlet" class="sidebar-link">
                Dashboard
            </a>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-label">Manage</div>
            <a href="<%= ctx %>/AdminPastriesServlet" class="sidebar-link">
                Menu Items
            </a>
            <a href="<%= ctx %>/AdminUsersServlet" class="sidebar-link">
                Users
            </a>
            <a href="<%= ctx %>/AdminOrdersServlet" class="sidebar-link">
                Orders
            </a>
            <a href="<%= ctx %>/AdminReservationsServlet" class="sidebar-link active">
                Reservations
            </a>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-label">Store</div>
            <a href="<%= ctx %>/DashboardServlet" class="sidebar-link">
                View Store
            </a>
        </div>
        <div class="sidebar-footer">
            Signed in as<br><strong style="color:var(--gold-light);"><%= user.getEmail() %></strong>
        </div>
    </aside>

    <main class="admin-main">
        <div style="margin-bottom:2rem;">
            <h1 style="font-family:var(--font-display); font-size:2rem; font-weight:400; color:var(--brown-dark); margin-bottom:0.25rem;">Reservations</h1>
            <p style="font-family:var(--font-ui); font-size:0.82rem; color:var(--gray); letter-spacing:0.04em;">View and manage all customer table bookings.</p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div style="background:#fce8e8; color:var(--red); padding:1rem 1.2rem; border-radius:var(--radius); margin-bottom:1.5rem; font-family:var(--font-ui); font-size:0.85rem;">
                ⚠ <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <!-- Stat cards -->
        <div class="admin-stats">
            <div class="admin-stat-card">
                <div class="stat-val"><%= totalRes %></div>
                <div class="stat-lbl">Total Reservations</div>
            </div>
            <div class="admin-stat-card brown">
                <div class="stat-val"><%= pendingRes %></div>
                <div class="stat-lbl">Pending</div>
            </div>
            <div class="admin-stat-card green">
                <div class="stat-val"><%= confirmedRes %></div>
                <div class="stat-lbl">Confirmed</div>
            </div>
            <div class="admin-stat-card red">
                <div class="stat-val"><%= cancelledRes %></div>
                <div class="stat-lbl">Cancelled</div>
            </div>
        </div>

        <!-- Filter bar -->
        <div class="filter-bar">
            <a href="<%= ctx %>/AdminReservationsServlet?status=all"       class="filter-btn <%= "all".equals(statusFilter)       ? "active" : "" %>">All</a>
            <a href="<%= ctx %>/AdminReservationsServlet?status=pending"   class="filter-btn <%= "pending".equals(statusFilter)   ? "active" : "" %>">Pending</a>
            <a href="<%= ctx %>/AdminReservationsServlet?status=confirmed" class="filter-btn <%= "confirmed".equals(statusFilter) ? "active" : "" %>">Confirmed</a>
            <a href="<%= ctx %>/AdminReservationsServlet?status=cancelled" class="filter-btn <%= "cancelled".equals(statusFilter) ? "active" : "" %>">Cancelled</a>
        </div>

        <!-- Table -->
        <div style="background:var(--warm-white); border-radius:var(--radius); box-shadow:var(--shadow); overflow:auto;">
            <% if (reservations == null || reservations.isEmpty()) { %>
                <div style="padding:3rem; text-align:center; font-family:var(--font-ui); color:var(--gray);">
                    No reservations found.
                </div>
            <% } else { %>
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Account</th>
                            <th>Guest Name</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Guests</th>
                            <th>Location</th>
                            <th>Notes</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (String[] r : reservations) {
                            // [0]id [1]userName [2]guestName [3]email [4]phone [5]date [6]time [7]guests [8]location [9]notes [10]status [11]createdAt
                            String statusClass = "badge-" + r[10];
                        %>
                        <tr>
                            <td style="color:var(--gray); font-size:0.8rem;">#<%= r[0] %></td>
                            <td><%= r[1] %><br><small style="color:#aaa;"><%= r[3] %></small></td>
                            <td><%= r[2] %></td>
                            <td><%= r[5] %></td>
                            <td><%= r[6] %></td>
                            <td><%= r[7] %></td>
                            <td><%= r[8] %></td>
                            <td style="color:#888; font-size:0.82rem;"><%= r[9].equals("-") ? "—" : r[9] %></td>
                            <td><span class="<%= statusClass %>"><%= r[10] %></span></td>
                            <td>
                                <% if (!"confirmed".equals(r[10])) { %>
                                    <form class="action-form" method="post" action="<%= ctx %>/AdminReservationsServlet">
                                        <input type="hidden" name="action" value="confirm">
                                        <input type="hidden" name="reservationId" value="<%= r[0] %>">
                                        <button type="submit" class="btn btn-primary btn-sm">Confirm</button>
                                    </form>
                                <% } %>
                                <% if (!"cancelled".equals(r[10])) { %>
                                    <form class="action-form" method="post" action="<%= ctx %>/AdminReservationsServlet"
                                          style="margin-left:0.3rem;">
                                        <input type="hidden" name="action" value="cancel">
                                        <input type="hidden" name="reservationId" value="<%= r[0] %>">
                                        <button type="button" class="btn btn-outline btn-sm" style="color:var(--red); border-color:var(--red);" onclick="adminConfirm('Cancel this reservation for <strong><%= r[1] %></strong>?', this.closest('form'))">Cancel</button>
                                    </form>
                                <% } %>
                                <% if ("cancelled".equals(r[10])) { %>
                                    <form class="action-form" method="post" action="<%= ctx %>/AdminReservationsServlet" style="margin-left:0.3rem;">
                                        <input type="hidden" name="action" value="pending">
                                        <input type="hidden" name="reservationId" value="<%= r[0] %>">
                                        <button type="submit" class="btn btn-outline btn-sm">Restore</button>
                                    </form>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
    </main>
</div>

<!-- ── Custom Confirm Modal ── -->
<div id="adminModal" style="display:none; position:fixed; inset:0; z-index:9999; align-items:center; justify-content:center;">
    <div style="position:absolute; inset:0; background:rgba(0,0,0,0.55);" onclick="adminModalClose()"></div>
    <div style="position:relative; background:#fff8f2; border-radius:12px; padding:2rem 2rem 1.5rem; min-width:320px; max-width:420px; width:90%; box-shadow:0 8px 40px rgba(44,24,16,0.28); border-top:4px solid var(--gold,#c9a84c);">
        <div style="font-family:var(--font-display,Georgia,serif); font-size:1.1rem; color:var(--brown-dark,#2c1810); margin-bottom:1.5rem; line-height:1.5;" id="adminModalMsg"></div>
        <div style="display:flex; gap:0.75rem; justify-content:flex-end;">
            <button onclick="adminModalClose()" style="padding:0.55rem 1.3rem; border:1.5px solid #d8cfc6; background:#fff; border-radius:8px; font-family:var(--font-ui,sans-serif); font-size:0.82rem; letter-spacing:0.06em; cursor:pointer; color:var(--brown-dark,#2c1810);">Cancel</button>
            <button id="adminModalOk" style="padding:0.55rem 1.3rem; background:var(--brown-dark,#2c1810); color:#fff; border:none; border-radius:8px; font-family:var(--font-ui,sans-serif); font-size:0.82rem; letter-spacing:0.06em; cursor:pointer;">Confirm</button>
        </div>
    </div>
</div>

<script>
var _pendingForm = null;
function adminConfirm(msg, form) {
    _pendingForm = form;
    document.getElementById('adminModalMsg').innerHTML = msg;
    document.getElementById('adminModal').style.display = 'flex';
}
function adminModalClose() {
    _pendingForm = null;
    document.getElementById('adminModal').style.display = 'none';
}
document.getElementById('adminModalOk').addEventListener('click', function() {
    if (_pendingForm) { _pendingForm.submit(); }
    adminModalClose();
});
</script>

</body>
</html>