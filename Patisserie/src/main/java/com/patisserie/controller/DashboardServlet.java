package com.patisserie.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

import com.patisserie.model.User;

/**
 * Servlet implementation class DashboardServlet
 */
@WebServlet(asyncSupported = true, urlPatterns = { "/DashboardServlet" })
public class DashboardServlet extends HttpServlet {
	 
    private final com.patisserie.service.UserService userService = new com.patisserie.service.UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // ── Auto-login via Remember Me cookie ────────────────
        if (user == null) {
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                String rememberedEmail = null;
                for (Cookie c : cookies) {
                    if ("rememberedEmail".equals(c.getName()) && !c.getValue().isEmpty()) {
                        rememberedEmail = c.getValue();
                    }
                }
                if (rememberedEmail != null) {
                    try {
                        // Look up user by email (no password needed — cookie is the trust token)
                        user = userService.getUserByEmail(rememberedEmail);
                        if (user != null) {
                            HttpSession newSession = request.getSession(true);
                            newSession.setAttribute("user", user);
                            newSession.setMaxInactiveInterval(30 * 60);
                        }
                    } catch (Exception e) {
                        // Cookie lookup failed — continue as guest
                    }
                }
            }
        }

        // ── Admin redirect ────────────────────────────────────
        if (user != null && "admin".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
            return;
        }

        // ── Pass user (or null for guest) to JSP ─────────────
        request.setAttribute("loggedInUser", user);
        request.setAttribute("guestMode", user == null);

        request.getRequestDispatcher("/WEB-INF/pages/dashboard.jsp").forward(request, response);
    }
}