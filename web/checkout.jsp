<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null) {
        response.sendRedirect("login.html");
        return;
    }

    // Retrieve selected items from the request parameters
    String[] selectedItemIds = request.getParameterValues("selected_item_id");
    String[] selectedItemQtys = request.getParameterValues("selected_item_qty");

    // Map to store selected items (id -> quantity)
    Map<Integer, Integer> itemsToCheckout = new HashMap<>();

    if (selectedItemIds != null && selectedItemQtys != null && selectedItemIds.length == selectedItemQtys.length) {
        for (int i = 0; i < selectedItemIds.length; i++) {
            try {
                int id = Integer.parseInt(selectedItemIds[i]);
                int qty = Integer.parseInt(selectedItemQtys[i]);
                itemsToCheckout.put(id, qty);
            } catch (NumberFormatException e) {
                System.err.println("Error parsing selected item ID or quantity: " + e.getMessage());
            }
        }
    }

    double totalHargaCheckout = 0;
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout</title>
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

        #keranjang-count {
            background: var(--red-badge);
            color: var(--white);
            font-size: 12px;
            font-weight: 700;
            padding: 2px 6px;
            border-radius: 50%;
            position: absolute;
            top: -5px;
            right: -10px;
            transform: translate(50%, -50%);
            user-select: none;
        }

        .container {
            max-width: 900px;
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
        h3 {
            color: var(--primary-blue);
            font-weight: 600;
            margin-top: 30px;
            margin-bottom: 20px;
        }
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }
        .table thead th {
            background-color: var(--primary-blue);
            color: var(--white);
            font-weight: 600;
            padding: 15px;
            vertical-align: middle;
            text-align: center;
            border-bottom: none;
        }
        .table tbody tr {
            background-color: var(--white);
            border-bottom: 1px solid #e0e0e0;
        }
        .table tbody tr:last-child {
            border-bottom: none;
        }
        .table tbody td {
            vertical-align: middle;
            padding: 15px;
            text-align: center;
            color: var(--text-medium);
        }
        .product-image {
            width: 70px;
            height: 70px;
            object-fit: cover;
            border-radius: 8px;
            margin-right: 15px;
            border: 1px solid #eee;
        }
        .product-info {
            display: flex;
            align-items: center;
            justify-content: flex-start;
            text-align: left;
        }
        .product-name-text {
            font-weight: 500;
            color: var(--text-dark);
            font-size: 1.05em;
        }
        .total-section {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            font-size: 1.3em;
            font-weight: 700;
            color: var(--primary-blue);
            margin-bottom: 30px;
            padding-right: 15px;
        }
        .total-section span {
            color: var(--accent-yellow);
            margin-left: 10px;
            font-size: 1.2em;
        }
        .form-label {
            font-weight: 500;
            color: var(--primary-blue);
        }
        .form-control, .form-select {
            border-radius: 8px;
            padding: 10px 15px;
            border: 1px solid #ced4da;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--accent-yellow);
            box-shadow: 0 0 0 0.25rem rgba(255, 215, 0, 0.25);
        }
        .btn-primary {
            background-color: var(--primary-blue);
            border-color: var(--primary-blue);
            padding: 12px 25px;
            border-radius: 10px;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }
        .btn-primary:hover {
            background-color: #001f3f;
            border-color: #001f3f;
        }
        .btn-success {
            background-color: var(--accent-yellow);
            border-color: var(--accent-yellow);
            color: var(--primary-blue);
            padding: 12px 25px;
            border-radius: 10px;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }
        .btn-success:hover {
            background-color: #e6c100;
            border-color: #e6c100;
        }
        .alert-warning {
            background-color: #fff3cd;
            color: #856404;
            border-color: #ffeeba;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            font-size: 1.1em;
            margin-bottom: 20px;
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
            .product-info {
                flex-direction: column;
                align-items: center;
                text-align: center;
            }
            .product-image {
                margin-right: 0;
                margin-bottom: 10px;
            }
            .total-section {
                justify-content: center;
                font-size: 1.1em;
            }
            .d-flex.justify-content-center {
                flex-direction: column;
                gap: 15px;
            }
            .btn-primary, .btn-success {
                width: 100%;
                max-width: 250px;
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
    <h2>Detail Checkout</h2>

    <%
        if (itemsToCheckout.isEmpty()) {
    %>
        <div class="alert alert-warning">Tidak ada barang yang dipilih untuk checkout. Kembali ke <a href="keranjang.jsp">Keranjang</a>.</div>
    <%
        } else {
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");
    %>
    <h3>Barang yang Dipilih</h3>
    <div class="table-responsive">
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>Nama Barang</th>
                    <th>Harga Satuan</th>
                    <th>Jumlah</th>
                    <th>Subtotal</th>
                </tr>
            </thead>
            <tbody>
                <%
                    for (Map.Entry<Integer, Integer> entry : itemsToCheckout.entrySet()) {
                        int idBarang = entry.getKey();
                        int kuantitas = entry.getValue();

                        String sql = "SELECT nama_barang, harga, gambar FROM barang WHERE id = ?";
                        ps = conn.prepareStatement(sql);
                        ps.setInt(1, idBarang);
                        rs = ps.executeQuery();

                        if (rs.next()) {
                            String nama = rs.getString("nama_barang");
                            double hargaSatuan = rs.getDouble("harga");
                            // String gambar = rs.getString("gambar"); // Not displayed on checkout, but can be added
                            double subtotal = hargaSatuan * kuantitas;
                            totalHargaCheckout += subtotal;
                %>
                <tr>
                    <td>
                        <div class="product-info">
                            <span class="product-name-text"><%= nama %></span>
                        </div>
                    </td>
                    <td>Rp<%= String.format("%,.0f", hargaSatuan) %></td>
                    <td><%= kuantitas %></td>
                    <td>Rp<%= String.format("%,.0f", subtotal) %></td>
                </tr>
                <%
                        }
                        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
                    }
                %>
            </tbody>
        </table>
    </div>

    <div class="total-section">
        Total yang harus dibayar: <span>Rp<%= String.format("%,.0f", totalHargaCheckout) %></span>
    </div>

    <h3>Informasi Pengiriman & Pembayaran</h3>
    <form action="proses_checkout.jsp" method="post">
        <div class="mb-3">
            <label for="namaPenerima" class="form-label">Nama Penerima</label>
            <input type="text" class="form-control" id="namaPenerima" name="nama_penerima" required>
        </div>
        <div class="mb-3">
            <label for="alamat" class="form-label">Alamat Lengkap</label>
            <textarea class="form-control" id="alamat" name="alamat" rows="3" required></textarea>
        </div>
        <div class="mb-4">
            <label for="metodePembayaran" class="form-label">Metode Pembayaran</label>
            <select class="form-select" id="metodePembayaran" name="metode_pembayaran" required>
                <option value="">Pilih Metode Pembayaran</option>
                <option value="transfer_bank">Transfer Bank</option>
                <option value="ewallet">E-Wallet</option>
                <option value="cod">Cash On Delivery (COD)</option>
            </select>
        </div>

        <%-- Hidden fields for selected items to pass them to proses_checkout.jsp --%>
        <%
            for (Map.Entry<Integer, Integer> entry : itemsToCheckout.entrySet()) {
        %>
            <input type="hidden" name="checkout_item_id" value="<%= entry.getKey() %>">
            <input type="hidden" name="checkout_item_qty" value="<%= entry.getValue() %>">
        <%
            }
        %>
        <input type="hidden" name="total_harga_checkout" value="<%= totalHargaCheckout %>">

        <div class="d-flex justify-content-between mt-4">
            <a href="keranjang.jsp" class="btn btn-primary"><i class="fas fa-arrow-left"></i> Kembali ke Keranjang</a>
            <button type="submit" class="btn btn-success">Simpan <i class="fas fa-arrow-right"></i></button>
        </div>
    </form>

    <%
            } catch (Exception e) {
    %>
            <div class="alert alert-danger">Terjadi kesalahan saat memuat detail checkout: <%= e.getMessage() %></div>
    <%
            } finally {
                if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
            }
        }
    %>
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