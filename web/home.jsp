<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null) {
        response.sendRedirect("login.html");
        return;
    }

    // Hitung total quantity di keranjang session
    Map<Integer, Integer> keranjang = (Map<Integer, Integer>) session.getAttribute("keranjang");
    int totalQty = 0;
    if (keranjang != null) {
        for (int qty : keranjang.values()) {
            totalQty += qty;
        }
    }

    // Declare variables for user data
    String userEmail = "";
    String userDisplayName = ""; // Mengubah nama variabel agar lebih sesuai dengan 'name' di DB

    Connection connUser = null;
    PreparedStatement pstmtUser = null;
    ResultSet rsUser = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        connUser = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");
        // Fetch user details from the 'users' table
        // Menggunakan kolom 'name' dari database sebagai username/display name
        String sqlUser = "SELECT name, email FROM users WHERE name = ?"; // Mengambil 'name' dan 'email'
        pstmtUser = connUser.prepareStatement(sqlUser);
        pstmtUser.setString(1, userName); // Menggunakan userName dari session (yang seharusnya adalah nilai dari kolom 'name' saat login)
        rsUser = pstmtUser.executeQuery();

        if (rsUser.next()) {
            userEmail = rsUser.getString("email");
            userDisplayName = rsUser.getString("name"); // Menggunakan kolom 'name' sebagai nama tampilan
        }

    } catch (Exception e) {
        // Handle exceptions (e.g., log them, display a user-friendly message)
        e.printStackTrace(); // For debugging
    } finally {
        // Close resources for user data fetch
        if (rsUser != null) try { rsUser.close(); } catch (SQLException ignore) {}
        if (pstmtUser != null) try { pstmtUser.close(); } catch (SQLException ignore) {}
        if (connUser != null) try { connUser.close(); } catch (SQLException ignore) {}
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8" />
  <title>DreamTales - Beranda</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
  <style>
    /* ... (CSS Anda sebelumnya, tidak ada perubahan di sini kecuali yang sudah saya tambahkan untuk dropdown) ... */

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
      position: relative; /* Tambahkan ini untuk posisi dropdown */
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
    .user-account-container { /* Kontainer baru untuk user account dan dropdown */
        position: relative;
        margin-right: 50px;
    }
    .top-navbar .user-account {
        display: flex;
        align-items: center;
        gap: 8px;
        color: var(--white); /* White text for user account */
        font-weight: 500;
        font-size: 16px;
        cursor: pointer; /* Make it clickable */
        padding: 5px 10px; /* Tambahkan padding agar clickable area lebih besar */
        border-radius: 5px;
        transition: background-color 0.2s ease;
    }
    .top-navbar .user-account:hover {
        background-color: rgba(255, 255, 255, 0.1);
    }
    .top-navbar .user-account i {
        font-size: 18px;
        color: var(--accent-yellow); /* Yellow for user icon */
    }

    /* User Dropdown */
    .user-dropdown {
        position: absolute;
        top: 100%; /* Muncul di bawah user-account */
        right: 0; /* Sejajar dengan sisi kanan user-account */
        background-color: var(--white);
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        padding: 15px;
        min-width: 200px;
        z-index: 1001;
        opacity: 0;
        visibility: hidden;
        transform: translateY(10px);
        transition: opacity 0.3s ease, transform 0.3s ease, visibility 0.3s ease;
    }
    .user-dropdown.show {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
    }
    .user-dropdown p {
        margin-bottom: 8px;
        font-size: 15px;
        color: var(--text-dark);
    }
    .user-dropdown p strong {
        color: var(--primary-blue);
    }
    .user-dropdown .dropdown-divider {
        border-top: 1px solid #eee;
        margin: 10px 0;
    }
    .user-dropdown .btn-logout {
        display: block; /* Agar tombol mengisi lebar dropdown */
        width: 100%;
        background-color: var(--red-badge);
        color: var(--white);
        border: none;
        padding: 8px 15px;
        border-radius: 5px;
        text-align: center;
        font-size: 14px;
        transition: background-color 0.2s ease;
        text-decoration: none; /* Hapus underline default dari link */
    }
    .user-dropdown .btn-logout:hover {
        background-color: #c82333;
    }


    /* Hero Section */
    .hero-section {
      background-image: url('https://via.placeholder.com/1500x300/002D62/FFD700?text=DreamTales+Books'); /* Updated placeholder with blue background, yellow text */
      background-size: cover;
      background-position: center;
      padding: 80px 20px;
      text-align: center;
      color: var(--white);
      position: relative;
    }
    .hero-section::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background-color: rgba(0,0,0,0.5); /* Slightly darker overlay for contrast */
      z-index: 1;
    }
    .hero-content {
      position: relative;
      z-index: 2;
    }
    .hero-content h1 {
      font-size: 38px;
      margin-bottom: 15px;
      font-weight: 700;
    }
    .hero-content p {
      font-size: 18px;
      margin-bottom: 30px;
    }
    .search-bar-container {
      display: flex;
      justify-content: center;
      gap: 10px;
    }
    .search-bar-container .form-select,
    .search-bar-container .form-control {
      border-radius: 5px;
      padding: 10px 15px;
      border: 1px solid #ccc;
      font-size: 16px;
    }
    .search-bar-container .form-select {
        width: 150px;
    }
    .search-bar-container .form-control {
        flex-grow: 1;
        max-width: 400px;
    }
    .search-bar-container .btn-search {
      background-color: var(--accent-yellow); /* Yellow search button */
      color: var(--primary-blue); /* Dark blue text on search button */
      border: none;
      padding: 10px 20px;
      border-radius: 5px;
      cursor: pointer;
    }
    .search-bar-container .btn-search:hover {
      background-color: #e6c100; /* Slightly darker yellow on hover */
    }

    /* Main Content Sections */
    .main-content {
      padding: 40px 20px;
      max-width: 1200px;
      margin: 0 auto;
    }
    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 25px;
    }
    .section-header h2 {
      font-size: 28px;
      color: var(--primary-blue); /* Dark Blue for section headers */
      font-weight: 700;
    }
    .section-header a {
      color: var(--primary-blue); /* Dark Blue for "view all" links */
      text-decoration: none;
      font-weight: 500;
    }
    .book-card {
      border: 1px solid #e0e0e0;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
      transition: transform 0.2s ease-in-out;
      background-color: var(--white);
      overflow: hidden;
    }
    .book-card:hover {
      transform: translateY(-5px);
    }
    .book-card img {
      width: 100%;
      height: 220px;
      object-fit: cover;
      border-top-left-radius: 8px;
      border-top-right-radius: 8px;
    }
    .book-card .card-body {
      padding: 15px;
      display: flex;
      flex-direction: column;
      height: calc(100% - 220px);
    }
    .book-card .card-title {
      font-weight: 600;
      font-size: 17px;
      color: var(--text-dark);
      margin-bottom: 5px;
    }
    .book-card .card-author {
      font-size: 14px;
      color: var(--text-light);
      margin-bottom: 10px;
    }
    .book-card .card-price {
      font-weight: 700;
      color: var(--green-price);
      font-size: 18px;
      margin-top: auto;
    }
    .book-card .card-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 10px 15px;
        border-top: 1px solid #eee;
        background-color: #f9f9f9;
    }
    .book-card .card-footer .star-rating {
        color: var(--accent-yellow); /* Yellow for stars */
        font-size: 14px;
    }
    .book-card .card-footer .wishlist-icon i {
        color: #ccc;
        font-size: 18px;
        cursor: pointer;
    }
    .book-card .card-footer .wishlist-icon i.fas {
        color: var(--red-badge);
    }
    .book-card .card-footer .btn-beli {
      background-color: var(--accent-yellow); /* Yellow Buy button */
      color: var(--primary-blue); /* Dark blue text on Buy button */
      border: none;
      padding: 8px 15px;
      border-radius: 5px;
      font-size: 14px;
      cursor: pointer;
      transition: background-color 0.2s ease;
    }
    .book-card .card-footer .btn-beli:hover {
      background-color: #e6c100; /* Slightly darker yellow on hover */
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
      display: none;
      user-select: none;
    }

    /* Footer */
    .footer {
      background-color: var(--primary-blue); /* Dark Blue footer */
      color: var(--white);
      padding: 40px 20px;
      text-align: center;
      font-size: 14px;
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
        .user-account-container {
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
      .user-account-container { /* Sesuaikan untuk mobile */
        margin-right: 0;
        width: 100%; /* Ambil lebar penuh */
        display: flex; /* Untuk menengahkan */
        justify-content: center; /* Untuk menengahkan */
      }
      .top-navbar .user-account { /* Sesuaikan juga untuk mobile */
        width: fit-content;
      }
      .user-dropdown {
        position: static; /* Hilangkan posisi absolut di mobile agar tidak overlay */
        width: 90%; /* Lebar dropdown di mobile */
        margin: 10px auto 0; /* Tengah dan beri jarak */
        transform: translateY(0); /* Reset transform */
        border-top: 1px solid #eee; /* Tambahkan garis pemisah */
        box-shadow: none; /* Hapus shadow */
      }
      .hero-content h1 {
        font-size: 30px;
      }
      .hero-content p {
        font-size: 16px;
      }
      .search-bar-container {
        flex-direction: column;
        align-items: center;
      }
      .search-bar-container .form-select,
      .search-bar-container .form-control,
      .search-bar-container .btn-search {
        width: 90%;
        max-width: 300px;
      }
      .section-header {
        flex-direction: column;
        align-items: flex-start;
      }
      .section-header h2 {
        margin-bottom: 10px;
      }
      .book-card img {
        height: 180px;
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
    <a href="home.jsp" class="active">Beranda</a>
    <a href="keranjang.jsp" id="keranjang-link">
      Keranjang
      <span id="keranjang-count"><%= totalQty %></span>
    </a>
    <a href="pesanan.jsp">Pesanan</a>
  </div>
  <div class="user-account-container">
    <div class="user-account" id="userAccountToggle">
      <i class="fas fa-user"></i> <%= userName %> <i class="fas fa-caret-down"></i>
    </div>
    <div class="user-dropdown" id="userDropdown">
      <p><strong>Username:</strong> <%= userName %></p>
      <p><strong>Nama Lengkap:</strong> <%= userDisplayName %></p> <p><strong>Email:</strong> <%= userEmail %></p>
      <div class="dropdown-divider"></div>
      <a href="logout.jsp" class="btn btn-logout">Logout</a>
    </div>
  </div>
</div>

<div class="hero-section">
  <div class="hero-content">
    <h1>Baca buku dimana saja, kapan saja.</h1>
    <p>Kini hadir e-book gratis yang lebih mudah diakses</p>
    <div class="search-bar-container">
      <input type="text" class="form-control" placeholder="Cari buku..." />
      <button class="btn btn-search"><i class="fas fa-search"></i></button>
    </div>
  </div>
</div>

<div class="main-content">
  <div class="container">
    <div class="section-header">
        <h2>Sedang banyak dibaca</h2>
    </div>
    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-4 g-4 mb-5">
      <%
        try {
          Class.forName("com.mysql.cj.jdbc.Driver");
          Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");
          Statement stmt = conn.createStatement();
          ResultSet rs = stmt.executeQuery("SELECT * FROM barang ORDER BY id DESC LIMIT 8"); // Increased limit to show more items

          while (rs.next()) {
      %>
        <div class="col">
          <div class="card book-card h-100">
            <img src="uploads/<%= rs.getString("gambar") %>" class="card-img-top" alt="Gambar Barang" />
            <div class="card-body">
              <h5 class="card-title"><%= rs.getString("nama_barang") %></h5>
              <p class="card-author">Deskripsi</p>
              <p class="card-price">Rp <%= String.format("%,.2f", rs.getDouble("harga")) %></p>
            </div>
            <div class="card-footer">
                <button class="btn btn-beli" data-id="<%= rs.getInt("id") %>">Beli <i class="fas fa-shopping-cart"></i></button>
            </div>
          </div>
        </div>
      <%
          }
          conn.close();
        } catch (Exception e) {
      %>
        <div class="alert alert-danger">Gagal memuat data: <%= e.getMessage() %></div>
      <%
        }
      %>
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

  // Set initial count dari server
  updateKeranjangCount(<%= totalQty %>);

  // Event listener for all "Beli" buttons
  document.querySelectorAll('.btn-beli').forEach(button => {
    button.addEventListener('click', function() {
      const idBarang = this.getAttribute('data-id');

      fetch('addToCart.jsp?id_barang=' + idBarang, { method: 'GET' })
        .then(response => response.json())
        .then(data => {
          if (data.success) {
            alert('Berhasil tambah ke keranjang! Jumlah sekarang: ' + data.qty);
            updateKeranjangCount(data.totalCartQty); // Use the totalCartQty returned from the server
          } else {
            alert('Gagal tambah ke keranjang: ' + data.message);
          }
        })
        .catch(error => {
          alert('Error saat tambah ke keranjang.');
          console.error(error);
        });
    });
  });

  // JavaScript untuk dropdown info user
  const userAccountToggle = document.getElementById('userAccountToggle');
  const userDropdown = document.getElementById('userDropdown');
  const userAccountContainer = document.querySelector('.user-account-container');

  userAccountToggle.addEventListener('click', function(event) {
    userDropdown.classList.toggle('show');
    event.stopPropagation(); // Mencegah event klik menyebar ke document
  });

  // Tutup dropdown jika klik di luar area dropdown
  document.addEventListener('click', function(event) {
    if (!userAccountContainer.contains(event.target)) {
      userDropdown.classList.remove('show');
    }
  });

</script>

</body>
</html>