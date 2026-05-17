package com.patisserie.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * AuthFilter intercepts all requests and enforces access control:
 * - Unauthenticated users are redirected to the login page.
 * - Regular users cannot access admin pages.
 * - Already-logged-in users are redirected away from login/register.
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    // URLs that anyone can access without being logged in
    private static final String[] PUBLIC_URLS = {
        "/LoginServlet",
        "/RegisterServlet",
        "/ForgotPasswordServlet",
        "/ResetPasswordServlet",
        "/index.jsp",
        "/css/",
        "/images/",
        "/video/",
        "/DashboardServlet",   
        "/ProductsServlet",    
        "/LocationServlet"
    };

    // URLs only admins can access
    private static final String[] ADMIN_URLS = {
        "/AdminDashboardServlet",
        "/AdminPastriesServlet",
        "/AdminUsersServlet",
        "/AdminOrdersServlet",
        "/AdminReservationsServlet"  
    };

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        Object user = (session != null) ? session.getAttribute("user") : null;

        // Allow public URLs through without checking
        if (isPublic(path)) {
            // If already logged in and trying to visit login/register, redirect to dashboard
            if (user != null && (path.contains("LoginServlet") || path.contains("RegisterServlet"))) {
                com.patisserie.model.User u = (com.patisserie.model.User) user;
                if ("admin".equals(u.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
                } else {
                    response.sendRedirect(request.getContextPath() + "/DashboardServlet");
                }
                return;
            }
            chain.doFilter(req, res);
            return;
        }

        // Not logged in — redirect to login
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        // Logged in but trying to access admin pages without admin role
        com.patisserie.model.User loggedIn = (com.patisserie.model.User) user;
        if (isAdminUrl(path) && !"admin".equals(loggedIn.getRole())) {
            response.sendRedirect(request.getContextPath() + "/DashboardServlet");
            return;
        }

        // All checks passed
        chain.doFilter(req, res);
    }

    private boolean isPublic(String path) {
        for (String pub : PUBLIC_URLS) {
            if (path.startsWith(pub)) return true;
        }
        return false;
    }

    private boolean isAdminUrl(String path) {
        for (String admin : ADMIN_URLS) {
            if (path.startsWith(admin)) return true;
        }
        return false;
    }

    @Override public void init(FilterConfig config) {}
    @Override public void destroy() {}
}