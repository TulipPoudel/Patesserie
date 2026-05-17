<%-- FILE LOCATION: WEB-INF/pages/admin-pastries.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) { response.sendRedirect(request.getContextPath() + "/LoginServlet"); return; }
    String ctx = request.getContextPath();
    List<String[]> pastries   = (List<String[]>) request.getAttribute("pastries");
    List<String[]> categories = (List<String[]>) request.getAttribute("categories");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Menu – L'Atelier Sucré Admin</title>
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
        .admin-card-title { font-family:var(--font-ui); font-size:0.72rem; letter-spacing:0.14em; text-transform:uppercase; color:var(--brown-mid); margin-bottom:1.4rem; }
        .form-row { display:grid; grid-template-columns:1fr 1fr; gap:1rem; }
        .form-group { display:flex; flex-direction:column; gap:0.3rem; }
        .form-group label { font-family:var(--font-ui); font-size:0.72rem; letter-spacing:0.08em; text-transform:uppercase; color:var(--gray); }
        .form-group input, .form-group select, .form-group textarea {
            padding:0.65rem 0.9rem; border:1px solid var(--gray-light); border-radius:var(--radius);
            font-family:var(--font-ui); font-size:0.88rem; color:var(--brown-dark);
            background:var(--cream); transition:border-color 0.2s;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { outline:none; border-color:var(--gold); }
        .form-full { grid-column:1/-1; }
        .check-row { display:flex; align-items:center; gap:0.6rem; padding-top:1.4rem; font-family:var(--font-ui); font-size:0.85rem; color:var(--brown-mid); }
        .check-row input { width:16px; height:16px; accent-color:var(--gold); }
        .admin-table { width:100%; border-collapse:collapse; font-size:0.87rem; }
        .admin-table th { font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.12em; text-transform:uppercase; color:var(--gray); padding:0.7rem 1rem; border-bottom:2px solid var(--gray-light); text-align:left; }
        .admin-table td { padding:0.9rem 1rem; border-bottom:1px solid var(--gray-light); color:var(--brown-dark); vertical-align:middle; }
        .admin-table tr:last-child td { border-bottom:none; }
        .admin-table tr:hover td { background:var(--parchment); }
        .cat-tag { background:var(--gold-pale); color:var(--brown-mid); padding:0.2rem 0.65rem; border-radius:20px; font-size:0.75rem; font-family:var(--font-ui); }
        .avail-yes { color:var(--green); font-weight:600; font-size:0.82rem; }
        .avail-no  { color:var(--gray); font-size:0.82rem; }
        .btn-edit { background:none; border:1px solid var(--gold); color:var(--brown-mid); padding:0.3rem 0.8rem; border-radius:20px; font-family:var(--font-ui); font-size:0.72rem; letter-spacing:0.06em; cursor:pointer; transition:all 0.2s; }
        .btn-edit:hover { background:var(--gold-pale); }
        .btn-del { background:none; border:1px solid var(--red); color:var(--red); padding:0.3rem 0.8rem; border-radius:20px; font-family:var(--font-ui); font-size:0.72rem; letter-spacing:0.06em; cursor:pointer; transition:all 0.2s; }
        .btn-del:hover { background:#fce8e8; }
        .alert-ok  { background:#e8f5e9; color:#2e7d32; padding:0.9rem 1.2rem; border-radius:var(--radius); margin-bottom:1.2rem; font-family:var(--font-ui); font-size:0.85rem; }
        .alert-err { background:#fce8e8; color:var(--red); padding:0.9rem 1.2rem; border-radius:var(--radius); margin-bottom:1.2rem; font-family:var(--font-ui); font-size:0.85rem; }

        /* Edit modal */
        .modal-overlay { display:none; position:fixed; inset:0; background:rgba(20,10,4,0.6); z-index:5000; align-items:center; justify-content:center; backdrop-filter:blur(3px); }
        .modal-overlay.open { display:flex; }
        .modal-box { background:var(--warm-white); border-radius:var(--radius); padding:2rem; width:90%; max-width:520px; box-shadow:var(--shadow-lg); border-top:3px solid var(--gold); }
        .modal-box h3 { font-family:var(--font-display); font-size:1.4rem; font-weight:400; color:var(--brown-dark); margin-bottom:1.4rem; }
        .modal-actions { display:flex; gap:0.8rem; margin-top:1.4rem; }
        .btn-primary-admin { background:var(--brown); color:white; border:none; padding:0.65rem 1.6rem; border-radius:var(--radius); font-family:var(--font-ui); font-size:0.8rem; letter-spacing:0.08em; text-transform:uppercase; cursor:pointer; transition:background 0.2s; }
        .btn-primary-admin:hover { background:var(--brown-dark); }
        .btn-cancel { background:none; border:1px solid var(--gray-light); color:var(--gray); padding:0.65rem 1.6rem; border-radius:var(--radius); font-family:var(--font-ui); font-size:0.8rem; letter-spacing:0.08em; text-transform:uppercase; cursor:pointer; }
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
            <a href="<%= ctx %>/AdminPastriesServlet" class="sidebar-link active">Menu Items</a>
            <a href="<%= ctx %>/AdminUsersServlet" class="sidebar-link">Users</a>
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
            <h1>Menu Items</h1>
            <p>Add, edit, or remove items from the pastry menu.</p>
        </div>

        <% if (request.getAttribute("error")   != null) { %><div class="alert-err">⚠ <%= request.getAttribute("error") %></div><% } %>
        <% if (request.getAttribute("success") != null) { %><div class="alert-ok">✓ <%= request.getAttribute("success") %></div><% } %>

        <!-- Add new item -->
        <div class="admin-card">
            <div class="admin-card-title">+ Add New Item</div>
            <form action="<%= ctx %>/AdminPastriesServlet" method="post">
                <input type="hidden" name="action" value="create">
                <div class="form-row">
                    <div class="form-group">
                        <label>Item Name *</label>
                        <input type="text" name="name" required placeholder="e.g. Butter Croissant">
                    </div>
                    <div class="form-group">
                        <label>Price (£) *</label>
                        <input type="number" name="price" step="0.01" min="0" required placeholder="e.g. 2.50">
                    </div>
                    <div class="form-group">
                        <label>Category *</label>
                        <select name="category_id" required>
                            <% if (categories != null) { for (String[] cat : categories) { %>
                                <option value="<%= cat[0] %>"><%= cat[1] %></option>
                            <% }} %>
                        </select>
                    </div>
                    <div class="check-row">
                        <input type="checkbox" name="is_available" id="availCreate" checked>
                        <label for="availCreate">Available on menu</label>
                    </div>
                    <div class="form-group form-full">
                        <label>Description *</label>
                        <textarea name="description" required rows="2" placeholder="Brief description..."></textarea>
                    </div>
                </div>
                <button type="submit" class="btn-primary-admin" style="margin-top:1.2rem;">Add Item</button>
            </form>
        </div>

        <!-- Items table -->
        <div class="admin-card">
            <div class="admin-card-title">Current Menu Items (<%= pastries != null ? pastries.size() : 0 %> items)</div>
            <% if (pastries == null || pastries.isEmpty()) { %>
                <p style="color:var(--gray); text-align:center; padding:2rem; font-family:var(--font-display); font-style:italic;">No items yet. Add your first item above.</p>
            <% } else { %>
            <div style="overflow-x:auto;">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Name</th><th>Category</th><th>Price</th><th>Status</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <% for (String[] p : pastries) {
                       String pid=p[0], pname=p[1], pdesc=p[2], pprice=p[3], pcatId=p[4], pcatName=p[5], pavail=p[6];
                %>
                    <tr>
                        <td>
                            <strong style="font-family:var(--font-display); font-size:1rem;"><%= pname %></strong><br>
                            <small style="color:var(--gray); font-size:0.78rem;"><%= pdesc.length() > 55 ? pdesc.substring(0,55)+"…" : pdesc %></small>
                        </td>
                        <td><span class="cat-tag"><%= pcatName %></span></td>
                        <td style="font-family:var(--font-display); font-size:1rem;">£<%= pprice %></td>
                        <td>
                            <% if ("1".equals(pavail)) { %><span class="avail-yes">✓ Available</span>
                            <% } else { %><span class="avail-no">✗ Hidden</span><% } %>
                        </td>
                        <td style="display:flex; gap:0.5rem; align-items:center;">
                            <button class="btn-edit" onclick="showEdit('<%= pid %>','<%= pname.replace("'","\\'") %>','<%= pdesc.replace("'","\\'") %>','<%= pprice %>','<%= pcatId %>','<%= pavail %>')">Edit</button>
                            <form action="<%= ctx %>/AdminPastriesServlet" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="pastry_id" value="<%= pid %>">
                                <button type="button" class="btn-del" onclick="adminConfirm('Delete <strong><%= pname %></strong> from the menu? This cannot be undone.', this.closest('form'))">Delete</button>
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

<!-- Edit modal -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box">
        <h3>Edit Menu Item</h3>
        <form action="<%= ctx %>/AdminPastriesServlet" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="pastry_id" id="editId">
            <div class="form-row">
                <div class="form-group">
                    <label>Name</label>
                    <input type="text" name="name" id="editName" required>
                </div>
                <div class="form-group">
                    <label>Price (£)</label>
                    <input type="number" name="price" id="editPrice" step="0.01" min="0" required>
                </div>
                <div class="form-group">
                    <label>Category</label>
                    <select name="category_id" id="editCat">
                        <% if (categories != null) { for (String[] cat : categories) { %>
                            <option value="<%= cat[0] %>"><%= cat[1] %></option>
                        <% }} %>
                    </select>
                </div>
                <div class="check-row">
                    <input type="checkbox" name="is_available" id="editAvail">
                    <label for="editAvail">Available on menu</label>
                </div>
                <div class="form-group form-full">
                    <label>Description</label>
                    <textarea name="description" id="editDesc" rows="2"></textarea>
                </div>
            </div>
            <div class="modal-actions">
                <button type="submit" class="btn-primary-admin">Save Changes</button>
                <button type="button" class="btn-cancel" onclick="closeEdit()">Cancel</button>
            </div>
        </form>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

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
function showEdit(id, name, desc, price, catId, avail) {
    document.getElementById('editId').value    = id;
    document.getElementById('editName').value  = name;
    document.getElementById('editDesc').value  = desc;
    document.getElementById('editPrice').value = price;
    document.getElementById('editCat').value   = catId;
    document.getElementById('editAvail').checked = (avail === '1');
    document.getElementById('editModal').classList.add('open');
}
function closeEdit() { document.getElementById('editModal').classList.remove('open'); }
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeEdit(); });

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