<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Simpan Transaksi</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 20px; }
        .container { background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); max-width: 600px; margin: auto; text-align: center; }
        h2 { color: #333; }
        p { margin-bottom: 15px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .links { margin-top: 25px; }
        .links a {
            display: inline-block;
            background-color: #007bff;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            text-decoration: none;
            margin: 0 5px;
        }
        .links a:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Status Penyimpanan Transaksi</h2>

        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            String message = "";
            boolean success = false;

            try {
                // Ambil data dari form yang lebih sederhana
                int idBarang = Integer.parseInt(request.getParameter("id_barang"));
                String tanggalStr = request.getParameter("tanggal");
                String namaPenerima = request.getParameter("nama_penerima");
                int jumlahBarang = Integer.parseInt(request.getParameter("jumlah_barang"));
                double totalHarga = Double.parseDouble(request.getParameter("total_harga")); // Ambil dari hidden input total_harga
                String metodePembayaran = request.getParameter("metode_pembayaran");

                // --- Berikan nilai default untuk kolom yang tidak ada di form ---
                String alamat = "Offline Order"; // Atau string kosong, atau null jika kolom di DB NULLABLE
                String statusPesanan = "Selesai"; // Atau nilai default lainnya yang relevan
                // -----------------------------------------------------------------

                // --- Konfigurasi Koneksi Database Anda ---
                String jdbcURL = "jdbc:mysql://localhost:3306/dreamtales?useSSL=false&serverTimezone=UTC";
                String dbUser = "root";
                String dbPassword = ""; // Ganti dengan password database Anda
                // ------------------------------------------

                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);

                // SQL untuk insert data ke transaksi_db (menyesuaikan kolom yang diinsert)
                // Pastikan urutan dan jumlah tanda tanya (?) sesuai dengan kolom di database
                String sqlInsert = "INSERT INTO transaksi_db (id_barang, tanggal, nama_penerima, jumlah_barang, total_harga, alamat, metode_pembayaran, status_pesanan) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                pstmt = conn.prepareStatement(sqlInsert);

                pstmt.setInt(1, idBarang);
                // Konversi String tanggal ke java.sql.Date
                pstmt.setDate(2, java.sql.Date.valueOf(tanggalStr));
                pstmt.setString(3, namaPenerima);
                pstmt.setInt(4, jumlahBarang);
                pstmt.setDouble(5, totalHarga);
                pstmt.setString(6, alamat); // Menggunakan nilai default
                pstmt.setString(7, metodePembayaran);
                pstmt.setString(8, statusPesanan); // Menggunakan nilai default

                int rowsAffected = pstmt.executeUpdate();

                if (rowsAffected > 0) {
                    message = "Transaksi berhasil disimpan!";
                    success = true;
                    // --- Redirect langsung ke halaman tampil-transaksi.jsp setelah berhasil ---
                    response.sendRedirect("tampil-transaksi.jsp");
                    return; // Penting: Hentikan eksekusi JSP setelah redirect
                    // -----------------------------------------------------------------------
                } else {
                    message = "Gagal menyimpan transaksi: Tidak ada baris yang terpengaruh.";
                    success = false;
                }

            } catch (NumberFormatException e) {
                message = "Error input: Pastikan ID Barang, Jumlah Barang, dan Total Harga adalah angka yang valid. " + e.getMessage();
                success = false;
                e.printStackTrace();
            } catch (SQLException e) {
                message = "Error database: " + e.getMessage();
                success = false;
                e.printStackTrace();
            } catch (ClassNotFoundException e) {
                message = "Error: Driver JDBC tidak ditemukan. " + e.getMessage();
                success = false;
                e.printStackTrace();
            } catch (Exception e) {
                message = "Terjadi kesalahan tak terduga: " + e.getMessage();
                success = false;
                e.printStackTrace();
            } finally {
                // Pastikan menutup sumber daya database
                try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        %>

        <% if (success) { %>
            <p class="success"><%= message %></p>
        <% } else { %>
            <p class="error"><%= message %></p>
        <% } %>

        <div class="links">
            <a href="tampil-transaksi.jsp">Lihat Daftar Transaksi</a>
        </div>
    </div>
</body>
</html>