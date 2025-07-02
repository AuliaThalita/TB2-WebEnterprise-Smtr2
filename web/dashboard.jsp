<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null) {
        response.sendRedirect("login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
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
            width: 180px;
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

        .main {
            margin-left: 200px;
            padding: 50px;
        }

        .content {
            max-width: 800px;
        }

        h2 {
            font-size: 24px;
            margin-top: 0;
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
        <a href="dashboard.jsp" class="active"><i class="fas fa-home"></i>Home</a>
        <a href="data-regis.jsp"><i class="fas fa-user-plus"></i>Data Register</a>
        <a href="inputBarang.jsp"><i class="fas fa-book"></i>Master Buku</a>
        <a href="tampil-transaksi.jsp"><i class="fas fa-history"></i>Transaksi</a>
        <a href="logout.jsp"><i class="fas fa-sign-out-alt"></i>Logout</a>
    </div>
</div>
</body>
</html>
