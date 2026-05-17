<%-- FILE LOCATION: WEB-INF/pages/reset-password.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String resetEmail  = (String) session.getAttribute("resetEmail");
    boolean otpVerified = Boolean.TRUE.equals(session.getAttribute("otpVerified"));
    if (resetEmail == null) {
        response.sendRedirect(request.getContextPath() + "/ForgotPasswordServlet");
        return;
    }
    // Mask email for display: e.g. jo***@gmail.com
    String maskedEmail = resetEmail;
    int at = resetEmail.indexOf('@');
    if (at > 2) {
        maskedEmail = resetEmail.substring(0, 2) + "***" + resetEmail.substring(at);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password – L'Atelier Sucré Pâtisserie</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2">
    <style>
        .otp-inputs {
            display: flex;
            gap: 0.6rem;
            justify-content: center;
            margin: 1.2rem 0;
        }
        .otp-inputs input {
            width: 46px;
            height: 54px;
            text-align: center;
            font-size: 1.4rem;
            font-weight: 700;
            border: 1.5px solid var(--gray-light);
            border-radius: 8px;
            font-family: monospace;
            color: var(--brown-dark);
            transition: border-color 0.2s;
        }
        .otp-inputs input:focus {
            outline: none;
            border-color: var(--gold);
        }
        .otp-hidden { display: none; }
        .resend-link {
            font-size: 0.82rem;
            color: var(--gray);
            text-align: center;
            margin-top: 0.8rem;
        }
        .resend-link a { color: var(--brown); }
    </style>
</head>
<body>

<div class="auth-wrapper">
    <div class="auth-box">

        <div class="auth-logo">
            <h1>L'Atelier Sucré</h1>
            <p><%= otpVerified ? "Choose a new password" : "Enter your reset code" %></p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>

        <% if (!otpVerified) { %>
        <%-- ── STEP 1: OTP entry ─────────────────────────── --%>
        <p style="color:#888; font-size:0.88rem; margin-bottom:0.5rem; line-height:1.6; text-align:center;">
            We sent a 6-digit code to <strong><%= maskedEmail %></strong>
        </p>

        <form action="<%= request.getContextPath() %>/ResetPasswordServlet" method="post" id="otpForm">
            <input type="hidden" name="action" value="verifyOtp">
            <input type="hidden" name="otp" id="otpHidden">

            <div class="otp-inputs">
                <input type="text" maxlength="1" class="otp-digit" inputmode="numeric" pattern="[0-9]" autocomplete="one-time-code">
                <input type="text" maxlength="1" class="otp-digit" inputmode="numeric" pattern="[0-9]">
                <input type="text" maxlength="1" class="otp-digit" inputmode="numeric" pattern="[0-9]">
                <input type="text" maxlength="1" class="otp-digit" inputmode="numeric" pattern="[0-9]">
                <input type="text" maxlength="1" class="otp-digit" inputmode="numeric" pattern="[0-9]">
                <input type="text" maxlength="1" class="otp-digit" inputmode="numeric" pattern="[0-9]">
            </div>

            <button type="submit" class="btn btn-primary btn-block">Verify Code</button>
        </form>

        <div class="resend-link">
            Didn't get it? <a href="<%= request.getContextPath() %>/ForgotPasswordServlet">Send a new code</a>
        </div>

        <% } else { %>
        <%-- ── STEP 2: New password ──────────────────────── --%>
        <p style="color:#888; font-size:0.88rem; margin-bottom:1.2rem; line-height:1.6;">
            Code verified. Choose a new password for <strong><%= maskedEmail %></strong>.
        </p>

        <form action="<%= request.getContextPath() %>/ResetPasswordServlet" method="post">
            <input type="hidden" name="action" value="resetPassword">

            <div class="form-group">
                <label for="newPassword">New Password</label>
                <input type="password"
                       id="newPassword"
                       name="newPassword"
                       placeholder="At least 8 characters"
                       minlength="8"
                       required
                       autofocus
                       style="width:100%;">
            </div>

            <div class="form-group">
                <label for="confirmPassword">Confirm Password</label>
                <input type="password"
                       id="confirmPassword"
                       name="confirmPassword"
                       placeholder="Repeat your new password"
                       minlength="8"
                       required
                       style="width:100%;">
            </div>

            <button type="submit" class="btn btn-primary btn-block">Update Password</button>
        </form>
        <% } %>

        <div class="auth-footer">
            <a href="<%= request.getContextPath() %>/LoginServlet">&larr; Back to Sign In</a>
        </div>

    </div>
</div>

<script>
// Auto-advance OTP digits + assemble hidden field on submit
(function () {
    var digits  = document.querySelectorAll('.otp-digit');
    var hidden  = document.getElementById('otpHidden');
    var form    = document.getElementById('otpForm');

    if (!digits.length) return;

    digits.forEach(function (input, i) {
        input.addEventListener('input', function () {
            this.value = this.value.replace(/\D/, '');
            if (this.value && i < digits.length - 1) {
                digits[i + 1].focus();
            }
        });
        input.addEventListener('keydown', function (e) {
            if (e.key === 'Backspace' && !this.value && i > 0) {
                digits[i - 1].focus();
            }
        });
        // Handle paste on first box
        if (i === 0) {
            input.addEventListener('paste', function (e) {
                e.preventDefault();
                var pasted = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g, '');
                pasted.split('').forEach(function (ch, idx) {
                    if (digits[idx]) digits[idx].value = ch;
                });
                var last = Math.min(pasted.length, digits.length) - 1;
                if (last >= 0) digits[last].focus();
            });
        }
    });

    form.addEventListener('submit', function (e) {
        var code = Array.from(digits).map(function (d) { return d.value; }).join('');
        if (code.length < 6) {
            e.preventDefault();
            alert('Please enter all 6 digits of the code.');
            return;
        }
        hidden.value = code;
    });
}());
</script>

<%@ include file="../includes/footer.jsp" %>
</body>
</html>