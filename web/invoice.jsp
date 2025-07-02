<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null) {
        response.sendRedirect("login.html");
        return;
    }

    // Since your transaksi_db doesn't have a transaction_id to group,
    // we'll rely on the nama_penerima and the current date for the invoice.
    // The timestamp passed from proses_checkout is just a visual indicator for this session.
    String orderTimestampStr = request.getParameter("order_timestamp");
    String recipientNameParam = request.getParameter("nama_penerima");
    double overallTotalHarga = 0; // Initialize to 0

    // Try to parse overallTotalHarga, handle NumberFormatException
    try {
        overallTotalHarga = Double.parseDouble(request.getParameter("total_harga_order"));
    } catch (NumberFormatException e) {
        // If overallTotalHarga_order is not a valid number, redirect to a simple error state
        // or set a default value. For now, we'll indicate an issue.
        System.err.println("Invalid total_harga_order parameter: " + request.getParameter("total_harga_order"));
        // You might want to redirect to home or a generic error if this parameter is critical.
        // For this scenario, we'll let it proceed with 0 and show a warning in the page.
        // For a more robust solution, consider redirecting to a proper error page or home.
    }


    String namaPenerima = "";
    String alamat = "";
    String metodePembayaran = "";
    String tanggalTransaksi = "";
    String statusTransaksi = "";

    // List to hold invoice item details
    List<Map<String, Object>> invoiceItems = new ArrayList<>();

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    // A flag to check if invoice data was found.
    boolean invoiceDataFound = false;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");

        // Fetch transaction details for the current order based on nama_penerima and today's date
        // NOTE: This assumes only one order per user per day. For robustness, add an 'order_id' column to transaksi_db.
        String getTransaksiItemsSQL = "SELECT td.id, td.id_barang, td.jumlah_barang, td.tanggal, td.nama_penerima, td.alamat, " +
                                      "td.metode_pembayaran, td.total_harga, td.status_pesanan, b.nama_barang " + // 'b.gambar' removed here
                                      "FROM transaksi_db td JOIN barang b ON td.id_barang = b.id " +
                                      "WHERE td.nama_penerima = ? AND td.tanggal = CURDATE() ORDER BY td.id DESC"; // Get recent ones first

        ps = conn.prepareStatement(getTransaksiItemsSQL);
        ps.setString(1, recipientNameParam);
        rs = ps.executeQuery();

        boolean firstRow = true;
        while (rs.next()) {
            invoiceDataFound = true; // Mark that we found data
            if (firstRow) { // Get general order details from the first item
                namaPenerima = rs.getString("nama_penerima");
                alamat = rs.getString("alamat");
                metodePembayaran = rs.getString("metode_pembayaran");
                tanggalTransaksi = new SimpleDateFormat("dd-MM-yyyy").format(rs.getDate("tanggal"));
                statusTransaksi = rs.getString("status_pesanan");
                firstRow = false;
            }

            Map<String, Object> item = new HashMap<>();
            item.put("nama_barang", rs.getString("nama_barang"));
            item.put("kuantitas", rs.getInt("jumlah_barang"));
            item.put("harga_satuan", rs.getDouble("total_harga") / rs.getInt("jumlah_barang")); // Calculate actual unit price
            item.put("subtotal_item", rs.getDouble("total_harga")); // total_harga in your DB is item subtotal
            // item.put("gambar", rs.getString("gambar")); // Removed 'gambar' from the map
            invoiceItems.add(item);
        }

    } catch (Exception e) {
        System.err.println("Error fetching invoice: " + e.getMessage());
        e.printStackTrace();
        // Instead of redirecting to error.jsp, we can display a message on this page.
        // For simplicity, we will just set invoiceDataFound to false and let the HTML block handle it.
        invoiceDataFound = false;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Faktur Pesanan</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-blue: #002D62;
            --accent-yellow: #FFD700;
            --light-grey-bg: #f0f2f5;
            --white: #fff;
            --text-dark: #333;
            --text-medium: #555;
            --red-badge: #dc3545;
        }

        body {
            font-family: 'Roboto', sans-serif;
            background-color: var(--light-grey-bg);
            color: var(--text-dark);
        }

        .top-navbar {
            background-color: var(--primary-blue);
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
            padding: 10px 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            width: 100%;
            z-index: 1000;
        }
        .top-navbar .logo {
            display: flex;
            align-items: center;
            gap: 5px;
            font-weight: 700;
            font-size: 24px;
            color: var(--white);
            margin-left: 50px;
        }
        .top-navbar .logo i {
            font-size: 28px;
            color: var(--accent-yellow);
        }
        .top-navbar .menu {
            display: flex;
            gap: 30px;
            flex-grow: 1;
            justify-content: center;
        }
        .top-navbar .menu a {
            color: var(--white);
            text-decoration: none;
            font-weight: 500;
            font-size: 16px;
            padding: 5px 0;
            position: relative;
        }
        .top-navbar .menu a:hover {
            color: var(--accent-yellow);
        }
        .top-navbar .menu a.active {
            color: var(--accent-yellow);
            border-bottom: 2px solid var(--accent-yellow);
        }
        .top-navbar .user-account {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--white);
            font-weight: 500;
            font-size: 16px;
            margin-right: 50px;
        }
        .top-navbar .user-account i {
            font-size: 18px;
            color: var(--accent-yellow);
        }

        .container {
            max-width: 800px;
            margin-top: 40px;
            padding: 30px;
            background-color: var(--white);
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }
        h2 {
            color: var(--primary-blue);
            font-weight: 700;
            margin-bottom: 30px;
            text-align: center;
        }
        .invoice-header, .invoice-details, .invoice-items, .invoice-summary, .invoice-footer {
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px dashed #e0e0e0;
        }
        .invoice-header {
            text-align: center;
            font-size: 1.5em;
            font-weight: 600;
            color: var(--primary-blue);
        }
        .invoice-header span {
            color: var(--accent-yellow);
        }
        .invoice-details p {
            margin-bottom: 5px;
            font-size: 1.05em;
        }
        .invoice-details strong {
            color: var(--text-dark);
        }
        .invoice-items .table thead th {
            background-color: var(--primary-blue);
            color: var(--white);
            font-weight: 600;
            padding: 12px;
            text-align: center;
            border-bottom: none;
        }
        .invoice-items .table tbody td {
            vertical-align: middle;
            padding: 12px;
            text-align: center;
            color: var(--text-medium);
        }
        .invoice-items .table tbody tr {
            background-color: var(--white);
            border-bottom: 1px solid #f0f0f0;
        }
        .invoice-items .table tbody tr:last-child {
            border-bottom: none;
        }
        .invoice-items .product-name-text {
            font-weight: 500;
            color: var(--text-dark);
        }
        /* .invoice-items .product-image { // This CSS rule is no longer needed but kept commented for reference
            width: 50px;
            height: 50px;
            object-fit: cover;
            border-radius: 5px;
            margin-right: 10px;
        } */
        .invoice-summary {
            font-size: 1.2em;
            font-weight: 600;
            text-align: right;
            padding-right: 15px;
            color: var(--primary-blue);
        }
        .invoice-summary span {
            color: var(--accent-yellow);
            font-size: 1.1em;
            margin-left: 10px;
        }
        .invoice-footer {
            border-bottom: none;
            text-align: center;
            color: var(--text-medium);
            font-size: 0.95em;
        }
        .btn-primary {
            background-color: var(--primary-blue);
            border-color: var(--primary-blue);
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }
        .btn-primary:hover {
            background-color: #001f3f;
            border-color: #001f3f;
        }
        .btn-secondary {
            background-color: #6c757d;
            border-color: #6c757d;
            color: var(--white);
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }
        .btn-secondary:hover {
            background-color: #5a6268;
            border-color: #5a6268;
        }
        .text-center {
            text-align: center;
        }

        .footer {
            background-color: var(--primary-blue);
            color: var(--white);
            padding: 40px 20px;
            text-align: center;
            font-size: 14px;
            margin-top: 60px;
        }
        .footer .footer-links {
            margin-bottom: 20px;
        }
        .footer .footer-links a {
            color: var(--white);
            text-decoration: none;
            margin: 0 15px;
        }
        .footer .footer-links a:hover {
            text-decoration: underline;
            color: var(--accent-yellow);
        }
        .footer .social-icons a {
            color: var(--white);
            font-size: 20px;
            margin: 0 10px;
            text-decoration: none;
        }
        .footer .social-icons a:hover {
            color: var(--accent-yellow);
        }

        @media (max-width: 768px) {
            .top-navbar {
                flex-direction: column;
                padding: 10px;
                gap: 10px;
            }
            .top-navbar .logo, .top-navbar .menu, .top-navbar .user-account {
                margin: 0;
                align-items: center;
            }
            .top-navbar .menu {
                flex-direction: column;
            }
            .container {
                margin-top: 20px !important;
                padding: 20px;
            }
            h2 {
                font-size: 24px;
                margin-bottom: 20px;
            }
            .d-flex.justify-content-center {
                flex-direction: column;
                gap: 15px;
            }
            .btn-primary, .btn-secondary {
                width: 100%;
                max-width: 250px;
            }
            .invoice-summary {
                text-align: center;
            }
        }
    </style>
</head>
<body>

<div class="top-navbar">
    <div class="logo">
        <i class="fas fa-moon"></i> DreamTales
    </div>
    <div class="menu">
        <a href="home.jsp">Beranda</a>
        <a href="keranjang.jsp">Keranjang</a>
        <a href="pesanan.jsp" class="active">Pesanan</a>
    </div>
    <div class="user-account">
        <i class="fas fa-user"></i> <%= userName %>
    </div>
</div>

<div class="container">
    <h2>Faktur Pesanan Anda</h2>

    <% if (!invoiceDataFound && invoiceItems.isEmpty()) { %>
        <div class="alert alert-warning text-center" role="alert">
            <i class="fas fa-info-circle"></i> Maaf, faktur tidak ditemukan untuk pesanan ini atau mungkin sudah kadaluarsa.
            Ini bisa terjadi jika Anda mencoba melihat pesanan lama tanpa Order ID khusus, atau ada masalah saat memuat data.
        </div>
        <div class="d-flex justify-content-center gap-3">
            <a href="home.jsp" class="btn btn-primary"><i class="fas fa-home"></i> Kembali ke Beranda</a>
            <a href="pesanan.jsp" class="btn btn-secondary"><i class="fas fa-list"></i> Lihat Riwayat Pesanan</a>
        </div>
    <% } else { %>
        <div class="invoice-header">
            Nomor Pesanan: <span>#<%= orderTimestampStr != null ? orderTimestampStr : "N/A" %></span>
        </div>

        <div class="invoice-details">
            <p><strong>Tanggal Pesanan:</strong> <%= tanggalTransaksi %></p>
            <p><strong>Status:</strong> <%= statusTransaksi %></p>
            <p><strong>Nama Penerima:</strong> <%= namaPenerima %></p>
            <p><strong>Alamat Pengiriman:</strong> <%= alamat %></p>
            <p><strong>Metode Pembayaran:</strong> <%= metodePembayaran %></p>
        </div>

        <div class="invoice-items">
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>Nama Barang</th>
                        <th>Kuantitas</th>
                        <th>Harga Satuan</th>
                        <th>Subtotal</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> item : invoiceItems) { %>
                    <tr>
                        <td><span class="product-name-text"><%= item.get("nama_barang") %></span></td>
                        <td><%= item.get("kuantitas") %></td>
                        <td>Rp<%= String.format("%,.0f", (Double) item.get("harga_satuan")) %></td>
                        <td>Rp<%= String.format("%,.0f", (Double) item.get("subtotal_item")) %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <div class="invoice-summary">
            Total Pembayaran: <span>Rp<%= String.format("%,.0f", overallTotalHarga) %></span>
        </div>

        <div class="invoice-footer">
            <p>Terima kasih telah berbelanja di DreamTales!</p>
        </div>

        <div class="d-flex justify-content-center gap-3">
            <a href="home.jsp" class="btn btn-primary"><i class="fas fa-home"></i> Kembali ke Beranda</a>
            <a href="pesanan.jsp" class="btn btn-secondary"><i class="fas fa-list"></i> Lihat Riwayat Pesanan</a>
        </div>
    <% } %>
</div>

<div class="footer">
    <div class="footer-links">
        <a href="#">Blog</a> |
        <a href="#">FAQ</a> |
        <a href="#">Privacy policy</a> |
        <a href="#">License agreement</a> |
        <a href="#">Support</a> |
        <a href="#">Contact</a> |
        <a href="#">Copyright</a>
    </div>
    <div class="social-icons">
        <a href="#"><i class="fab fa-facebook-f"></i></a>
        <a href="#"><i class="fab fa-twitter"></i></a>
        <a href="#"><i class="fab fa-instagram"></i></a>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>