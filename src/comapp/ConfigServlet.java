package comapp;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.util.Objects;
import java.util.Properties;

import javax.naming.InitialContext;
import javax.naming.NamingException;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.Level;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.core.LoggerContext;

import comapp.cloud.GenesysUser;
import comapp.cloud.TrackId;

import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebInitParam;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;

@WebServlet(urlPatterns = "/ConfigServlet", loadOnStartup = 100, asyncSupported = false, initParams = { @WebInitParam(name = "config-properties-location", value = "C:/Comapp/Config") })
public class ConfigServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    public static String version = "1.0.0-Calendario";
    public static String ConfigLocation;
    
    public static GenesysUser globalGenesysUser;
    public static String TABLE_WEEKLY_ID;
    public static String TABLE_SPECIAL_ID;

    public static Logger log = LogManager.getLogger("comapp");
    public static String web_app;

    public ConfigServlet() {
        super();
    }

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        final ServletContext sc = config.getServletContext();

        try (InputStream manifestStream = sc.getResourceAsStream("/META-INF/MANIFEST.MF")) {
            if (manifestStream != null) {
                Properties manifestProps = new Properties();
                manifestProps.load(manifestStream);
                String _version = manifestProps.getProperty("Implementation-Version");
                if (StringUtils.isNotBlank(_version)) {
                    version = _version.trim();
                }
            }
        } catch (Exception e) {
            LogManager.getLogger(getClass()).debug("MANIFEST read failed", e);
        }

        try {
            ConfigLocation = resolveConfigLocationViaJndi("java:comp/env/url/comapp.calendario.properties");
        } catch (Exception jndiEx) {
            String baseDir = config.getInitParameter("config-properties-location");
            String fileName = "Calendario.properties"; 
            ConfigLocation = baseDir + "/" + fileName;
        }

        web_app = (sc.getContextPath() != null ? sc.getContextPath().replaceAll("/", "") : "comapp");

        try {
            try {
                File configFile = toFile(ConfigLocation);
                File logFile = new File(configFile.getParent(), "Calendario.xml");
                
                if (logFile.exists()) {
                    LoggerContext context = (LoggerContext) LogManager.getContext(false);
                    context.setConfigLocation(logFile.toURI());
                }
            } catch (Exception ignore) {}

            log = LogManager.getLogger(getClass());
            log.info("\n================ CALENDARIO STARTING (v" + version + ") ================\n");
            log.info("Config File: " + ConfigLocation);
            Properties prop = getProperties();
            if (prop == null) {
                throw new IllegalStateException("Config file not found: " + ConfigLocation);
            }

            String clientId = prop.getProperty("genesys.clientId", "").trim();
            String clientSecret = prop.getProperty("genesys.clientSecret", "").trim();
            String urlRegion = prop.getProperty("genesys.region", "mypurecloud.ie").trim();

            TABLE_WEEKLY_ID = prop.getProperty("table.weekly.id", "").trim();
            TABLE_SPECIAL_ID = prop.getProperty("table.special.id", "").trim();

            if (clientId.isEmpty() || clientSecret.isEmpty()) {
                log.warn("WARNING: Genesys credentials (clientId/Secret) are missing!");
            } else {
                TrackId trackId = new TrackId("SystemStartup");
                globalGenesysUser = new GenesysUser(trackId.toString(), clientId, clientSecret, urlRegion);
                log.info("Genesys connection ready. Region: " + urlRegion);
                log.info("Tables -> Weekly: " + TABLE_WEEKLY_ID + " | Special: " + TABLE_SPECIAL_ID);
            }

        } catch (Exception e) {
            log.log(Level.ERROR, "Critical error while starting ConfigServlet", e);
        }
    }

    @Override
    public void destroy() {
        if(log != null) {
            log.info("\n================ CALENDARIO STOPPING ================\n");
        }
        super.destroy();
    }

    public static Properties getProperties() {
        try {
            File file = toFile(ConfigLocation);
            if (!file.exists()) return null;

            try (FileInputStream fis = new FileInputStream(file)) {
                Properties props = new Properties();
                props.load(fis);
                return props;
            }
        } catch (Exception e) {
            log.error("Error loading properties", e);
            return null;
        }
    }

    public static void saveProperties(String key, String value) {
        Objects.requireNonNull(key, "key cannot be null");
        Objects.requireNonNull(value, "value cannot be null");

        try {
            Properties cs = getProperties();
            if (cs == null) return;
            cs.setProperty(key, value);

            File file = toFile(ConfigLocation);
            try (FileOutputStream os = new FileOutputStream(file)) {
                cs.store(os, null);
            }
        } catch (Exception e) {
            log.warn("Error saving settings: " + key, e);
        }
    }

    public static void stop() {
        try {
            Logger l = LogManager.getLogger(ConfigServlet.class);
            l.info("Stopping comapp via stop()");
        } catch (Exception e) {
            LogManager.getLogger(ConfigServlet.class).warn("Error on stop()", e);
        }
    }

    private static String resolveConfigLocationViaJndi(String jndiName) throws NamingException {
        InitialContext ctx = new InitialContext();
        URL url = (URL) ctx.lookup(jndiName);
        return url.toString();
    }

    private static File toFile(String location) {
        try {
            return new File(new URI(location));
        } catch (Exception e) {
            return new File(location);
        }
    }
}