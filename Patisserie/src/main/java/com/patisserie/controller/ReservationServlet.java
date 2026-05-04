package com.patisserie.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

import com.patisserie.model.User;

/**
 * Servlet implementation class ReservationServlet
 */
@WebServlet(asyncSupported = true, urlPatterns = { "/ReservationServlet" })
public class ReservationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Security check: must be logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        // TODO: load existing reservations for this user from DB and set as attribute
        // List<Reservation> reservations = reservationService.getByUser(user.getUserId());
        // request.setAttribute("reservations", reservations);

        request.getRequestDispatcher("/WEB-INF/pages/reservation.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String action = request.getParameter("action");

        if ("book".equals(action)) {
            String guestName = request.getParameter("guestName");
            String email     = request.getParameter("email");
            String phone     = request.getParameter("phone");
            String date      = request.getParameter("date");
            String time      = request.getParameter("time");
            String guests    = request.getParameter("guests");
            String location  = request.getParameter("location");
            String notes     = request.getParameter("notes");

            // Basic validation
            if (date == null || date.isEmpty() || time == null || time.isEmpty()
                    || guests == null || guests.isEmpty() || location == null || location.isEmpty()) {
                request.setAttribute("error", "Please fill in all required fields.");
                request.getRequestDispatcher("/WEB-INF/pages/reservation.jsp").forward(request, response);
                return;
            }

            // TODO: save reservation to database
            // reservationService.save(userId, guestName, email, phone, date, time, guests, location, notes);

            request.setAttribute("success",
                "Reservation confirmed for " + guests + " guest(s) at " + location
                + " on " + date + " at " + time + ". We look forward to seeing you!");
            request.getRequestDispatcher("/WEB-INF/pages/reservation.jsp").forward(request, response);

        } else {
            response.sendRedirect(request.getContextPath() + "/ReservationServlet");
        }
    }
}