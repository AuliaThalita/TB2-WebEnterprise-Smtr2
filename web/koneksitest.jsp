<%@ page import="java.sql.*" %>
<%
    String url = "jdbc:mysql://localhost:3306/dreamtales";
    String user = "root";
    String pass = ""; // password MySQL kamu

    Connection conn = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, pass);
        out.println("Koneksi ke database BERHASIL!");
    } catch(Exception e) {
        out.println("Koneksi GAGAL: " + e.getMessage());
    }
%>
