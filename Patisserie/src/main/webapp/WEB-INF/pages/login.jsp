<%-- FILE LOCATION: WEB-INF/pages/login.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login – La Farine Pâtisserie</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<div class="auth-wrapper">
    <div class="auth-box">

        <%-- Logo / branding --%>
        <div class="auth-logo">
            <h1>&#127968; La Farine</h1>
            <p>Pâtisserie &mdash; Sign in to your account</p>
        </div>

        <%-- Cookie: Welcome back message --%>
        <% if (request.getAttribute("welcomeBack") != null) { %>
            <div class="alert alert-info">
                Welcome back, <strong><%= request.getAttribute("welcomeBack") %></strong>!
            </div>
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
        <form action="<%= request.getContextPath() %>/login" method="post">

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
        </form>

        <div class="auth-footer">
            Don't have an account?
            <a href="<%= request.getContextPath() %>/register">Create one here</a>
        </div>

    </div>
</div>

<footer class="footer">
    <div class="container">
        <p>&copy; 2025 La Farine Pâtisserie</p>
    </div>
</footer>
</body>
</html>