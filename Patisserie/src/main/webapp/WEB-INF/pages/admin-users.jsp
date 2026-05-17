<%-- FILE LOCATION: WEB-INF/pages/admin-users.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) { response.sendRedirect(request.getContextPath() + "/LoginServlet"); return; }
    String ctx = request.getContextPath();
    List<String[]> users = (List<String[]>) request.getAttribute("users");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users – L'Atelier Sucré Admin</title>
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
        .admin-main { margin-left:240px; flex:1; padding:2.5rem 2rem; }
        .admin-topbar { position:fixed; top:0; left:0; right:0; height:var(--nav-h); background:var(--brown-dark); z-index:200; display:flex; align-items:center; justify-content:space-between; padding:0 2rem; }
        .admin-topbar .tb-brand { font-family:var(--font-display); font-size:1.2rem; color:var(--gold-light); letter-spacing:0.04em; text-decoration:none; }
        .admin-topbar .tb-brand span { font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.15em; text-transform:uppercase; color:rgba(255,255,255,0.4); margin-left:0.6rem; }
        .admin-topbar .tb-right { display:flex; align-items:center; gap:1.2rem; }
        .admin-topbar .tb-user { font-family:var(--font-ui); font-size:0.8rem; color:rgba(255,255,255,0.6); }
        .admin-topbar .tb-logout { font-family:var(--font-ui); font-size:0.75rem; letter-spacing:0.1em; text-transform:uppercase; color:var(--gold-light); text-decoration:none; padding:0.4rem 1rem; border:1px solid rgba(201,168,76,0.4); border-radius:20px; transition:all 0.2s; }
        .admin-topbar .tb-logout:hover { background:rgba(201,168,76,0.15); }
        .admin-page-header { margin-bottom:2rem; }
        .admin-page-header h1 { font-family:var(--font-display); font-size:2rem; font-weight:400; color:var(--brown-dark); margin-bottom:0.25rem; }
        .admin-page-header p { font-family:var(--font-ui); font-size:0.82rem; color:var(--gray); letter-spacing:0.04em; }
        .admin-card { background:var(--warm-white); border-radius:var(--radius); box-shadow:var(--shadow); padding:1.8rem; margin-bottom:1.5rem; }
        .admin-card-title { font-family:var(--font-ui); font-size:0.72rem; letter-spacing:0.14em; text-transform:uppercase; color:var(--brown-mid); margin-bottom:1.4rem; display:flex; justify-content:space-between; align-items:center; }
        .admin-table { width:100%; border-collapse:collapse; font-size:0.87rem; }
        .admin-table th { font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.12em; text-transform:uppercase; color:var(--gray); padding:0.7rem 1rem; border-bottom:2px solid var(--gray-light); text-align:left; }
        .admin-table td { padding:0.9rem 1rem; border-bottom:1px solid var(--gray-light); color:var(--brown-dark); vertical-align:middle; }
        .admin-table tr:last-child td { border-bottom:none; }
        .admin-table tr:hover td { background:var(--parchment); }
        .badge-admin    { background:var(--brown); color:white; padding:0.2rem 0.65rem; border-radius:20px; font-size:0.72rem; font-family:var(--font-ui); letter-spacing:0.06em; }
        .badge-customer { background:var(--gold-pale); color:var(--brown-mid); padding:0.2rem 0.65rem; border-radius:20px; font-size:0.72rem; font-family:var(--font-ui); }
        .badge-active   { background:#e8f5e9; color:#2e7d32; padding:0.2rem 0.65rem; border-radius:20px; font-size:0.72rem; font-family:var(--font-ui); }
        .badge-locked   { background:#fce8e8; color:var(--red); padding:0.2rem 0.65rem; border-radius:20px; font-size:0.72rem; font-family:var(--font-ui); }
        .btn-unlock { background:none; border:1px solid var(--green); color:var(--green); padding:0.3rem 0.8rem; border-radius:20px; font-family:var(--font-ui); font-size:0.72rem; cursor:pointer; transition:all 0.2s; }
        .btn-unlock:hover { background:#e8f5e9; }
        .btn-del { background:none; border:1px solid var(--red); color:var(--red); padding:0.3rem 0.8rem; border-radius:20px; font-family:var(--font-ui); font-size:0.72rem; cursor:pointer; transition:all 0.2s; }
        .btn-del:hover { background:#fce8e8; }
        .btn-role { background:none; border:1px solid var(--gold); color:var(--brown); padding:0.3rem 0.8rem; border-radius:20px; font-family:var(--font-ui); font-size:0.72rem; cursor:pointer; transition:all 0.2s; }
        .btn-role:hover { background:var(--gold-pale); }
        .search-bar { padding:0.55rem 1rem; border:1px solid var(--gray-light); border-radius:20px; font-family:var(--font-ui); font-size:0.82rem; color:var(--brown-dark); background:var(--cream); width:220px; }
        .search-bar:focus { outline:none; border-color:var(--gold); }
        .alert-ok  { background:#e8f5e9; color:#2e7d32; padding:0.9rem 1.2rem; border-radius:var(--radius); margin-bottom:1.2rem; font-family:var(--font-ui); font-size:0.85rem; }
        .alert-err { background:#fce8e8; color:var(--red); padding:0.9rem 1.2rem; border-radius:var(--radius); margin-bottom:1.2rem; font-family:var(--font-ui); font-size:0.85rem; }
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
            <a href="<%= ctx %>/AdminUsersServlet" class="sidebar-link active">Users</a>
            <a href="<%= ctx %>/AdminOrdersServlet" class="sidebar-link">Orders</a>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-label">Store</div>
            <a href="<%= ctx %>/DashboardServlet" class="sidebar-link">View Store</a>
        </div>
        <div class="sidebar-footer">Signed in as<br><strong style="color:var(--gold-light);"><%= user.getEmail() %></strong></div>
    </aside>

    <main class="admin-main">
        <div class="admin-page-header">
            <h1>Users</h1>
            <p>View, unlock, or remove user accounts.</p>
        </div>

        <% if (request.getAttribute("error")   != null) { %><div class="alert-err">⚠ <%= request.getAttribute("error") %></div><% } %>
        <% if (request.getAttribute("success") != null) { %><div class="alert-ok">✓ <%= request.getAttribute("success") %></div><% } %>

        <div class="admin-card">
            <div class="admin-card-title">
                <span>All Users (<%= users != null ? users.size() : 0 %>)</span>
                <input type="text" class="search-bar" id="userSearch" placeholder="Search users..." oninput="filterUsers(this.value)">
            </div>

            <% if (users == null || users.isEmpty()) { %>
                <p style="color:var(--gray); text-align:center; padding:2rem; font-family:var(--font-display); font-style:italic;">No users found.</p>
            <% } else { %>
            <div style="overflow-x:auto;">
            <table class="admin-table" id="usersTable">
                <thead>
                    <tr>
                        <th>#</th><th>Name</th><th>Email</th><th>Phone</th><th>Role</th><th>Status</th><th>Joined</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <% for (String[] u : users) {
                       String uid=u[0], uname=u[1], uemail=u[2], uphone=u[3], urole=u[4], ufailed=u[5], ustatus=u[6];
                       String ujoined = u[7] != null ? u[7].substring(0,10) : "-";
                       boolean isMe = uid.equals(String.valueOf(user.getUserId()));
                %>
                    <tr>
                        <td style="color:var(--gray); font-size:0.8rem;">#<%= uid %></td>
                        <td><strong style="font-family:var(--font-display); font-size:1rem;"><%= uname %></strong></td>
                        <td style="color:var(--gray);"><%= uemail %></td>
                        <td style="color:var(--gray);"><%= uphone %></td>
                        <td>
                            <% if ("admin".equals(urole)) { %><span class="badge-admin">Admin</span>
                            <% } else { %><span class="badge-customer">Customer</span><% } %>
                        </td>
                        <td>
                            <% if ("Locked".equals(ustatus)) { %><span class="badge-locked">Locked — Locked</span>
                            <% } else { %><span class="badge-active">✓ Active</span><% } %>
                            <% if (!"0".equals(ufailed)) { %><br><small style="color:var(--gray); font-size:0.72rem;"><%= ufailed %> failed</small><% } %>
                        </td>
                        <td style="color:var(--gray); font-size:0.82rem;"><%= ujoined %></td>
                        <td style="display:flex; gap:0.5rem; flex-wrap:wrap; align-items:center;">
                            <% if (!isMe) { %>
                                <% if ("Locked".equals(ustatus)) { %>
                                    <form action="<%= ctx %>/AdminUsersServlet" method="post" style="display:inline;">
                                        <input type="hidden" name="action" value="unlock">
                                        <input type="hidden" name="user_id" value="<%= uid %>">
                                        <button type="submit" class="btn-unlock">Unlock</button>
                                    </form>
                                <% } %>
                                <form action="<%= ctx %>/AdminUsersServlet" method="post" style="display:inline;"
                                      onsubmit="return false;">
                                    <input type="hidden" name="action" value="changeRole">
                                    <input type="hidden" name="user_id" value="<%= uid %>">
                                    <input type="hidden" name="role" value="<%= "admin".equals(urole) ? "customer" : "admin" %>">
                                    <button type="button" class="btn-role" onclick="adminConfirm('Change role of &lt;<%= uname %>&gt; to <strong><%= "admin".equals(urole) ? "customer" : "admin" %></strong>?', this.closest('form'))"><%= "admin".equals(urole) ? "→ Customer" : "→ Admin" %></button>
                                </form>
                                <form action="<%= ctx %>/AdminUsersServlet" method="post" style="display:inline;">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="user_id" value="<%= uid %>">
                                    <button type="button" class="btn-del" onclick="adminConfirm('Permanently delete <strong><%= uname %></strong>? This cannot be undone.', this.closest('form'))">Delete</button>
                                </form>
                            <% } else { %>
                                <span style="color:var(--gray); font-size:0.8rem; font-family:var(--font-ui);">You</span>
                            <% } %>
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
function filterUsers(query) {
    var rows = document.querySelectorAll('#usersTable tbody tr');
    query = query.toLowerCase();
    rows.forEach(function(row) {
        row.style.display = row.textContent.toLowerCase().includes(query) ? '' : 'none';
    });
}

var _pendingForm = null;
function adminConfirm(msg, form) {
    _pendingForm = form;
    document.getElementById('adminModalMsg').innerHTML = msg;
    var modal = document.getElementById('adminModal');
    modal.style.display = 'flex';
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