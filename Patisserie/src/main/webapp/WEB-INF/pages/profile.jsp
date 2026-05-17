<%-- FILE LOCATION: WEB-INF/pages/profile.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.patisserie.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/DashboardServlet");
        return;
    }
    // Get first letter for avatar
    String initials = user.getFullName() != null && !user.getFullName().isEmpty()
        ? String.valueOf(user.getFullName().charAt(0)).toUpperCase() : "U";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile – L'Atelier Sucré</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=3">
    <style>

        .profile-page {
            min-height: 100vh;
            background: #f5f0eb;
        }

        .profile-wrapper {
            max-width: 820px;
            margin: 0 auto;
            padding: 2.5rem 1.5rem 4rem;
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        /* ── Card shell ────────────────────────────── */
        .profile-card {
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 2px 20px rgba(44,24,16,0.07);
            overflow: hidden;
        }

        /* ── Card header bar ───────────────────────── */
        .card-header {
            padding: 1.5rem 2rem;
            border-bottom: 1px solid #f0ebe5;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .card-header h2 {
            font-family: var(--font-display, Georgia, serif);
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--brown-dark, #2c1810);
            margin: 0;
        }

        /* ── Saving indicator ──────────────────────── */
        .saving-indicator {
            font-size: 0.82rem;
            color: var(--gold, #c9a84c);
            display: flex;
            align-items: center;
            gap: 0.4rem;
            opacity: 0;
            transition: opacity 0.3s;
        }
        .saving-indicator.show { opacity: 1; }
        .saving-spinner {
            width: 13px; height: 13px;
            border: 2px solid var(--gold, #c9a84c);
            border-top-color: transparent;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }
        @keyframes spin { to { transform: rotate(360deg); } }

        .card-body { padding: 2rem; }

        /* ── Avatar row ────────────────────────────── */
        .avatar-row {
            display: flex;
            align-items: center;
            gap: 1.2rem;
            margin-bottom: 2rem;
            padding-bottom: 2rem;
            border-bottom: 1px solid #f0ebe5;
        }

        .avatar-circle {
            width: 76px;
            height: 76px;
            border-radius: 50%;
            background: var(--brown-dark, #2c1810);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: var(--font-display, Georgia, serif);
            font-size: 1.8rem;
            color: var(--gold, #c9a84c);
            font-weight: 700;
            flex-shrink: 0;
            border: 3px solid #f0ebe5;
        }

        .avatar-details h3 {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--brown-dark, #2c1810);
            margin: 0 0 0.25rem;
            font-family: var(--font-display, Georgia, serif);
        }

        .avatar-details span {
            font-size: 0.83rem;
            color: #aaa;
        }

        .role-badge {
            display: inline-block;
            margin-left: 0.5rem;
            padding: 0.15rem 0.65rem;
            border-radius: 20px;
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            vertical-align: middle;
        }
        .role-badge.admin   { background: #fff3cd; color: #856404; }
        .role-badge.customer{ background: #ede9e4; color: #6b5344; }

        /* ── Two-column form grid ──────────────────── */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.2rem 1.5rem;
        }

        .form-grid .span-full { grid-column: 1 / -1; }

        .field {
            display: flex;
            flex-direction: column;
            gap: 0.45rem;
        }

        .field label {
            font-size: 0.78rem;
            font-weight: 600;
            color: #999;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .field input {
            padding: 0.78rem 1rem;
            border: 1.5px solid #e8e0d8;
            border-radius: 10px;
            font-size: 0.92rem;
            color: var(--brown-dark, #2c1810);
            background: #fff;
            font-family: var(--font-body, sans-serif);
            transition: border-color 0.18s, box-shadow 0.18s;
            width: 100%;
            box-sizing: border-box;
        }

        .field input:focus {
            outline: none;
            border-color: var(--brown-dark, #2c1810);
            box-shadow: 0 0 0 3px rgba(44,24,16,0.08);
        }

        .field input:disabled {
            background: #f9f7f5;
            color: #bbb;
            border-color: #ede9e4;
            cursor: not-allowed;
        }

        .field .field-note {
            font-size: 0.74rem;
            color: #bbb;
            margin-top: -0.2rem;
        }

        /* ── Form actions ──────────────────────────── */
        .form-actions {
            margin-top: 1.6rem;
            padding-top: 1.5rem;
            border-top: 1px solid #f0ebe5;
            display: flex;
            justify-content: flex-end;
        }

        /* ── Delete account section ────────────────── */
        .delete-section {
            margin-top: 1.5rem;
            padding: 1.4rem;
            background: #fdf7f7;
            border-radius: 12px;
            border: 1px solid #f5dada;
        }

        .delete-section h4 {
            font-size: 0.95rem;
            font-weight: 700;
            color: #c0392b;
            margin: 0 0 0.5rem;
        }

        .delete-section p {
            font-size: 0.82rem;
            color: #888;
            margin: 0;
            line-height: 1.6;
        }

        /* ── Alerts ────────────────────────────────── */
        .profile-alert {
            border-radius: 10px;
            padding: 0.9rem 1.2rem;
            font-size: 0.88rem;
            display: flex;
            align-items: center;
            gap: 0.6rem;
        }
        .profile-alert.error   { background: #fdf0f0; color: #c0392b; border: 1px solid #f5c6c6; }
        .profile-alert.success { background: #f0faf4; color: #1e7e45; border: 1px solid #b7e4c7; }

        /* ── Profile hero banner ───────────────────── */
        .profile-hero {
            position: relative;
            height: 220px;
            background: var(--brown-dark, #2c1810);
            overflow: hidden;
        }

        .profile-hero img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            object-position: center;
            opacity: 0.55;
        }

        .profile-hero-overlay {
            position: absolute;
            inset: 0;
            background: linear-gradient(160deg, rgba(26,11,4,0.6) 0%, rgba(44,24,16,0.4) 100%);
            display: flex;
            align-items: flex-end;
            padding: 2rem clamp(1.5rem, 5vw, 3rem);
        }

        .profile-hero-title {
            font-family: var(--font-display, Georgia, serif);
            font-size: clamp(1.8rem, 4vw, 2.8rem);
            font-weight: 300;
            color: #fff;
            letter-spacing: 0.06em;
        }

        .profile-hero-sub {
            font-family: var(--font-display, Georgia, serif);
            font-style: italic;
            font-size: 0.95rem;
            color: rgba(255,255,255,0.55);
            margin-left: 1rem;
            padding-bottom: 0.3rem;
        }

        /* ── Responsive ────────────────────────────── */
        @media (max-width: 600px) {
            .form-grid { grid-template-columns: 1fr; }
            .form-grid .span-full { grid-column: 1; }
            .card-body { padding: 1.4rem; }
            .card-header { padding: 1.2rem 1.4rem; }
            .profile-hero { height: 150px; }
        }

    </style>
</head>
<body>

<%@ include file="../includes/navbar.jsp" %>

<!-- Profile hero banner -->
<div class="profile-hero">
    <img src="<%= request.getContextPath() %>/images/topper.jpg" alt="Profile Banner">
    <div class="profile-hero-overlay">
        <div style="display:flex; align-items:baseline; gap:0.8rem;">
            <span class="profile-hero-title">My Profile</span>
            <span class="profile-hero-sub">L'Atelier Sucré Pâtisserie</span>
        </div>
    </div>
</div>

<div class="profile-page">
    <div class="profile-wrapper">

        <%-- ── Alerts ── --%>
        <% if (request.getAttribute("error") != null) { %>
            <div class="profile-alert error">
                <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <div class="profile-alert success">
                <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                <%= request.getAttribute("success") %>
            </div>
        <% } %>

        <%-- ══════════════════════════════════════════
             CARD 1 — PERSONAL INFORMATION
        ═══════════════════════════════════════════ --%>
        <div class="profile-card">
            <div class="card-header">
                <h2>Personal Information</h2>
                <div class="saving-indicator" id="savingIndicator">
                    <div class="saving-spinner"></div>
                    Saving changes
                </div>
            </div>
            <div class="card-body">

                <%-- Avatar row --%>
                <div class="avatar-row">
                    <div class="avatar-circle"><%= initials %></div>
                    <div class="avatar-details">
                        <h3>
                            <%= user.getFullName() %>
                            <span class="role-badge <%= user.getRole() %>"><%= user.getRole() %></span>
                        </h3>
                        <span><%= user.getEmail() %></span>
                    </div>
                </div>

                <%-- Form --%>
                <form action="<%= request.getContextPath() %>/ProfileServlet" method="post" id="profileForm">
                    <input type="hidden" name="action" value="updateProfile">

                    <div class="form-grid">

                        <div class="field">
                            <label>Full Name</label>
                            <input type="text" name="fullName"
                                   value="<%= user.getFullName() != null ? user.getFullName() : "" %>"
                                   placeholder="Your full name" required>
                        </div>

                        <div class="field">
                            <label>Email Address</label>
                            <input type="email"
                                   value="<%= user.getEmail() != null ? user.getEmail() : "" %>"
                                   disabled>
                            <span class="field-note">Email cannot be changed</span>
                        </div>

                        <div class="field">
                            <label>Phone Number</label>
                            <input type="tel" name="phone"
                                   value="<%= user.getPhone() != null ? user.getPhone() : "" %>"
                                   placeholder="e.g. 07700000000">
                        </div>

                        <div class="field">
                            <label>Role</label>
                            <input type="text" value="<%= user.getRole() %>" disabled>
                        </div>

                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                    </div>
                </form>

            </div>
        </div>

        <%-- ══════════════════════════════════════════
             CARD 2 — EMAILS & PASSWORD
        ═══════════════════════════════════════════ --%>
        <div class="profile-card">
            <div class="card-header">
                <h2>Emails &amp; Password</h2>
            </div>
            <div class="card-body">

                <form action="<%= request.getContextPath() %>/ProfileServlet" method="post">
                    <input type="hidden" name="action" value="changePassword">

                    <div class="form-grid">

                        <div class="field span-full">
                            <label>Current Password</label>
                            <input type="password" name="currentPassword"
                                   placeholder="Enter your current password" required>
                        </div>

                        <div class="field">
                            <label>New Password</label>
                            <input type="password" name="newPassword"
                                   placeholder="Min. 6 characters" minlength="6" required>
                        </div>

                        <div class="field">
                            <label>Confirm New Password</label>
                            <input type="password" name="confirmPassword"
                                   placeholder="Repeat new password" required>
                        </div>

                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-outline">Update Password</button>
                    </div>
                </form>

            </div>
        </div>

    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

<script>
    // Show saving indicator briefly on form submit
    document.getElementById('profileForm').addEventListener('submit', function() {
        const ind = document.getElementById('savingIndicator');
        ind.classList.add('show');
    });
</script>

</body>
</html>