<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8" />
  <title>Login DreamTales</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body class="d-flex justify-content-center align-items-center vh-100" style="background:#0D47A1;">
  <div class="card p-4" style="width:350px;">
    <h3 class="mb-4 text-center text-primary">Login DreamTales</h3>
    <% if (error != null) { %>
      <div class="alert alert-danger" role="alert">
        <%= error %>
      </div>
    <% } %>
    <form method="post" action="login.jsp">
      <div class="mb-3">
        <label for="email" class="form-label">Email</label>
        <input type="email" name="email" id="email" class="form-control" required />
      </div>
      <div class="mb-3">
        <label for="password" class="form-label">Password</label>
        <input type="password" name="password" id="password" class="form-control" required />
      </div>
      <button type="submit" class="btn btn-primary w-100">Login</button>
    </form>
  </div>
</body>
</html>

<%
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");

      PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE email = ? AND password = ?");
      ps.setString(1, email);
      ps.setString(2, password);
      ResultSet rs = ps.executeQuery();

      if (rs.next()) {
        String role = rs.getString("role");
        // Simpan session login
        session.setAttribute("userEmail", email);
        session.setAttribute("userName", rs.getString("name"));
        session.setAttribute("userRole", role);
        session.setAttribute("userId", rs.getInt("id")); 

        if ("admin".equalsIgnoreCase(role)) {
          response.sendRedirect("dashboard.jsp");
        } else if ("user".equalsIgnoreCase(role)) {
          response.sendRedirect("home.jsp");
        } else {
          response.sendRedirect("login.jsp?error=Role tidak dikenali.");
        }
      } else {
        response.sendRedirect("login.jsp?error=Email atau password salah.");
      }
      rs.close();
      ps.close();
      conn.close();
    } catch (Exception e) {
      out.println("<p class='text-danger'>Error: " + e.getMessage() + "</p>");
    }
  }
%>
