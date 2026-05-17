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

@WebServlet(asyncSupported = true, urlPatterns = { "/LoginServlet" })
public class LoginServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User u = (User) session.getAttribute("user");
            redirectByRole(request, response, u);
            return;
        }

        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("rememberedEmail".equals(c.getName()))
                    request.setAttribute("rememberedEmail", c.getValue());
                if ("userName".equals(c.getName()))
                    request.setAttribute("welcomeBack", c.getValue());
            }
        }

        request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
        String email    = request.getParameter("email").trim();
        String password = request.getParameter("password");
        String remember = request.getParameter("rememberMe");

        try {
            if (userService.isLocked(email)) {
                if (isAjax) {
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\":false,\"message\":\"Account locked. Please contact support.\"}");
                } else {
                    request.setAttribute("error", "Account locked after too many failed attempts. Please contact support.");
                    request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
                }
                return;
            }

            User user = userService.login(email, password);

            if (user != null) {
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setMaxInactiveInterval(30 * 60);

                // ✅ HttpOnly flag set on both set and clear
                if ("yes".equals(remember)) {
                    Cookie emailCookie = new Cookie("rememberedEmail", email);
                    emailCookie.setMaxAge(7 * 24 * 60 * 60);
                    emailCookie.setPath("/");
                    emailCookie.setHttpOnly(true);
                    response.addCookie(emailCookie);
                } else {
                    Cookie emailCookie = new Cookie("rememberedEmail", "");
                    emailCookie.setMaxAge(0);
                    emailCookie.setPath("/");
                    emailCookie.setHttpOnly(true);
                    response.addCookie(emailCookie);
                }

                if (isAjax) {
                    String redirect = "admin".equals(user.getRole())
                        ? request.getContextPath() + "/AdminDashboardServlet"
                        : request.getContextPath() + "/DashboardServlet";
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\":true,\"redirect\":\"" + redirect + "\"}");
                } else {
                    redirectByRole(request, response, user);
                }

            } else {
                if (isAjax) {
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\":false,\"message\":\"Invalid email or password.\"}");
                } else {
                    request.setAttribute("error", "Invalid email or password. Please try again.");
                    request.setAttribute("rememberedEmail", email);
                    request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            if (isAjax) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"message\":\"Server error. Please try again.\"}");
            } else {
                request.setAttribute("error", e.getMessage());
                request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
            }
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