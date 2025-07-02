package controller;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;

@WebServlet("/DeleteBarangServlet")
public class DeleteBarangServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");
             PreparedStatement selectStmt = conn.prepareStatement("SELECT gambar FROM barang WHERE id=?");
             PreparedStatement deleteStmt = conn.prepareStatement("DELETE FROM barang WHERE id=?")) {

            // Hapus gambar dari folder uploads
            selectStmt.setInt(1, id);
            ResultSet rs = selectStmt.executeQuery();
            if (rs.next()) {
                String fileName = rs.getString("gambar");
                String filePath = getServletContext().getRealPath("/uploads/" + fileName);
                File file = new File(filePath);
                if (file.exists()) file.delete();
            }

            // Hapus dari database
            deleteStmt.setInt(1, id);
            deleteStmt.executeUpdate();

            response.sendRedirect("inputBarang.jsp?success=true");

        } catch (Exception e) {
            response.sendRedirect("inputBarang.jsp?success=false");
        }
    }
}