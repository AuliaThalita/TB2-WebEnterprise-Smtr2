<%@ page import="java.sql.*" %>
<%
    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");
        application.setAttribute("koneksi", conn);
    } catch(Exception e) {
        out.println("Koneksi Gagal: " + e.getMessage());
    }
%>