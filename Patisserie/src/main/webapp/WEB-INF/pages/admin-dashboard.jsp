<%-- FILE LOCATION: WEB-INF/pages/admin-dashboard.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
<%@ page import="jakarta.servlet.http.Cookie" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/LoginServlet"); return; }
    if (!"admin".equals(user.getRole())) { response.sendRedirect(request.getContextPath() + "/DashboardServlet"); return; }
    String ctx = request.getContextPath();
    int totalUsers    = request.getAttribute("totalUsers")    != null ? (int) request.getAttribute("totalUsers")    : 0;
    int totalOrders   = request.getAttribute("totalOrders")   != null ? (int) request.getAttribute("totalOrders")   : 0;
    int totalPastries = request.getAttribute("totalPastries") != null ? (int) request.getAttribute("totalPastries") : 0;
    double totalRev   = request.getAttribute("totalRevenue")  != null ? (double) request.getAttribute("totalRevenue") : 0.0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard – L'Atelier Sucré</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=2">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.0/chart.umd.min.js"></script>
    <style>
        /* ── Admin Layout ─────────────────────────────── */
        body { display: flex; flex-direction: column; min-height: 100vh; background: var(--cream); }

        .admin-shell { display: flex; flex: 1; padding-top: var(--nav-h); }

        /* Sidebar */
        .admin-sidebar {
            width: 240px; min-height: calc(100vh - var(--nav-h));
            background: var(--brown-dark); color: var(--cream);
            display: flex; flex-direction: column;
            position: fixed; top: var(--nav-h); left: 0; bottom: 0;
            z-index: 100; overflow-y: auto;
        }
        .sidebar-brand {
            padding: 1.8rem 1.5rem 1.2rem;
            border-bottom: 1px solid rgba(255,255,255,0.08);
        }
        .sidebar-brand .sb-title {
            font-family: var(--font-display); font-size: 1.1rem; color: var(--gold-light);
            letter-spacing: 0.03em;
        }
        .sidebar-brand .sb-sub {
            font-family: var(--font-ui); font-size: 0.65rem; letter-spacing: 0.15em;
            color: rgba(255,255,255,0.4); text-transform: uppercase; margin-top: 2px;
        }
        .sidebar-section {
            padding: 1.2rem 0 0.5rem;
        }
        .sidebar-label {
            font-family: var(--font-ui); font-size: 0.6rem; letter-spacing: 0.18em;
            text-transform: uppercase; color: rgba(255,255,255,0.3);
            padding: 0 1.5rem 0.5rem;
        }
        .sidebar-link {
            display: flex; align-items: center; gap: 0.75rem;
            padding: 0.7rem 1.5rem; color: rgba(255,255,255,0.65);
            font-family: var(--font-ui); font-size: 0.82rem; letter-spacing: 0.05em;
            text-decoration: none; transition: all 0.2s;
        }
        .sidebar-link:hover { background: rgba(255,255,255,0.07); color: var(--gold-light); }
        .sidebar-link.active { background: rgba(201,168,76,0.15); color: var(--gold-light); border-left: 3px solid var(--gold); }
        .sidebar-link .icon { font-size: 1rem; width: 20px; text-align: center; }
        .sidebar-footer {
            margin-top: auto; padding: 1.2rem 1.5rem;
            border-top: 1px solid rgba(255,255,255,0.08);
            font-family: var(--font-ui); font-size: 0.78rem; color: rgba(255,255,255,0.4);
        }

        /* Main content */
        .admin-main {
            margin-left: 240px; flex: 1; padding: 2.5rem 2rem;
            max-width: calc(100vw - 240px);
        }

        /* Page header */
        .admin-page-header { margin-bottom: 2rem; }
        .admin-page-header h1 {
            font-family: var(--font-display); font-size: 2rem; font-weight: 400;
            color: var(--brown-dark); margin-bottom: 0.25rem;
        }
        .admin-page-header p { font-family: var(--font-ui); font-size: 0.82rem; color: var(--gray); letter-spacing: 0.04em; }

        /* Stat cards */
        .admin-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1.2rem; margin-bottom: 2rem; }
        .admin-stat-card {
            background: var(--warm-white); border-radius: var(--radius);
            padding: 1.4rem 1.6rem; box-shadow: var(--shadow);
            border-top: 3px solid var(--gold);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .admin-stat-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-lg); }
        .admin-stat-card.green { border-top-color: var(--green); }
        .admin-stat-card.red   { border-top-color: var(--red); }
        .admin-stat-card.brown { border-top-color: var(--brown); }
        .stat-icon { font-size: 1.4rem; margin-bottom: 0.6rem; }
        .stat-val {
            font-family: var(--font-display); font-size: 2.2rem; font-weight: 500;
            color: var(--brown-dark); line-height: 1;
        }
        .stat-lbl {
            font-family: var(--font-ui); font-size: 0.65rem; letter-spacing: 0.14em;
            text-transform: uppercase; color: var(--gray); margin-top: 0.3rem;
        }

        /* Charts row */
        .admin-charts { display: grid; grid-template-columns: 2fr 1fr; gap: 1.2rem; margin-bottom: 2rem; }
        .admin-card {
            background: var(--warm-white); border-radius: var(--radius);
            box-shadow: var(--shadow); padding: 1.5rem;
        }
        .admin-card-title {
            font-family: var(--font-ui); font-size: 0.72rem; letter-spacing: 0.14em;
            text-transform: uppercase; color: var(--brown-mid); margin-bottom: 1.2rem;
            display: flex; align-items: center; justify-content: space-between;
        }

        /* Quick links */
        .admin-quick { display: grid; grid-template-columns: repeat(4,1fr); gap: 1rem; margin-bottom: 2rem; }
        .quick-card {
            background: var(--warm-white); border-radius: var(--radius); box-shadow: var(--shadow);
            padding: 1.4rem; text-decoration: none; color: var(--brown-dark);
            display: flex; align-items: center; gap: 1rem;
            border-left: 4px solid var(--gold);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .quick-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-lg); color: var(--brown-dark); }
        .quick-card .qicon { font-size: 1.8rem; }
        .quick-card .qtitle { font-family: var(--font-display); font-size: 1.05rem; }
        .quick-card .qsub { font-family: var(--font-ui); font-size: 0.72rem; color: var(--gray); letter-spacing:0.04em; margin-top:2px; }

        /* Admin navbar override */
        .admin-topbar {
            position: fixed; top: 0; left: 0; right: 0; height: var(--nav-h);
            background: var(--brown-dark); z-index: 200;
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 2rem;
        }
        .admin-topbar .tb-brand {
            font-family: var(--font-display); font-size: 1.2rem; color: var(--gold-light);
            letter-spacing: 0.04em; text-decoration: none;
        }
        .admin-topbar .tb-brand span {
            font-family: var(--font-ui); font-size: 0.65rem; letter-spacing: 0.15em;
            text-transform: uppercase; color: rgba(255,255,255,0.4); margin-left: 0.6rem;
        }
        .admin-topbar .tb-right { display: flex; align-items: center; gap: 1.2rem; }
        .admin-topbar .tb-user {
            font-family: var(--font-ui); font-size: 0.8rem; color: rgba(255,255,255,0.6);
            letter-spacing: 0.04em;
        }
        .admin-topbar .tb-logout {
            font-family: var(--font-ui); font-size: 0.75rem; letter-spacing: 0.1em;
            text-transform: uppercase; color: var(--gold-light); text-decoration: none;
            padding: 0.4rem 1rem; border: 1px solid rgba(201,168,76,0.4); border-radius: 20px;
            transition: all 0.2s;
        }
        .admin-topbar .tb-logout:hover { background: rgba(201,168,76,0.15); color: var(--gold-light); }

        /* Recent orders table */
        .admin-table { width: 100%; border-collapse: collapse; font-size: 0.87rem; }
        .admin-table th {
            font-family: var(--font-ui); font-size: 0.65rem; letter-spacing: 0.12em;
            text-transform: uppercase; color: var(--gray); padding: 0.6rem 1rem;
            border-bottom: 2px solid var(--gray-light); text-align: left;
        }
        .admin-table td { padding: 0.85rem 1rem; border-bottom: 1px solid var(--gray-light); color: var(--brown-dark); }
        .admin-table tr:last-child td { border-bottom: none; }
        .admin-table tr:hover td { background: var(--parchment); }

        .badge-admin    { background: var(--brown); color: white; padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.72rem; font-family: var(--font-ui); letter-spacing: 0.08em; }
        .badge-customer { background: var(--gold-pale); color: var(--brown-mid); padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.72rem; font-family: var(--font-ui); letter-spacing: 0.08em; }
        .badge-active   { background: #e8f5e9; color: #2e7d32; padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.72rem; font-family: var(--font-ui); }
        .badge-locked   { background: #fce8e8; color: var(--red); padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.72rem; font-family: var(--font-ui); }
    </style>
</head>
<body>

<!-- Top bar -->
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

    <!-- Sidebar -->
    <aside class="admin-sidebar">
        <div class="sidebar-brand">
            <div class="sb-title">L'Atelier Sucré</div>
            <div class="sb-sub">Admin Panel</div>
        </div>

        <div class="sidebar-section">
            <div class="sidebar-label">Main</div>
            <a href="<%= ctx %>/AdminDashboardServlet" class="sidebar-link active">
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
            <a href="<%= ctx %>/AdminReservationsServlet" class="sidebar-link">
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

    <!-- Main content -->
    <main class="admin-main">

        <div class="admin-page-header">
            <h1>Dashboard</h1>
            <p>Welcome back, <%= user.getFullName() %> — here's what's happening today.</p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div style="background:#fce8e8; color:var(--red); padding:1rem 1.2rem; border-radius:var(--radius); margin-bottom:1.5rem; font-family:var(--font-ui); font-size:0.85rem;">
                ⚠ <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <!-- Stat cards -->
        <div class="admin-stats">
            <div class="admin-stat-card">
                <div class="stat-val"><%= totalUsers %></div>
                <div class="stat-lbl">Registered Users</div>
            </div>
            <div class="admin-stat-card brown">
                <div class="stat-val"><%= totalOrders %></div>
                <div class="stat-lbl">Total Orders</div>
            </div>
            <div class="admin-stat-card">
                <div class="stat-val"><%= totalPastries %></div>
                <div class="stat-lbl">Menu Items</div>
            </div>
            <div class="admin-stat-card green">
                <div class="stat-val">£<%= String.format("%.0f", totalRev) %></div>
                <div class="stat-lbl">Total Revenue</div>
            </div>
        </div>

        <!-- Charts -->
        <div class="admin-charts">
            <div class="admin-card">
                <div class="admin-card-title">
                    <span>Overview</span>
                </div>
                <canvas id="overviewChart" height="120"></canvas>
            </div>
            <div class="admin-card">
                <div class="admin-card-title"><span>Users vs Orders</span></div>
                <canvas id="donutChart" height="180"></canvas>
            </div>
        </div>

        <!-- Quick nav cards -->
        <div class="admin-quick">
            <a href="<%= ctx %>/AdminPastriesServlet" class="quick-card">
                <div>
                    <div class="qtitle">Manage Menu</div>
                    <div class="qsub">Add, edit or remove pastries</div>
                </div>
            </a>
            <a href="<%= ctx %>/AdminUsersServlet" class="quick-card" style="border-left-color:var(--brown);">
                <div>
                    <div class="qtitle">Manage Users</div>
                    <div class="qsub">View, unlock or remove accounts</div>
                </div>
            </a>
            <a href="<%= ctx %>/AdminReservationsServlet" class="quick-card" style="border-left-color:#f59e0b;">
                <div>
                    <div class="qtitle">Reservations</div>
                    <div class="qsub">View and manage bookings</div>
                </div>
            </a>
            <a href="<%= ctx %>/DashboardServlet" class="quick-card" style="border-left-color:var(--green);">
                <div>
                    <div class="qtitle">View Store</div>
                    <div class="qsub">See the customer-facing site</div>
                </div>
            </a>
        </div>

    </main>
</div>

<script>
// Overview bar chart
var bCtx = document.getElementById('overviewChart').getContext('2d');
new Chart(bCtx, {
    type: 'bar',
    data: {
        labels: ['Users', 'Orders', 'Menu Items'],
        datasets: [{
            label: 'Count',
            data: [<%= totalUsers %>, <%= totalOrders %>, <%= totalPastries %>],
            backgroundColor: ['rgba(201,168,76,0.7)', 'rgba(92,61,46,0.7)', 'rgba(74,124,89,0.7)'],
            borderColor:     ['#c9a84c', '#5c3d2e', '#4a7c59'],
            borderWidth: 2, borderRadius: 6
        }]
    },
    options: {
        responsive: true, plugins: { legend: { display: false } },
        scales: {
            y: { beginAtZero: true, ticks: { precision: 0, font: { family: 'Josefin Sans', size: 11 } }, grid: { color: 'rgba(0,0,0,0.05)' } },
            x: { ticks: { font: { family: 'Josefin Sans', size: 11 } }, grid: { display: false } }
        }
    }
});

// Donut chart
var dCtx = document.getElementById('donutChart').getContext('2d');
new Chart(dCtx, {
    type: 'doughnut',
    data: {
        labels: ['Users', 'Orders'],
        datasets: [{
            data: [<%= totalUsers %>, <%= totalOrders %>],
            backgroundColor: ['rgba(201,168,76,0.8)', 'rgba(92,61,46,0.8)'],
            borderColor: ['#c9a84c', '#5c3d2e'], borderWidth: 2
        }]
    },
    options: {
        responsive: true, cutout: '65%',
        plugins: { legend: { position: 'bottom', labels: { font: { family: 'Josefin Sans', size: 11 }, padding: 12 } } }
    }
});
</script>
</body>
</html>