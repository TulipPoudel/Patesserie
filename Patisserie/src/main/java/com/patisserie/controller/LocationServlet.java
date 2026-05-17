package com.patisserie.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet implementation class LocationServlet
 */
@WebServlet(asyncSupported = true, urlPatterns = { "/LocationServlet" })
public class LocationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // guests are allowed to view locations — no redirect

        request.getRequestDispatcher("/WEB-INF/pages/locations.jsp").forward(request, response);
    }
}