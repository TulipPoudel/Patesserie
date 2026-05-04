package com.patisserie.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.patisserie.config.DBConfig;
import com.patisserie.model.User;

@WebServlet(asyncSupported = true, urlPatterns = { "/ProductsServlet" })
public class ProductsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        try (Connection conn = DBConfig.getConnection()) {
            // Join pastries with categories to get category name
            String sql = "SELECT p.pastry_id, p.name, p.description, p.price, " +
                         "c.category_name " +
                         "FROM pastries p JOIN categories c ON p.category_id = c.category_id " +
                         "WHERE p.is_available = 1 " +
                         "ORDER BY c.category_name, p.name";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            List<String[]> pastries = new ArrayList<>();
            while (rs.next()) {
                pastries.add(new String[]{
                    String.valueOf(rs.getInt("pastry_id")),        // [0] id
                    rs.getString("name"),                           // [1] name
                    rs.getString("description"),                    // [2] description
                    String.format("%.2f", rs.getDouble("price")),  // [3] price
                    rs.getString("category_name")                  // [4] category
                });
            }
            request.setAttribute("pastries", pastries);

        } catch (SQLException e) {
            request.setAttribute("error", "Could not load menu items. Please try again later.");
        }

        request.getRequestDispatcher("/WEB-INF/pages/products.jsp").forward(request, response);
    }
}