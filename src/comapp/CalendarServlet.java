package comapp;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;

import comapp.business.CalendarService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/api/calendar/*")
public class CalendarServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger log = LogManager.getLogger(CalendarServlet.class);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        setCorsAndContentType(response);
        String trackId = "GET_CALENDAR_" + System.currentTimeMillis();

        try {
            String pathInfo = request.getPathInfo();
            boolean isServiceHours = "/serviceHours".equals(pathInfo);
            
            JSONArray data = CalendarService.getAllRows(trackId, isServiceHours);

            PrintWriter out = response.getWriter();
            out.print(data.toString());
            out.flush();
        } catch (Exception e) {
            log.error(trackId + " Error occurred during GET operation:", e);
            response.setStatus(500);
            response.getWriter().print("[]");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        setCorsAndContentType(response);
        String trackId = "SAVE_CALENDAR_" + System.currentTimeMillis();
        JSONObject responseJson = new JSONObject();

        try {
            String pathInfo = request.getPathInfo();
            boolean isServiceHours = "/serviceHours".equals(pathInfo);

            String requestBody = request.getReader().lines().collect(Collectors.joining(System.lineSeparator()));
            JSONObject rowData = new JSONObject(requestBody);
            
            boolean success = CalendarService.saveRow(trackId, isServiceHours, rowData);
            
            responseJson.put("success", success);
            responseJson.put("message", success ? "Save successful." : "Error occurred during save. (Please check the logs)");
        } catch (Exception e) {
            log.error(trackId + " Error occurred during POST operation:", e);
            responseJson.put("success", false);
            responseJson.put("message", "Server error: " + e.getMessage());
        }

        PrintWriter out = response.getWriter();
        out.print(responseJson.toString());
        out.flush();
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        setCorsAndContentType(response);
        String trackId = "DELETE_CALENDAR_" + System.currentTimeMillis();
        JSONObject responseJson = new JSONObject();

        try {
            String pathInfo = request.getPathInfo();
            boolean isServiceHours = "/serviceHours".equals(pathInfo);
            String rowKey = request.getParameter("key");

            if (rowKey != null && !rowKey.isEmpty()) {
                boolean success;
                if (isServiceHours) {
                    success = CalendarService.deleteCalendarWithSpecialDays(trackId, rowKey);
                } else {
                    success = CalendarService.deleteRow(trackId, isServiceHours, rowKey);
                }
                responseJson.put("success", success);
                responseJson.put("message", success ? "Delete successful." : "Error occurred during delete.");
            } else {
                responseJson.put("success", false);
                responseJson.put("message", "Key to be deleted was not specified.");
            }
        } catch (Exception e) {
            log.error(trackId + " Error occurred during DELETE operation:", e);
            responseJson.put("success", false);
            responseJson.put("message", "Server error: " + e.getMessage());
        }

        PrintWriter out = response.getWriter();
        out.print(responseJson.toString());
        out.flush();
    }

    private void setCorsAndContentType(HttpServletResponse response) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, DELETE, PUT, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
    }

    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        setCorsAndContentType(response);
        response.setStatus(HttpServletResponse.SC_OK);
    }
}