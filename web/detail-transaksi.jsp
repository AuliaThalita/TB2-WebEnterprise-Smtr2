<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<% request.setCharacterEncoding("UTF-8"); %>

<%
    String transactionId = request.getParameter("id");
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    StringBuilder detailHtml = new StringBuilder(); 

    if (transactionId != null && !transactionId.isEmpty()) {
        try {
            String jdbcURL = "jdbc:mysql://localhost:3306/dreamtales?useSSL=false&serverTimezone=UTC";
            String dbUser = "root";
            String dbPassword = "";

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);

            // SQL query to get all details for a single transaction, joining directly with 'barang'
            // This query assumes 'transaksi_db' has 'id_barang' and 'jumlah_barang' columns.
            // If a single transaction ID in transaksi_db can correspond to multiple rows (for multiple items),
            // this code will currently only display the first item's details.
            String sqlSelect = "SELECT t.id, t.tanggal, t.nama_penerima, t.alamat, b.nama_barang, t.jumlah_barang, " +
                               "t.total_harga, t.metode_pembayaran, t.status_pesanan " +
                               "FROM transaksi_db t " +
                               "JOIN barang b ON t.id_barang = b.id " +
                               "WHERE t.id = ?";

            pstmt = conn.prepareStatement(sqlSelect);
            pstmt.setString(1, transactionId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                // Header of the receipt
                detailHtml.append("<div class='text-center mb-4'>");
                detailHtml.append("<h4>Struk Belanja</h4>");
                detailHtml.append("<h5>DreamTales</h5>");
                detailHtml.append("<hr>");
                detailHtml.append("</div>");

                // Transaction Details Section (excluding payment method and status)
                detailHtml.append("<div class='row mb-3'>");
                detailHtml.append("<div class='col-6'><strong>No. Transaksi:</strong> ").append(rs.getInt("id")).append("</div>");
                detailHtml.append("<div class='col-6 text-end'><strong>Tanggal:</strong> ").append(rs.getDate("tanggal").toString()).append("</div>");
                detailHtml.append("<div class='col-12'><strong>Pelanggan:</strong> ").append(rs.getString("nama_penerima")).append("</div>");
                detailHtml.append("<div class='col-12'><strong>Alamat:</strong> ").append(rs.getString("alamat")).append("</div>");
                detailHtml.append("</div>");
                
                detailHtml.append("<hr>");

                // Item Details Table (will only show one item if ID is primary key in transaksi_db)
                detailHtml.append("<h6 class='mb-2'>Detail Barang:</h6>");
                detailHtml.append("<table class='table table-bordered table-sm mb-3'>");
                detailHtml.append("<thead>");
                detailHtml.append("<tr>");
                detailHtml.append("<th>Nama Barang</th>");
                detailHtml.append("<th class='text-center'>Jumlah</th>");
                detailHtml.append("<th class='text-end'>Harga Satuan</th>");
                detailHtml.append("<th class='text-end'>Sub Total</th>");
                detailHtml.append("</tr>");
                detailHtml.append("</thead>");
                detailHtml.append("<tbody>");
                
                double jumlahBarang = rs.getInt("jumlah_barang");
                double totalHargaItem = rs.getDouble("total_harga"); // This might be total for this item or grand total
                double hargaSatuan = (jumlahBarang > 0) ? (totalHargaItem / jumlahBarang) : 0.0; // Calculate per item price

                detailHtml.append("<tr>");
                detailHtml.append("<td>").append(rs.getString("nama_barang")).append("</td>");
                detailHtml.append("<td class='text-center'>").append((int)jumlahBarang).append("</td>");
                detailHtml.append("<td class='text-end'>").append(String.format("Rp %,.2f", hargaSatuan)).append("</td>");
                detailHtml.append("<td class='text-end'>").append(String.format("Rp %,.2f", totalHargaItem)).append("</td>");
                detailHtml.append("</tr>");
                
                detailHtml.append("</tbody>");
                detailHtml.append("</table>");

                // Moved Payment Method and Order Status here, below the item table
                detailHtml.append("<div class='row mb-3'>");
                detailHtml.append("<div class='col-12'><strong>Metode Pembayaran:</strong> ").append(rs.getString("metode_pembayaran")).append("</div>");
                detailHtml.append("<div class='col-12'><strong>Status Pesanan:</strong> ").append(rs.getString("status_pesanan")).append("</div>");
                detailHtml.append("</div>");
                
                // Overall Total
                detailHtml.append("<div class='text-end mb-3'>");
                detailHtml.append("<strong>TOTAL: ").append(String.format("Rp %,.2f", rs.getDouble("total_harga"))).append("</strong>");
                detailHtml.append("</div>");

            } else {
                detailHtml.append("<p class='text-center text-danger'>Detail transaksi tidak ditemukan.</p>");
            }

        } catch (SQLException e) {
            detailHtml.append("<p style='color:red;'>Error database: ").append(e.getMessage()).append("</p>");
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            detailHtml.append("<p style='color:red;'>Error: Driver JDBC tidak ditemukan. ").append(e.getMessage()).append("</p>");
            e.printStackTrace();
        } catch (Exception e) {
            detailHtml.append("<p style='color:red;'>Terjadi kesalahan tak terduga: ").append(e.getMessage()).append("</p>");
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    } else {
        detailHtml.append("<p style='color:red;'>ID Transaksi tidak diberikan.</p>");
    }
    out.print(detailHtml.toString()); // Only print the generated HTML content
%>