<%-- FILE LOCATION: WEB-INF/pages/locations.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    // guests can view locations — user may be null
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Our Locations – L'Atelier Sucré</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2">
    <style>

        /* ── Locations Hero ─────────────────────────────── */
        .loc-hero {
            position: relative;
            padding: calc(var(--nav-h) + 5rem) 0 5rem;
            text-align: center;
            overflow: hidden;
            background: var(--brown-dark);
        }

        .loc-hero-topper {
            position: absolute;
            inset: 0;
            z-index: 0;
        }

        .loc-hero-topper img {
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

        .loc-hero-topper img.active { opacity: 0.38; }

        .loc-hero::before {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(160deg, rgba(26,11,4,0.82) 0%, rgba(58,32,16,0.72) 45%, rgba(92,56,32,0.65) 100%);
            z-index: 1;
        }

        .loc-hero-content { position: relative; z-index: 1; }

        .loc-hero h1 {
            font-family: var(--font-display);
            font-size: clamp(2.5rem, 6vw, 5rem);
            font-weight: 300;
            color: #fff;
            letter-spacing: 0.06em;
            margin-bottom: 0.5rem;
        }

        .loc-hero p {
            font-family: var(--font-display);
            font-style: italic;
            color: rgba(255,255,255,0.55);
            font-size: 1.1rem;
            max-width: 500px;
            margin: 0 auto;
        }

        .loc-hero-line {
            width: 55px;
            height: 1px;
            background: var(--gold);
            margin: 1.5rem auto;
        }

        /* ── Intro strip ────────────────────────────────── */
        .loc-intro {
            background: var(--parchment);
            padding: 4.5rem 0;
            text-align: center;
            border-bottom: 1px solid var(--gray-light);
        }

        .loc-intro h2 {
            font-size: clamp(1.4rem, 3vw, 2.2rem);
            font-weight: 300;
            max-width: 680px;
            margin: 0 auto 1rem;
            line-height: 1.3;
        }

        .loc-intro p {
            max-width: 520px;
            margin: 0 auto;
            font-family: var(--font-body);
            font-style: italic;
            font-size: 1rem;
            color: var(--gray);
        }

        /* ── Location entries (La Parisienne style: full-width rows) ── */
        .locations-list { background: var(--cream); }

        .location-entry {
            display: grid;
            grid-template-columns: 1fr 1fr;
            min-height: 380px;
            border-bottom: 1px solid var(--gray-light);
            overflow: hidden;
        }

        .location-entry.reverse { direction: rtl; }
        .location-entry.reverse > * { direction: ltr; }

        /* Image panel */
        .loc-img-panel {
            position: relative;
            overflow: hidden;
            background: var(--brown);
            min-height: 320px;
        }

        .loc-img-panel img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
            transition: transform 6s ease;
        }

        .location-entry:hover .loc-img-panel img { transform: scale(1.04); }

        /* Image placeholder */
        .loc-img-placeholder {
            width: 100%;
            height: 100%;
            min-height: 320px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--gray-light);
            font-family: var(--font-ui);
            font-size: 0.62rem;
            letter-spacing: 0.25em;
            text-transform: uppercase;
            color: #b0a090;
        }

        /* Flagship badge */
        .loc-flagship-badge {
            position: absolute;
            top: 1.5rem;
            left: 1.5rem;
            background: var(--gold);
            color: var(--brown-dark);
            font-family: var(--font-ui);
            font-size: 0.6rem;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            padding: 0.3rem 0.8rem;
            font-weight: 600;
            z-index: 2;
        }

        /* Info panel */
        .loc-info-panel {
            background: var(--warm-white);
            padding: clamp(2.5rem, 5vw, 4.5rem) clamp(2rem, 5vw, 4rem);
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .loc-number {
            font-family: var(--font-display);
            font-size: 4rem;
            font-weight: 300;
            color: rgba(201,168,76,0.2);
            line-height: 1;
            margin-bottom: 0.5rem;
        }

        .loc-name {
            font-family: var(--font-display);
            font-size: clamp(1.6rem, 3vw, 2.4rem);
            font-weight: 300;
            color: var(--brown);
            margin-bottom: 0.3rem;
        }

        .loc-tagline {
            font-family: var(--font-body);
            font-style: italic;
            font-size: 0.95rem;
            color: var(--gray);
            margin-bottom: 2rem;
        }

        .loc-divider {
            width: 40px;
            height: 1px;
            background: var(--gold);
            margin-bottom: 2rem;
            opacity: 0.6;
        }

        /* Details */
        .loc-details { display: flex; flex-direction: column; gap: 1rem; margin-bottom: 2rem; }

        .loc-detail-row {
            display: flex;
            gap: 1rem;
            align-items: flex-start;
        }

        .loc-detail-label {
            font-family: var(--font-ui);
            font-size: 0.6rem;
            letter-spacing: 0.22em;
            text-transform: uppercase;
            color: var(--gold);
            min-width: 70px;
            padding-top: 2px;
        }

        .loc-detail-value {
            font-family: var(--font-body);
            font-size: 0.92rem;
            color: var(--brown-dark);
            line-height: 1.6;
        }

        .loc-detail-value a {
            color: var(--brown);
            transition: color 0.2s;
        }
        .loc-detail-value a:hover { color: var(--gold); }

        /* Hours table */
        .loc-hours {
            width: 100%;
        }

        .loc-hours-row {
            display: flex;
            justify-content: space-between;
            padding: 0.25rem 0;
            border-bottom: 1px solid var(--gray-light);
            font-family: var(--font-ui);
            font-size: 0.8rem;
        }

        .loc-hours-row:last-child { border-bottom: none; }
        .loc-hours-row .day  { color: var(--gray); font-weight: 300; letter-spacing: 0.04em; }
        .loc-hours-row .time { color: var(--brown-dark); font-weight: 400; }
        .loc-hours-row .closed { color: #b84040; }

        /* Buttons */
        .loc-actions {
            display: flex;
            gap: 0.8rem;
            flex-wrap: wrap;
            margin-top: 0.5rem;
        }

        /* ── Amenities section ──────────────────────────── */
        .amenities-section {
            background: var(--brown-dark);
            padding: 6rem 0;
            text-align: center;
        }

        .amenities-section .section-eyebrow { color: var(--gold); margin-bottom: 1rem; }

        .amenities-section h2 {
            color: #fff;
            font-size: clamp(1.8rem, 3vw, 2.8rem);
            font-weight: 300;
            margin-bottom: 0.5rem;
        }

        .amenities-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 2px;
            background: rgba(255,255,255,0.05);
            margin-top: 3.5rem;
            text-align: left;
        }

        .amenity-tile {
            background: rgba(255,255,255,0.03);
            padding: 2.5rem 2rem;
            transition: background 0.2s;
        }

        .amenity-tile:hover { background: rgba(201,168,76,0.08); }

        .amenity-tile .amenity-label {
            font-family: var(--font-ui);
            font-size: 0.68rem;
            letter-spacing: 0.18em;
            text-transform: uppercase;
            color: var(--gold-light);
            margin-bottom: 0.5rem;
        }

        .amenity-tile p {
            font-family: var(--font-body);
            font-style: italic;
            font-size: 0.88rem;
            color: rgba(255,255,255,0.45);
            line-height: 1.6;
        }

        /* ── Responsive ─────────────────────────────────── */
        @media (max-width: 900px) {
            .location-entry,
            .location-entry.reverse {
                grid-template-columns: 1fr;
                direction: ltr;
            }

            .location-entry.reverse > * { direction: ltr; }

            .loc-img-panel { min-height: 260px; }
            .loc-info-panel { padding: 2.5rem 2rem; }
            .loc-number { font-size: 2.5rem; }
        }

        @media (max-width: 480px) {
            .loc-actions { flex-direction: column; }
            .amenities-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<%@ include file="../includes/navbar.jsp" %>

<!-- Hero -->
<div class="loc-hero">
    <div class="loc-hero-topper">
        <img src="<%= request.getContextPath() %>/images/store.jpg"  alt="" class="active">
        <img src="<%= request.getContextPath() %>/images/store2.jpg" alt="">
        <img src="<%= request.getContextPath() %>/images/store3.jpg" alt="">
    </div>
    <div class="loc-hero-content">
        <div class="section-eyebrow" style="color:var(--gold); margin-bottom:1rem;">La Farine Pâtisserie</div>
        <h1>Our Locations</h1>
        <div class="loc-hero-line"></div>
        <p>Three houses of pastry — each one a little world of its own</p>
    </div>
</div>

<!-- Intro -->
<div class="loc-intro">
    <div class="container">
        <div class="section-eyebrow reveal">Find Us</div>
        <h2 class="reveal reveal-delay-1">La Farine is spread across three locations in London</h2>
        <p class="reveal reveal-delay-2">Same recipes, same care, same morning ritual — wherever you are in the city.</p>
    </div>
</div>

<!-- Location entries -->
<div class="locations-list">

    <!-- 1. Notting Hill -->
    <div class="location-entry reveal">
        <div class="loc-img-panel">
            <img src="<%= request.getContextPath() %>/images/store.jpg" alt="Notting Hill">
            <div class="loc-flagship-badge">Flagship</div>
        </div>
        <div class="loc-info-panel">
            <div class="loc-number">01</div>
            <div class="loc-name">Notting Hill</div>
            <div class="loc-tagline">Our original home, on the famous Portobello Road</div>
            <div class="loc-divider"></div>
            <div class="loc-details">
                <div class="loc-detail-row">
                    <span class="loc-detail-label">Address</span>
                    <span class="loc-detail-value">
                        14 Portobello Road<br>London, W11 1LA
                    </span>
                </div>
                <div class="loc-detail-row">
                    <span class="loc-detail-label">Phone</span>
                    <span class="loc-detail-value">
                        <a href="tel:02071234567">020 7123 4567</a>
                    </span>
                </div>
                <div class="loc-detail-row">
                    <span class="loc-detail-label">Hours</span>
                    <div class="loc-detail-value">
                        <div class="loc-hours">
                            <div class="loc-hours-row"><span class="day">Mon – Fri</span><span class="time">7:30 – 18:00</span></div>
                            <div class="loc-hours-row"><span class="day">Saturday</span><span class="time">8:00 – 19:00</span></div>
                            <div class="loc-hours-row"><span class="day">Sunday</span><span class="time">9:00 – 17:00</span></div>
                        </div>
                    </div>
                </div>
                <div class="loc-detail-row">
                    <span class="loc-detail-label">Transit</span>
                    <span class="loc-detail-value">Notting Hill Gate — Circle, District, Central</span>
                </div>
            </div>
            <div class="loc-actions">
                <a href="<%= request.getContextPath() %>/ReservationServlet" class="btn btn-gold btn-sm">Reserve a Table</a>
                <a href="https://maps.google.com/?q=14+Portobello+Road+London+W11" target="_blank" class="btn btn-outline btn-sm">Get Directions</a>
            </div>
        </div>
    </div>

    <!-- 2. Soho (reversed) -->
    <div class="location-entry reverse reveal">
        <div class="loc-img-panel">
            <img src="<%= request.getContextPath() %>/images/store2.jpg" alt="Soho">
        </div>
        <div class="loc-info-panel">
            <div class="loc-number">02</div>
            <div class="loc-name">Soho</div>
            <div class="loc-tagline">In the heart of the city, for the city that never slows down</div>
            <div class="loc-divider"></div>
            <div class="loc-details">
                <div class="loc-detail-row">
                    <span class="loc-detail-label">Address</span>
                    <span class="loc-detail-value">
                        7 Carnaby Street<br>London, W1F 9PE
                    </span>
                </div>
                <div class="loc-detail-row">
                    <span class="loc-detail-label">Phone</span>
                    <span class="loc-detail-value">
                        <a href="tel:02072345678">020 7234 5678</a>
                    </span>
                </div>
                <div class="loc-detail-row">
                    <span class="loc-detail-label">Hours</span>
                    <div class="loc-detail-value">
                        <div class="loc-hours">
                            <div class="loc-hours-row"><span class="day">Mon – Fri</span><span class="time">8:00 – 19:00</span></div>
                            <div class="loc-hours-row"><span class="day">Saturday</span><span class="time">8:00 – 20:00</span></div>
                            <div class="loc-hours-row"><span class="day">Sunday</span><span class="time">10:00 – 18:00</span></div>
                        </div>
                    </div>
                </div>
                <div class="loc-detail-row">
                    <span class="loc-detail-label">Transit</span>
                    <span class="loc-detail-value">Oxford Circus — Bakerloo, Central, Victoria</span>
                </div>
            </div>
            <div class="loc-actions">
                <a href="<%= request.getContextPath() %>/ReservationServlet" class="btn btn-gold btn-sm">Reserve a Table</a>
                <a href="https://maps.google.com/?q=7+Carnaby+Street+London+W1F" target="_blank" class="btn btn-outline btn-sm">Get Directions</a>
            </div>
        </div>
    </div>

    <!-- 3. Marylebone -->
    <div class="location-entry reveal">
        <div class="loc-img-panel">
            <img src="<%= request.getContextPath() %>/images/store3.jpg" alt="Marylebone">
        </div>
        <div class="loc-info-panel">
            <div class="loc-number">03</div>
            <div class="loc-name">Marylebone</div>
            <div class="loc-tagline">Quieter streets, longer mornings, unhurried pastries</div>
            <div class="loc-divider"></div>
            <div class="loc-details">
                <div class="loc-detail-row">
                    <span class="loc-detail-label">Address</span>
                    <span class="loc-detail-value">
                        22 Baker Street<br>London, W1U 3BW
                    </span>
                </div>
                <div class="loc-detail-row">
                    <span class="loc-detail-label">Phone</span>
                    <span class="loc-detail-value">
                        <a href="tel:02073456789">020 7345 6789</a>
                    </span>
                </div>
                <div class="loc-detail-row">
                    <span class="loc-detail-label">Hours</span>
                    <div class="loc-detail-value">
                        <div class="loc-hours">
                            <div class="loc-hours-row"><span class="day">Mon – Fri</span><span class="time">7:00 – 17:30</span></div>
                            <div class="loc-hours-row"><span class="day">Saturday</span><span class="time">8:00 – 18:00</span></div>
                            <div class="loc-hours-row"><span class="day">Sunday</span><span class="time closed">Closed</span></div>
                        </div>
                    </div>
                </div>
                <div class="loc-detail-row">
                    <span class="loc-detail-label">Transit</span>
                    <span class="loc-detail-value">Baker Street — Bakerloo, Circle, Jubilee, Metropolitan</span>
                </div>
            </div>
            <div class="loc-actions">
                <a href="<%= request.getContextPath() %>/ReservationServlet" class="btn btn-gold btn-sm">Reserve a Table</a>
                <a href="https://maps.google.com/?q=22+Baker+Street+London+W1U" target="_blank" class="btn btn-outline btn-sm">Get Directions</a>
            </div>
        </div>
    </div>

</div>

<!-- Amenities -->
<div class="amenities-section">
    <div class="container">
        <div class="section-eyebrow">Every Location</div>
        <h2 class="reveal">What We Offer Everywhere</h2>
        <div class="section-ornament reveal reveal-delay-1">✦</div>
        <div class="amenities-grid">
            <div class="amenity-tile reveal">
                <div class="amenity-label">Dine In</div>
                <p>Comfortable indoor seating with complimentary Wi-Fi</p>
            </div>
            <div class="amenity-tile reveal reveal-delay-1">
                <div class="amenity-label">Gift Boxes</div>
                <p>Custom-packaged pastry gift sets, available to take away</p>
            </div>
            <div class="amenity-tile reveal reveal-delay-2">
                <div class="amenity-label">Accessibility</div>
                <p>Wheelchair accessible entrances and dedicated seating areas</p>
            </div>
            <div class="amenity-tile reveal reveal-delay-3">
                <div class="amenity-label">Payment</div>
                <p>Card, Apple Pay, and Google Pay accepted at all locations</p>
            </div>
            <div class="amenity-tile reveal">
                <div class="amenity-label">Dietary</div>
                <p>Gluten-free and vegan selections baked fresh every morning</p>
            </div>
            <div class="amenity-tile reveal reveal-delay-1">
                <div class="amenity-label">Click & Collect</div>
                <p>Order online, collect in store — no waiting in line</p>
            </div>
        </div>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

<script>
(function() {
    var reveals = document.querySelectorAll('.reveal');
    var observer = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });
    reveals.forEach(function(el) { observer.observe(el); });
})();
// ── Topper slideshow ─────────────────────────────────────
(function(){
    var imgs = document.querySelectorAll('.loc-hero-topper img');
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