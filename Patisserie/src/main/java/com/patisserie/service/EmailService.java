package com.patisserie.service;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

public class EmailService {

    // ── CONFIGURE THESE ──────────────────────────────────────────────────────
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int    SMTP_PORT = 587;
    private static final String FROM_EMAIL = "poudeltulip@gmail.com";   
    private static final String FROM_NAME  = "L'Atelier Sucré";
    private static final String APP_PASSWORD = "iggo govn qpvn kxwp"; 
    // ─────────────────────────────────────────────────────────────────────────

    public static void sendOtp(String toEmail, String otp) throws MessagingException, java.io.UnsupportedEncodingException {
        Properties props = new Properties();
        props.put("mail.smtp.host",            SMTP_HOST);
        props.put("mail.smtp.port",            String.valueOf(SMTP_PORT));
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("Your Password Reset Code – L'Atelier Sucré");

        String html = "<!DOCTYPE html>" +
            "<html><head><meta charset='UTF-8'></head><body style='margin:0;padding:0;background:#f5f0e8;font-family:Georgia,serif;'>" +
            "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f5f0e8;padding:40px 0;'>" +
            "<tr><td align='center'>" +
            "<table width='520' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:8px;overflow:hidden;box-shadow:0 2px 12px rgba(0,0,0,0.08);'>" +
            "<tr><td style='background:#2c1810;padding:32px 40px;text-align:center;'>" +
            "<p style='font-family:Georgia,serif;font-size:22px;color:#c9a84c;letter-spacing:0.08em;margin:0;'>L'Atelier Sucré</p>" +
            "<p style='font-size:10px;color:rgba(255,255,255,0.4);letter-spacing:0.2em;text-transform:uppercase;margin:4px 0 0;'>Pâtisserie Artisanale</p>" +
            "</td></tr>" +
            "<tr><td style='padding:40px 40px 20px;text-align:center;'>" +
            "<h2 style='font-family:Georgia,serif;font-weight:300;color:#2c1810;font-size:24px;margin:0 0 12px;'>Password Reset</h2>" +
            "<p style='color:#666;font-size:14px;line-height:1.6;margin:0 0 32px;'>Use the code below to reset your password. It expires in <strong>15 minutes</strong>.</p>" +
            "<div style='background:#f5f0e8;border-radius:8px;padding:24px;margin:0 auto;display:inline-block;'>" +
            "<span style='font-family:monospace;font-size:36px;font-weight:700;letter-spacing:0.3em;color:#2c1810;'>" + otp + "</span>" +
            "</div>" +
            "<p style='color:#999;font-size:12px;margin-top:32px;'>If you didn't request this, you can safely ignore this email.</p>" +
            "</td></tr>" +
            "<tr><td style='background:#f9f6f0;padding:20px 40px;text-align:center;border-top:1px solid #ece8e0;'>" +
            "<p style='color:#aaa;font-size:11px;margin:0;'>© L'Atelier Sucré Pâtisserie · 123 Rue de la Paix, Paris</p>" +
            "</td></tr></table></td></tr></table></body></html>";

        message.setContent(html, "text/html; charset=UTF-8");
        Transport.send(message);
    }
}