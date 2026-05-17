<%-- FILE LOCATION: WEB-INF/includes/footer.jsp --%>
<%
    String fctx = request.getContextPath();
%>

<!-- ═══ FOOTER ═══ -->
<footer class="footer">
    <div class="footer-top">
        <div class="container">
            <div class="footer-grid">

                <!-- Brand col -->
                <div class="footer-brand-col">
                    <div class="footer-logo">L'Atelier Sucré</div>
                    <div class="footer-logo-sub">Pâtisserie Artisanale</div>
                    <p>
                        Crafted with flour, time, and devotion.
                        Every pastry a small ceremony — made fresh
                        each morning in our kitchen.
                    </p>
                    <div class="footer-ornament">✦</div>
                    <div class="footer-social">
                        <a href="#" title="Instagram">in</a>
                        <a href="#" title="Facebook">fb</a>
                        <a href="#" title="Twitter">tw</a>
                    </div>
                </div>

                <!-- Explore -->
                <div class="footer-col">
                    <h4>Explore</h4>
                    <ul>
                        <li><a href="<%= fctx %>/ProductsServlet">Our Menu</a></li>
                        <li><a href="<%= fctx %>/ReservationServlet">Reserve a Table</a></li>
                        <li><a href="<%= fctx %>/OrderServlet">My Orders</a></li>
                        <li><a href="<%= fctx %>/LocationServlet">Locations</a></li>
                    </ul>
                </div>

                <!-- Account -->
                <div class="footer-col">
                    <h4>Account</h4>
                    <ul>
                        <%
                            Object footerUser = session != null ? session.getAttribute("user") : null;
                            if (footerUser != null) {
                        %>
                            <li><a href="<%= fctx %>/ProfileServlet">My Profile</a></li>
                            <li><a href="<%= fctx %>/DashboardServlet">Dashboard</a></li>
                            <li><a href="<%= fctx %>/LogoutServlet">Sign Out</a></li>
                        <% } else { %>
                            <li><a href="<%= fctx %>/LoginServlet">Sign In</a></li>
                            <li><a href="<%= fctx %>/RegisterServlet">Register</a></li>
                            <li><a href="<%= fctx %>/DashboardServlet">Dashboard</a></li>
                        <% } %>
                    </ul>
                </div>

                <!-- Visit -->
                <div class="footer-col">
                    <h4>Visit Us</h4>
                    <address>
                        L'Atelier Sucré Pâtisserie<br>
                        123 Rue de la Paix<br>
                        Paris, 75001<br><br>
                        Mon–Sat: 7:00 – 19:00<br>
                        Sunday: 8:00 – 14:00<br><br>
                        +33 1 23 45 67 89
                    </address>
                </div>

            </div>
        </div>
    </div>

    <div class="footer-bottom">
        <div class="container" style="display:contents">
            <div class="container" style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:0.8rem; width:100%; max-width:1280px; margin:0 auto; padding:0 clamp(1rem,4vw,3rem);">
                <p>&copy; 2025 L'Atelier Sucré Pâtisserie &mdash; All Rights Reserved</p>
                <div class="footer-bottom-links">
                    <a href="#">Privacy Policy</a>
                    <a href="#">Terms of Use</a>
                    <a href="#">Legal</a>
                </div>
            </div>
        </div>
    </div>
</footer>