<%@ page language="java" contentType="text/html; charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Error – L'Atelier Sucré</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .error-container {
            display: flex; flex-direction: column; align-items: center;
            justify-content: center; min-height: 80vh; text-align: center; padding: 2rem;
        }
        .error-code { font-size: 6rem; font-weight: bold; color: #2c1810; margin: 0; }
        .error-msg  { font-size: 1.4rem; color: #555; margin: 1rem 0 2rem; }
        .home-btn   {
            background: #2c1810; color: #fff; padding: 0.8rem 2rem;
            border-radius: 6px; text-decoration: none; font-size: 1rem;
        }
        .home-btn:hover { background: #4a2c1a; }
    </style>
</head>
<body>
    <div class="error-container">
        <p class="error-code">500</p>
        <p class="error-msg">Something went wrong on our end. Please try again shortly.</p>
        <a href="${pageContext.request.contextPath}/LoginServlet" class="home-btn">Back to Home</a>
    </div>
</body>
</html>
