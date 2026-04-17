package com.patisserie.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpSession;
import java.sql.SQLException;

import com.patisserie.service.UserService;
/**
 * Servlet implementation class RegisterServlet
 */
@WebServlet(asyncSupported = true, urlPatterns = { "/RegisterServlet" })

public class RegisterServlet extends HttpServlet {
	 
    private final UserService userService = new UserService();
 
    // ── GET: show the register form ───────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
    }
 
    // ── POST: process registration ────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        String fullName        = request.getParameter("fullName").trim();
        String email           = request.getParameter("email").trim();
        String password        = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String phone           = request.getParameter("phone").trim();
 
        // ── Validation checks ─────────────────────────────────
 
        // All required fields must not be empty
        if (fullName.isEmpty() || email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            keepFormValues(request, fullName, email, phone);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
 
        // Full name must not contain numbers (as required by coursework)
        if (fullName.matches(".*\\d.*")) {
            request.setAttribute("error", "Full name must not contain numbers.");
            keepFormValues(request, fullName, email, phone);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
 
        // Password length check
        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters long.");
            keepFormValues(request, fullName, email, phone);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
 
        // Passwords must match
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match. Please try again.");
            keepFormValues(request, fullName, email, phone);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
 
        // Try to register in the database
        try {
            boolean success = userService.register(fullName, email, password, phone);
 
            if (success) {
                // Registration worked — send to login with success message
                request.setAttribute("success", "Account created successfully! Please sign in.");
                request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
            } else {
                // Email already taken
                request.setAttribute("error", "An account with that email already exists.");
                keepFormValues(request, fullName, email, phone);
                request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            }
 
        } catch (SQLException e) {
            request.setAttribute("error", "Something went wrong. Please try again later.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
        }
    }
 
    // Keep form values so user doesn't have to re-type everything on error
    private void keepFormValues(HttpServletRequest req, String fullName, String email, String phone) {
        req.setAttribute("fullName", fullName);
        req.setAttribute("email",    email);
        req.setAttribute("phone",    phone);
    }
}
