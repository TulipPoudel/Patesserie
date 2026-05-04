package com.patisserie.controller;

import jakarta.servlet.ServletException;
import java.sql.SQLException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

import com.patisserie.model.User;
import com.patisserie.service.UserService;
/**
 * Servlet implementation class LoginServlet
 */
@WebServlet(asyncSupported = true, urlPatterns = { "/LoginServlet" })
public class LoginServlet extends HttpServlet {
	 
    private final UserService userService = new UserService();
 
    // ── GET: show login form ──────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        // If session already exists, skip straight to dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User u = (User) session.getAttribute("user");
            redirectByRole(request, response, u);
            return;
        }
 
        // Check for "Remember Me" cookie and pre-fill email field
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("rememberedEmail".equals(c.getName())) {
                    // Send remembered email to JSP so it can pre-fill the input
                    request.setAttribute("rememberedEmail", c.getValue());
                }
                if ("userName".equals(c.getName())) {
                    request.setAttribute("welcomeBack", c.getValue());
                }
            }
        }
 
        request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
    }
 
    // ── POST: handle form submission ──────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        String email      = request.getParameter("email").trim();
        String password   = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe"); // "yes" if ticked
 
        try {
            // Account locked check
            if (userService.isLocked(email)) {
                request.setAttribute("error",
                    "Account locked after too many failed attempts. Please contact support.");
                request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
                return;
            }
 
            User user = userService.login(email, password);
 
            if (user != null) {
                // ── 1. Create HTTP Session ────────────────────
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setMaxInactiveInterval(30 * 60); // expires after 30 mins idle
 
                // ── 2. Handle Cookies ─────────────────────────
                if ("yes".equals(rememberMe)) {
                    // Save email cookie for 7 days so form pre-fills next visit
                    Cookie emailCookie = new Cookie("rememberedEmail", email);
                    emailCookie.setMaxAge(7 * 24 * 60 * 60);
                    emailCookie.setPath("/");
                    response.addCookie(emailCookie);
 
                    // Save name cookie to show "Welcome back, Name" message
                    Cookie nameCookie = new Cookie("userName", user.getFullName());
                    nameCookie.setMaxAge(7 * 24 * 60 * 60);
                    nameCookie.setPath("/");
                    response.addCookie(nameCookie);
 
                } else {
                    // User did NOT tick "Remember Me" — delete existing cookies
                    Cookie emailCookie = new Cookie("rememberedEmail", "");
                    emailCookie.setMaxAge(0); // 0 = delete immediately
                    emailCookie.setPath("/");
                    response.addCookie(emailCookie);
                }
 
                // ── 3. Redirect based on role ─────────────────
                redirectByRole(request, response, user);
 
            } else {
                // Wrong password or email
                request.setAttribute("error", "Invalid email or password. Please try again.");
                request.setAttribute("rememberedEmail", email);
                request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
            }
 
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
        }
    }
 
    private void redirectByRole(HttpServletRequest req, HttpServletResponse res, User user)
            throws IOException {
        if ("admin".equals(user.getRole())) {
            res.sendRedirect(req.getContextPath() + "/AdminDashboardServlet");
        } else {
            res.sendRedirect(req.getContextPath() + "/DashboardServlet");
        }
    }
}
