package com.patisserie.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.Random;

import com.patisserie.config.DBConfig;
import com.patisserie.service.EmailService;

@WebServlet(asyncSupported = true, urlPatterns = { "/ForgotPasswordServlet" })
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Please enter your email address.");
            request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp").forward(request, response);
            return;
        }
        email = email.trim().toLowerCase();

        try {
            if (!emailExists(email)) {
                // Don't reveal whether email exists — show same success message
                request.setAttribute("success", "If that email is registered, you'll receive a reset code shortly.");
                request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp").forward(request, response);
                return;
            }

            String otp = generateOtp();
            saveOtp(email, otp);
            EmailService.sendOtp(email, otp);

            // Pass email to reset page via session so user doesn't retype it
            request.getSession().setAttribute("resetEmail", email);
            response.sendRedirect(request.getContextPath() + "/ResetPasswordServlet");

        } catch (SQLException e) {
            request.setAttribute("error", "Database error. Please try again.");
            request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Could not send email. Please try again later.");
            request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp").forward(request, response);
        }
    }

    private boolean emailExists(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private String generateOtp() {
        // 6-digit numeric OTP
        int code = 100000 + new Random().nextInt(900000);
        return String.valueOf(code);
    }

    private void saveOtp(String email, String otp) throws SQLException {
        // Delete any existing OTP for this email first
        String delete = "DELETE FROM password_reset_tokens WHERE email = ?";
        String insert = "INSERT INTO password_reset_tokens (email, otp, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 15 MINUTE))";

        try (Connection conn = DBConfig.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(delete)) {
                ps.setString(1, email);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(insert)) {
                ps.setString(1, email);
                ps.setString(2, otp);
                ps.executeUpdate();
            }
        }
    }
}