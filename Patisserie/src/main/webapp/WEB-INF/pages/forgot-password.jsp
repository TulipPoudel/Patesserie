<%-- FILE LOCATION: WEB-INF/pages/forgot-password.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password – L'Atelier Sucré Pâtisserie</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2">
</head>
<body>

<div class="auth-wrapper">
    <div class="auth-box">

        <div class="auth-logo">
            <h1>L'Atelier Sucré</h1>
            <p>Reset your password</p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>

        <p style="color:#888; font-size:0.88rem; margin-bottom:1.4rem; line-height:1.6;">
            Enter the email address on your account and we'll send you a 6-digit reset code.
        </p>

        <form action="<%= request.getContextPath() %>/ForgotPasswordServlet" method="post">
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email"
                       id="email"
                       name="email"
                       placeholder="you@example.com"
                       required
                       autofocus
                       style="width:100%;">
            </div>
            <button type="submit" class="btn btn-primary btn-block">Send Reset Code</button>
        </form>

        <div class="auth-footer">
            <a href="<%= request.getContextPath() %>/LoginServlet">&larr; Back to Sign In</a>
        </div>

    </div>
</div>

<%@ include file="../includes/footer.jsp" %>
</body>
</html>
