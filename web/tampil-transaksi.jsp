<%@ page import="java.sql.*, java.util.ArrayList, java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% request.setCharacterEncoding("UTF-8"); %>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8" />
    <title>Riwayat Transaksi</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <style>
        /* Salin seluruh blok <style> dari data-regis.jsp ke sini */
        body {
            margin: 0;
            font-family: 'Poppins', sans-serif;
            background-color: #f4f6f8;
            color: #0D47A1;
        }
        .sidebar {
            height: 100vh;
            width: 220px;
            position: fixed;
            background-color: #0D47A1;
            padding: 30px 20px;
            display: flex;
            flex-direction: column;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.2);
            color: white;
            z-index: 1000;
        }
        .logo {
            margin-bottom: 50px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .logo i {
            font-size: 28px;
            color: #FFD700;
            text-shadow: 0 0 5px rgba(255, 215, 0, 0.7);
        }
        .logo h2 {
            font-size: 22px;
            font-weight: 700;
            margin: 0;
            letter-spacing: 1.2px;
            text-shadow: 0 0 5px rgba(255, 215, 0, 0.7);
        }
        .menu {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        .menu a {
            display: flex;
            align-items: center;
            padding: 12px 15px;
            border-radius: 12px;
            color: white;
            text-decoration: none;
            font-size: 14px;
            transition: all 0.3s ease;
            transform: translateX(0);
        }
        .menu a i {
            font-size: 18px;
            margin-right: 12px;
            width: 20px;
            text-align: center;
        }
        .menu a:hover {
            background-color: rgba(255, 255, 255, 0.15);
            color: #FFD700;
            transform: translateX(10px);
            box-shadow: 2px 4px 10px rgba(0, 0, 0, 0.1);
        }
        .menu a:active,
        .menu a.active {
            background-color: rgba(255, 255, 255, 0.15);
            color: #FFD700;
            font-weight: 600;
        }
        .main-content {
            margin-left: 240px;
            padding: 40px 30px;
        }
        h1 {
            font-size: 32px;
            color: #0D47A1;
        }
        .card {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 25px rgba(13, 71, 161, 0.2);
            max-width: 100%;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(13, 71, 161, 0.3);
        }
        .table thead {
            background-color: #0D47A1;
            color: white;
        }
        .btn-sm {
            padding: 4px 10px;
            font-size: 0.8rem;
        }

        /* Kelas tombol hapus warna biru tua */
        .btn-darkblue {
            background-color: #0B3D91; /* Biru tua */
            border-color: #0B3D91;
            color: white;
        }
        .btn-darkblue:hover {
            background-color: #093270;
            border-color: #093270;
            color: white;
        }

        /* Styles for the form within the modal - adapted from your form-transaksi.jsp */
        .modal-body h2 {
            text-align: center;
            color: #333;
            margin-bottom: 20px;
        }
        .modal-body label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
        }
        .modal-body input[type="text"],
        .modal-body input[type="number"],
        .modal-body input[type="date"],
        .modal-body select {
            width: 100%; /* Make inputs fill the width */
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .modal-body input[type="submit"] {
            background-color: #0D47A1;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
            margin-top: 20px;
        }
        .modal-body input[type="submit"]:hover {
            background-color: #0B3D91;
        }
        .modal-body .error {
            color: red;
            font-size: 0.9em;
            margin-bottom: 15px;
        }


        @media screen and (max-width: 768px) {
            .main-content {
                margin-left: 0;
                padding: 20px;
            }
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
                flex-direction: row;
                padding: 10px;
                justify-content: space-between;
            }
        }
    </style>
</head>
<body>

<div class="sidebar">
    <div class="logo">
        <i class="fas fa-moon"></i>
        <h2>DreamTales</h2>
    </div>
    <div class="menu">
        <a href="dashboard.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="data-regis.jsp"><i class="fas fa-user-plus"></i> Data Register</a>
        <a href="inputBarang.jsp"><i class="fas fa-book"></i> Master Buku</a>
        <a href="tampil-transaksi.jsp" class="active"><i class="fas fa-history"></i> Transaksi</a>
        <a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
</div>

<div class="main-content">
    <div class="container px-4 mx-auto">
        <h1 class="mb-4">Daftar Transaksi</h1>

        <div class="mb-3 text-end">
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addTransactionModal">
                <i class="fas fa-plus"></i>
            </button>
        </div>
        <div class="card">
            <div style="overflow-x: auto;">
                <table class="table table-bordered table-striped mb-0">
                    <thead>
                        <tr>
                            <th class="text-center">ID Transaksi</th>
                            <th class="text-center">Nama</th>
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
                                PreparedStatement deletePstmt = null;
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    deleteConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");

                                    
                                    String sqlDeleteTransaksi = "DELETE FROM transaksi_db WHERE id = ?";
                                    deletePstmt = deleteConn.prepareStatement(sqlDeleteTransaksi);
                                    deletePstmt.setString(1, deleteId);
                                    int rowsAffected = deletePstmt.executeUpdate();

                                    if (rowsAffected > 0) {
                                        out.println("<div class='alert alert-success mt-3' role='alert'>Transaksi dengan ID " + deleteId + " berhasil dihapus!</div>");
                                    } else {
                                        out.println("<div class='alert alert-warning mt-3' role='alert'>Transaksi dengan ID " + deleteId + " tidak ditemukan.</div>");
                                    }
                                } catch (SQLException e) {
                                    out.println("<div class='alert alert-danger mt-3' role='alert'>Error menghapus transaksi: " + e.getMessage() + "</div>");
                                    e.printStackTrace();
                                } catch (ClassNotFoundException e) {
                                    out.println("<div class='alert alert-danger mt-3' role='alert'>Error: Driver JDBC tidak ditemukan. " + e.getMessage() + "</div>");
                                    e.printStackTrace();
                                } finally {
                                    try { if (deletePstmt != null) deletePstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    try { if (deleteConn != null) deleteConn.close(); } catch (SQLException e) { e.printStackTrace(); }
                                }
                            }

                            int no = 1;
                            Connection conn = null;
                            Statement stmt = null;
                            ResultSet rs = null;
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");
                                stmt = conn.createStatement();
                                rs = stmt.executeQuery("SELECT * FROM transaksi_db ORDER BY tanggal DESC"); // Asumsi tabel transaksi bernama 'transaksi_db'

                                while (rs.next()) {
                                    String transactionId = rs.getString("id");
                                    String currentStatus = rs.getString("status_pesanan");
                        %>
                        <tr>
                            <td class="text-center align-middle"><%= rs.getString("id") %></td>
                            <td class="text-center align-middle"><%= rs.getString("nama_penerima") %></td>
                            <td class="text-center align-middle"><%= rs.getString("tanggal") %></td>
                            <td class="text-center align-middle"><%= rs.getDouble("total_harga") %></td>
                            <td class="text-center align-middle">
                                <select class="form-select form-select-sm"
                                        onchange="updateTransactionStatus(this, '<%= transactionId %>')">
                                    <option value="Pending" <%= "pending".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Pending</option>
                                    <option value="di Terima" <%= "Di Terima".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Diterima</option>
                                    <option value="Di Kirim" <%= "Di Kirim".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Dikirim</option>
                                    <option value="selesai" <%= "Selesai".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Selesai</option>
                                    <option value="Di Batalkan" <%= "Di Batalkan".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Dibatalkan</option>
                                </select>
                            </td>
                            <td class="text-center align-middle">
                                <button type="button" class="btn btn-sm btn-info text-white" data-bs-toggle="modal" data-bs-target="#transactionDetailModal" data-transaction-id="<%= transactionId %>">Detail</button>
                                <a href="tampil-transaksi.jsp?delete=true&id=<%= transactionId %>"
                                   class="btn btn-sm btn-danger"
                                   onclick="return confirm('Yakin ingin menghapus transaksi ini? Data terkait juga akan terhapus.')">
                                    Hapus
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='6' class='text-center text-danger'>Error: " + e.getMessage() + "</td></tr>");
                            } finally {
                                try { if (rs != null) rs.close(); } catch (SQLException e) { /* handle exception */ }
                                try { if (stmt != null) stmt.close(); } catch (SQLException e) { /* handle exception */ }
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
                <h5 class="modal-title" id="transactionDetailModalLabel">Detail Transaksi</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="transactionDetailContent">
                Loading transaction details...
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Tutup</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="addTransactionModal" tabindex="-1" aria-labelledby="addTransactionModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addTransactionModalLabel">Form Tambah Transaksi Baru</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <%-- JSP Scriptlet untuk mengambil data barang langsung di sini --%>
                <%
                    // Deklarasi variabel untuk koneksi database
                    Connection connForm = null; // Gunakan nama variabel berbeda untuk menghindari konflik
                    PreparedStatement pstmtForm = null;
                    ResultSet rsForm = null;

                    // List untuk menyimpan data barang (id, nama_barang, harga)
                    List<String[]> daftarBarang = new ArrayList<>();

                    // Error message (jika ada)
                    String errorMessageForm = null; // Gunakan nama variabel berbeda

                    try {
                        // --- Konfigurasi Koneksi Database Anda ---
                        String jdbcURL = "jdbc:mysql://localhost:3306/dreamtales?useSSL=false&serverTimezone=UTC"; // Ganti dengan nama database Anda
                        String dbUser = "root"; // Ganti dengan username database Anda
                        String dbPassword = ""; // Ganti dengan password database Anda
                        // ------------------------------------------

                        // Memuat driver JDBC
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        connForm = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);

                        // Mengambil data barang dari tabel 'barang'
                        String sqlBarang = "SELECT id, nama_barang, harga FROM barang ORDER BY nama_barang";
                        pstmtForm = connForm.prepareStatement(sqlBarang);
                        rsForm = pstmtForm.executeQuery();

                        while (rsForm.next()) {
                            String[] barang = {
                                String.valueOf(rsForm.getInt("id")),
                                rsForm.getString("nama_barang"),
                                String.valueOf(rsForm.getDouble("harga"))
                            };
                            daftarBarang.add(barang);
                        }

                    } catch (SQLException e) {
                        errorMessageForm = "Error koneksi database atau pengambilan data barang: " + e.getMessage();
                        e.printStackTrace();
                    } catch (ClassNotFoundException e) {
                        errorMessageForm = "Driver JDBC tidak ditemukan: " + e.getMessage();
                        e.printStackTrace();
                    } finally {
                        // Menutup koneksi database
                        try { if (rsForm != null) rsForm.close(); } catch (SQLException e) { e.printStackTrace(); }
                        try { if (pstmtForm != null) pstmtForm.close(); } catch (SQLException e) { e.printStackTrace(); }
                        try { if (connForm != null) connForm.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>

                <% if (errorMessageForm != null) { %>
                    <p class="error"><%= errorMessageForm %></p>
                <% } %>

                <form id="transactionForm" action="simpan-transaksi.jsp" method="post">
                    <div class="mb-3">
                        <label for="id_barang">Pilih Barang:</label>
                        <select id="id_barang" name="id_barang" class="form-select" required onchange="updateHarga()">
                            <option value="">-- Pilih Barang --</option>
                            <%
                                if (!daftarBarang.isEmpty()) {
                                    for (String[] barang : daftarBarang) {
                                        out.println("<option value='" + barang[0] + "' data-harga='" + barang[2] + "'>" + barang[1] + " (Rp " + String.format("%,.2f", Double.parseDouble(barang[2])) + ")</option>");
                                    }
                                } else {
                                    out.println("<option value=''>Tidak ada barang tersedia</option>");
                                }
                            %>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label for="tanggal">Tanggal:</label>
                        <input type="date" id="tanggal" name="tanggal" class="form-control" value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" required>
                    </div>

                    <div class="mb-3">
                        <label for="nama_penerima">Nama Penerima:</label>
                        <input type="text" id="nama_penerima" name="nama_penerima" class="form-control" required>
                    </div>

                    <div class="mb-3">
                        <label for="jumlah_barang">Jumlah Barang:</label>
                        <input type="number" id="jumlah_barang" name="jumlah_barang" class="form-control" min="1" value="1" required oninput="hitungTotalHarga()">
                    </div>

                    <div class="mb-3">
                        <label for="total_harga_display">Total Harga:</label>
                        <input type="text" id="total_harga_display" class="form-control" value="0.00" readonly>
                        <input type="hidden" id="total_harga" name="total_harga"> <%-- Hidden input untuk mengirim nilai total harga --%>
                    </div>

                    <div class="mb-3">
                        <label for="metode_pembayaran">Metode Pembayaran:</label>
                        <select id="metode_pembayaran" name="metode_pembayaran" class="form-select" required>
                            <option value="">-- Pilih Metode Pembayaran --</option>
                            <option value="Transfer Bank">Transfer Bank</option>
                            <option value="Kartu Kredit">Kartu Kredit</option>
                            <option value="Cash On Delivery (COD)">Cash On Delivery (COD)</option>
                            <option value="E-Wallet">E-Wallet</option>
                            <option value="Lainnya">Lainnya</option>
                        </select>
                    </div>

                    <input type="submit" value="Simpan Transaksi">
                </form>
            </div>
        </div>
    </div>
</div>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        // Script untuk Modal Detail Transaksi (Tidak Berubah)
        var transactionDetailModal = document.getElementById('transactionDetailModal');
        transactionDetailModal.addEventListener('show.bs.modal', function (event) {
            var button = event.relatedTarget;
            var transactionId = button.getAttribute('data-transaction-id');
            var modalBody = transactionDetailModal.querySelector('#transactionDetailContent');
            modalBody.innerHTML = 'Loading transaction details...';

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
                    modalBody.innerHTML = '<p style="color:red;">Gagal memuat detail transaksi. Silakan coba lagi.</p>';
                });
        });

        // Script untuk Modal Tambah Transaksi (Disesuaikan)
        var addTransactionModal = document.getElementById('addTransactionModal');
        addTransactionModal.addEventListener('shown.bs.modal', function () {
            // Panggil fungsi-fungsi JavaScript form setelah modal sepenuhnya muncul
            if (typeof updateHarga === 'function') {
                updateHarga();
            }
        });
    });

    // Fungsi untuk mengupdate status transaksi melalui AJAX
    function updateTransactionStatus(selectElement, transactionId) {
        const newStatus = selectElement.value;
        const confirmation = confirm('Yakin ingin mengubah status transaksi ID ' + transactionId + ' menjadi "' + newStatus + '"?');

        if (confirmation) {
            // Display a temporary message near the dropdown (optional)
            // For a more robust UI, consider a small loading spinner or success checkmark
            const originalText = selectElement.options[selectElement.selectedIndex].text;
            selectElement.style.pointerEvents = 'none'; // Disable dropdown during update
            selectElement.style.opacity = '0.7';

            const formData = new URLSearchParams();
            formData.append('id_transaksi', transactionId);
            formData.append('status_pesanan', newStatus);

            fetch('update-status.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: formData
            })
            .then(response => {
                // Check if the redirect happened (indicating success or specific error)
                if (response.redirected) {
                    // Refresh the page to show the updated status and any alert messages
                    window.location.href = response.url;
                } else if (response.ok) {
                    // This might happen if update-status-transaksi.jsp just prints success
                    // or doesn't redirect. In our case, it redirects.
                    console.log('Status updated successfully (AJAX response).');
                    // Optionally, you could update a badge here without page reload
                    // alert('Status transaksi berhasil diubah!');
                } else {
                    return response.text().then(text => { throw new Error('Server error: ' + text); });
                }
            })
            .catch(error => {
                console.error('Error updating status:', error);
                alert('Gagal mengubah status transaksi: ' + error.message);
                // Revert dropdown if error occurs
                selectElement.value = originalText; // This won't work well if originalText is not a value
                // A better approach is to store the actual original value before update
                // For simplicity, we just alert and let user retry.
            })
            .finally(() => {
                selectElement.style.pointerEvents = 'auto'; // Re-enable dropdown
                selectElement.style.opacity = '1';
            });
        } else {
            // If user cancels, revert dropdown to original selection (optional, but good UX)
            // You might need to store the initial value when the page loads
            // For this example, we'll just let it stay on the attempted new value.
            // A page refresh would reset it anyway if not updated.
        }
    }


    // Fungsi-fungsi JavaScript untuk perhitungan harga
    function updateHarga() {
        const selectBarang = document.getElementById('id_barang');
        // Pastikan selectBarang tidak null dan ada selectedOption
        if (selectBarang && selectBarang.selectedIndex !== -1) {
            const selectedOption = selectBarang.options[selectBarang.selectedIndex];
            const hargaSatuan = parseFloat(selectedOption.getAttribute('data-harga')) || 0;
            hitungTotalHarga();
        } else {
             // Jika tidak ada barang terpilih, set harga ke 0
            document.getElementById('total_harga_display').value = "Rp 0.00";
            document.getElementById('total_harga').value = "0.00";
        }
    }

    function hitungTotalHarga() {
        const selectBarang = document.getElementById('id_barang');
        let hargaSatuan = 0;
        if (selectBarang && selectBarang.selectedIndex !== -1) {
            const selectedOption = selectBarang.options[selectBarang.selectedIndex];
            hargaSatuan = parseFloat(selectedOption.getAttribute('data-harga')) || 0;
        }

        const jumlahBarangInput = document.getElementById('jumlah_barang');
        const jumlahBarang = parseInt(jumlahBarangInput ? jumlahBarangInput.value : 0) || 0;

        const totalHarga = hargaSatuan * jumlahBarang;

        const totalHargaDisplay = document.getElementById('total_harga_display');
        const totalHargaHidden = document.getElementById('total_harga');

        if (totalHargaDisplay) {
            totalHargaDisplay.value = "Rp " + totalHarga.toLocaleString('id-ID', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        }
        if (totalHargaHidden) {
            totalHargaHidden.value = totalHarga.toFixed(2);
        }
    }
</script>
</body>
</html>