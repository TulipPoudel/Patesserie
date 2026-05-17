<%-- FILE LOCATION: WEB-INF/pages/dashboard.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
<%
    User user = (User) request.getAttribute("loggedInUser");
    boolean guestMode = (Boolean) request.getAttribute("guestMode");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>L'Atelier Sucré Pâtisserie</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=2">
    <style>
        /* ── Login Modal ─────────────────────────────────── */
        .login-modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(20,10,4,0.72);
            z-index: 5000;
            align-items: center;
            justify-content: center;
            padding: 1rem;
            backdrop-filter: blur(4px);
        }
        .login-modal-overlay.open { display: flex; }
        .login-modal {
            background: var(--warm-white);
            width: 100%;
            max-width: 420px;
            border-top: 3px solid var(--gold);
            box-shadow: 0 24px 80px rgba(0,0,0,0.45);
            animation: modalIn 0.3s cubic-bezier(0.4,0,0.2,1);
            position: relative;
        }
        @keyframes modalIn {
            from { opacity:0; transform:translateY(24px) scale(0.97); }
            to   { opacity:1; transform:translateY(0) scale(1); }
        }
        .modal-header { padding:2rem 2rem 1rem; text-align:center; border-bottom:1px solid var(--gray-light); }
        .modal-logo { font-family:var(--font-display); font-size:2rem; font-weight:300; color:var(--brown); letter-spacing:0.08em; }
        .modal-logo-sub { font-family:var(--font-ui); font-size:0.6rem; letter-spacing:0.3em; text-transform:uppercase; color:var(--gold); margin-top:2px; }
        .modal-body { padding:1.8rem 2rem; }
        .modal-close { position:absolute; top:1rem; right:1rem; background:none; border:none; font-size:1.3rem; color:var(--gray); cursor:pointer; padding:0.2rem 0.5rem; transition:color 0.2s; }
        .modal-close:hover { color:var(--brown); }
        .modal-error { display:none; background:#fde8e8; color:var(--red); border-left:3px solid var(--red); padding:0.7rem 1rem; font-size:0.82rem; font-family:var(--font-ui); margin-bottom:1.2rem; }
        .modal-footer { padding:1rem 2rem 1.8rem; text-align:center; font-family:var(--font-ui); font-size:0.78rem; color:var(--gray); border-top:1px solid var(--gray-light); }
        .modal-footer a { color:var(--brown); }
        .modal-footer a:hover { color:var(--gold); }
        .modal-remember { display:flex; align-items:center; gap:0.5rem; margin-bottom:1.3rem; font-family:var(--font-ui); font-size:0.75rem; color:var(--gray); }
        .modal-remember input { width:auto; margin:0; }
    </style>
</head>
<body>

<!-- ═══ NAVBAR (fixed, transparent over hero) ═══ -->
<%@ include file="../includes/navbar.jsp" %>

<!-- ═══ HERO VIDEO SECTION ═══ -->
<section class="hero-video-section" id="heroSection">

    <video class="hero-video-bg" autoplay muted loop playsinline>
        <source src="<%= ctx %>/video/cinnamon.mp4" type="video/mp4">
    </video>

    <div class="hero-video-overlay"></div>

    <div class="hero-video-content">
        <div class="hero-ornament">Artisan Pâtisserie · Since 1998</div>
        <h1>L'Atelier Sucré</h1>
        <div class="hero-gold-line"></div>
        <p class="hero-subtitle">Where every morning begins with something beautiful</p>
        <div class="hero-cta-group">
            <% if (guestMode) { %>
                <a href="javascript:void(0)" onclick="openLoginModal()" class="btn btn-gold">Sign In to Order</a>
                <a href="<%= ctx %>/ProductsServlet" class="btn btn-outline-light">Explore Our Menu</a>
            <% } else { %>
                <a href="<%= ctx %>/ProductsServlet" class="btn btn-gold">Explore Our Menu</a>
                <a href="<%= ctx %>/ReservationServlet" class="btn btn-outline-light">Reserve a Table</a>
            <% } %>
        </div>
    </div>

    <div class="hero-scroll-indicator" onclick="document.getElementById('welcomeSection').scrollIntoView({behavior:'smooth'})">
        <div class="scroll-line"></div>
        <span>Scroll</span>
    </div>
</section>

<!-- ═══ WELCOME SECTION ═══ -->
<section class="welcome-section" id="welcomeSection">
    <div class="container">
        <%-- Flash messages --%>
        <% if (!guestMode) { %>
        <% if (request.getAttribute("welcomeBack") != null) { %>
            <div class="alert alert-info" style="max-width:560px; margin:0 auto 3rem; text-align:left;">
                Welcome back, <strong><%= request.getAttribute("welcomeBack") %></strong>! Good to see you again.
            </div>
        <% } else { %>
            <div class="alert alert-success" style="max-width:560px; margin:0 auto 3rem; text-align:left;">
                Welcome, <strong><%= user.getFullName() %></strong>! You are now logged in.
            </div>
        <% } %>
        <% } %>

        <% if (guestMode) { %>
            <div class="section-eyebrow reveal">Welcome to L'Atelier Sucré</div>
            <h2 class="reveal reveal-delay-1">A table is waiting.<br>The pastries are fresh.</h2>
            <div class="section-ornament reveal reveal-delay-2">✦</div>
            <p class="lead reveal reveal-delay-2">
                Browse our menu freely — sign in when you're ready to order or reserve a table.
            </p>
            <div style="text-align:center; margin-top:2rem;" class="reveal reveal-delay-3">
                <a href="javascript:void(0)" onclick="openLoginModal()" class="btn btn-gold">Sign In</a>
                &nbsp;&nbsp;
                <a href="<%= ctx %>/RegisterServlet" class="btn btn-outline">Create Account</a>
            </div>
        <% } else { %>
            <div class="section-eyebrow reveal">Hello, <%= user.getFullName() %></div>
            <h2 class="reveal reveal-delay-1">A table is waiting.<br>The pastries are fresh.</h2>
            <div class="section-ornament reveal reveal-delay-2">✦</div>
            <p class="lead reveal reveal-delay-2">
                Everything you love about L'Atelier Sucré — your orders, your reservations,
                your profile — all in one place.
            </p>
        <% } %>
    </div>
</section>

<!-- ═══ FEATURES GRID ═══ -->
<section class="features-section">
    <div class="container">
        <div class="section-header">
            <div class="section-eyebrow reveal">What you can do</div>
            <h2 class="reveal reveal-delay-1">Your Dashboard</h2>
        </div>
        <div class="features-grid">

            <div class="feature-tile reveal">
                <div class="tile-num">01</div>
                <h3>Browse Menu</h3>
                <p>Explore our fresh pastries, viennoiseries, and seasonal specials. Add items to your cart with ease.</p>
                <a href="<%= ctx %>/ProductsServlet" class="btn btn-primary btn-sm">Go to Menu</a>
            </div>

            <div class="feature-tile reveal reveal-delay-1">
                <div class="tile-num">02</div>
                <h3>My Orders</h3>
                <p>View your current basket, track active orders, and browse your full order history.</p>
                <% if (guestMode) { %>
                    <a href="javascript:void(0)" onclick="openLoginModal()" class="btn btn-outline btn-sm">Sign In to View</a>
                <% } else { %>
                    <a href="<%= ctx %>/OrderServlet" class="btn btn-outline btn-sm">View Orders</a>
                <% } %>
            </div>

            <div class="feature-tile reveal reveal-delay-2">
                <div class="tile-num">03</div>
                <h3>Reserve a Table</h3>
                <p>Book a table for two, a family lunch, or a private gathering at L'Atelier Sucré.</p>
                <% if (guestMode) { %>
                    <a href="javascript:void(0)" onclick="openLoginModal()" class="btn btn-gold btn-sm">Sign In to Book</a>
                <% } else { %>
                    <a href="<%= ctx %>/ReservationServlet" class="btn btn-gold btn-sm">Book Now</a>
                <% } %>
            </div>

            <div class="feature-tile reveal reveal-delay-3">
                <div class="tile-num">04</div>
                <h3>My Profile</h3>
                <p>Update your name, phone number, and password to keep your account current.</p>
                <% if (guestMode) { %>
                    <a href="javascript:void(0)" onclick="openLoginModal()" class="btn btn-outline btn-sm">Sign In</a>
                <% } else { %>
                    <a href="<%= ctx %>/ProfileServlet" class="btn btn-outline btn-sm">Edit Profile</a>
                <% } %>
            </div>

        </div>
    </div>
</section>

<!-- ═══ FULL BLEED BANNER ═══ -->
<div class="full-bleed-section reveal">
    <div class="full-bleed-bg"></div>
    <div class="full-bleed-overlay"></div>
    <div class="full-bleed-content">
        <div class="section-eyebrow">Our promise</div>
        <h2>Handmade. Every Day.</h2>
        <p>Flour, butter, time. Nothing shortcuts the craft we learned from our grandmothers.</p>
        <a href="<%= ctx %>/ProductsServlet" class="btn btn-gold">Discover the Menu</a>
    </div>
</div>

<!-- ═══ STORY ROWS ═══ -->
<section class="story-section">

    <div class="story-row">
        <div class="story-img">
            <img src="<%= ctx %>/images/croi.jpg" alt="Croissants at Dawn" style="width:100%;height:100%;object-fit:cover;display:block;">
        </div>
        <div class="story-text reveal">
            <div class="eyebrow">The Craft</div>
            <h2>Croissants folded by hand, laminated with care</h2>
            <p>
                Our croissants begin the night before — dough rested, butter layered,
                each fold deliberate. By 6am they are golden. By noon, they are gone.
            </p>
            <a href="<%= ctx %>/ProductsServlet" class="btn btn-outline btn-sm">View Viennoiseries</a>
        </div>
    </div>

    <div class="story-row reverse">
        <div class="story-img">
            <img src="<%= ctx %>/images/pie.jpg" alt="Seasonal Tarts" style="width:100%;height:100%;object-fit:cover;display:block;">
        </div>
        <div class="story-text reveal">
            <div class="eyebrow">The Season</div>
            <h2>Pastries that follow the calendar</h2>
            <p>
                Strawberry tarts in June. Apple galettes in October. Bûche de Noël
                in December. We bake what the season gives us.
            </p>
            <a href="<%= ctx %>/ProductsServlet" class="btn btn-outline btn-sm">See Seasonal Menu</a>
        </div>
    </div>

    <div class="story-row">
        <div class="story-img">
            <img src="<%= ctx %>/images/table.jpg" alt="The Table" style="width:100%;height:100%;object-fit:cover;display:block;">
        </div>
        <div class="story-text reveal">
            <div class="eyebrow">The Experience</div>
            <h2>A table, a coffee, a moment to yourself</h2>
            <p>
                L'Atelier Sucré is more than a bakery — it is a place to slow down.
                Reserve your seat and let us take care of the rest.
            </p>
            <a href="<%= ctx %>/ReservationServlet" class="btn btn-gold btn-sm">Reserve a Table</a>
        </div>
    </div>

</section>

<!-- ═══ MUST-HAVES ═══ -->
<section class="musthave-section">
    <div class="container">
        <div style="text-align:center">
            <div class="section-eyebrow">Our Signatures</div>
            <h2>The Must-Haves</h2>
            <div class="section-ornament">✦</div>
        </div>
        <div class="musthave-grid">
            <div class="musthave-item reveal">
                <div class="item-num">01</div>
                <div class="item-name">Croissant au Beurre</div>
                <p>Eighty-one layers of pure French butter</p>
            </div>
            <div class="musthave-item reveal reveal-delay-1">
                <div class="item-num">02</div>
                <div class="item-name">Tarte aux Framboises</div>
                <p>Crème pâtissière, fresh raspberries, mirror glaze</p>
            </div>
            <div class="musthave-item reveal reveal-delay-2">
                <div class="item-num">03</div>
                <div class="item-name">Paris-Brest</div>
                <p>Hazelnut praline cream in choux pastry</p>
            </div>
            <div class="musthave-item reveal reveal-delay-3">
                <div class="item-num">04</div>
                <div class="item-name">Flan à la Vanille</div>
                <p>Hand-rolled shortcrust, Madagascar vanilla</p>
            </div>
        </div>
    </div>
</section>

<!-- ═══ QUOTE ═══ -->
<section class="quote-section">
    <div class="container">
        <blockquote class="reveal">
            The search for the perfect pastry is the pursuit of excellence itself —
            we have never stopped searching.
        </blockquote>
        <div class="quote-attribution reveal reveal-delay-1">L'Atelier Sucré, Paris · Est. 1998</div>
    </div>
</section>

<!-- ═══ SESSION INFO ═══ -->
<% if (!guestMode) { %>
<section class="session-section">
    <div class="container">
        <h2>Your Session</h2>
        <div class="session-panel reveal">
            <div class="session-row">
                <span class="s-label">Logged in as</span>
                <span class="s-value"><strong><%= user.getFullName() %></strong></span>
            </div>
            <div class="session-row">
                <span class="s-label">Email</span>
                <span class="s-value"><%= user.getEmail() %></span>
            </div>
            <div class="session-row">
                <span class="s-label">Role</span>
                <span class="s-value"><%= user.getRole() %></span>
            </div>
            <div class="session-row">
                <span class="s-label">Session ID</span>
                <span class="s-value" style="font-size:0.75rem; color:#aaa"><%= session.getId().substring(0,16) %>...</span>
            </div>
            <div class="session-row">
                <span class="s-label">Remember Me</span>
                <span class="s-value">
                    <%
                        Cookie[] cookies = request.getCookies();
                        boolean hasRemember = false;
                        if (cookies != null) {
                            for (Cookie c : cookies) {
                                if ("rememberedEmail".equals(c.getName()) && !c.getValue().isEmpty()) {
                                    hasRemember = true;
                                }
                            }
                        }
                    %>
                    <%= hasRemember ? "&#10003; Cookie active (7 days)" : "Not set" %>
                </span>
            </div>
        </div>
    </div>
</section>
<% } %>

<!-- ═══ FOOTER ═══ -->
<%@ include file="../includes/footer.jsp" %>

<!-- ═══ LOGIN MODAL ═══ -->
<div class="login-modal-overlay" id="loginModalOverlay">
    <div class="login-modal" id="loginModal">
        <div class="modal-header">
            <div class="modal-logo">L'Atelier Sucré</div>
            <div class="modal-logo-sub">Pâtisserie</div>
        </div>
        <div class="modal-body" style="text-align:center; padding: 2rem 2rem 1.5rem;">
            <p style="font-family:var(--font-display); font-style:italic; color:var(--gray); margin-bottom:2rem; font-size:1.05rem;">
                Sign in to order, reserve a table, and manage your account.
            </p>
            <a href="<%= ctx %>/LoginServlet" class="btn btn-gold btn-block" style="display:block; margin-bottom:1rem;">Sign In</a>
            <a href="<%= ctx %>/RegisterServlet" class="btn btn-outline btn-block" style="display:block; margin-bottom:1.5rem;">Create an Account</a>
            <button onclick="closeLoginModal()" style="background:none; border:none; font-family:var(--font-ui); font-size:0.78rem; color:var(--gray); cursor:pointer; letter-spacing:0.08em; text-transform:uppercase;">
                Browse without signing in
            </button>
        </div>
    </div>
</div>

<script>
// ── Force video play (bypass autoplay block) ─────────────
(function() {
    var vid = document.querySelector('.hero-video-bg');
    if (!vid) return;
    vid.muted = true;
    var p = vid.play();
    if (p !== undefined) {
        p.catch(function() {
            // Autoplay blocked - play on first user interaction
            document.addEventListener('click', function once() {
                vid.play();
                document.removeEventListener('click', once);
            });
        });
    }
})();

// ── Auto-open login modal for guests ─────────────────────
<% if (guestMode) { %>
window.addEventListener('DOMContentLoaded', function() {
    setTimeout(openLoginModal, 600);
});
<% } %>

// ── Scroll reveal ─────────────────────────────────────────
(function() {
    var reveals = document.querySelectorAll('.reveal');
    var observer = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.12 });
    reveals.forEach(function(el) { observer.observe(el); });
})();

// ── Login Modal ───────────────────────────────────────────
function openLoginModal() {
    document.getElementById('loginModalOverlay').classList.add('open');
    document.body.style.overflow = 'hidden';
}

function closeLoginModal() {
    document.getElementById('loginModalOverlay').classList.remove('open');
    document.body.style.overflow = '';
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeLoginModal();
});
</script>
</body>
</html>