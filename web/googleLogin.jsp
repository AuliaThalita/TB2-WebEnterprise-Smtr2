<%@ page import="java.io.*, java.net.*, org.json.*, java.util.*" %>
<%@ page import="javax.net.ssl.*, java.security.cert.X509Certificate, java.security.SecureRandom" %>
<%
    TrustManager[] trustAllCerts = new TrustManager[]{
        new X509TrustManager() {
            public java.security.cert.X509Certificate[] getAcceptedIssuers() { return null; }
            public void checkClientTrusted(X509Certificate[] certs, String authType) { }
            public void checkServerTrusted(X509Certificate[] certs, String authType) { }
        }
    };

    SSLContext sc = SSLContext.getInstance("SSL");
    sc.init(null, trustAllCerts, new SecureRandom());
    HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());

    HostnameVerifier allHostsValid = new HostnameVerifier() {
        public boolean verify(String hostname, SSLSession session) {
            return true;
        }
    };
    HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
%>

<%
    response.setContentType("application/json");  // set content-type jadi JSON

    String idToken = request.getParameter("id_token");
    if (idToken == null || idToken.isEmpty()) {
        out.print("{\"status\":\"error\",\"message\":\"Invalid token\"}");
        return;
    }

    try {
        URL url = new URL("https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken);
        HttpsURLConnection con = (HttpsURLConnection) url.openConnection();
        con.setRequestMethod("GET");

        BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
        String inputLine;
        StringBuffer responseStr = new StringBuffer();
        while ((inputLine = in.readLine()) != null) {
            responseStr.append(inputLine);
        }
        in.close();

        JSONObject json = new JSONObject(responseStr.toString());
        String email = json.getString("email");
        String name = json.getString("name");

        // Simulasi logika redirect, misal user dengan email tertentu diarahkan ke dashboard, sisanya ke home
        String redirectTo = "home.jsp";
        if (email.endsWith("athasabhila04@gmail.com")) {  // contoh cek domain email admin
            redirectTo = "dashboard.jsp";
        }

        // Simpan session user
        session.setAttribute("userName", name);

        // Kirim response JSON sukses dengan info redirect
        JSONObject result = new JSONObject();
        result.put("status", "success");
        result.put("redirectTo", redirectTo);
        out.print(result.toString());

    } catch (Exception e) {
        JSONObject error = new JSONObject();
        error.put("status", "error");
        error.put("message", e.getMessage());
        out.print(error.toString());
    }
%>
