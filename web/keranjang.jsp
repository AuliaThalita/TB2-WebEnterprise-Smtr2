<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null) {
        response.sendRedirect("login.html");
        return;
    }

    Map<Integer, Integer> keranjang = (Map<Integer, Integer>) session.getAttribute("keranjang");
    if (keranjang == null) {
        keranjang = new HashMap<>();
        session.setAttribute("keranjang", keranjang);
    }

    String idBarangUpdateStr = request.getParameter("id_barang_update");
    String actionUpdate = request.getParameter("action_update");

    if (idBarangUpdateStr != null && actionUpdate != null) {
        try {
            int idBarangUpdate = Integer.parseInt(idBarangUpdateStr);
            Integer currentQuantity = keranjang.get(idBarangUpdate);

            if (currentQuantity != null) {
                if ("increase".equals(actionUpdate)) {
                    keranjang.put(idBarangUpdate, currentQuantity + 1);
                } else if ("decrease".equals(actionUpdate)) {
                    if (currentQuantity > 1) {
                        keranjang.put(idBarangUpdate, currentQuantity - 1);
                    } else {
                        keranjang.remove(idBarangUpdate);
                    }
                }
                session.setAttribute("keranjang", keranjang);
            }
            response.sendRedirect("keranjang.jsp");
            return;
        } catch (NumberFormatException e) {
            System.err.println("Error parsing id_barang_update: " + e.getMessage());
        }
    }

    int jumlahTotalBarangDiKeranjang = 0;
    for (int qty : keranjang.values()) {
        jumlahTotalBarangDiKeranjang += qty;
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keranjang</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
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
            --red-badge: #dc3545; /* Kept red for notifications */
            --green-price: #28a745;
        }

        body {
            font-family: 'Roboto', sans-serif; /* Matched to home.jsp */
            background-color: var(--light-grey-bg); /* Matched to home.jsp */
            color: var(--text-dark);
            padding-top: 0; /* No top padding as navbar is not fixed in the same way now */
        }
        /* Navbar styles - Adapted from home.jsp */
        .top-navbar { /* Changed from .navbar to .top-navbar to match home.jsp */
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
            gap: 5px; /* Matched gap to home.jsp */
            font-weight: 700;
            font-size: 24px; /* Matched font-size to home.jsp */
            color: var(--white);
            margin-left: 50px; /* Matched margin to home.jsp */
        }
        .top-navbar .logo i {
            font-size: 28px;
            color: var(--accent-yellow);
        }
        .top-navbar .menu {
            display: flex;
            gap: 30px;
            flex-grow: 1; /* Allow menu to take available space */
            justify-content: center; /* Center the menu items */
        }
        .top-navbar .menu a {
            color: var(--white);
            text-decoration: none;
            font-weight: 500; /* Matched font-weight to home.jsp */
            font-size: 16px; /* Matched font-size to home.jsp */
            padding: 5px 0; /* Matched padding to home.jsp */
            position: relative;
        }
        .top-navbar .menu a:hover {
            color: var(--accent-yellow);
        }
        .top-navbar .menu a.active {
            color: var(--accent-yellow);
            border-bottom: 2px solid var(--accent-yellow); /* Matched underline style */
        }
        .top-navbar .user-account { /* Added .user-account to match home.jsp */
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--white);
            font-weight: 500;
            font-size: 16px;
            margin-right: 50px; /* Matched margin to home.jsp */
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
            top: -5px; /* Adjust positioning */
            right: -10px; /* Adjust positioning */
            transform: translate(50%, -50%);
            user-select: none;
            /* display property controlled by JSP/JS, but default to none if 0 */
        }
        /* End Navbar styles */

        .container {
            max-width: 900px;
            margin-top: 40px; /* Adjusted margin-top after removing fixed navbar */
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
        /* --- Perbaikan Tampilan Tabel --- */
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
        }
        .table {
            margin-bottom: 0;
        }
        .table thead th {
            background-color: var(--primary-blue); /* Dark blue for table header */
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
            transition: background-color 0.2s ease-in-out;
        }
        .table tbody tr:last-child {
            border-bottom: none;
        }
        .table tbody tr:hover {
            background-color: #e6e6e6; /* Lighter hover for table rows */
        }
        .table tbody td {
            vertical-align: middle;
            padding: 15px;
            text-align: center;
            color: var(--text-medium);
        }
        .table tbody td:first-child {
            font-weight: 600;
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
        .table tfoot th {
            background-color: var(--primary-blue); /* Dark blue for table footer */
            color: var(--white);
            font-weight: 700;
            font-size: 1.2em;
            padding: 20px;
            text-align: center;
            border-top: 2px solid var(--accent-yellow); /* Yellow top border for footer */
        }
        /* --- Akhir Perbaikan Tampilan Tabel --- */

        .btn-danger {
            background-color: var(--red-badge);
            border-color: var(--red-badge);
            transition: background-color 0.3s ease;
            font-size: 0.9em;
            padding: 6px 12px;
            border-radius: 8px;
        }
        .btn-danger:hover {
            background-color: #a71d2a; /* Darker red */
            border-color: #a71d2a;
        }
        /* Style for quantity buttons */
        .quantity-control {
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .quantity-control a.btn {
            background-color: var(--accent-yellow); /* Yellow for quantity buttons */
            color: var(--primary-blue); /* Dark blue text */
            border: none;
            padding: 6px 12px;
            cursor: pointer;
            border-radius: 5px;
            font-weight: bold;
            font-size: 1em;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background-color 0.3s ease;
        }
        .quantity-control a.btn:hover {
            background-color: #e6c100; /* Darker yellow on hover */
        }
        .quantity-control input[type="number"] {
            width: 60px;
            text-align: center;
            border: 1px solid #ccc;
            border-radius: 5px;
            margin: 0 8px;
            padding: 5px;
            -moz-appearance: textfield;
            font-size: 1.1em;
            color: var(--text-dark);
        }
        .quantity-control input[type="number"]::-webkit-outer-spin-button,
        .quantity-control input[type="number"]::-webkit-inner-spin-button {
            -webkit-appearance: none;
            margin: 0;
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
        .btn-secondary {
            background-color: var(--primary-blue); /* Dark Blue for back button */
            border-color: var(--primary-blue);
            color: var(--white);
            padding: 12px 25px;
            border-radius: 10px;
            font-weight: 600;
            margin-left: 0; /* Reset margin-left to 0 if pushed right by flex later */
            transition: background-color 0.3s ease;
        }
        .btn-secondary:hover {
            background-color: #001f3f; /* Even darker blue */
            border-color: #001f3f;
        }
        .alert-info {
            background-color: #d1ecf1; /* Light cyan, adjust if needed */
            color: #0c5460; /* Dark cyan text */
            border-color: #bee5eb;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            font-size: 1.1em;
        }
        .alert-info a {
            color: #0c5460;
            font-weight: 600;
            text-decoration: none;
        }
        .alert-info a:hover {
            text-decoration: underline;
        }
        .footer {
            background-color: var(--primary-blue); /* Dark Blue footer */
            color: var(--white);
            padding: 40px 20px; /* Matched padding to home.jsp */
            text-align: center;
            font-size: 14px; /* Matched font-size to home.jsp */
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
            .container {
                margin-top: 20px !important; /* Adjust for smaller screens */
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
            .quantity-control {
                flex-direction: column;
                gap: 5px;
            }
            .quantity-control a.btn,
            .quantity-control input[type="number"] {
                width: 100%;
            }
            .d-flex.justify-content-end {
                flex-direction: column;
                align-items: center;
                gap: 15px;
            }
            .btn-secondary, .btn-success {
                width: 100%;
                max-width: 250px;
                margin-left: 0 !important; /* Override ms-3 on small screens */
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
        <a href="keranjang.jsp" class="active" id="keranjang-link">
            Keranjang
            <span id="keranjang-count" style="<%= jumlahTotalBarangDiKeranjang > 0 ? "display: inline-block;" : "display: none;" %>">
                <%= jumlahTotalBarangDiKeranjang %>
            </span>
        </a>
        <a href="pesanan.jsp">Pesanan</a>
    </div>
    <div class="user-account">
        <i class="fas fa-user"></i> <%= userName %>
    </div>
</div>

<div class="container">
    <h2>Keranjang Belanja Anda</h2>
    <%
        if (keranjang.isEmpty()) {
    %>
        <div class="alert alert-info">Keranjang belanjamu masih kosong. Yuk belanja dulu di <a href="home.jsp">Beranda</a>!</div>
    <%
        } else {
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");
    %>

    <div class="table-responsive">
        <table class="table table-hover bg-white" id="cartTable">
            <thead>
                <tr>
                    <th style="width: 5%;">
                        <input type="checkbox" id="selectAllItems">
                    </th>
                    <th>Nama Barang</th>
                    <th>Harga Satuan</th>
                    <th>Jumlah</th>
                    <th>Subtotal</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                <%
                    for (Map.Entry<Integer, Integer> entry : keranjang.entrySet()) {
                        int idBarang = entry.getKey();
                        int kuantitas = entry.getValue();

                        String sql = "SELECT nama_barang, harga, gambar FROM barang WHERE id = ?";
                        ps = conn.prepareStatement(sql);
                        ps.setInt(1, idBarang);
                        rs = ps.executeQuery();

                        if (rs.next()) {
                            String nama = rs.getString("nama_barang");
                            double hargaSatuan = rs.getDouble("harga");
                            String gambar = rs.getString("gambar");
                            double subtotal = hargaSatuan * kuantitas;
                %>
                <tr data-id="<%= idBarang %>" data-price="<%= hargaSatuan %>" data-qty="<%= kuantitas %>">
                    <td>
                        <input type="checkbox" class="item-checkbox" value="<%= idBarang %>">
                    </td>
                    <td>
                        <div class="product-info">
                            <img src="uploads/<%= gambar %>" alt="<%= nama %>" class="product-image">
                            <span class="product-name-text"><%= nama %></span>
                        </div>
                    </td>
                    <td>Rp<%= String.format("%,.0f", hargaSatuan) %></td>
                    <td>
                        <div class="quantity-control">
                            <a href="keranjang.jsp?id_barang_update=<%= idBarang %>&action_update=decrease" class="btn btn-sm">-</a>
                            <input type="number" value="<%= kuantitas %>" min="1" readonly class="item-qty-display">
                            <a href="keranjang.jsp?id_barang_update=<%= idBarang %>&action_update=increase" class="btn btn-sm">+</a>
                        </div>
                    </td>
                    <td class="item-subtotal">Rp<%= String.format("%,.0f", subtotal) %></td>
                    <td>
                        <form action="hapusKeranjang.jsp" method="post" style="display:inline;">
                            <input type="hidden" name="id_barang" value="<%= idBarang %>">
                            <button type="submit" class="btn btn-sm btn-danger"><i class="fas fa-trash-alt"></i> Hapus</button>
                        </form>
                    </td>
                </tr>
                <%
                        }
                        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
                    }
                %>
            </tbody>
            <tfoot>
                <tr>
                    <th colspan="4">Total Belanja</th>
                    <th colspan="2" id="grandTotal">Rp0</th>
                </tr>
            </tfoot>
        </table>
    </div>

    <div class="d-flex justify-content-end mt-4">
        <a href="home.jsp" class="btn btn-secondary"><i class="fas fa-arrow-left"></i> Lanjut Belanja</a>
        <button type="button" class="btn btn-success ms-3" id="checkoutBtn" disabled>Checkout</button>
    </div>

    <%
            } catch (Exception e) {
    %>
            <div class="alert alert-danger">Gagal memuat keranjang: <%= e.getMessage() %></div>
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
        <a href="#"><a href="#"><i class="fab fa-instagram"></i></a>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const selectAllCheckbox = document.getElementById('selectAllItems');
        const itemCheckboxes = document.querySelectorAll('.item-checkbox');
        const grandTotalElement = document.getElementById('grandTotal');
        const checkoutBtn = document.getElementById('checkoutBtn');
        const cartTable = document.getElementById('cartTable');

        function updateGrandTotal() {
            let currentGrandTotal = 0;
            let anyItemSelected = false; // Track if any item is selected

            itemCheckboxes.forEach(checkbox => {
                if (checkbox.checked) {
                    anyItemSelected = true;
                    const row = checkbox.closest('tr');
                    const price = parseFloat(row.dataset.price);
                    const qty = parseInt(row.querySelector('.item-qty-display').value);
                    currentGrandTotal += (price * qty);
                }
            });
            grandTotalElement.textContent = 'Rp' + currentGrandTotal.toLocaleString('id-ID');

            // Enable/disable checkout button based on selection
            if (checkoutBtn) {
                checkoutBtn.disabled = !anyItemSelected;
            }
        }

        // Event listener for "Select All" checkbox
        if (selectAllCheckbox) {
            selectAllCheckbox.addEventListener('change', function() {
                itemCheckboxes.forEach(checkbox => {
                    checkbox.checked = selectAllCheckbox.checked;
                });
                updateGrandTotal();
            });
        }


        // Event listeners for individual item checkboxes
        itemCheckboxes.forEach(checkbox => {
            checkbox.addEventListener('change', function() {
                updateGrandTotal();
                // If any individual checkbox is unchecked, uncheck "Select All"
                if (!this.checked) {
                    if (selectAllCheckbox) {
                        selectAllCheckbox.checked = false;
                    }
                } else {
                    // If all individual checkboxes are checked, check "Select All"
                    if (selectAllCheckbox && Array.from(itemCheckboxes).every(cb => cb.checked)) {
                        selectAllCheckbox.checked = true;
                    }
                }
            });
        });

        // Event listener for Checkout button
        if (checkoutBtn) {
            checkoutBtn.addEventListener('click', function() {
                const selectedItems = [];
                itemCheckboxes.forEach(checkbox => {
                    if (checkbox.checked) {
                        const row = checkbox.closest('tr');
                        const id = checkbox.value;
                        const qty = parseInt(row.querySelector('.item-qty-display').value);
                        selectedItems.push({ id: id, qty: qty });
                    }
                });

                if (selectedItems.length === 0) {
                    alert('Pilih setidaknya satu barang untuk melanjutkan checkout.');
                    return;
                }

                // Create a hidden form and submit it with selected item data
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'checkout.jsp';

                selectedItems.forEach(item => {
                    const idInput = document.createElement('input');
                    idInput.type = 'hidden';
                    idInput.name = 'selected_item_id'; // Name will be repeated for each item
                    idInput.value = item.id;
                    form.appendChild(idInput);

                    const qtyInput = document.createElement('input');
                    qtyInput.type = 'hidden';
                    qtyInput.name = 'selected_item_qty'; // Name will be repeated for each item
                    qtyInput.value = item.qty;
                    form.appendChild(qtyInput);
                });

                document.body.appendChild(form);
                form.submit();
            });
        }

        // Initial calculation when the page loads
        updateGrandTotal();
    });
</script>
</body>
</html>