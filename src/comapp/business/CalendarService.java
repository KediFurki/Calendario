package comapp.business;

import java.util.Properties;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;

import comapp.ConfigServlet;
import comapp.cloud.Genesys;
import comapp.cloud.GenesysUser;

public class CalendarService {

    private static final Logger log = LogManager.getLogger(CalendarService.class);

    private static String cachedServiceHoursTableId = null;
    private static String cachedSpecialDaysTableId = null;

    private static GenesysUser getGenesysUser(String trackId) {
        Properties props = ConfigServlet.getProperties();
        if (props == null) return null;
        
        String clientId = props.getProperty("clientId", "").trim();
        String clientSecret = props.getProperty("clientSecret", "").trim();
        String urlRegion = props.getProperty("urlRegion", "").trim();
        
        return new GenesysUser(trackId, clientId, clientSecret, urlRegion);
    }

    private static boolean isUuid(String s) {
        return s != null && s.matches("[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}");
    }

    private static String getTableIdByName(String trackId, GenesysUser guser, String tableName, boolean isServiceHours) {
        if (isServiceHours && cachedServiceHoursTableId != null) return cachedServiceHoursTableId;
        if (!isServiceHours && cachedSpecialDaysTableId != null) return cachedSpecialDaysTableId;
        if (isUuid(tableName)) {
            log.info(trackId + " Using table UUID directly: " + tableName);
            if (isServiceHours) cachedServiceHoursTableId = tableName;
            else cachedSpecialDaysTableId = tableName;
            return tableName;
        }
        try {
            JSONArray dataTables = Genesys.getAllDataTable(trackId, guser, tableName, null);
            if (dataTables != null && dataTables.length() > 0) {
                for (int i = 0; i < dataTables.length(); i++) {
                    JSONObject table = dataTables.getJSONObject(i);
                    if (tableName.equalsIgnoreCase(table.optString("name"))) {
                        String id = table.optString("id");
                        if (isServiceHours) cachedServiceHoursTableId = id;
                        else cachedSpecialDaysTableId = id;
                        return id;
                    }
                }
            }
        } catch (Exception e) {
            log.error(trackId + " Error occurred while finding Data Table ID: " + tableName, e);
        }
        return null;
    }

    public static JSONArray getAllRows(String trackId, boolean isServiceHours) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            Properties props = ConfigServlet.getProperties();
            
            if (guser == null || props == null) {
                log.error(trackId + " Properties file could not be read or is invalid!");
                return new JSONArray();
            }

            String tableName = isServiceHours ? props.getProperty("table.serviceHours") : props.getProperty("table.specialDays");
            String tableId = getTableIdByName(trackId, guser, tableName, isServiceHours);
            
            if (tableId == null) {
                log.warn(trackId + " Table ID not found: " + tableName);
                return new JSONArray();
            }

            return Genesys.getAllDatabaseRows(trackId, guser, tableId);
        } catch (Exception e) {
            log.error(trackId + " getAllRows error", e);
            return new JSONArray();
        }
    }

    public static boolean saveRow(String trackId, boolean isServiceHours, JSONObject rowData) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            Properties props = ConfigServlet.getProperties();
            
            if (guser == null || props == null) {
                log.error(trackId + " Properties file could not be read!");
                return false;
            }

            String tableName = isServiceHours ? props.getProperty("table.serviceHours") : props.getProperty("table.specialDays");
            String tableId = getTableIdByName(trackId, guser, tableName, isServiceHours);
            
            if (tableId == null) {
                log.error(trackId + " Table ID not found: " + tableName);
                return false;
            }

            return Genesys.upsertDatabaseRow(trackId, guser, tableId, rowData);
        } catch (Exception e) {
            log.error(trackId + " Error occurred while saving row. Table isServiceHours=" + isServiceHours, e);
            return false;
        }
    }

    public static boolean deleteRow(String trackId, boolean isServiceHours, String rowKey) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            Properties props = ConfigServlet.getProperties();
            
            if (guser == null || props == null) return false;

            String tableName = isServiceHours ? props.getProperty("table.serviceHours") : props.getProperty("table.specialDays");
            String tableId = getTableIdByName(trackId, guser, tableName, isServiceHours);
            
            if (tableId == null) return false;

            return Genesys.deleteDatabaseRow(trackId, guser, tableId, rowKey);
        } catch (Exception e) {
            log.error(trackId + " Error occurred while deleting row. Key: " + rowKey, e);
            return false;
        }
    }

    public static boolean deleteCalendarWithSpecialDays(String trackId, String calendarKey) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            Properties props = ConfigServlet.getProperties();
            
            if (guser == null || props == null) {
                log.error(trackId + " Properties file could not be read!");
                return false;
            }

            String specialDaysTableName = props.getProperty("table.specialDays");
            String specialDaysTableId = getTableIdByName(trackId, guser, specialDaysTableName, false);
            
            if (specialDaysTableId != null) {
                JSONArray allSpecialDays = Genesys.getAllDatabaseRows(trackId, guser, specialDaysTableId);
                if (allSpecialDays != null) {
                    for (int i = 0; i < allSpecialDays.length(); i++) {
                        JSONObject row = allSpecialDays.getJSONObject(i);
                        String key = row.optString("key", "");
                        if (key.startsWith(calendarKey + ".")) {
                            Genesys.deleteDatabaseRow(trackId, guser, specialDaysTableId, key);
                            log.info(trackId + " Deleted related special day: " + key);
                        }
                    }
                }
            }

            String serviceHoursTableName = props.getProperty("table.serviceHours");
            String serviceHoursTableId = getTableIdByName(trackId, guser, serviceHoursTableName, true);
            
            if (serviceHoursTableId == null) {
                log.error(trackId + " Service Hours Table ID not found!");
                return false;
            }

            return Genesys.deleteDatabaseRow(trackId, guser, serviceHoursTableId, calendarKey);
        } catch (Exception e) {
            log.error(trackId + " Error occurred while deleting calendar with special days. Key: " + calendarKey, e);
            return false;
        }
    }
}
