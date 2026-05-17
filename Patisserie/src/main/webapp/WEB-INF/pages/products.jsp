<%-- FILE LOCATION: WEB-INF/pages/products.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.LinkedHashSet" %>
<%
    User user = (User) session.getAttribute("user");
    // guests can browse — user may be null
    List<String[]> pastries = (List<String[]>) request.getAttribute("pastries");

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
    <title>Our Menu – La Farine</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2">
    <style>
        /* ── Menu page specific ─────────────────────────── */

        /* Hero banner */
        .menu-hero {
            position: relative;
            background: var(--brown-dark);
            padding: calc(var(--nav-h) + 4rem) 0 4rem;
            text-align: center;
            overflow: hidden;
        }

        .menu-hero-topper {
            position: absolute;
            inset: 0;
            z-index: 0;
        }

        .menu-hero-topper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            object-position: center;
            display: block;
            opacity: 0;
            position: absolute;
            inset: 0;
            transition: opacity 1.2s ease;
        }

        .menu-hero-topper img.active { opacity: 0.38; }

        .menu-hero::before {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(160deg, rgba(26,11,4,0.82) 0%, rgba(58,32,16,0.72) 40%, rgba(92,56,32,0.65) 100%);
            z-index: 1;
        }

        .menu-hero-content {
            position: relative;
            z-index: 2;
        }

        .menu-hero h1 {
            font-family: var(--font-display);
            font-size: clamp(2.5rem, 6vw, 5rem);
            font-weight: 300;
            color: #fff;
            letter-spacing: 0.06em;
            margin-bottom: 0.5rem;
        }

        .menu-hero p {
            font-family: var(--font-display);
            font-style: italic;
            color: rgba(255,255,255,0.55);
            font-size: 1.1rem;
            margin-bottom: 2.5rem;
        }

        .menu-hero-line {
            width: 55px;
            height: 1px;
            background: var(--gold);
            margin: 0 auto 2.5rem;
        }

        /* Search bar */
        .menu-search-wrap {
            display: flex;
            justify-content: center;
            padding: 0 1rem;
        }

        .menu-search {
            display: flex;
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.18);
            max-width: 520px;
            width: 100%;
        }

        .menu-search input {
            flex: 1;
            background: transparent;
            border: none;
            padding: 0.85rem 1.2rem;
            color: #fff;
            font-family: var(--font-ui);
            font-size: 0.82rem;
            letter-spacing: 0.08em;
            outline: none;
        }

        .menu-search input::placeholder { color: rgba(255,255,255,0.38); }

        .menu-search button {
            background: var(--gold);
            border: none;
            color: var(--brown-dark);
            padding: 0.85rem 1.8rem;
            font-family: var(--font-ui);
            font-size: 0.68rem;
            letter-spacing: 0.18em;
            text-transform: uppercase;
            cursor: pointer;
            transition: background 0.2s;
            font-weight: 600;
        }

        .menu-search button:hover { background: var(--gold-light); }

        /* ── Layout: sidebar + content ─── */
        .menu-layout {
            display: flex;
            align-items: flex-start;
            gap: 0;
            min-height: 70vh;
        }

        /* Sidebar */
        .menu-sidebar {
            width: 240px;
            flex-shrink: 0;
            background: var(--warm-white);
            border-right: 1px solid var(--gray-light);
            position: sticky;
            top: var(--nav-h);
            height: calc(100vh - var(--nav-h));
            overflow-y: auto;
            padding: 2rem 0;
        }

        .sidebar-title {
            font-family: var(--font-ui);
            font-size: 0.62rem;
            letter-spacing: 0.3em;
            text-transform: uppercase;
            color: var(--gold);
            padding: 0 1.5rem 1rem;
            border-bottom: 1px solid var(--gray-light);
            margin-bottom: 0.5rem;
        }

        .sidebar-item {
            display: block;
            width: 100%;
            padding: 0.9rem 1.5rem;
            font-family: var(--font-ui);
            font-size: 0.78rem;
            letter-spacing: 0.08em;
            color: var(--gray);
            background: none;
            border: none;
            text-align: left;
            cursor: pointer;
            transition: background 0.15s, color 0.15s;
            border-left: 3px solid transparent;
            text-transform: uppercase;
        }

        .sidebar-item:hover {
            background: var(--gold-pale);
            color: var(--brown);
        }

        .sidebar-item.active {
            border-left-color: var(--gold);
            color: var(--brown);
            background: var(--gold-pale);
            font-weight: 600;
        }

        /* Main content area */
        .menu-content {
            flex: 1;
            padding: 3rem clamp(1.5rem, 4vw, 3rem);
            min-width: 0;
            background: var(--cream);
        }

        /* Category section header */
        .category-section {
            margin-bottom: 4rem;
        }

        .category-heading {
            font-family: var(--font-display);
            font-size: clamp(1.8rem, 3vw, 2.6rem);
            font-weight: 300;
            color: var(--brown);
            margin-bottom: 0.3rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--gold-light);
        }

        .category-count {
            font-family: var(--font-ui);
            font-size: 0.65rem;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            color: var(--gold);
            margin-bottom: 2rem;
            display: block;
        }

        /* Product grid */
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 1.5px;
            background: rgba(92,61,46,0.08);
        }

        /* Product card */
        .product-card {
            background: var(--warm-white);
            display: flex;
            flex-direction: column;
            transition: box-shadow 0.25s, transform 0.25s;
            cursor: pointer;
            position: relative;
        }

        .product-card:hover {
            box-shadow: 0 8px 32px rgba(58,34,21,0.18);
            transform: translateY(-3px);
            z-index: 2;
        }

        /* Image placeholder (replace with <img> when you have images) */
        .product-img {
            width: 100%;
            height: 200px;
            object-fit: cover;
            display: block;
        }

        .product-img-placeholder {
            width: 100%;
            height: 200px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--gray-light);
            font-family: var(--font-ui);
            font-size: 0.65rem;
            letter-spacing: 0.25em;
            text-transform: uppercase;
            color: #b0a090;
            flex-shrink: 0;
        }

        .product-body {
            padding: 1.3rem 1.4rem 1.6rem;
            display: flex;
            flex-direction: column;
            flex: 1;
        }

        .product-cat-tag {
            font-family: var(--font-ui);
            font-size: 0.6rem;
            letter-spacing: 0.18em;
            text-transform: uppercase;
            color: var(--gold);
            margin-bottom: 0.4rem;
        }

        .product-name {
            font-family: var(--font-display);
            font-size: 1.3rem;
            font-weight: 400;
            color: var(--brown);
            margin-bottom: 0.4rem;
            line-height: 1.2;
        }

        .product-desc {
            font-family: var(--font-body);
            font-style: italic;
            font-size: 0.88rem;
            color: var(--gray);
            line-height: 1.6;
            flex: 1;
            margin-bottom: 1.2rem;
        }

        .product-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.8rem;
            margin-top: auto;
        }

        .product-price {
            font-family: var(--font-display);
            font-size: 1.4rem;
            color: var(--brown);
            font-weight: 400;
        }

        .product-actions {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        /* Qty stepper */
        .qty-stepper {
            display: flex;
            align-items: center;
            border: 1px solid var(--gray-light);
            background: var(--cream);
        }

        .qty-stepper button {
            background: none;
            border: none;
            width: 28px;
            height: 28px;
            font-size: 1rem;
            cursor: pointer;
            color: var(--brown);
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.15s;
        }

        .qty-stepper button:hover { background: var(--gold-pale); }

        .qty-stepper input {
            width: 32px;
            height: 28px;
            border: none;
            border-left: 1px solid var(--gray-light);
            border-right: 1px solid var(--gray-light);
            text-align: center;
            font-family: var(--font-ui);
            font-size: 0.82rem;
            background: transparent;
            color: var(--brown-dark);
            outline: none;
        }

        /* Add button */
        .btn-add {
            background: var(--brown);
            color: #fff;
            border: none;
            padding: 0.5rem 1.1rem;
            font-family: var(--font-ui);
            font-size: 0.65rem;
            letter-spacing: 0.15em;
            text-transform: uppercase;
            cursor: pointer;
            transition: background 0.2s;
            white-space: nowrap;
        }

        .btn-add:hover { background: var(--brown-dark); }

        /* Empty / no results */
        .no-results {
            grid-column: 1 / -1;
            text-align: center;
            padding: 4rem 1rem;
        }

        .no-results p { font-size: 1rem; color: var(--gray); }

        /* Mobile: collapse sidebar to top bar */
        @media (max-width: 768px) {
            .menu-layout { flex-direction: column; }

            .menu-sidebar {
                width: 100%;
                height: auto;
                position: static;
                display: flex;
                flex-direction: row;
                overflow-x: auto;
                padding: 0;
                border-right: none;
                border-bottom: 2px solid var(--gold-light);
            }

            .sidebar-title { display: none; }

            .sidebar-item {
                white-space: nowrap;
                border-left: none;
                border-bottom: 3px solid transparent;
                padding: 1rem 1.2rem;
            }

            .sidebar-item.active {
                border-bottom-color: var(--gold);
                border-left: none;
                background: transparent;
            }

            .menu-content { padding: 2rem 1rem; }
            .product-grid { grid-template-columns: 1fr 1fr; gap: 1.5px; }
        }

        @media (max-width: 480px) {
            .product-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<%@ include file="../includes/navbar.jsp" %>

<!-- Hero -->
<div class="menu-hero">
    <div class="menu-hero-topper">
        <img src="<%= request.getContextPath() %>/images/topper.jpg"  alt="" class="active">
        <img src="<%= request.getContextPath() %>/images/topper2.jpg" alt="">
        <img src="<%= request.getContextPath() %>/images/topper3.jpg" alt="">
        <img src="<%= request.getContextPath() %>/images/topper4.jpg" alt="">
        <img src="<%= request.getContextPath() %>/images/topper5.jpg" alt="">
    </div>
    <div class="menu-hero-content">
        <div class="section-eyebrow" style="color:var(--gold); margin-bottom:1rem;">La Farine Pâtisserie</div>
        <h1>Our Menu</h1>
        <div class="menu-hero-line"></div>
        <p>Freshly baked every morning — made with care, served with love</p>
        <div class="menu-search-wrap">
            <div class="menu-search">
                <input type="text" id="searchInput" placeholder="Search croissants, tarts, éclairs..." oninput="liveSearch()">
                <button onclick="liveSearch()">Search</button>
            </div>
        </div>
    </div>
</div>

<!-- Menu layout -->
<div class="menu-layout" id="menuLayout">

    <!-- Sidebar -->
    <nav class="menu-sidebar" id="menuSidebar">
        <div class="sidebar-title">Menu</div>
        <button class="sidebar-item active" onclick="filterCategory('all', this)" data-cat="all">
            All Items
        </button>
        <% for (String cat : categorySet) { %>
            <button class="sidebar-item" onclick="filterCategory('<%= cat.toLowerCase().replace("'","\\'"  ) %>', this)" data-cat="<%= cat.toLowerCase() %>">
                <%= cat %>
            </button>
        <% } %>
    </nav>

    <!-- Content -->
    <main class="menu-content">

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>

        <%
            if (pastries != null && !pastries.isEmpty()) {
                // Group by category
                java.util.Map<String, java.util.List<String[]>> grouped = new java.util.LinkedHashMap<>();
                for (String[] p : pastries) {
                    String cat = p[4] != null ? p[4] : "Other";
                    grouped.computeIfAbsent(cat, k -> new java.util.ArrayList<>()).add(p);
                }

                for (java.util.Map.Entry<String, java.util.List<String[]>> entry : grouped.entrySet()) {
                    String catName  = entry.getKey();
                    String catId    = catName.toLowerCase().replaceAll("[^a-z0-9]", "-");
                    java.util.List<String[]> items = entry.getValue();
        %>
        <section class="category-section" id="cat-<%= catId %>" data-section="<%= catName.toLowerCase() %>">
            <h2 class="category-heading"><%= catName %></h2>
            <span class="category-count"><%= items.size() %> item<%= items.size() != 1 ? "s" : "" %></span>

            <div class="product-grid">
            <%
                for (String[] p : items) {
                    String pid      = p[0];
                    String name     = p[1];
                    String desc     = p[2];
                    String price    = p[3];
                    String category = p[4] != null ? p[4] : "Other";
                    String catLower = category.toLowerCase();

                    String emoji = "🥐";
                    if (catLower.contains("tart"))    emoji = "🥧";
                    else if (catLower.contains("eclair") || catLower.contains("éclair")) emoji = "🍫";
                    else if (catLower.contains("macaron")) emoji = "🫐";
                    else if (catLower.contains("cake"))    emoji = "🎂";
                    else if (catLower.contains("bread") || catLower.contains("pain")) emoji = "🍞";
                    else if (catLower.contains("cookie")) emoji = "🍪";

                    // Gradient per category for placeholder bg
                    String[] gradients = {
                        "linear-gradient(135deg,#f5e9c4,#e8cc80)",
                        "linear-gradient(135deg,#f2e9d8,#c9a84c)",
                        "linear-gradient(135deg,#ede7dc,#a07858)",
                        "linear-gradient(135deg,#f0d580,#7a5540)",
                        "linear-gradient(135deg,#faf5ee,#c9a84c)"
                    };
                    int gIdx = Math.abs(catName.hashCode()) % gradients.length;
                    String gradient = gradients[gIdx];
            %>
                <div class="product-card" data-category="<%= catLower %>" data-name="<%= name.toLowerCase() %>">

                    <%-- Category-based product image with per-item variety --%>
                    <%
                        String[] croissantImgs = { navCtx+"/images/criossant.jpg", navCtx+"/images/croissant.jpg", navCtx+"/images/croissant2.jpg", navCtx+"/images/croissant3.jpg", navCtx+"/images/croissant4.jpg" };
                        String[] tartImgs      = { navCtx+"/images/tart.jpg", navCtx+"/images/pie.jpg" };
                        String[] cakeImgs      = { navCtx+"/images/cake.jpg" };
                        String[] macaronImgs   = { navCtx+"/images/macaron.jpg" };
                        String[] defaultImgs   = { navCtx+"/images/croi.jpg", navCtx+"/images/criossant.jpg", navCtx+"/images/croissant.jpg" };

                        String[] imgPool;
                        if (catLower.contains("viennoiserie") || catLower.contains("croissant") || catLower.contains("viennoiser")) {
                            imgPool = croissantImgs;
                        } else if (catLower.contains("tart")) {
                            imgPool = tartImgs;
                        } else if (catLower.contains("cake") || catLower.contains("gâteau") || catLower.contains("gateau")) {
                            imgPool = cakeImgs;
                        } else if (catLower.contains("macaron")) {
                            imgPool = macaronImgs;
                        } else {
                            imgPool = defaultImgs;
                        }
                        int imgIdx = Math.abs(pid.hashCode()) % imgPool.length;
                        String imgSrc = imgPool[imgIdx];
                    %>
                    <img src="<%= imgSrc %>" alt="<%= name %>" class="product-img">

                    <div class="product-body">
                        <div class="product-cat-tag"><%= category %></div>
                        <div class="product-name"><%= name %></div>
                        <div class="product-desc"><%= desc %></div>

                        <div class="product-footer">
                            <div class="product-price">&pound;<%= price %></div>
                            <div class="product-actions">
                                <form action="<%= navCtx %>/OrderServlet" method="post" style="display:flex; align-items:center; gap:0.5rem;"
                                      onsubmit="<% if (user == null) { %>return guestAddToCart(event);<% } %>">
                                    <input type="hidden" name="action"      value="add">
                                    <input type="hidden" name="productId"   value="<%= pid %>">
                                    <input type="hidden" name="productName" value="<%= name %>">
                                    <input type="hidden" name="price"       value="<%= price %>">
                                    <div class="qty-stepper">
                                        <button type="button" onclick="adjustQty(this,-1)">&#8722;</button>
                                        <input type="number" name="quantity" value="1" min="1" max="20" class="qty-val">
                                        <button type="button" onclick="adjustQty(this,1)">&#43;</button>
                                    </div>
                                    <button type="submit" class="btn-add">Add</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            <%
                }
            %>
            </div>
        </section>
        <%
                } // end category loop
            } else {
        %>
            <div class="no-results">
                <p style="font-size:3rem; margin-bottom:1rem;">🥐</p>
                <p>No menu items available right now.</p>
            </div>
        <%
            }
        %>

        <!-- Global no-results message for search/filter -->
        <div id="emptyState" style="display:none; text-align:center; padding:4rem 1rem;">
            <p style="font-size:2.5rem; margin-bottom:1rem;">🔍</p>
            <p style="color:var(--gray); font-family:var(--font-ui); letter-spacing:0.06em;">No items match your search.</p>
        </div>

    </main>
</div>

<%@ include file="../includes/footer.jsp" %>

<script>
// ── Guest cart guard ──────────────────────────────────────
function guestAddToCart(e) {
    e.preventDefault();
    if (confirm('You need to sign in to add items to your basket.\n\nGo to Sign In now?')) {
        window.location.href = '<%= request.getContextPath() %>/LoginServlet';
    }
    return false;
}

// ── Qty stepper ───────────────────────────────────────────
function adjustQty(btn, delta) {
    var input = btn.parentElement.querySelector('.qty-val');
    var val = parseInt(input.value) + delta;
    input.value = Math.min(20, Math.max(1, val));
}

// ── Category filter (sidebar) ────────────────────────────
function filterCategory(cat, btn) {
    // Update sidebar active state
    document.querySelectorAll('.sidebar-item').forEach(function(b) {
        b.classList.remove('active');
    });
    btn.classList.add('active');

    // Show/hide category sections
    var sections = document.querySelectorAll('.category-section');
    sections.forEach(function(sec) {
        if (cat === 'all' || sec.dataset.section === cat) {
            sec.style.display = '';
        } else {
            sec.style.display = 'none';
        }
    });

    // Clear search
    document.getElementById('searchInput').value = '';
    document.getElementById('emptyState').style.display = 'none';

    // Scroll content to top
    document.querySelector('.menu-content').scrollTop = 0;
}

// ── Live search ──────────────────────────────────────────
function liveSearch() {
    var query = document.getElementById('searchInput').value.toLowerCase().trim();

    // Reset sidebar to "all"
    document.querySelectorAll('.sidebar-item').forEach(function(b) {
        b.classList.remove('active');
        if (b.dataset.cat === 'all') b.classList.add('active');
    });

    if (!query) {
        // Show everything
        document.querySelectorAll('.category-section').forEach(function(s) { s.style.display = ''; });
        document.querySelectorAll('.product-card').forEach(function(c) { c.style.display = ''; });
        document.getElementById('emptyState').style.display = 'none';
        return;
    }

    var anyVisible = false;

    document.querySelectorAll('.category-section').forEach(function(sec) {
        var cards = sec.querySelectorAll('.product-card');
        var sectionHasMatch = false;
        cards.forEach(function(card) {
            var match = card.dataset.name.includes(query);
            card.style.display = match ? '' : 'none';
            if (match) sectionHasMatch = true;
        });
        sec.style.display = sectionHasMatch ? '' : 'none';
        if (sectionHasMatch) anyVisible = true;
    });

    document.getElementById('emptyState').style.display = anyVisible ? 'none' : 'block';
}
// ── Topper slideshow ─────────────────────────────────────
(function(){
    var imgs = document.querySelectorAll('.menu-hero-topper img');
    var cur = 0;
    if (imgs.length < 2) return;
    setInterval(function(){
        imgs[cur].classList.remove('active');
        cur = (cur + 1) % imgs.length;
        imgs[cur].classList.add('active');
    }, 3500);
})();
</script>
</body>
</html>