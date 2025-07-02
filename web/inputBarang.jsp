<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.*" %>
<%@ page import="jakarta.servlet.annotation.*" %>
<%@ page import="jakarta.servlet.http.*" %>

<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Master Barang</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <style>
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

    .btn-edit {
      background-color: #FFD700;
      color: black;
      border: none;
    }

    .btn-edit:hover {
      background-color: white;
      color: black;
    }

    .btn-delete {
      background-color: #0D47A1;
      color: white;
      border: none;
    }

    .btn-delete:hover {
      background-color: white;
      color: #0D47A1;
    }

    .btn-primary {
      background-color: #0D47A1;
      border: none;
    }

    .btn-primary:hover {
      background-color: #08306b;
    }

    .btn-secondary {
      background-color: #6c757d;
    }

    .btn-blue-dark {
      background-color: #0D47A1;
      color: white;
      border: none;
    }

    .btn-blue-dark:hover {
      background-color: #08306b;
      color: white;
    }

    .modal-header.bg-blue-dark {
      background-color: #0D47A1;
      color: white;
    }

    .modal-title {
      color: #0D47A1;
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

<!-- Sidebar -->
<div class="sidebar">
  <div class="logo">
    <i class="fas fa-moon"></i>
    <h2>DreamTales</h2>
  </div>
  <div class="menu">
    <a href="dashboard.jsp"><i class="fas fa-home"></i> Home</a>
    <a href="data-regis.jsp"><i class="fas fa-user-plus"></i> Data Register</a>
    <a href="inputBarang.jsp" class="active"><i class="fas fa-book"></i> Master Buku</a>
    <a href="tampil-transaksi.jsp"><i class="fas fa-history"></i>Transaksi</a>
    <a href="logout.jsp"><i class="fas fa-sign-out-alt"></i>Logout</a>
  </div>
</div>

<!-- Main Content -->
<div class="main-content">
  <div class="container px-4 mx-auto">
    <h1 class="mb-4">Master Barang</h1>

    <% if ("true".equals(request.getParameter("success"))) { %>
    <div class="alert alert-success">Data barang berhasil disimpan!</div>
    <% } else if ("false".equals(request.getParameter("success"))) { %>
    <div class="alert alert-danger">Gagal menyimpan data barang.</div>
    <% } %>

    <div class="d-flex justify-content-end mb-3">
      <button class="btn btn-blue-dark" data-bs-toggle="modal" data-bs-target="#modalTambahBarang">
        <i class="fas fa-plus"></i>
      </button>
    </div>

    <div class="card">
      <div style="overflow-x: auto;">
        <table class="table table-bordered table-striped mb-0">
          <thead>
            <tr>
              <th class="text-center">No</th>
              <th class="text-center">Nama Barang</th>
              <th class="text-center">Gambar</th>
              <th class="text-center">Quantity</th>
              <th class="text-center">Harga</th>
              <th class="text-center">Aksi</th>
            </tr>
          </thead>
          <tbody>
            <%
              int no = 1;
              try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM barang");
                while (rs.next()) {
            %>
            <tr>
              <td class="text-center align-middle"><%= no++ %></td>
              <td class="text-center align-middle"><%= rs.getString("nama_barang") %></td>
              <td class="text-center align-middle">
                <img src="uploads/<%= rs.getString("gambar") %>" alt="Gambar Barang" width="60" height="60" style="object-fit:cover;" />
              </td>
              <td class="text-center align-middle"><%= rs.getInt("quantity") %></td>
              <td class="text-center align-middle"><%= String.format("Rp%,.2f", rs.getDouble("harga")) %></td>
              <td class="text-center align-middle">
                <!-- Tombol Edit tanpa ikon -->
                <button class="btn btn-warning btn-sm" data-bs-toggle="modal" data-bs-target="#editModal"
                        data-id="<%= rs.getInt("id") %>"
                        data-nama="<%= rs.getString("nama_barang") %>"
                        data-quantity="<%= rs.getInt("quantity") %>"
                        data-harga="<%= rs.getDouble("harga") %>"
                        data-gambar="<%= rs.getString("gambar") %>">
                  Edit
                </button>

                <!-- Tombol Delete tanpa ikon -->
                <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#deleteModal"
                        data-id="<%= rs.getInt("id") %>" data-nama="<%= rs.getString("nama_barang") %>">
                  Hapus
                </button>
              </td>
            </tr>
            <% }
              conn.close();
            } catch (Exception e) {
              out.println("<tr><td colspan='6' class='text-center text-danger'>Error: " + e.getMessage() + "</td></tr>");
            } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<!-- Modal Tambah Barang -->
<div class="modal fade" id="modalTambahBarang" tabindex="-1" aria-labelledby="modalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <form action="UploadBarangServlet" method="post" enctype="multipart/form-data">
        <div class="modal-header bg-blue-dark text-white">
          <h5 class="modal-title" id="modalLabel">Tambah Barang</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Tutup"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label for="namaBarang" class="form-label">Nama Barang</label>
            <input type="text" class="form-control" id="namaBarang" name="namaBarang"/>
          </div>
          <div class="mb-3">
            <label for="gambar" class="form-label">Upload Gambar</label>
            <input type="file" class="form-control" id="gambar" name="gambar" accept="image/*" required />
          </div>
          <div class="mb-3">
            <label for="quantity" class="form-label">Quantity</label>
            <input type="number" class="form-control" id="quantity" name="quantity" min="1"/>
          </div>
          <div class="mb-3">
            <label for="harga" class="form-label">Harga</label>
            <input type="number" step="0.01" class="form-control" id="harga" name="harga" min="0"/>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
          <button type="submit" class="btn btn-blue-dark">Simpan Barang</button>
        </div>
      </form>
    </div>
  </div>
</div>


<!-- Modal Edit Barang -->
<div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <form action="EditBarangServlet" method="post" enctype="multipart/form-data" class="modal-content">
      <div class="modal-header bg-warning text-dark">
        <h5 class="modal-title" id="editModalLabel">Edit Barang</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Tutup"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="edit-id" name="id" />
        <div class="mb-3">
          <label for="edit-namaBarang" class="form-label">Nama Barang</label>
          <input type="text" class="form-control" id="edit-namaBarang" name="namaBarang" required />
        </div>
        <div class="mb-3">
          <label for="edit-gambarLama" class="form-label">Gambar Saat Ini</label><br />
          <img id="edit-gambarLama" src="" alt="Gambar Lama" width="120" style="border-radius:8px; object-fit:cover;" />
          <input type="hidden" id="edit-gambarLama-value" name="gambarLama" />
        </div>
        <div class="mb-3">
          <label for="edit-gambar" class="form-label">Ganti Gambar</label>
          <input type="file" class="form-control" id="edit-gambar" name="gambar" accept="image/*" />
          <small class="text-muted">Kosongkan jika tidak ingin mengganti gambar.</small>
        </div>
        <div class="mb-3">
          <label for="edit-quantity" class="form-label">Quantity</label>
          <input type="number" class="form-control" id="edit-quantity" name="quantity" min="1" required />
        </div>
        <div class="mb-3">
          <label for="edit-harga" class="form-label">Harga</label>
          <input type="number" step="0.01" class="form-control" id="edit-harga" name="harga" min="0" required />
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
        <button type="submit" class="btn btn-warning">Simpan Perubahan</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal Delete Barang -->
<div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form action="DeleteBarangServlet" method="post" class="modal-content">
      <div class="modal-header bg-dark text-white">
        <h5 class="modal-title" id="deleteModalLabel">Konfirmasi Hapus</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Tutup"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="delete-id" name="id" />
        <p>Apakah Anda yakin ingin menghapus <strong id="delete-nama"></strong>?</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
        <button type="submit" class="btn btn-dark">Hapus</button>
      </div>
    </form>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  var editModal = document.getElementById('editModal');
  editModal.addEventListener('show.bs.modal', function (event) {
    var button = event.relatedTarget;
    document.getElementById('edit-id').value = button.getAttribute('data-id');
    document.getElementById('edit-namaBarang').value = button.getAttribute('data-nama');
    document.getElementById('edit-quantity').value = button.getAttribute('data-quantity');
    document.getElementById('edit-harga').value = button.getAttribute('data-harga');
    var gambar = button.getAttribute('data-gambar');
    document.getElementById('edit-gambarLama').src = 'uploads/' + gambar;
    document.getElementById('edit-gambarLama-value').value = gambar;
  });

  var deleteModal = document.getElementById('deleteModal');
  deleteModal.addEventListener('show.bs.modal', function (event) {
    var button = event.relatedTarget;
    document.getElementById('delete-id').value = button.getAttribute('data-id');
    document.getElementById('delete-nama').textContent = button.getAttribute('data-nama');
  });
</script>

</body>
</html>
