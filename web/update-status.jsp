<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% request.setCharacterEncoding("UTF-8"); %>

<%
    String transactionId = request.getParameter("id_transaksi");
    String newStatus = request.getParameter("status_pesanan");

    if (transactionId != null && !transactionId.isEmpty() &&
        newStatus != null && !newStatus.isEmpty()) {

        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dreamtales", "root", "");

            String sql = "UPDATE transaksi_db SET status_pesanan = ? WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newStatus);
            pstmt.setString(2, transactionId);

            int rowsAffected = pstmt.executeUpdate();

            if (rowsAffected > 0) {
                // Success: Redirect back to the transaction list with a success message
                response.sendRedirect("tampil-transaksi.jsp?statusUpdate=success&id=" + transactionId);
            } else {
                // No rows affected: Transaction ID might not exist
                response.sendRedirect("tampil-transaksi.jsp?statusUpdate=notFound&id=" + transactionId);
            }

        } catch (SQLException e) {
            // Database error
            response.sendRedirect("tampil-transaksi.jsp?statusUpdate=error&message=" + e.getMessage());
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            // JDBC Driver error
            response.sendRedirect("tampil-transaksi.jsp?statusUpdate=error&message=JDBC Driver not found");
            e.printStackTrace();
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    } else {
        // Invalid parameters
        response.sendRedirect("tampil-transaksi.jsp?statusUpdate=invalidParams");
    }
%>