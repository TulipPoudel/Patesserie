<%-- FILE LOCATION: WEB-INF/pages/reservation.jsp --%>
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
    <title>Reserve a Table – La Farine Pâtisserie</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
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
            <a href="<%= request.getContextPath() %>/ReservationServlet" class="active">Reserve Table</a>
            <a href="<%= request.getContextPath() %>/OrderServlet">My Orders</a>
            <a href="<%= request.getContextPath() %>/LocationServlet">Locations</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </div>
    </div>
</nav>

<div class="page-content">
    <div class="container">

        <div class="page-header">
            <div>
                <h1>&#127860; Reserve a Table</h1>
                <p style="color:#888; margin-top:0.3rem;">Book your spot at La Farine — we'll have it ready for you.</p>
            </div>
        </div>

        <%-- Success / error messages --%>
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success">
                &#10003; <%= request.getAttribute("success") %>
            </div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error">
                <%= request.getAttribute("error") %>
            </div>
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
                            <input type="text"
                                   id="guestName"
                                   name="guestName"
                                   placeholder="e.g. Sophie Martin"
                                   required
                                   value="<%= user.getFullName() %>">
                        </div>

                        <div class="form-group">
                            <label for="email">Email address</label>
                            <input type="email"
                                   id="email"
                                   name="email"
                                   placeholder="you@example.com"
                                   required
                                   value="<%= user.getEmail() %>">
                        </div>

                        <div class="form-group">
                            <label for="phone">Phone number</label>
                            <input type="tel"
                                   id="phone"
                                   name="phone"
                                   placeholder="07700 000000"
                                   value="<%= user.getPhone() != null ? user.getPhone() : "" %>">
                        </div>

                        <div style="display:flex; gap:1rem; flex-wrap:wrap;">
                            <div class="form-group" style="flex:1; min-width:140px;">
                                <label for="date">Date</label>
                                <input type="date"
                                       id="date"
                                       name="date"
                                       required
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
                        <h3 style="margin-bottom:0.8rem;">&#128337; Opening Hours</h3>
                        <table style="width:100%; font-size:0.88rem;">
                            <tr>
                                <td style="padding:0.35rem 0; color:#888;">Mon – Fri</td>
                                <td style="font-weight:600;">7:30 AM – 6:00 PM</td>
                            </tr>
                            <tr>
                                <td style="padding:0.35rem 0; color:#888;">Saturday</td>
                                <td style="font-weight:600;">8:00 AM – 7:00 PM</td>
                            </tr>
                            <tr>
                                <td style="padding:0.35rem 0; color:#888;">Sunday</td>
                                <td style="font-weight:600;">9:00 AM – 5:00 PM</td>
                            </tr>
                        </table>
                    </div>
                </div>

                <div class="card">
                    <div class="card-body">
                        <h3 style="margin-bottom:0.8rem;">&#8505;&#65039; Good to Know</h3>
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
                        <h3 style="margin-bottom:0.8rem;">&#128222; Contact Us</h3>
                        <p style="font-size:0.87rem; color:#666; line-height:1.8;">
                            Phone: <strong>020 7123 4567</strong><br>
                            Email: <strong>hello@lafarine.co.uk</strong>
                        </p>
                    </div>
                </div>

            </div>
        </div>

        <%-- My upcoming reservations --%>
        <div style="margin-top:2.5rem;">
            <h2 class="section-title">&#128203; My Reservations</h2>

            <% if (request.getAttribute("reservations") == null) { %>
                <div class="empty-state">
                    <h3>No reservations yet</h3>
                    <p>Your upcoming bookings will appear here once you make one above.</p>
                </div>
            <% } %>

            <%-- If you wire up a list from the servlet, iterate here:
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>#</th><th>Date</th><th>Time</th><th>Guests</th><th>Location</th><th>Notes</th><th>Status</th><th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        ... iterate request.getAttribute("reservations") ...
                    </tbody>
                </table>
            </div>
            --%>
        </div>

    </div>
</div>

<footer class="footer">
    <div class="container">
        <p>&copy; 2025 La Farine Pâtisserie</p>
    </div>
</footer>
</body>
</html>