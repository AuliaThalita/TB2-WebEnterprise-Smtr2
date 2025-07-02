<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String nama = request.getParameter("name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String role = request.getParameter("role");

    if (nama != null && email != null && password != null && role != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");  // Update driver baru
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");

            String sql = "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, nama);
            ps.setString(2, email);
            ps.setString(3, password);  // Saran: hash password dulu
            ps.setString(4, role);

            ps.executeUpdate();

            // Tutup koneksi dan statement
            ps.close();
            conn.close();

            // Redirect ke halaman login setelah berhasil daftar
            response.sendRedirect("login.html");
            return;

        } catch (Exception e) {
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terjadi Kesalahan</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f3e6f5;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        .header {
            text-align: center;
            color: #e74c3c;
        }
        .message {
            font-size: 18px;
            color: #6a4f98;
            text-align: center;
            margin: 20px 0;
        }
        .button {
            display: block;
            width: 200px;
            margin: 0 auto;
            padding: 10px;
            background-color: #e74c3c;
            color: white;
            border: none;
            border-radius: 5px;
            text-align: center;
            text-decoration: none;
            font-size: 16px;
        }
        .button:hover {
            background-color: #c0392b;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1>Terjadi Kesalahan</h1>
    </div>
    <div class="message">
        <p>Maaf, terjadi kesalahan saat proses registrasi. Silakan coba lagi nanti.</p>
        <p>Error: <%= e.getMessage() %></p>
    </div>
    <a href="login.html" class="button">Kembali ke Halaman Login</a>
</div>

</body>
</html>
<%
        }
    }
%>
