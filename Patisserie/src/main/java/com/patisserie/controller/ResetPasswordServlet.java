package com.patisserie.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.security.MessageDigest;

import com.patisserie.config.DBConfig;

@WebServlet(asyncSupported = true, urlPatterns = { "/ResetPasswordServlet" })
public class ResetPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("resetEmail") == null) {
            // No active reset flow — send back to forgot password
            response.sendRedirect(request.getContextPath() + "/ForgotPasswordServlet");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("resetEmail") == null) {
            response.sendRedirect(request.getContextPath() + "/ForgotPasswordServlet");
            return;
        }

        String email  = (String) session.getAttribute("resetEmail");
        String action = request.getParameter("action");

        if ("verifyOtp".equals(action)) {
            verifyOtp(request, response, session, email);
        } else if ("resetPassword".equals(action)) {
            resetPassword(request, response, session, email);
        } else {
            response.sendRedirect(request.getContextPath() + "/ResetPasswordServlet");
        }
    }

    private void verifyOtp(HttpServletRequest request, HttpServletResponse response,
                            HttpSession session, String email)
            throws ServletException, IOException {

        String otp = request.getParameter("otp");
        if (otp == null || otp.trim().isEmpty()) {
            request.setAttribute("error", "Please enter the code we sent you.");
            request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp").forward(request, response);
            return;
        }

        try {
            if (isOtpValid(email, otp.trim())) {
                // Mark OTP as verified in session — unlock password form
                session.setAttribute("otpVerified", true);
                response.sendRedirect(request.getContextPath() + "/ResetPasswordServlet");
            } else {
                request.setAttribute("error", "Invalid or expired code. Please try again or request a new one.");
                request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error. Please try again.");
            request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp").forward(request, response);
        }
    }

    private void resetPassword(HttpServletRequest request, HttpServletResponse response,
                                HttpSession session, String email)
            throws ServletException, IOException {

        // Must have verified OTP first
        if (!Boolean.TRUE.equals(session.getAttribute("otpVerified"))) {
            response.sendRedirect(request.getContextPath() + "/ResetPasswordServlet");
            return;
        }

        String newPassword     = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (newPassword == null || newPassword.length() < 8) {
            request.setAttribute("error", "Password must be at least 8 characters.");
            request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp").forward(request, response);
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp").forward(request, response);
            return;
        }

        try {
            updatePassword(email, newPassword);
            deleteOtp(email);

            // Clear reset session state
            session.removeAttribute("resetEmail");
            session.removeAttribute("otpVerified");

            // Redirect to login with success message
            session.setAttribute("flashSuccess", "Password updated successfully. Please sign in.");
            response.sendRedirect(request.getContextPath() + "/LoginServlet");

        } catch (SQLException e) {
            request.setAttribute("error", "Could not update password. Please try again.");
            request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp").forward(request, response);
        }
    }

    // ── DB helpers ────────────────────────────────────────────────────────────

    private boolean isOtpValid(String email, String otp) throws SQLException {
        String sql = "SELECT COUNT(*) FROM password_reset_tokens " +
                     "WHERE email = ? AND otp = ? AND expires_at > NOW()";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, otp);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private void updatePassword(String email, String newPassword) throws SQLException {
        String hashed = hashPassword(newPassword);
        String sql = "UPDATE users SET password = ?, failed_attempts = 0, is_locked = false WHERE email = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hashed);
            ps.setString(2, email);
            ps.executeUpdate();
        }
    }

    private void deleteOtp(String email) throws SQLException {
        String sql = "DELETE FROM password_reset_tokens WHERE email = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        }
    }

    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Hashing failed", e);
        }
    }
}