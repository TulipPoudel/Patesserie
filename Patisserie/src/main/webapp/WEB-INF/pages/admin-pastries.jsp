<%-- FILE LOCATION: WEB-INF/pages/admin-pastries.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    List<String[]> pastries   = (List<String[]>) request.getAttribute("pastries");
    List<String[]> categories = (List<String[]>) request.getAttribute("categories");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Menu – La Farine Admin</title>
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
            <a href="<%= request.getContextPath() %>/AdminPastriesServlet" class="active">Manage Menu</a>
            <a href="<%= request.getContextPath() %>/AdminUsersServlet">Manage Users</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </div>
    </div>
</nav>

<div class="page-content">
    <div class="container">

        <h1>Manage Menu Items</h1>
        <p style="color:#888; margin-bottom:1.5rem;">Add, edit, or remove items from the menu.</p>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>

        <%-- ADD NEW ITEM FORM --%>
        <div class="card" style="margin-bottom:2rem;">
            <div class="card-body">
                <h3 style="margin-bottom:1rem;">&#10133; Add New Item</h3>
                <form action="<%= request.getContextPath() %>/AdminPastriesServlet" method="post">
                    <input type="hidden" name="action" value="create">
                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:1rem;">
                        <div>
                            <label style="display:block; margin-bottom:0.3rem; font-size:0.85rem; color:#888;">Item Name *</label>
                            <input type="text" name="name" required placeholder="e.g. Butter Croissant"
                                   style="width:100%; padding:0.6rem; border:1px solid #ddd; border-radius:6px;">
                        </div>
                        <div>
                            <label style="display:block; margin-bottom:0.3rem; font-size:0.85rem; color:#888;">Price (£) *</label>
                            <input type="number" name="price" step="0.01" min="0" required placeholder="e.g. 2.50"
                                   style="width:100%; padding:0.6rem; border:1px solid #ddd; border-radius:6px;">
                        </div>
                        <div>
                            <label style="display:block; margin-bottom:0.3rem; font-size:0.85rem; color:#888;">Category *</label>
                            <select name="category_id" required style="width:100%; padding:0.6rem; border:1px solid #ddd; border-radius:6px;">
                                <% if (categories != null) { for (String[] cat : categories) { %>
                                    <option value="<%= cat[0] %>"><%= cat[1] %></option>
                                <% }} %>
                            </select>
                        </div>
                        <div style="display:flex; align-items:center; gap:0.5rem; padding-top:1.5rem;">
                            <input type="checkbox" name="is_available" id="availCreate" checked style="width:16px; height:16px;">
                            <label for="availCreate">Available on menu</label>
                        </div>
                        <div style="grid-column:1/-1;">
                            <label style="display:block; margin-bottom:0.3rem; font-size:0.85rem; color:#888;">Description *</label>
                            <textarea name="description" required rows="2" placeholder="Brief description..."
                                      style="width:100%; padding:0.6rem; border:1px solid #ddd; border-radius:6px; resize:vertical;"></textarea>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary" style="margin-top:1rem;">Add Item</button>
                </form>
            </div>
        </div>

        <%-- ITEMS TABLE --%>
        <div class="card">
            <div class="card-body">
                <h3 style="margin-bottom:1rem;">&#127859; Current Menu Items (<%= pastries != null ? pastries.size() : 0 %> items)</h3>

                <% if (pastries == null || pastries.isEmpty()) { %>
                    <p style="color:#888; text-align:center; padding:2rem;">No items yet. Add your first item above!</p>
                <% } else { %>
                <div style="overflow-x:auto;">
                <table style="width:100%; border-collapse:collapse; font-size:0.9rem;">
                    <thead>
                        <tr style="background:#f9f6f0; border-bottom:2px solid #eee;">
                            <th style="padding:0.8rem; text-align:left;">Name</th>
                            <th style="padding:0.8rem; text-align:left;">Category</th>
                            <th style="padding:0.8rem; text-align:left;">Price</th>
                            <th style="padding:0.8rem; text-align:left;">Status</th>
                            <th style="padding:0.8rem; text-align:left;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (String[] p : pastries) {
                           String pid    = p[0]; String pname = p[1]; String pdesc = p[2];
                           String pprice = p[3]; String pcatId = p[4]; String pcatName = p[5];
                           String pavail = p[6];
                    %>
                        <tr style="border-bottom:1px solid #f0ebe3;">
                            <td style="padding:0.8rem;">
                                <strong><%= pname %></strong><br>
                                <small style="color:#aaa;"><%= pdesc.length() > 50 ? pdesc.substring(0,50)+"..." : pdesc %></small>
                            </td>
                            <td style="padding:0.8rem;"><span class="category-tag"><%= pcatName %></span></td>
                            <td style="padding:0.8rem;">&pound;<%= pprice %></td>
                            <td style="padding:0.8rem;">
                                <% if ("1".equals(pavail)) { %>
                                    <span style="color:green; font-weight:600;">&#10003; Available</span>
                                <% } else { %>
                                    <span style="color:#aaa;">&#10007; Hidden</span>
                                <% } %>
                            </td>
                            <td style="padding:0.8rem;">
                                <button class="btn btn-outline btn-sm"
                                    onclick="showEdit('<%= pid %>','<%= pname.replace("'","\\'") %>','<%= pdesc.replace("'","\\'") %>','<%= pprice %>','<%= pcatId %>','<%= pavail %>')">Edit</button>
                                <form action="<%= request.getContextPath() %>/AdminPastriesServlet" method="post" style="display:inline;"
                                      onsubmit="return confirm('Delete <%= pname %>?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="pastry_id" value="<%= pid %>">
                                    <button type="submit" class="btn btn-sm" style="background:#dc3545;color:white;border:none;">Delete</button>
                                </form>
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

<%-- EDIT MODAL --%>
<div id="editModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:1000; align-items:center; justify-content:center;">
    <div style="background:white; padding:2rem; border-radius:12px; width:90%; max-width:500px;">
        <h3 style="margin-bottom:1.2rem;">Edit Menu Item</h3>
        <form action="<%= request.getContextPath() %>/AdminPastriesServlet" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="pastry_id" id="editId">
            <div style="display:grid; gap:0.8rem;">
                <div>
                    <label style="font-size:0.85rem; color:#888;">Name</label>
                    <input type="text" name="name" id="editName" required style="width:100%; padding:0.6rem; border:1px solid #ddd; border-radius:6px; margin-top:0.2rem;">
                </div>
                <div>
                    <label style="font-size:0.85rem; color:#888;">Description</label>
                    <textarea name="description" id="editDesc" rows="2" style="width:100%; padding:0.6rem; border:1px solid #ddd; border-radius:6px; margin-top:0.2rem; resize:vertical;"></textarea>
                </div>
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:0.8rem;">
                    <div>
                        <label style="font-size:0.85rem; color:#888;">Price (£)</label>
                        <input type="number" name="price" id="editPrice" step="0.01" min="0" required style="width:100%; padding:0.6rem; border:1px solid #ddd; border-radius:6px; margin-top:0.2rem;">
                    </div>
                    <div>
                        <label style="font-size:0.85rem; color:#888;">Category</label>
                        <select name="category_id" id="editCat" style="width:100%; padding:0.6rem; border:1px solid #ddd; border-radius:6px; margin-top:0.2rem;">
                            <% if (categories != null) { for (String[] cat : categories) { %>
                                <option value="<%= cat[0] %>"><%= cat[1] %></option>
                            <% }} %>
                        </select>
                    </div>
                </div>
                <div style="display:flex; align-items:center; gap:0.5rem;">
                    <input type="checkbox" name="is_available" id="editAvail" style="width:16px; height:16px;">
                    <label for="editAvail">Available on menu</label>
                </div>
            </div>
            <div style="display:flex; gap:0.8rem; margin-top:1.2rem;">
                <button type="submit" class="btn btn-primary" style="flex:1;">Save Changes</button>
                <button type="button" class="btn btn-outline" onclick="closeEdit()" style="flex:1;">Cancel</button>
            </div>
        </form>
    </div>
</div>

<footer class="footer">
    <div class="container"><p>&copy; 2025 La Farine Pâtisserie</p></div>
</footer>

<script>
    function showEdit(id, name, desc, price, catId, avail) {
        document.getElementById('editId').value    = id;
        document.getElementById('editName').value  = name;
        document.getElementById('editDesc').value  = desc;
        document.getElementById('editPrice').value = price;
        document.getElementById('editCat').value   = catId;
        document.getElementById('editAvail').checked = (avail === '1');
        document.getElementById('editModal').style.display = 'flex';
    }
    function closeEdit() {
        document.getElementById('editModal').style.display = 'none';
    }
</script>
</body>
</html>