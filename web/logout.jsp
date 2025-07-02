<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    session.invalidate(); // Menghapus sesi
    response.sendRedirect("login.html"); // Redirect ke halaman login
%>
