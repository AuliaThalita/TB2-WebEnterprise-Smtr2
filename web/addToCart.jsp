<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="org.json.JSONObject" %> <%-- Import the JSONObject class --%>
<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%
    // Ensure the user is logged in
    String userName = (String) session.getAttribute("userName");
    if (userName == null) {
        response.sendRedirect("login.html");
        return;
    }

    // Get the product ID from the request
    int idBarang = 0;
    try {
        idBarang = Integer.parseInt(request.getParameter("id_barang"));
    } catch (NumberFormatException e) {
        // Handle invalid product ID
        JSONObject responseJson = new JSONObject(); // Use JSONObject
        responseJson.put("success", false);
        responseJson.put("message", "Invalid product ID.");
        out.print(responseJson.toString()); // Convert to string for output
        return;
    }

    // Get the cart from the session, or create a new one if it doesn't exist
    Map<Integer, Integer> keranjang = (Map<Integer, Integer>) session.getAttribute("keranjang");
    if (keranjang == null) {
        keranjang = new HashMap<>();
        session.setAttribute("keranjang", keranjang);
    }

    // Add or update the item in the cart
    int currentQty = keranjang.getOrDefault(idBarang, 0);
    keranjang.put(idBarang, currentQty + 1);

    // Calculate the new total quantity in the cart
    int totalCartQty = 0;
    for (int qty : keranjang.values()) {
        totalCartQty += qty;
    }

    // Prepare the JSON response using JSONObject
    JSONObject responseJson = new JSONObject(); // Use JSONObject
    responseJson.put("success", true);
    responseJson.put("qty", keranjang.get(idBarang)); // Quantity of the specific item
    responseJson.put("totalCartQty", totalCartQty); // Total quantity in the cart

    // Convert the JSONObject to a string and print it
    out.print(responseJson.toString());
%>