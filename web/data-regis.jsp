<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  request.setCharacterEncoding("UTF-8");

  String editAction = request.getParameter("edit");
  String deleteAction = request.getParameter("delete");
  String id = request.getParameter("id");
  String name = request.getParameter("name");
  String email = request.getParameter("email");

  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");

    if ("true".equals(deleteAction) && id != null) {
      // Cek role di DB sebelum hapus
      PreparedStatement psCheck = conn.prepareStatement("SELECT role FROM users WHERE id=?");
      psCheck.setString(1, id);
      ResultSet rsCheck = psCheck.executeQuery();
      if (rsCheck.next()) {
        String roleDb = rsCheck.getString("role");
        if (!"admin".equalsIgnoreCase(roleDb)) {
          out.println("<p class='text-danger'>Error: Anda tidak punya hak akses untuk menghapus data ini.</p>");
          rsCheck.close();
          psCheck.close();
          conn.close();
          return;
        }
      }
      rsCheck.close();
      psCheck.close();

      // Proses hapus data jika role admin
      PreparedStatement psDel = conn.prepareStatement("DELETE FROM users WHERE id=?");
      psDel.setString(1, id);
      psDel.executeUpdate();
      psDel.close();
      conn.close();
      response.sendRedirect("data-regis.jsp");
      return;
    }

    if ("true".equals(editAction) && id != null && name != null && email != null) {
      // Cek role di DB sebelum update
      PreparedStatement psCheck = conn.prepareStatement("SELECT role FROM users WHERE id=?");
      psCheck.setString(1, id);
      ResultSet rsCheck = psCheck.executeQuery();
      if (rsCheck.next()) {
        String roleDb = rsCheck.getString("role");
        if (!"admin".equalsIgnoreCase(roleDb)) {
          out.println("<p class='text-danger'>Error: Anda tidak punya hak akses untuk mengubah data ini.</p>");
          rsCheck.close();
          psCheck.close();
          conn.close();
          return;
        }
      }
      rsCheck.close();
      psCheck.close();

      // Proses update data jika role admin
      PreparedStatement psEdit = conn.prepareStatement("UPDATE users SET name=?, email=? WHERE id=?");
      psEdit.setString(1, name);
      psEdit.setString(2, email);
      psEdit.setString(3, id);
      psEdit.executeUpdate();
      psEdit.close();
      conn.close();
      response.sendRedirect("data-regis.jsp");
      return;
    }

    conn.close();
  } catch (Exception e) {
    out.println("<p class='text-danger'>Error: " + e.getMessage() + "</p>");
  }
%>

<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8" />
  <title>Data Register</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
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
    <a href="data-regis.jsp" class="active"><i class="fas fa-user-plus"></i> Data Register</a>
    <a href="inputBarang.jsp"><i class="fas fa-book"></i> Master Buku</a>
    <a href="tampil-transaksi.jsp"><i class="fas fa-history"></i> Transaksi</a>
    <a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Logout</a>
  </div>
</div>

<!-- Main Content -->
<div class="main-content">
  <div class="container px-4 mx-auto">
    <h1 class="mb-4">Data Register</h1>

    <div class="card">
      <div style="overflow-x: auto;">
        <table class="table table-bordered table-striped mb-0">
          <thead>
            <tr>
              <th class="text-center">No</th>
              <th class="text-center">Nama</th>
              <th class="text-center">Email</th>
              <th class="text-center">Role</th>
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
                ResultSet rs = stmt.executeQuery("SELECT * FROM users");
                while (rs.next()) {
                  String rowId = rs.getString("id");
                  String userRole = rs.getString("role");
            %>
            <tr>
              <td class="text-center align-middle"><%= no++ %></td>
              <td class="text-center align-middle"><%= rs.getString("name") %></td>
              <td class="text-center align-middle"><%= rs.getString("email") %></td>
              <td class="text-center align-middle"><%= userRole %></td>
              <td class="text-center align-middle">
                <% if ("admin".equalsIgnoreCase(userRole)) { %>
                  <a href="#"
                     class="btn btn-sm btn-warning"
                     data-bs-toggle="modal"
                     data-bs-target="#editModal"
                     data-id="<%= rowId %>"
                     data-name="<%= rs.getString("name") %>"
                     data-email="<%= rs.getString("email") %>"
                     data-role="<%= userRole %>">
                    Edit
                  </a>
                  <a href="data-regis.jsp?delete=true&id=<%= rowId %>" 
                     class="btn btn-sm btn-darkblue" 
                     onclick="return confirm('Yakin ingin menghapus data ini?')">
                    Hapus
                  </a>
                <% } else { %>
                  <span class="text-muted">Tidak dapat diedit</span>
                <% } %>
              </td>
            </tr>
            <%
                }
                conn.close();
              } catch (Exception e) {
                out.println("<tr><td colspan='6' class='text-center text-danger'>Error: " + e.getMessage() + "</td></tr>");
              }
            %>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<!-- Modal Edit -->
<div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form method="post" action="data-regis.jsp">
      <input type="hidden" name="edit" value="true">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="editModalLabel">Edit Data Register</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Tutup"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" name="id" id="edit-id" />
          <div class="mb-3">
            <label for="edit-nama" class="form-label">Nama</label>
            <input type="text" class="form-control" name="name" id="edit-nama" required />
          </div>
          <div class="mb-3">
            <label for="edit-email" class="form-label">Email</label>
            <input type="email" class="form-control" name="email" id="edit-email" required />
          </div>
        </div>
        <div class="modal-footer">
          <button type="submit" class="btn btn-primary">Simpan Perubahan</button>
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
        </div>
      </div>
    </form>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  const editModal = document.getElementById('editModal');
  editModal.addEventListener('show.bs.modal', function (event) {
    const button = event.relatedTarget;
    const id = button.getAttribute('data-id');
    const name = button.getAttribute('data-name');
    const email = button.getAttribute('data-email');

    document.getElementById('edit-id').value = id;
    document.getElementById('edit-nama').value = name;
    document.getElementById('edit-email').value = email;
  });
</script>

</body>
</html>
