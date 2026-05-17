<%-- FILE LOCATION: WEB-INF/includes/navbar.jsp --%>
<%@ page import="com.patisserie.model.User" %>
<%
    String navCtx = request.getContextPath();
    String currentURI = request.getRequestURI();
    boolean isDash   = currentURI.contains("DashboardServlet");
    boolean isMenu   = currentURI.contains("ProductsServlet");
    boolean isRes    = currentURI.contains("ReservationServlet");
    boolean isOrders = currentURI.contains("OrderServlet");
    boolean isProf   = currentURI.contains("ProfileServlet");
    boolean isLoc    = currentURI.contains("LocationServlet");

    // Determine guest mode — works on any page that sets loggedInUser or uses session
    User navUser = (User) request.getAttribute("loggedInUser");
    if (navUser == null) {
        jakarta.servlet.http.HttpSession navSession = request.getSession(false);
        if (navSession != null) navUser = (User) navSession.getAttribute("user");
    }
    boolean navGuest = (navUser == null);
%>

<!-- ═══ NAVBAR ═══ -->
<nav class="navbar" id="mainNavbar">
    <div class="nav-inner">

        <!-- Left nav links -->
        <div class="nav-links-left">
            <a href="<%= navCtx %>/DashboardServlet" class="<%= isDash ? "active" : "" %>">Dashboard</a>
            <a href="<%= navCtx %>/ProductsServlet"  class="<%= isMenu ? "active" : "" %>">Menu</a>
            <a href="<%= navCtx %>/ReservationServlet"
               class="<%= isRes ? "active" : "" %>"
               <% if (navGuest) { %> onclick="return navRequireLogin(event, this.href)" <% } %>>Reserve</a>
        </div>

        <!-- Centre brand -->
        <a href="<%= navCtx %>/DashboardServlet" class="navbar-brand">
            <div class="brand-name">L'Atelier Sucré</div>
            <div class="brand-line"></div>
            <div class="brand-sub">Pâtisserie</div>
        </a>

        <!-- Right nav links -->
        <div class="nav-links-right">
            <a href="<%= navCtx %>/OrderServlet"
               class="<%= isOrders ? "active" : "" %>"
               <% if (navGuest) { %> onclick="return navRequireLogin(event, this.href)" <% } %>>My Orders</a>
            <a href="<%= navCtx %>/ProfileServlet"
               class="<%= isProf ? "active" : "" %>"
               <% if (navGuest) { %> onclick="return navRequireLogin(event, this.href)" <% } %>>Profile</a>
            <a href="<%= navCtx %>/LocationServlet" class="<%= isLoc ? "active" : "" %>">Locations</a>
            <% if (navGuest) { %>
                <a href="<%= navCtx %>/LoginServlet" style="color: var(--gold-light);">Sign In</a>
            <% } else { %>
                <a href="<%= navCtx %>/LogoutServlet">Logout</a>
            <% } %>
        </div>

        <!-- Hamburger (mobile) -->
        <button class="nav-hamburger" id="navHamburger" aria-label="Menu">
            <span></span><span></span><span></span>
        </button>
    </div>
</nav>

<!-- Mobile drawer -->
<div class="nav-overlay" id="navOverlay"></div>
<div class="nav-mobile-drawer" id="mobileDrawer">
    <a href="<%= navCtx %>/DashboardServlet">Dashboard</a>
    <a href="<%= navCtx %>/ProductsServlet">Menu</a>
    <% if (navGuest) { %>
        <a href="javascript:void(0)" onclick="navRequireLogin(event, '<%= navCtx %>/ReservationServlet')">Reserve a Table</a>
        <a href="javascript:void(0)" onclick="navRequireLogin(event, '<%= navCtx %>/OrderServlet')">My Orders</a>
        <a href="javascript:void(0)" onclick="navRequireLogin(event, '<%= navCtx %>/ProfileServlet')">Profile</a>
    <% } else { %>
        <a href="<%= navCtx %>/ReservationServlet">Reserve a Table</a>
        <a href="<%= navCtx %>/OrderServlet">My Orders</a>
        <a href="<%= navCtx %>/ProfileServlet">Profile</a>
    <% } %>
    <a href="<%= navCtx %>/LocationServlet">Locations</a>
    <% if (navGuest) { %>
        <a href="<%= navCtx %>/LoginServlet">Sign In</a>
    <% } else { %>
        <a href="<%= navCtx %>/LogoutServlet">Logout</a>
    <% } %>
</div>

<script>
// ── Intercept restricted links for guests ─────────────────
function navRequireLogin(event, href) {
    event.preventDefault();
    // If we're on the dashboard, open its modal; otherwise redirect to dashboard
    if (typeof openLoginModal === 'function') {
        openLoginModal();
    } else {
        window.location.href = '<%= navCtx %>/DashboardServlet';
    }
    return false;
}

(function() {
    var navbar = document.getElementById('mainNavbar');
    var hamburger = document.getElementById('navHamburger');
    var overlay = document.getElementById('navOverlay');
    var drawer = document.getElementById('mobileDrawer');

    function onScroll() {
        if (window.scrollY > 60) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    }
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();

    hamburger.addEventListener('click', function() {
        drawer.classList.add('open');
        overlay.classList.add('open');
        document.body.style.overflow = 'hidden';
    });

    function closeDrawer() {
        drawer.classList.remove('open');
        overlay.classList.remove('open');
        document.body.style.overflow = '';
    }

    overlay.addEventListener('click', closeDrawer);
    drawer.querySelectorAll('a').forEach(function(a) {
        a.addEventListener('click', closeDrawer);
    });
})();
</script>