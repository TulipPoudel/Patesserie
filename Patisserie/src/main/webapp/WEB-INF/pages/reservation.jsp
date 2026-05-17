<%-- FILE LOCATION: WEB-INF/pages/reservation.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/DashboardServlet"); return; }
    List<String[]> reservations = (List<String[]>) request.getAttribute("reservations");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reserve a Table – L'Atelier Sucré Pâtisserie</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2">
    <style>
        .reserve-hero {
            position: relative;
            padding: calc(var(--nav-h) + 5.5rem) 0 5.5rem;
            text-align: center;
            overflow: hidden;
            background: var(--brown-dark);
        }
        .reserve-hero-topper {
            position: absolute;
            inset: 0;
            z-index: 0;
        }
        .reserve-hero-topper img {
            width: 100%; height: 100%;
            object-fit: cover; object-position: center;
            display: block; opacity: 0.32;
        }
        .reserve-hero::before {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, rgba(14,7,4,0.88) 0%, rgba(46,21,8,0.78) 40%, rgba(74,37,18,0.72) 100%);
            z-index: 1;
        }
        .reserve-hero-content { position: relative; z-index: 2; }
        .reserve-hero h1 {
            font-family: var(--font-display);
            font-size: clamp(2.4rem, 5.5vw, 4.5rem);
            font-weight: 300; color: #fff;
            letter-spacing: 0.06em; margin-bottom: 0.5rem;
        }
        .reserve-hero p {
            font-family: var(--font-display); font-style: italic;
            color: rgba(255,255,255,0.55); font-size: 1.05rem;
            max-width: 500px; margin: 0 auto;
        }
        .reserve-hero-line { width: 50px; height: 1px; background: var(--gold); margin: 1.4rem auto; }

        /* Status badges */
        .badge-pending   { background: #fff8e1; color: #f59e0b; padding: 0.2rem 0.7rem; border-radius: 20px; font-size: 0.72rem; font-family: var(--font-ui); font-weight: 600; }
        .badge-confirmed { background: #e8f5e9; color: #2e7d32; padding: 0.2rem 0.7rem; border-radius: 20px; font-size: 0.72rem; font-family: var(--font-ui); font-weight: 600; }
        .badge-cancelled { background: #fce8e8; color: #c62828; padding: 0.2rem 0.7rem; border-radius: 20px; font-size: 0.72rem; font-family: var(--font-ui); font-weight: 600; }
    </style>
</head>
<body>

<%@ include file="../includes/navbar.jsp" %>

<div class="reserve-hero">
    <div class="reserve-hero-topper">
        <img src="<%= request.getContextPath() %>/images/table.jpg" alt="">
    </div>
    <div class="reserve-hero-content">
        <div class="section-eyebrow" style="color:var(--gold); margin-bottom:0.8rem;">L'Atelier Sucré</div>
        <h1>Reserve a Table</h1>
        <div class="reserve-hero-line"></div>
        <p>Book your spot — we'll have everything ready for you</p>
    </div>
</div>

<div class="page-content">
    <div class="container">

        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success">&#10003; <%= request.getAttribute("success") %></div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>

        <div style="display:flex; gap:2rem; flex-wrap:wrap; align-items:flex-start;">

            <%-- Booking form --%>
            <div class="card" style="flex:2; min-width:280px;">
                <div class="card-body" style="padding:2rem;">
                    <h2 style="margin-bottom:1.5rem; font-size:1.2rem;">Make a Reservation</h2>

                    <form action="<%= request.getContextPath() %>/ReservationServlet" method="post">
                        <input type="hidden" name="action" value="book">

                        <div class="form-group">
                            <label for="guestName">Full name</label>
                            <input type="text" id="guestName" name="guestName"
                                   placeholder="e.g. Tulip Poudel" required
                                   value="<%= user.getFullName() %>">
                        </div>
                        <div class="form-group">
                            <label for="email">Email address</label>
                            <input type="email" id="email" name="email"
                                   placeholder="you@example.com" required
                                   value="<%= user.getEmail() %>">
                        </div>
                        <div class="form-group">
                            <label for="phone">Phone number</label>
                            <input type="tel" id="phone" name="phone"
                                   placeholder="07700 000000"
                                   value="<%= user.getPhone() != null ? user.getPhone() : "" %>">
                        </div>

                        <div style="display:flex; gap:1rem; flex-wrap:wrap;">
                            <div class="form-group" style="flex:1; min-width:140px;">
                                <label for="date">Date</label>
                                <input type="date" id="date" name="date" required
                                       min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                            </div>
                            <div class="form-group" style="flex:1; min-width:140px;">
                                <label for="time">Time</label>
                                <select id="time" name="time" required>
                                    <option value="">-- Select time --</option>
                                    <option value="08:00">8:00 AM</option>
                                    <option value="08:30">8:30 AM</option>
                                    <option value="09:00">9:00 AM</option>
                                    <option value="09:30">9:30 AM</option>
                                    <option value="10:00">10:00 AM</option>
                                    <option value="10:30">10:30 AM</option>
                                    <option value="11:00">11:00 AM</option>
                                    <option value="11:30">11:30 AM</option>
                                    <option value="12:00">12:00 PM</option>
                                    <option value="12:30">12:30 PM</option>
                                    <option value="13:00">1:00 PM</option>
                                    <option value="13:30">1:30 PM</option>
                                    <option value="14:00">2:00 PM</option>
                                    <option value="14:30">2:30 PM</option>
                                    <option value="15:00">3:00 PM</option>
                                    <option value="15:30">3:30 PM</option>
                                    <option value="16:00">4:00 PM</option>
                                    <option value="16:30">4:30 PM</option>
                                    <option value="17:00">5:00 PM</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="guests">Number of guests</label>
                            <select id="guests" name="guests" required>
                                <option value="">-- Select guests --</option>
                                <option value="1">1 person</option>
                                <option value="2">2 people</option>
                                <option value="3">3 people</option>
                                <option value="4">4 people</option>
                                <option value="5">5 people</option>
                                <option value="6">6 people</option>
                                <option value="7">7 people</option>
                                <option value="8">8 people (large group)</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="location">Branch</label>
                            <select id="location" name="location" required>
                                <option value="">-- Select location --</option>
                                <option value="Notting Hill">Notting Hill – 14 Portobello Rd</option>
                                <option value="Soho">Soho – 7 Carnaby Street</option>
                                <option value="Marylebone">Marylebone – 22 Baker Street</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="notes">Special requests <small style="font-weight:normal;">(optional)</small></label>
                            <textarea id="notes" name="notes" placeholder="e.g. window seat, birthday celebration, allergy info..."></textarea>
                        </div>

                        <button type="submit" class="btn btn-primary btn-block">Confirm Reservation</button>
                    </form>
                </div>
            </div>

            <%-- Info sidebar --%>
            <div style="flex:1; min-width:240px; display:flex; flex-direction:column; gap:1.2rem;">
                <div class="card">
                    <div class="card-body">
                        <h3 style="margin-bottom:0.8rem;">🕑 Opening Hours</h3>
                        <table style="width:100%; font-size:0.88rem;">
                            <tr><td style="padding:0.35rem 0; color:#888;">Mon – Fri</td><td style="font-weight:600;">7:30 AM – 6:00 PM</td></tr>
                            <tr><td style="padding:0.35rem 0; color:#888;">Saturday</td><td style="font-weight:600;">8:00 AM – 7:00 PM</td></tr>
                            <tr><td style="padding:0.35rem 0; color:#888;">Sunday</td><td style="font-weight:600;">9:00 AM – 5:00 PM</td></tr>
                        </table>
                    </div>
                </div>
                <div class="card">
                    <div class="card-body">
                        <h3 style="margin-bottom:0.8rem;">ℹ️ Good to Know</h3>
                        <ul style="font-size:0.87rem; color:#666; line-height:1.9; padding-left:1.1rem;">
                            <li>Reservations held for 15 minutes</li>
                            <li>Walk-ins welcome when available</li>
                            <li>Groups over 8 — please call us</li>
                            <li>We accommodate most dietary needs</li>
                        </ul>
                    </div>
                </div>
                <div class="card">
                    <div class="card-body">
                        <h3 style="margin-bottom:0.8rem;">📞 Contact Us</h3>
                        <p style="font-size:0.87rem; color:#666; line-height:1.8;">
                            Phone: <strong>020 7123 4567</strong><br>
                            Email: <strong>hello@lateliersucre.co.uk</strong>
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <%-- My Reservations table --%>
        <div style="margin-top:2.5rem;">
            <h2 class="section-title">📋 My Reservations</h2>

            <% if (reservations == null || reservations.isEmpty()) { %>
                <div class="empty-state">
                    <h3>No reservations yet</h3>
                    <p>Your upcoming bookings will appear here once you make one above.</p>
                </div>
            <% } else { %>
                <div class="table-wrapper">
                    <table style="width:100%; border-collapse:collapse; font-size:0.87rem;">
                        <thead>
                            <tr>
                                <th style="text-align:left; padding:0.6rem 1rem; font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.12em; text-transform:uppercase; color:var(--gray); border-bottom:2px solid var(--gray-light);">Date</th>
                                <th style="text-align:left; padding:0.6rem 1rem; font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.12em; text-transform:uppercase; color:var(--gray); border-bottom:2px solid var(--gray-light);">Time</th>
                                <th style="text-align:left; padding:0.6rem 1rem; font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.12em; text-transform:uppercase; color:var(--gray); border-bottom:2px solid var(--gray-light);">Guests</th>
                                <th style="text-align:left; padding:0.6rem 1rem; font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.12em; text-transform:uppercase; color:var(--gray); border-bottom:2px solid var(--gray-light);">Location</th>
                                <th style="text-align:left; padding:0.6rem 1rem; font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.12em; text-transform:uppercase; color:var(--gray); border-bottom:2px solid var(--gray-light);">Notes</th>
                                <th style="text-align:left; padding:0.6rem 1rem; font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.12em; text-transform:uppercase; color:var(--gray); border-bottom:2px solid var(--gray-light);">Status</th>
                                <th style="text-align:left; padding:0.6rem 1rem; font-family:var(--font-ui); font-size:0.65rem; letter-spacing:0.12em; text-transform:uppercase; color:var(--gray); border-bottom:2px solid var(--gray-light);">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (String[] r : reservations) {
                                // r: [0]id [1]guestName [2]date [3]time [4]guests [5]location [6]notes [7]status [8]createdAt
                                String statusClass = "badge-" + r[7];
                            %>
                            <tr style="border-bottom:1px solid var(--gray-light);">
                                <td style="padding:0.85rem 1rem;"><%= r[2] %></td>
                                <td style="padding:0.85rem 1rem;"><%= r[3] %></td>
                                <td style="padding:0.85rem 1rem;"><%= r[4] %></td>
                                <td style="padding:0.85rem 1rem;"><%= r[5] %></td>
                                <td style="padding:0.85rem 1rem; color:#888;"><%= r[6].isEmpty() ? "-" : r[6] %></td>
                                <td style="padding:0.85rem 1rem;"><span class="<%= statusClass %>"><%= r[7] %></span></td>
                                <td style="padding:0.85rem 1rem;">
                                    <% if (!"cancelled".equals(r[7])) { %>
                                        <form method="post" action="<%= request.getContextPath() %>/ReservationServlet"
                                              onsubmit="return confirm('Cancel this reservation?');" style="display:inline;">
                                            <input type="hidden" name="action" value="cancel">
                                            <input type="hidden" name="reservationId" value="<%= r[0] %>">
                                            <button type="submit" class="btn btn-outline btn-sm" style="color:var(--red); border-color:var(--red);">Cancel</button>
                                        </form>
                                    <% } else { %>
                                        <span style="color:#aaa; font-size:0.8rem;">—</span>
                                    <% } %>
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

<%@ include file="../includes/footer.jsp" %>
</body>
</html>