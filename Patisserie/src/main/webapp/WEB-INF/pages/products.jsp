<%-- FILE LOCATION: WEB-INF/pages/products.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.LinkedHashSet" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    List<String[]> pastries = (List<String[]>) request.getAttribute("pastries");

    // Collect unique categories for filter buttons
    java.util.Set<String> categorySet = new LinkedHashSet<>();
    if (pastries != null) {
        for (String[] p : pastries) {
            if (p[4] != null) categorySet.add(p[4]);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Our Menu – La Farine Pâtisserie</title>
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
            <a href="<%= request.getContextPath() %>/ProductsServlet" class="active">Menu</a>
            <a href="<%= request.getContextPath() %>/ReservationServlet">Reserve Table</a>
            <a href="<%= request.getContextPath() %>/OrderServlet">My Orders</a>
            <a href="<%= request.getContextPath() %>/ProfileServlet">Profile</a>
            <a href="<%= request.getContextPath() %>/LocationServlet">Locations</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </div>
    </div>
</nav>

<div class="hero">
    <div class="container">
        <h1>&#127859; Our Menu</h1>
        <p>Freshly baked every morning</p>
        <div class="search-bar">
            <input type="text" id="searchInput" placeholder="Search pastries, tarts, eclairs..." oninput="filterProducts()">
            <button class="btn btn-gold" onclick="filterProducts()">Search</button>
        </div>
    </div>
</div>

<div class="page-content">
    <div class="container">

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>

        <%-- Category filter buttons built from DB categories --%>
        <div style="display:flex; gap:0.5rem; flex-wrap:wrap; margin-bottom:1.8rem;">
            <button class="btn btn-primary btn-sm filter-btn active" onclick="filterCategory('all', this)">All Items</button>
            <% for (String cat : categorySet) { %>
                <button class="btn btn-outline btn-sm filter-btn" onclick="filterCategory('<%= cat.toLowerCase() %>', this)"><%= cat %></button>
            <% } %>
        </div>

        <div class="menu-grid" id="productGrid">
        <%
            if (pastries != null && !pastries.isEmpty()) {
                for (String[] p : pastries) {
                    String pid      = p[0];
                    String name     = p[1];
                    String desc     = p[2];
                    String price    = p[3];
                    String category = p[4] != null ? p[4] : "Other";
                    String catLower = category.toLowerCase();

                    // Pick emoji based on category name
                    String emoji = "&#127859;";
                    if (catLower.contains("vienno") || catLower.contains("croissant")) emoji = "&#129360;";
                    else if (catLower.contains("tart")) emoji = "&#129361;";
                    else if (catLower.contains("eclair")) emoji = "&#127874;";
                    else if (catLower.contains("macaron")) emoji = "&#129327;";
                    else if (catLower.contains("cake")) emoji = "&#127870;";
        %>
            <div class="card menu-card" data-category="<%= catLower %>" data-name="<%= name.toLowerCase() %>">
                <div style="background:linear-gradient(135deg,#f0d580,#c9a84c); height:130px; display:flex; align-items:center; justify-content:center; font-size:3.2rem;"><%= emoji %></div>
                <div class="card-body">
                    <span class="category-tag"><%= category %></span>
                    <div class="card-title"><%= name %></div>
                    <div class="card-text"><%= desc %></div>
                    <div class="card-price">&pound;<%= price %></div>
                    <form action="<%= request.getContextPath() %>/OrderServlet" method="post" style="display:flex; gap:0.5rem; align-items:center;">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="productId" value="<%= pid %>">
                        <input type="hidden" name="productName" value="<%= name %>">
                        <input type="hidden" name="price" value="<%= price %>">
                        <input type="number" name="quantity" value="1" min="1" max="20" class="qty-input">
                        <button type="submit" class="btn btn-primary btn-sm" style="flex:1;">Add to Order</button>
                    </form>
                </div>
            </div>
        <%
                }
            } else {
        %>
            <div style="grid-column:1/-1; text-align:center; padding:3rem; color:#888;">
                <p style="font-size:3rem;">&#127859;</p>
                <p>No menu items available right now.</p>
            </div>
        <%
            }
        %>
        </div>

        <div id="emptyState" style="display:none; text-align:center; padding:3rem; color:#888;">
            <h3>&#128269; No items found</h3>
            <p>Try a different search or category.</p>
        </div>

    </div>
</div>

<footer class="footer">
    <div class="container"><p>&copy; 2025 La Farine Pâtisserie</p></div>
</footer>

<script>
    function filterCategory(cat, btn) {
        document.querySelectorAll('.filter-btn').forEach(b => {
            b.classList.remove('active', 'btn-primary');
            b.classList.add('btn-outline');
        });
        btn.classList.add('active', 'btn-primary');
        btn.classList.remove('btn-outline');
        document.querySelectorAll('.menu-card').forEach(card => {
            card.style.display = (cat === 'all' || card.dataset.category === cat) ? '' : 'none';
        });
        checkEmpty();
    }

    function filterProducts() {
        const query = document.getElementById('searchInput').value.toLowerCase();
        document.querySelectorAll('.menu-card').forEach(card => {
            card.style.display = card.dataset.name.includes(query) ? '' : 'none';
        });
        checkEmpty();
    }

    function checkEmpty() {
        const anyVisible = Array.from(document.querySelectorAll('.menu-card')).some(c => c.style.display !== 'none');
        document.getElementById('emptyState').style.display = anyVisible ? 'none' : 'block';
        document.getElementById('productGrid').style.display = anyVisible ? '' : 'none';
    }
</script>
</body>
</html>