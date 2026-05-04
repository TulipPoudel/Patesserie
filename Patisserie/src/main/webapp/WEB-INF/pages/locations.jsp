<%-- FILE LOCATION: WEB-INF/pages/locations.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Our Locations – La Farine Pâtisserie</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .location-card {
            background: var(--warm-white);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            overflow: hidden;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .location-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 24px rgba(92,61,46,0.18);
        }
        .location-map-placeholder {
            height: 180px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3rem;
            position: relative;
        }
        .location-info { padding: 1.4rem; }
        .location-name {
            font-family: var(--font-main);
            font-size: 1.25rem;
            color: var(--brown);
            margin-bottom: 0.3rem;
        }
        .location-address {
            font-size: 0.88rem;
            color: var(--gray);
            margin-bottom: 1rem;
            line-height: 1.6;
        }
        .location-detail {
            display: flex;
            align-items: flex-start;
            gap: 0.5rem;
            font-size: 0.85rem;
            color: var(--gray);
            margin-bottom: 0.5rem;
        }
        .location-detail span:first-child { flex-shrink: 0; }
        .hours-row {
            display: flex;
            justify-content: space-between;
            font-size: 0.85rem;
            padding: 0.3rem 0;
            border-bottom: 1px solid var(--gray-light);
        }
        .hours-row:last-child { border-bottom: none; }
        .hours-row .day { color: var(--gray); }
        .hours-row .time { font-weight: 600; color: var(--brown-dark); }
    </style>
</head>
<body>

<%-- Navbar --%>
<nav class="navbar">
    <div class="container">
        <a href="<%= request.getContextPath() %>/DashboardServlet" class="navbar-brand">
            La Farine <span>Pâtisserie</span>
        </a>
        <div class="navbar-links">
            <a href="<%= request.getContextPath() %>/DashboardServlet">Dashboard</a>
            <a href="<%= request.getContextPath() %>/ProductsServlet">Menu</a>
            <a href="<%= request.getContextPath() %>/ReservationServlet">Reserve Table</a>
            <a href="<%= request.getContextPath() %>/OrderServlet">My Orders</a>
            <a href="<%= request.getContextPath() %>/LocationServlet" class="active">Locations</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </div>
    </div>
</nav>

<%-- Hero --%>
<div class="hero">
    <div class="container">
        <h1>&#128205; Find Us</h1>
        <p>Three locations across London — each with its own character, all with the same warmth.</p>
    </div>
</div>

<div class="page-content">
    <div class="container">

        <%-- Three location cards side by side --%>
        <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(300px, 1fr)); gap:1.6rem; margin-bottom:3rem;">

            <%-- Notting Hill --%>
            <div class="location-card">
                <div class="location-map-placeholder" style="background:linear-gradient(135deg,#f0d580,#c9a84c);">
                    &#127968;
                    <span style="position:absolute; bottom:10px; right:12px; background:var(--brown); color:#fff; font-size:0.72rem; padding:0.2rem 0.6rem; border-radius:999px;">Flagship</span>
                </div>
                <div class="location-info">
                    <div class="location-name">Notting Hill</div>
                    <div class="location-address">
                        14 Portobello Road<br>
                        London, W11 1LA
                    </div>

                    <div class="location-detail">
                        <span>&#128337;</span>
                        <div>
                            <div class="hours-row"><span class="day">Mon – Fri</span><span class="time">7:30 – 18:00</span></div>
                            <div class="hours-row"><span class="day">Saturday</span><span class="time">8:00 – 19:00</span></div>
                            <div class="hours-row"><span class="day">Sunday</span><span class="time">9:00 – 17:00</span></div>
                        </div>
                    </div>

                    <div class="location-detail" style="margin-top:0.8rem;">
                        <span>&#128222;</span><span>020 7123 4567</span>
                    </div>
                    <div class="location-detail">
                        <span>&#128652;</span><span>Notting Hill Gate (Circle, District, Central)</span>
                    </div>
                    <div class="location-detail">
                        <span>&#128663;</span><span>Pay-and-display on Portobello Rd</span>
                    </div>

                    <div style="margin-top:1.2rem; display:flex; gap:0.6rem;">
                        <a href="<%= request.getContextPath() %>/ReservationServlet" class="btn btn-primary btn-sm">Reserve Table</a>
                        <a href="https://maps.google.com/?q=14+Portobello+Road+London" target="_blank" class="btn btn-outline btn-sm">Get Directions</a>
                    </div>
                </div>
            </div>

            <%-- Soho --%>
            <div class="location-card">
                <div class="location-map-placeholder" style="background:linear-gradient(135deg,#5c3d2e,#8b6551);">
                    &#127968;
                </div>
                <div class="location-info">
                    <div class="location-name">Soho</div>
                    <div class="location-address">
                        7 Carnaby Street<br>
                        London, W1F 9PE
                    </div>

                    <div class="location-detail">
                        <span>&#128337;</span>
                        <div>
                            <div class="hours-row"><span class="day">Mon – Fri</span><span class="time">8:00 – 19:00</span></div>
                            <div class="hours-row"><span class="day">Saturday</span><span class="time">8:00 – 20:00</span></div>
                            <div class="hours-row"><span class="day">Sunday</span><span class="time">10:00 – 18:00</span></div>
                        </div>
                    </div>

                    <div class="location-detail" style="margin-top:0.8rem;">
                        <span>&#128222;</span><span>020 7234 5678</span>
                    </div>
                    <div class="location-detail">
                        <span>&#128652;</span><span>Oxford Circus (Bakerloo, Central, Victoria)</span>
                    </div>
                    <div class="location-detail">
                        <span>&#128663;</span><span>NCP Soho, Wardour St (5 min walk)</span>
                    </div>

                    <div style="margin-top:1.2rem; display:flex; gap:0.6rem;">
                        <a href="<%= request.getContextPath() %>/ReservationServlet" class="btn btn-primary btn-sm">Reserve Table</a>
                        <a href="https://maps.google.com/?q=7+Carnaby+Street+London" target="_blank" class="btn btn-outline btn-sm">Get Directions</a>
                    </div>
                </div>
            </div>

            <%-- Marylebone --%>
            <div class="location-card">
                <div class="location-map-placeholder" style="background:linear-gradient(135deg,#4a7c59,#3e2a1e);">
                    &#127968;
                </div>
                <div class="location-info">
                    <div class="location-name">Marylebone</div>
                    <div class="location-address">
                        22 Baker Street<br>
                        London, W1U 3BW
                    </div>

                    <div class="location-detail">
                        <span>&#128337;</span>
                        <div>
                            <div class="hours-row"><span class="day">Mon – Fri</span><span class="time">7:00 – 17:30</span></div>
                            <div class="hours-row"><span class="day">Saturday</span><span class="time">8:00 – 18:00</span></div>
                            <div class="hours-row"><span class="day">Sunday</span><span class="time">Closed</span></div>
                        </div>
                    </div>

                    <div class="location-detail" style="margin-top:0.8rem;">
                        <span>&#128222;</span><span>020 7345 6789</span>
                    </div>
                    <div class="location-detail">
                        <span>&#128652;</span><span>Baker Street (Bakerloo, Circle, H&C, Jubilee, Met)</span>
                    </div>
                    <div class="location-detail">
                        <span>&#128663;</span><span>Meter parking on Baker St and side streets</span>
                    </div>

                    <div style="margin-top:1.2rem; display:flex; gap:0.6rem;">
                        <a href="<%= request.getContextPath() %>/ReservationServlet" class="btn btn-primary btn-sm">Reserve Table</a>
                        <a href="https://maps.google.com/?q=22+Baker+Street+London" target="_blank" class="btn btn-outline btn-sm">Get Directions</a>
                    </div>
                </div>
            </div>

        </div>

        <%-- General info strip --%>
        <div class="card" style="margin-bottom:2rem;">
            <div class="card-body" style="padding:1.8rem;">
                <h2 style="margin-bottom:1.2rem;">&#127881; Every Branch Offers</h2>
                <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(200px, 1fr)); gap:1rem;">
                    <div style="display:flex; gap:0.7rem; align-items:flex-start;">
                        <span style="font-size:1.4rem;">&#9749;</span>
                        <div>
                            <strong style="font-size:0.9rem; color:var(--brown);">Dine-in seating</strong>
                            <p style="font-size:0.82rem; margin:0;">Comfortable indoor seating, free Wi-Fi</p>
                        </div>
                    </div>
                    <div style="display:flex; gap:0.7rem; align-items:flex-start;">
                        <span style="font-size:1.4rem;">&#127873;</span>
                        <div>
                            <strong style="font-size:0.9rem; color:var(--brown);">Gift boxes</strong>
                            <p style="font-size:0.82rem; margin:0;">Custom-packaged pastry gift sets to take away</p>
                        </div>
                    </div>
                    <div style="display:flex; gap:0.7rem; align-items:flex-start;">
                        <span style="font-size:1.4rem;">&#9855;</span>
                        <div>
                            <strong style="font-size:0.9rem; color:var(--brown);">Accessibility</strong>
                            <p style="font-size:0.82rem; margin:0;">Wheelchair accessible entrances and seating</p>
                        </div>
                    </div>
                    <div style="display:flex; gap:0.7rem; align-items:flex-start;">
                        <span style="font-size:1.4rem;">&#128241;</span>
                        <div>
                            <strong style="font-size:0.9rem; color:var(--brown);">Contactless pay</strong>
                            <p style="font-size:0.82rem; margin:0;">Card, Apple Pay, and Google Pay accepted</p>
                        </div>
                    </div>
                    <div style="display:flex; gap:0.7rem; align-items:flex-start;">
                        <span style="font-size:1.4rem;">&#127807;</span>
                        <div>
                            <strong style="font-size:0.9rem; color:var(--brown);">Dietary options</strong>
                            <p style="font-size:0.82rem; margin:0;">Gluten-free and vegan items available daily</p>
                        </div>
                    </div>
                    <div style="display:flex; gap:0.7rem; align-items:flex-start;">
                        <span style="font-size:1.4rem;">&#128230;</span>
                        <div>
                            <strong style="font-size:0.9rem; color:var(--brown);">Click & Collect</strong>
                            <p style="font-size:0.82rem; margin:0;">Order online and collect in-store, no wait</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<footer class="footer">
    <div class="container">
        <p>&copy; 2025 La Farine Pâtisserie &mdash; London</p>
    </div>
</footer>
</body>
</html>