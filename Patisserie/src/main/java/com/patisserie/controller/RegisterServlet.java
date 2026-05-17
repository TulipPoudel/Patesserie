package com.patisserie.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

import com.patisserie.service.UserService;
import com.patisserie.util.ValidationUtil;

@WebServlet(asyncSupported = true, urlPatterns = { "/RegisterServlet" })
public class RegisterServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName        = request.getParameter("fullName").trim();
        String email           = request.getParameter("email").trim();
        String password        = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String phone           = request.getParameter("phone").trim();

        // All fields required
        if (ValidationUtil.isEmpty(fullName) || ValidationUtil.isEmpty(email) || ValidationUtil.isEmpty(password)) {
            request.setAttribute("error", "All fields are required.");
            keepFormValues(request, fullName, email, phone);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        // Full name must not contain numbers
        if (!ValidationUtil.isValidFullName(fullName)) {
            request.setAttribute("error", "Full name must not contain numbers.");
            keepFormValues(request, fullName, email, phone);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        // Valid email format
        if (!ValidationUtil.isValidEmail(email)) {
            request.setAttribute("error", "Please enter a valid email address.");
            keepFormValues(request, fullName, email, phone);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        // Valid phone format
        if (!ValidationUtil.isValidPhone(phone)) {
            request.setAttribute("error", "Please enter a valid phone number (digits only, 7-15 characters).");
            keepFormValues(request, fullName, email, phone);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        // Password length
        if (!ValidationUtil.isValidPassword(password)) {
            request.setAttribute("error", "Password must be at least 6 characters long.");
            keepFormValues(request, fullName, email, phone);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        // Passwords match
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match. Please try again.");
            keepFormValues(request, fullName, email, phone);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        try {
            // ✅ Phone uniqueness check
            if (userService.phoneExists(phone)) {
                request.setAttribute("error", "An account with that phone number already exists.");
                keepFormValues(request, fullName, email, phone);
                request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
                return;
            }

            // ✅ UserService.register() uses BCrypt internally
            boolean success = userService.register(fullName, email, password, phone);

            if (success) {
                request.setAttribute("success", "Account created successfully! Please sign in.");
                request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "An account with that email already exists.");
                keepFormValues(request, fullName, email, phone);
                request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            request.setAttribute("error", "Something went wrong. Please try again later.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
        }
    }

    private void keepFormValues(HttpServletRequest req, String fullName, String email, String phone) {
        req.setAttribute("fullName", fullName);
        req.setAttribute("email",    email);
        req.setAttribute("phone",    phone);
    }
}