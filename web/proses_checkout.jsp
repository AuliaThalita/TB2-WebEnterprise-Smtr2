<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>
<%
    String userName = (String) session.getAttribute("userName");
    // Dapatkan ID pengguna yang sedang login dari session
    Integer userId = (Integer) session.getAttribute("userId");

    // Lakukan pengecekan untuk userName dan userId. Jika salah satu null, arahkan kembali ke login.
    if (userName == null || userId == null) {
        response.sendRedirect("login.html");
        return;
    }

    String namaPenerima = request.getParameter("nama_penerima");
    String alamat = request.getParameter("alamat");
    String metodePembayaran = request.getParameter("metode_pembayaran");
    double overallTotalHargaCheckout = 0;
    try {
        overallTotalHargaCheckout = Double.parseDouble(request.getParameter("total_harga_checkout"));
    } catch (NumberFormatException e) {
        // Handle case where total_harga_checkout is invalid
        %>
        <!DOCTYPE html>
        <html>
        <head>
            <title>Error</title>
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
            <style>
                body { padding: 30px; }
                .alert { margin-top: 20px; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="alert alert-danger" role="alert">
                    <strong>Error!</strong> Total harga checkout tidak valid. Silakan coba lagi.
                </div>
                <a href="checkout.jsp" class="btn btn-primary">Kembali ke Checkout</a>
            </div>
        </body>
        </html>
        <%
        return;
    }


    String[] checkoutItemIds = request.getParameterValues("checkout_item_id");
    String[] checkoutItemQtys = request.getParameterValues("checkout_item_qty");

    long currentOrderTimestamp = System.currentTimeMillis();

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    String errorMessage = null; // Variable to store error messages

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");
        conn.setAutoCommit(false); // Start transaction

        String getBarangHargaSQL = "SELECT nama_barang, harga, gambar, quantity FROM barang WHERE id = ?";
        // UBAH: Tambahkan id_users ke query INSERT
        String insertTransaksiDbSQL = "INSERT INTO transaksi_db (id_users, id_barang, jumlah_barang, tanggal, nama_penerima, alamat, total_harga, metode_pembayaran, status_pesanan) VALUES (?, ?, ?, CURDATE(), ?, ?, ?, ?, ?)";
        String updateStockSQL = "UPDATE barang SET quantity = quantity - ? WHERE id = ?";

        if (checkoutItemIds != null && checkoutItemQtys != null && checkoutItemIds.length > 0) {
            for (int i = 0; i < checkoutItemIds.length; i++) {
                int idBarang = Integer.parseInt(checkoutItemIds[i]);
                int kuantitas = Integer.parseInt(checkoutItemQtys[i]);

                // Query untuk mendapatkan detail barang dan stok
                ps = conn.prepareStatement(getBarangHargaSQL);
                ps.setInt(1, idBarang);
                rs = ps.executeQuery();

                String namaBarang = "";
                double hargaSatuan = 0;
                int currentStock = 0;
                if (rs.next()) {
                    namaBarang = rs.getString("nama_barang");
                    hargaSatuan = rs.getDouble("harga");
                    currentStock = rs.getInt("quantity");
                } else {
                    errorMessage = "Barang dengan ID " + idBarang + " tidak ditemukan.";
                    throw new SQLException(errorMessage);
                }
                if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}

                if (kuantitas > currentStock) {
                    errorMessage = "Stok barang '" + namaBarang + "' tidak mencukupi. Tersedia: " + currentStock + ", Diminta: " + kuantitas;
                    throw new SQLException(errorMessage);
                }

                double subtotalItem = hargaSatuan * kuantitas;

                // UBAH: Set parameter untuk query INSERT, tambahkan userId di awal
                ps = conn.prepareStatement(insertTransaksiDbSQL);
                ps.setInt(1, userId); // Parameter pertama untuk id_users
                ps.setInt(2, idBarang);
                ps.setInt(3, kuantitas);
                ps.setString(4, namaPenerima);
                ps.setString(5, alamat);
                ps.setDouble(6, subtotalItem);
                ps.setString(7, metodePembayaran);
                ps.setString(8, "Pending");
                ps.executeUpdate();
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}

                // Update stok barang
                ps = conn.prepareStatement(updateStockSQL);
                ps.setInt(1, kuantitas);
                ps.setInt(2, idBarang);
                ps.executeUpdate();
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            }
        } else {
            errorMessage = "Tidak ada barang yang dipilih untuk checkout. Silakan kembali ke keranjang.";
            throw new IllegalArgumentException(errorMessage);
        }

        conn.commit(); // Commit transaksi jika semua operasi berhasil

        // Hapus item dari keranjang (session) setelah berhasil checkout
        Map<Integer, Integer> cartItems = (Map<Integer, Integer>) session.getAttribute("keranjang");
        if (cartItems != null) {
            for (String itemIdStr : checkoutItemIds) {
                int itemId = Integer.parseInt(itemIdStr);
                cartItems.remove(itemId);
            }
            session.setAttribute("keranjang", cartItems);
        }

        // Redirect ke halaman invoice jika berhasil
        response.sendRedirect("invoice.jsp?order_timestamp=" + currentOrderTimestamp +
                              "&nama_penerima=" + java.net.URLEncoder.encode(namaPenerima, "UTF-8") +
                              "&total_harga_order=" + overallTotalHargaCheckout);

    } catch (SQLException e) {
        if (conn != null) {
            try {
                System.err.print("Transaction is being rolled back");
                conn.rollback(); // Rollback jika ada kesalahan SQL
            } catch(SQLException excep) {
                System.err.print("Rollback failed: " + excep.getMessage());
            }
        }
        System.err.println("SQL Exception in proses_checkout: " + e.getMessage());
        e.printStackTrace();
        errorMessage = (errorMessage != null) ? errorMessage : "Terjadi kesalahan database saat memproses pesanan: " + e.getMessage();
        // Fall through to HTML output below
    } catch (Exception e) {
        System.err.println("General Exception in proses_checkout: " + e.getMessage());
        e.printStackTrace();
        errorMessage = (errorMessage != null) ? errorMessage : "Terjadi kesalahan umum saat memproses pesanan: " + e.getMessage();
        // Fall through to HTML output below
    } finally {
        // Pastikan resource ditutup
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (conn != null) {
            try {
                conn.setAutoCommit(true); // Reset autocommit ke true
                conn.close();
            } catch (SQLException ignore) {}
        }
    }

    // Jika errorMessage tidak null, artinya terjadi error dan akan ditampilkan di sini
    if (errorMessage != null) {
        %>
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Kesalahan Pemrosesan Pesanan</title>
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet"/>
            <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
            <style>
                body {
                    font-family: 'Roboto', sans-serif;
                    background-color: #f0f2f5;
                    color: #333;
                    padding: 30px;
                }
                .container {
                    max-width: 700px;
                    margin-top: 50px;
                    padding: 40px;
                    background-color: #fff;
                    border-radius: 15px;
                    box-shadow: 0 8px 25px rgba(0,0,0,0.1);
                    text-align: center;
                }
                .alert-danger {
                    margin-bottom: 30px;
                    border-radius: 10px;
                    font-size: 1.1em;
                }
                .btn-primary {
                    background-color: #002D62;
                    border-color: #002D62;
                    padding: 12px 25px;
                    border-radius: 10px;
                    font-weight: 600;
                }
                .btn-primary:hover {
                    background-color: #001f3f;
                    border-color: #001f3f;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h2><i class="fas fa-exclamation-triangle text-danger"></i> Kesalahan Pemrosesan Pesanan</h2>
                <div class="alert alert-danger" role="alert">
                    <%= errorMessage %>
                </div>
                <p>Maaf, terjadi masalah saat memproses pesanan Anda. Silakan coba lagi nanti atau hubungi dukungan pelanggan.</p>
                <a href="checkout.jsp" class="btn btn-primary"><i class="fas fa-arrow-left"></i> Kembali ke Checkout</a>
                <a href="home.jsp" class="btn btn-secondary mt-3"><i class="fas fa-home"></i> Kembali ke Beranda</a>
            </div>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        </body>
        </html>
        <%
    }
%>