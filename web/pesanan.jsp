<%@ page import="java.sql.*, java.util.ArrayList, java.util.List, java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% request.setCharacterEncoding("UTF-8"); %>
<%
    String userName = (String) session.getAttribute("userName");
    // Mendapatkan ID pengguna yang sedang login dari session
    Integer userId = (Integer) session.getAttribute("userId"); // PASTIKAN userId ini tersedia di session saat login

    if (userName == null || userId == null) { // Tambahkan pengecekan userId
        response.sendRedirect("login.html");
        return;
    }

    // Hitung total quantity di keranjang session for the top navbar
    Map<Integer, Integer> keranjang = (Map<Integer, Integer>) session.getAttribute("keranjang");
    int totalQty = 0;
    if (keranjang != null) {
        for (int qty : keranjang.values()) {
            totalQty += qty;
        }
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8" />
    <title>DreamTales - Daftar Pesanan</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <style>
        :root {
        /* Define color variables for easier management */
        --primary-blue: #002D62; /* Dark Blue */
        --accent-yellow: #FFD700; /* Gold/Yellow */
        --light-grey-bg: #f0f2f5;
        --white: #fff;
        --text-dark: #333;
        --text-medium: #555;
        --text-light: #777;
        --red-badge: #dc3545;
        --green-price: #28a745;
    }
    
        body {
            font-family: 'Roboto', sans-serif;
            background-color: var(--light-grey-bg);
            margin: 0;
            padding-top: 0;
            color: var(--text-dark); /* Default text color */
        }
        .top-navbar {
            background-color: var(--primary-blue); /* Dark Blue background for the top bar */
            box-shadow: 0 2px 5px rgba(0,0,0,0.2); /* Slightly stronger shadow */
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
            color: var(--white); /* White text for logo */
            margin-left: 50px;
        }
        .top-navbar .logo i {
            font-size: 28px;
            color: var(--accent-yellow); /* Yellow for the moon icon */
        }
        .top-navbar .menu {
            display: flex;
            gap: 30px;
            flex-grow: 1;
            justify-content: center;
        }
        .top-navbar .menu a {
            color: var(--white); /* White text for menu items */
            text-decoration: none;
            font-weight: 500;
            font-size: 16px;
            padding: 5px 0;
            position: relative;
        }
        .top-navbar .menu a:hover {
            color: var(--accent-yellow); /* Yellow hover color */
        }
        .top-navbar .menu a.active {
            color: var(--accent-yellow); /* Yellow active color */
            border-bottom: 2px solid var(--accent-yellow); /* Yellow underline active link */
        }
        .top-navbar .user-account {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--white); /* White text for user account */
            font-weight: 500;
            font-size: 16px;
            margin-right: 50px;
        }
        .top-navbar .user-account i {
            font-size: 18px;
            color: var(--accent-yellow); /* Yellow for user icon */
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
            display: none; /* Hide initially, show with JS if count > 0 */
            user-select: none;
        }

        /* Main Content */
        .main-content {
            padding: 40px 20px;
            max-width: 1200px;
            margin: 0 auto;
        }
        h1 {
            font-size: 32px;
            color: var(--primary-blue);
            margin-bottom: 25px;
            font-weight: 700;
        }
        .card {
            background: var(--white);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 25px rgba(0, 45, 98, 0.1); /* Adjusted shadow for consistency */
            max-width: 100%;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0, 45, 98, 0.15);
        }
        .table thead {
            background-color: var(--primary-blue);
            color: var(--white);
        }
        .btn-sm {
            padding: 4px 10px;
            font-size: 0.8rem;
        }
        .btn-danger {
            background-color: var(--red-badge);
            border-color: var(--red-badge);
        }
        .btn-danger:hover {
            background-color: #c82333;
            border-color: #bd2130;
        }
        .btn-info {
            background-color: #17a2b8;
            border-color: #17a2b8;
        }
        .btn-info:hover {
            background-color: #138496;
            border-color: #117a8b;
        }

        /* Footer - Added for consistency */
        .footer {
            background-color: var(--primary-blue); /* Dark Blue footer */
            color: var(--white);
            padding: 40px 20px;
            text-align: center;
            font-size: 14px;
            margin-top: 40px; /* Space above footer */
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
            color: var(--accent-yellow); /* Yellow on hover for footer links */
        }
        .footer .social-icons a {
            color: var(--white);
            font-size: 20px;
            margin: 0 10px;
            text-decoration: none;
        }
        .footer .social-icons a:hover {
            color: var(--accent-yellow); /* Yellow on hover for social icons */
        }

        @media (max-width: 992px) {
            .top-navbar .menu {
                gap: 15px;
            }
            .top-navbar .logo {
                margin-left: 20px;
            }
            .top-navbar .user-account {
                margin-right: 20px;
            }
        }

        @media (max-width: 768px) {
            .top-navbar {
                flex-direction: column;
                padding: 10px;
                gap: 10px;
            }
            .top-navbar .logo {
                margin-left: 0;
            }
            .top-navbar .menu {
                flex-direction: column;
                align-items: center;
                margin-right: 0;
            }
            .top-navbar .user-account {
                margin-right: 0;
            }
            .main-content {
                padding: 20px;
            }
            h1 {
                font-size: 28px;
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
        <a href="keranjang.jsp" id="keranjang-link">
            Keranjang
            <span id="keranjang-count"><%= totalQty %></span>
        </a>
        <a href="pesanan.jsp" class="active">Pesanan</a>
    </div>
    <div class="user-account">
        <i class="fas fa-user"></i> <%= userName %>
    </div>
</div>

<div class="main-content">
    <div class="container px-4 mx-auto">
        <h1 class="mb-4">Daftar Pesanan Saya</h1>

        <div class="card">
            <div style="overflow-x: auto;">
                <table class="table table-bordered table-striped mb-0">
                    <thead>
                        <tr>
                            <th class="text-center">ID Transaksi</th>
                            <th class="text-center">Nama Penerima</th>
                            <th class="text-center">Tanggal Transaksi</th>
                            <th class="text-center">Total Harga</th>
                            <th class="text-center">Status</th>
                            <th class="text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            // Handle delete operation if requested
                            String deleteParam = request.getParameter("delete");
                            String deleteId = request.getParameter("id");
                            if ("true".equals(deleteParam) && deleteId != null && !deleteId.isEmpty()) {
                                Connection deleteConn = null;
                                PreparedStatement deletePstmtDetail = null; // Statement for detail table
                                PreparedStatement deletePstmtTransaksi = null; // Statement for main transaction table

                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    deleteConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");

                                    // Start transaction for atomicity
                                    deleteConn.setAutoCommit(false);
                                    
                                    // Then delete from transaksi_db, ensuring only the logged-in user's order can be deleted
                                    String sqlDeleteTransaksi = "DELETE FROM transaksi_db WHERE id = ? AND id_users = ?";
                                    deletePstmtTransaksi = deleteConn.prepareStatement(sqlDeleteTransaksi);
                                    deletePstmtTransaksi.setString(1, deleteId);
                                    deletePstmtTransaksi.setInt(2, userId); // Filter by logged-in user's ID
                                    int rowsAffected = deletePstmtTransaksi.executeUpdate();

                                    // Commit the transaction if all operations are successful
                                    deleteConn.commit();

                                    if (rowsAffected > 0) {
                                        out.println("<div class='alert alert-success mt-3' role='alert'>Pesanan dengan ID " + deleteId + " berhasil dihapus!</div>");
                                    } else {
                                        out.println("<div class='alert alert-warning mt-3' role='alert'>Pesanan dengan ID " + deleteId + " tidak ditemukan atau Anda tidak memiliki izin untuk menghapusnya.</div>");
                                    }
                                } catch (SQLException e) {
                                    // Rollback transaction on error
                                    if (deleteConn != null) {
                                        try { deleteConn.rollback(); } catch (SQLException rb_e) { rb_e.printStackTrace(); }
                                    }
                                    out.println("<div class='alert alert-danger mt-3' role='alert'>Error menghapus pesanan: " + e.getMessage() + "</div>");
                                    e.printStackTrace();
                                } catch (ClassNotFoundException e) {
                                    out.println("<div class='alert alert-danger mt-3' role='alert'>Error: Driver JDBC tidak ditemukan. " + e.getMessage() + "</div>");
                                    e.printStackTrace();
                                } finally {
                                    // Close statements and connection in finally block
                                    try { if (deletePstmtDetail != null) deletePstmtDetail.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    try { if (deletePstmtTransaksi != null) deletePstmtTransaksi.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    try { if (deleteConn != null) deleteConn.close(); } catch (SQLException e) { e.printStackTrace(); }
                                }
                            }

                            Connection conn = null;
                            PreparedStatement pstmt = null; // Menggunakan PreparedStatement
                            ResultSet rs = null;
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");
                                // Filter pesanan berdasarkan id_users dari pengguna yang sedang login
                                String sql = "SELECT * FROM transaksi_db WHERE id_users = ? ORDER BY tanggal DESC";
                                pstmt = conn.prepareStatement(sql);
                                pstmt.setInt(1, userId); // Mengatur parameter id_users
                                rs = pstmt.executeQuery();

                                while (rs.next()) {
                                    String transactionId = rs.getString("id");
                        %>
                        <tr>
                            <td class="text-center align-middle"><%= rs.getString("id") %></td>
                            <td class="text-center align-middle"><%= rs.getString("nama_penerima") %></td>
                            <td class="text-center align-middle"><%= rs.getString("tanggal") %></td>
                            <td class="text-center align-middle">Rp <%= String.format("%,.2f", rs.getDouble("total_harga")) %></td>
                            <td class="text-center align-middle"><%= rs.getString("status_pesanan") %></td>
                            <td class="text-center align-middle">
                                <button type="button" class="btn btn-sm btn-info text-white" data-bs-toggle="modal" data-bs-target="#transactionDetailModal" data-transaction-id="<%= transactionId %>">Detail</button>
                                <a href="pesanan.jsp?delete=true&id=<%= transactionId %>"
                                   class="btn btn-sm btn-danger"
                                   onclick="return confirm('Yakin ingin menghapus pesanan ini? Ini akan menghapus pesanan dan detailnya.')">
                                    Hapus
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='6' class='text-center text-danger'>Error: " + e.getMessage() + "</td></tr>");
                                e.printStackTrace();
                            } finally {
                                try { if (rs != null) rs.close(); } catch (SQLException e) { /* handle exception */ }
                                try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { /* handle exception */ } // Menutup PreparedStatement
                                try { if (conn != null) conn.close(); } catch (SQLException e) { /* handle exception */ }
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="transactionDetailModal" tabindex="-1" aria-labelledby="transactionDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="transactionDetailModalLabel">Detail Pesanan</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="transactionDetailContent">
                Loading pesanan details...
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Tutup</button>
            </div>
        </div>
    </div>
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
<script>
    function updateKeranjangCount(count) {
        const badge = document.getElementById('keranjang-count');
        if (count > 0) {
            badge.textContent = count;
            badge.style.display = 'inline-block';
        } else {
            badge.style.display = 'none';
        }
    }

    // Set initial count from server
    updateKeranjangCount(<%= totalQty %>);

    document.addEventListener('DOMContentLoaded', function () {
        var transactionDetailModal = document.getElementById('transactionDetailModal');
        transactionDetailModal.addEventListener('show.bs.modal', function (event) {
            var button = event.relatedTarget;
            var transactionId = button.getAttribute('data-transaction-id');
            var modalBody = transactionDetailModal.querySelector('#transactionDetailContent');
            modalBody.innerHTML = 'Loading pesanan details...';

            fetch('detail-transaksi.jsp?id=' + transactionId)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.text();
                })
                .then(data => {
                    modalBody.innerHTML = data;
                })
                .catch(error => {
                    console.error('Error fetching transaction details:', error);
                    modalBody.innerHTML = '<p style="color:red;">Gagal memuat detail pesanan. Silakan coba lagi.</p>';
                });
        });
    });
</script>
</body>
</html>