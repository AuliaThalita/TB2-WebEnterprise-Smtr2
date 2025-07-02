package controller;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;

@WebServlet("/EditBarangServlet")
@MultipartConfig
public class EditBarangServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        String namaBarang = request.getParameter("namaBarang");
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        double harga = Double.parseDouble(request.getParameter("harga"));
        Part filePart = request.getPart("gambar");
        String gambarLama = request.getParameter("gambarLama");

        var fileName = gambarLama;
        if (filePart != null && filePart.getSize() > 0) {
            String submittedFileName = filePart.getSubmittedFileName();
            String extension = submittedFileName.substring(submittedFileName.lastIndexOf("."));
            String baseName = submittedFileName.substring(0, submittedFileName.lastIndexOf(".")).replaceAll("[^a-zA-Z0-9\\-]", "");
            fileName = baseName + "_" + System.currentTimeMillis() + extension;

            String uploadPath = getServletContext().getRealPath("/uploads");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();

            try (InputStream input = filePart.getInputStream();
                 FileOutputStream output = new FileOutputStream(new File(uploadPath, fileName))) {
                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = input.read(buffer)) != -1) {
                    output.write(buffer, 0, bytesRead);
                }
            }

            // Hapus file lama jika ada file baru
            File oldFile = new File(uploadPath, gambarLama);
            if (oldFile.exists()) oldFile.delete();
        }

        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");
             PreparedStatement pstmt = conn.prepareStatement(
                "UPDATE barang SET nama_barang=?, gambar=?, quantity=?, harga=? WHERE id=?"
             )) {

            pstmt.setString(1, namaBarang);
            pstmt.setString(2, fileName);
            pstmt.setInt(3, quantity);
            pstmt.setDouble(4, harga);
            pstmt.setInt(5, id);

            pstmt.executeUpdate();
            response.sendRedirect("inputBarang.jsp?success=true");

        } catch (Exception e) {
            response.sendRedirect("inputBarang.jsp?success=false");
        }
    }
}