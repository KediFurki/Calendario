package comapp.logic;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.List;

import org.json.JSONObject;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import comapp.ConfigServlet;
import comapp.cloud.Genesys;
import comapp.cloud.TrackId;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/api/engine")
public class CalendarEngine extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger log = LogManager.getLogger(CalendarEngine.class);

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        TrackId trackId = new TrackId("READ-" + System.currentTimeMillis());
        
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject result = new JSONObject();

        String key = request.getParameter("key");
        
        try {
            log.info(trackId + " >>> READ REQUEST STARTED. Key: " + key);

            if (key == null || key.trim().isEmpty()) {
                throw new Exception("Key parameter is missing!");
            }

            String tableId = ConfigServlet.TABLE_WEEKLY_ID;
            
            log.info(trackId + " Reading Genesys Data Table... ID: " + tableId);
            
            JSONObject row = Genesys.getDatabaseRowById(
                trackId.toString(), 
                ConfigServlet.globalGenesysUser, 
                tableId, 
                key
            );

            if (row != null) {
                log.info(trackId + " DATA FOUND: " + row.toString());
                result.put("status", "success");
                result.put("data", row);
            } else {
                log.warn(trackId + " Genesys data returned empty or not found.");
                result.put("status", "error");
                result.put("msg", "Data not found in Genesys");
            }

        } catch (Exception e) {
            log.error(trackId + " !!! CRITICAL ERROR !!!", e);
            result.put("status", "error");
            result.put("msg", e.getMessage());
        }

        out.print(result.toString());
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        TrackId trackId = new TrackId("WRITE-" + System.currentTimeMillis());
        
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject result = new JSONObject();

        try {
            log.info(trackId + " >>> WRITE REQUEST STARTED.");

            String key = request.getParameter("key");
            if (key == null || key.trim().isEmpty()) {
                throw new Exception("Key is required for saving!");
            }

            JSONObject dataToSend = new JSONObject();
            dataToSend.put("key", key);

            List<String> columns = Arrays.asList("mon", "tue", "wed", "thu", "fri", "sat", "sun", "msg");

            for (String col : columns) {
                String value = request.getParameter(col);
                dataToSend.put(col, value == null ? "" : value.trim());
            }

            log.info(trackId + " Payload ready to send to Genesys: " + dataToSend.toString());

            boolean success = Genesys.putDatabaseRow(
                trackId.toString(), 
                ConfigServlet.globalGenesysUser, 
                ConfigServlet.TABLE_WEEKLY_ID, 
                dataToSend
            );

            if (success) {
                log.info(trackId + " <<< OPERATION SUCCESSFUL: Data saved to Genesys.");
                result.put("status", "success");
                result.put("msg", "Changes saved to Genesys Cloud.");
            } else {
                log.error(trackId + " !!! ERROR: Genesys save operation failed.");
                result.put("status", "error");
                result.put("msg", "Genesys API returned failure.");
            }

        } catch (Exception e) {
            log.error(trackId + " !!! CRITICAL WRITE ERROR !!!", e);
            result.put("status", "error");
            result.put("msg", e.getMessage());
        }

        out.print(result.toString());
    }
}