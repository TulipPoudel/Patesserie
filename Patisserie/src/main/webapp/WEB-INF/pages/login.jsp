<%-- FILE LOCATION: WEB-INF/pages/login.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login – L'Atelier Sucré Pâtisserie</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2">
</head>
<body>

<div class="auth-wrapper">
    <div class="auth-box">

        <%-- Logo / branding --%>
        <div class="auth-logo">
            <h1>L'Atelier Sucré</h1>
            <p>Pâtisserie &mdash; Sign in to your account</p>
        </div>

        <%-- Cookie: Welcome back message --%>
        <% if (request.getAttribute("welcomeBack") != null) { %>
            <div class="alert alert-info">
                Welcome back, <strong><%= request.getAttribute("welcomeBack") %></strong>!
            </div>
        <% } %>

        <%-- Flash success from password reset --%>
        <% if (session.getAttribute("flashSuccess") != null) { %>
            <div class="alert alert-success"><%= session.getAttribute("flashSuccess") %></div>
            <% session.removeAttribute("flashSuccess"); %>
        <% } %>

        <%-- Error message (wrong password, locked, etc.) --%>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <%-- Success message (e.g. after registration) --%>
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success">
                <%= request.getAttribute("success") %>
            </div>
        <% } %>

        <%-- Login form --%>
        <form action="<%= request.getContextPath() %>/LoginServlet" method="post">

            <div class="form-group">
                <label for="email">Email address</label>
                <input type="email"
                       id="email"
                       name="email"
                       placeholder="you@example.com"
                       required
                       autofocus
                       value="<%= request.getAttribute("rememberedEmail") != null
                                  ? request.getAttribute("rememberedEmail") : "" %>">
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password"
                       id="password"
                       name="password"
                       placeholder="Enter your password"
                       required>
            </div>

            <%-- Remember Me checkbox – tied to cookie logic in LoginServlet --%>
            <div class="form-group" style="display:flex; align-items:center; gap:0.5rem;">
                <input type="checkbox"
                       id="rememberMe"
                       name="rememberMe"
                       value="yes"
                       style="width:auto;"
                       <%= request.getAttribute("rememberedEmail") != null ? "checked" : "" %>>
                <label for="rememberMe" style="margin:0; font-weight:normal; font-size:0.9rem;">
                    Remember me for 7 days
                </label>
            </div>

            <button type="submit" class="btn btn-primary btn-block">Sign In</button>

            <div style="text-align:right; margin-top:0.6rem;">
                <a href="<%= request.getContextPath() %>/ForgotPasswordServlet"
                   style="font-size:0.82rem; color:var(--brown); text-decoration:none;">
                    Forgot your password?
                </a>
            </div>
        </form>

        <div class="auth-footer">
            Don't have an account?
            <a href="<%= request.getContextPath() %>/RegisterServlet">Create one here</a>
        </div>

    </div>
</div>

<%-- footer --%>
<%@ include file="../includes/footer.jsp" %>

</body>
</html>