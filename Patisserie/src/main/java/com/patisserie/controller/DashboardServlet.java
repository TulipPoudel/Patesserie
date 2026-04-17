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
	 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        // Security check: must be logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
 
        User user = (User) session.getAttribute("user");
 
        // Admin should not see customer dashboard
        if ("admin".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }
 
        // Check for "Welcome back" cookie to display greeting
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("userName".equals(c.getName())) {
                    request.setAttribute("welcomeBack", c.getValue());
                }
            }
        }
 
        request.getRequestDispatcher("/WEB-INF/pages/dashboard.jsp").forward(request, response);
    }
}