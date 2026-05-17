<%-- FILE LOCATION: WEB-INF/pages/register.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register – L'Atelier Sucré Pâtisserie</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=2">
</head>
<body>

<div class="auth-wrapper">
    <div class="auth-box">

        <div class="auth-logo">
            <h1>L'Atelier Sucré</h1>
            <p>Create your account</p>
        </div>

        <%-- Error message --%>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/RegisterServlet" method="post">

            <div class="form-group">
                <label for="fullName">Full name</label>
                <input type="text"
                       id="fullName"
                       name="fullName"
                       placeholder="e.g. Tulip Poudel"
                       required
                       value="<%= request.getAttribute("fullName") != null ? request.getAttribute("fullName") : "" %>">
                <small style="color:#888; font-size:0.8rem;">No numbers allowed in name</small>
            </div>

            <div class="form-group">
                <label for="email">Email address</label>
                <input type="email"
                       id="email"
                       name="email"
                       placeholder="you@example.com"
                       required
                       value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>">
            </div>

            <div class="form-group">
                <label for="phone">Phone number</label>
                <input type="tel"
                       id="phone"
                       name="phone"
                       placeholder="07700 000000"
                       value="<%= request.getAttribute("phone") != null ? request.getAttribute("phone") : "" %>">
            </div>

            <div class="form-group">
                <label for="password">Password <small>(min. 6 characters)</small></label>
                <input type="password"
                       id="password"
                       name="password"
                       placeholder="Choose a strong password"
                       required
                       minlength="6">
            </div>

            <div class="form-group">
                <label for="confirmPassword">Confirm password</label>
                <input type="password"
                       id="confirmPassword"
                       name="confirmPassword"
                       placeholder="Repeat your password"
                       required
                       minlength="6">
            </div>

            <button type="submit" class="btn btn-primary btn-block">Create Account</button>
        </form>

        <div class="auth-footer">
            Already have an account?
            <a href="<%= request.getContextPath() %>/LoginServlet">Sign in here</a>
        </div>

    </div>
</div>

<footer class="footer">
    <div class="container">
        <p>&copy; 2025 L'Atelier Sucré Pâtisserie</p>
    </div>
</footer>

</body>
</html>