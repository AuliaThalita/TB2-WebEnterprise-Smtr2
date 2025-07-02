package controller;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;

@WebServlet("/UploadBarangServlet")
@MultipartConfig
public class UploadBarangServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            // Koneksi database
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");

            // Ambil parameter dari form
            String namaBarang = request.getParameter("namaBarang");
            Part filePart = request.getPart("gambar");
            String quantityStr = request.getParameter("quantity");
            String hargaStr = request.getParameter("harga");

            int quantity = Integer.parseInt(quantityStr);
            double harga = Double.parseDouble(hargaStr);

            // Buat nama file yang aman
            String submittedFileName = filePart.getSubmittedFileName();
            String extension = submittedFileName.substring(submittedFileName.lastIndexOf("."));
            String baseName = submittedFileName.substring(0, submittedFileName.lastIndexOf("."))
                                .replaceAll("[^a-zA-Z0-9\\-]", ""); // hapus karakter aneh
            String fileName = baseName + "_" + System.currentTimeMillis() + extension;

            // Path folder uploads (di dalam WebContent/web/uploads)
            String uploadPath = getServletContext().getRealPath("/uploads");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();

            // Simpan file
            try (InputStream input = filePart.getInputStream()) {
    File file = new File(uploadPath, fileName);
    try (FileOutputStream output = new FileOutputStream(file)) {
        byte[] buffer = new byte[1024];
        int bytesRead;
        while ((bytesRead = input.read(buffer)) != -1) {
            output.write(buffer, 0, bytesRead);
        }
    }
}


            // Simpan data ke database
            String sql = "INSERT INTO barang (nama_barang, gambar, quantity, harga) VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, namaBarang);
            pstmt.setString(2, fileName); // simpan nama file, bukan full path
            pstmt.setInt(3, quantity);
            pstmt.setDouble(4, harga);

            int rows = pstmt.executeUpdate();

            if (rows > 0) {
    // Redirect ke halaman master barang
    response.sendRedirect("inputBarang.jsp");  // sesuaikan nama file / URL-nya
} else {
    out.println("<div class='alert alert-danger'>Gagal menyimpan data barang.</div>");
}


        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (Exception ignored) {}
        }
    }
}