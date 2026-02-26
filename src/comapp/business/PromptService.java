package comapp.business;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;
import comapp.ConfigServlet;
import comapp.cloud.Genesys;
import comapp.cloud.GenesysUser;

public class PromptService {
    private static final Logger log = LogManager.getLogger(PromptService.class);
    private static List<JSONObject> cachedDnisConfigTables = null;

    public static GenesysUser getGenesysUser(String trackId) {
        Properties props = ConfigServlet.getProperties();
        if (props == null) return null;
        String clientId = props.getProperty("clientId", "").trim();
        String clientSecret = props.getProperty("clientSecret", "").trim();
        String urlRegion = props.getProperty("urlRegion", "").trim();
        return new GenesysUser(trackId, clientId, clientSecret, urlRegion);
    }

    private static List<JSONObject> getAllDnisConfigTables(String trackId, GenesysUser guser) {
        Properties props = ConfigServlet.getProperties();
        String tableIdConfig = props.getProperty("table.dnisConfig", "").trim();
        String tableName = props.getProperty("table.dnisConfigName", "BG_DnisConfig_Home").trim();
        List<JSONObject> found = new ArrayList<>();
        if (tableIdConfig.isEmpty()) {
            log.warn(trackId + " table.dnisConfig not configured in properties!");
            return found;
        }
        String[] ids = tableIdConfig.split(",");
        for (String rawId : ids) {
            String id = rawId.trim();
            if (!id.isEmpty()) {
                JSONObject t = new JSONObject();
                t.put("id", id);
                t.put("name", tableName);
                found.add(t);
                log.info(trackId + " Using DnisConfig table: " + tableName + " id=" + id);
            }
        }
        return found;
    }

    private static String getPrimaryDnisConfigTableId(String trackId, GenesysUser guser) {
        List<JSONObject> tables = getAllDnisConfigTables(trackId, guser);
        if (tables != null && !tables.isEmpty()) {
            return tables.get(0).optString("id");
        }
        return null;
    }

    public static JSONArray getDnisList(String trackId, String environmentPrefix) {
        JSONArray result = new JSONArray();
        try {
            JSONArray rows = getDnisConfigRows(trackId);
            LinkedHashSet<String> seenDnis = new LinkedHashSet<>();
            for (int i = 0; i < rows.length(); i++) {
                JSONObject row = rows.getJSONObject(i);
                String headPrompt = row.optString("HeadPrompt", "").trim();
                if (environmentPrefix != null && !environmentPrefix.isEmpty()
                        && !headPrompt.equals(environmentPrefix)) continue;
                String dnis = row.optString("Dnis", "").trim();
                if (dnis.isEmpty() || seenDnis.contains(dnis)) continue;
                seenDnis.add(dnis);
                JSONObject entry = new JSONObject();
                entry.put("dnis",          dnis);
                entry.put("calledAddress", row.optString("key",  ""));
                entry.put("abi",           row.optString("Abi",  ""));
                entry.put("environment",   headPrompt);
                result.put(entry);
            }
        } catch (Exception e) {
            log.error(trackId + " Error in getDnisList", e);
        }
        return result;
    }

    public static JSONArray getPromptsByEnvironmentAndDnis(String trackId, String environmentPrefix, String dnis) {
        JSONArray result = new JSONArray();
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) {
                log.error(trackId + " GenesysUser could not be created!");
                return result;
            }

            String filterPrefix = environmentPrefix + dnis + "_BG_";
            JSONArray allPrompts = Genesys.getAllPrompts(trackId, guser);
            if (allPrompts == null || allPrompts.length() == 0) {
                log.warn(trackId + " No prompts returned from Genesys Cloud");
                return result;
            }
            log.info(trackId + " Genesys prompts fetched (all): " + allPrompts.length() + ", filtering client-side with prefix: " + filterPrefix);
            String asrInfix = "_BG_A_";
            String tmfInfix = "_BG_D_";

            Map<String, JSONObject[]> grouped = new LinkedHashMap<>();
            for (int i = 0; i < allPrompts.length(); i++) {
                JSONObject p = allPrompts.getJSONObject(i);
                String name = p.optString("name", "").trim();
                if (!name.startsWith(filterPrefix)) continue;

                int asrIdx = name.indexOf(asrInfix);
                int tmfIdx = name.indexOf(tmfInfix);
                String baseName;
                boolean isAsr;
                if (asrIdx >= 0) {
                    baseName = name.substring(asrIdx + asrInfix.length());
                    isAsr = true;
                } else if (tmfIdx >= 0) {
                    baseName = name.substring(tmfIdx + tmfInfix.length());
                    isAsr = false;
                } else {
                    continue;
                }

                grouped.computeIfAbsent(baseName, k -> new JSONObject[2]);
                if (isAsr) grouped.get(baseName)[0] = p;
                else       grouped.get(baseName)[1] = p;
            }
            log.info(trackId + " Grouped base names for " + environmentPrefix + dnis + ": " + grouped.size());
            int idx = 1;
            for (Map.Entry<String, JSONObject[]> entry : grouped.entrySet()) {
                String baseName = entry.getKey();
                JSONObject rawAsr = entry.getValue()[0];
                JSONObject rawTmf = entry.getValue()[1];

                String asrFullName = environmentPrefix + dnis + asrInfix + baseName;
                String tmfFullName = environmentPrefix + dnis + tmfInfix + baseName;

                JSONObject asrData = rawAsr != null
                        ? resolvePromptDetail(trackId, guser, rawAsr, asrFullName)
                        : null;
                JSONObject tmfData = rawTmf != null
                        ? resolvePromptDetail(trackId, guser, rawTmf, tmfFullName)
                        : null;
                JSONObject row = new JSONObject();
                row.put("rowId", idx++);
                row.put("name",  baseName);
                row.put("asr",   asrData  != null ? asrData  : emptyPromptStub(asrFullName));
                row.put("tmf",   tmfData  != null ? tmfData  : emptyPromptStub(tmfFullName));
                result.put(row);
            }

            log.info(trackId + " Returning " + result.length() + " Genesys-driven prompt rows for "
                    + environmentPrefix + dnis);
        } catch (Exception e) {
            log.error(trackId + " Error in getPromptsByEnvironmentAndDnis", e);
        }
        return result;
    }

    public static JSONArray getPromptsByDnis(String trackId, String dnis) {
        JSONArray result = new JSONArray();
        long t0 = System.currentTimeMillis();

        log.info(trackId + " === [getPromptsByDnis] START  dnis=" + dnis + " ===");

        if (dnis == null || dnis.trim().isEmpty()) {
            log.error(trackId + " [getPromptsByDnis] dnis parameter is null or empty - aborting.");
            return result;
        }
        dnis = dnis.trim();

        GenesysUser guser = getGenesysUser(trackId);
        if (guser == null) {
            log.error(trackId + " [getPromptsByDnis] GenesysUser could not be created - check clientId/clientSecret/urlRegion in properties.");
            return result;
        }
        log.info(trackId + " [getPromptsByDnis] GenesysUser created successfully.");
        log.info(trackId + " [getPromptsByDnis] Calling Genesys.getAllPrompts (no server-side filter) ...");
        long apiStart = System.currentTimeMillis();
        JSONArray allPrompts = Genesys.getAllPrompts(trackId, guser);
        long apiMs = System.currentTimeMillis() - apiStart;

        if (allPrompts == null || allPrompts.length() == 0) {
            log.warn(trackId + " [getPromptsByDnis] Genesys.getAllPrompts returned " +
                     (allPrompts == null ? "null" : "empty array") +
                     " after " + apiMs + " ms - nothing to filter.");
            return result;
        }
        log.info(trackId + " [getPromptsByDnis] API call completed in " + apiMs +
                 " ms - total prompts received: " + allPrompts.length());

        String vPrefix = "V_" + dnis + "_BG_";
        String pPrefix = "P_" + dnis + "_BG_";
        String asrInfix = "_BG_A_";
        String tmfInfix = "_BG_D_";
        log.info(trackId + " [getPromptsByDnis] Filter prefixes - V: \"" + vPrefix + "\"  P: \"" + pPrefix + "\"");

        Map<String, JSONObject[]> grouped = new LinkedHashMap<>();
        Map<String, String> keyToEnv = new LinkedHashMap<>();

        int scannedV = 0, scannedP = 0, skipped = 0;
        for (int i = 0; i < allPrompts.length(); i++) {
            JSONObject p = allPrompts.getJSONObject(i);
            String name = p.optString("name", "").trim();
            if (name.isEmpty()) { skipped++; continue; }

            String env;
            if (name.startsWith(vPrefix)) {
                env = "V_";
                scannedV++;
            } else if (name.startsWith(pPrefix)) {
                env = "P_";
                scannedP++;
            } else {
                skipped++;
                continue;
            }

            int asrIdx = name.indexOf(asrInfix);
            int tmfIdx = name.indexOf(tmfInfix);
            String baseName;
            boolean isAsr;
            if (asrIdx >= 0) {
                baseName = name.substring(asrIdx + asrInfix.length());
                isAsr    = true;
            } else if (tmfIdx >= 0) {
                baseName = name.substring(tmfIdx + tmfInfix.length());
                isAsr    = false;
            } else {
                log.warn(trackId + " [getPromptsByDnis] Prompt \"" + name +
                         "\" matches env prefix but has no _BG_A_ / _BG_D_ infix - skipping.");
                skipped++;
                continue;
            }

            String compositeKey = env + "|" + baseName;
            grouped.computeIfAbsent(compositeKey, k -> new JSONObject[2]);
            keyToEnv.put(compositeKey, env);
            if (isAsr) {
                grouped.get(compositeKey)[0] = p;
                log.debug(trackId + " [getPromptsByDnis] Mapped ASR  env=" + env + "  baseName=" + baseName + "  promptName=" + name);
            } else {
                grouped.get(compositeKey)[1] = p;
                log.debug(trackId + " [getPromptsByDnis] Mapped TMF  env=" + env + "  baseName=" + baseName + "  promptName=" + name);
            }
        }

        log.info(trackId + " [getPromptsByDnis] Scan complete -" +
                 "  total=" + allPrompts.length() +
                 "  matched V_=" + scannedV +
                 "  matched P_=" + scannedP +
                 "  skipped=" + skipped +
                 "  unique (env+baseName) groups=" + grouped.size());

        if (grouped.isEmpty()) {
            log.warn(trackId + " [getPromptsByDnis] No prompts matched for dnis=" + dnis +
                     " - returning empty result.");
            return result;
        }

        int rowId = 1;
        int resolvedAsr = 0, resolvedTmf = 0, stubAsr = 0, stubTmf = 0;

        for (Map.Entry<String, JSONObject[]> entry : grouped.entrySet()) {
            String compositeKey = entry.getKey();
            String env          = keyToEnv.get(compositeKey);
            String baseName     = compositeKey.substring(compositeKey.indexOf('|') + 1);
            JSONObject rawAsr   = entry.getValue()[0];
            JSONObject rawTmf   = entry.getValue()[1];

            String asrFullName = env + dnis + asrInfix + baseName;
            String tmfFullName = env + dnis + tmfInfix + baseName;

            log.info(trackId + " [getPromptsByDnis] Resolving row #" + rowId +
                     "  env=" + env + "  baseName=" + baseName +
                     "  hasAsr=" + (rawAsr != null) + "  hasTmf=" + (rawTmf != null));

            JSONObject asrData, tmfData;
            if (rawAsr != null) {
                log.debug(trackId + " [getPromptsByDnis] Fetching ASR resource details for: " + asrFullName);
                asrData = resolvePromptDetail(trackId, guser, rawAsr, asrFullName);
                resolvedAsr++;
                log.debug(trackId + " [getPromptsByDnis] ASR resolved - hasAudio=" +
                          asrData.optBoolean("hasAudio") + "  ttsLen=" +
                          asrData.optString("ttsText", "").length());
            } else {
                log.info(trackId + " [getPromptsByDnis] ASR not found in Genesys — creating empty stub for: " + asrFullName);
                asrData = emptyPromptStub(asrFullName);
                stubAsr++;
            }

            if (rawTmf != null) {
                log.debug(trackId + " [getPromptsByDnis] Fetching TMF resource details for: " + tmfFullName);
                tmfData = resolvePromptDetail(trackId, guser, rawTmf, tmfFullName);
                resolvedTmf++;
                log.debug(trackId + " [getPromptsByDnis] TMF resolved - hasAudio=" +
                          tmfData.optBoolean("hasAudio") + "  ttsLen=" +
                          tmfData.optString("ttsText", "").length());
            } else {
                log.info(trackId + " [getPromptsByDnis] TMF not found in Genesys — creating empty stub for: " + tmfFullName);
                tmfData = emptyPromptStub(tmfFullName);
                stubTmf++;
            }

            JSONObject row = new JSONObject();
            row.put("rowId", rowId++);
            row.put("env",   env);
            row.put("name",  baseName);
            row.put("asr",   asrData);
            row.put("tmf",   tmfData);
            result.put(row);
        }

        long totalMs = System.currentTimeMillis() - t0;
        log.info(trackId + " [getPromptsByDnis] Build complete -" +
                 "  rows=" + result.length() +
                 "  resolvedAsr=" + resolvedAsr + "  stubAsr=" + stubAsr +
                 "  resolvedTmf=" + resolvedTmf + "  stubTmf=" + stubTmf);
        log.info(trackId + " === [getPromptsByDnis] END  totalTimeMs=" + totalMs +
                 "  returning " + result.length() + " rows ===");
        return result;
    }

    private static JSONObject resolvePromptDetail(String trackId, GenesysUser guser,
                                                   JSONObject raw, String fullName) {
        JSONObject obj = new JSONObject();
        String promptId = raw.optString("id", "");
        obj.put("id",          promptId);
        obj.put("name",        fullName);
        obj.put("displayName", extractDisplayName(fullName));
        obj.put("found",       true);
        obj.put("needsCreation", false);
        try {
            JSONArray resources = Genesys.getPromptResources(trackId, guser, promptId);
            if (resources != null && resources.length() > 0) {
                JSONObject res = resources.getJSONObject(0);
                obj.put("resourceId",   res.optString("id", ""));
                obj.put("language",     res.optString("language", ""));
                obj.put("uploadStatus", res.optString("uploadStatus", ""));
                obj.put("ttsText",  res.has("ttsString")  && !res.isNull("ttsString")  ? res.getString("ttsString")  : "");
                if (res.has("mediaUri") && !res.isNull("mediaUri")) {
                    obj.put("audioUrl", res.getString("mediaUri"));
                    obj.put("hasAudio", true);
                } else {
                    obj.put("audioUrl", "");
                    obj.put("hasAudio", false);
                }
                if (res.has("uploadUri") && !res.isNull("uploadUri")) {
                    obj.put("uploadUri", res.getString("uploadUri"));
                }
            } else {
                obj.put("resourceId", "");
                obj.put("ttsText", "");
                obj.put("audioUrl", "");
                obj.put("hasAudio", false);
                obj.put("needsResourceCreation", true);
            }
        } catch (Exception e) {
            log.error(trackId + " Error resolving resources for: " + fullName, e);
            obj.put("resourceId", "");
            obj.put("ttsText", "");
            obj.put("audioUrl", "");
            obj.put("hasAudio", false);
        }
        return obj;
    }

    private static JSONObject emptyPromptStub(String fullName) {
        JSONObject obj = new JSONObject();
        obj.put("id",          "");
        obj.put("name",        fullName);
        obj.put("displayName", extractDisplayName(fullName));
        obj.put("found",       false);
        obj.put("needsCreation", false);
        obj.put("resourceId",  "");
        obj.put("ttsText",     "");
        obj.put("audioUrl",    "");
        obj.put("hasAudio",    false);
        return obj;
    }

    public static JSONArray getPromptsByEnvironment(String trackId, String environmentPrefix) {
        JSONArray result = new JSONArray();
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) {
                log.error(trackId + " GenesysUser could not be created!");
                return result;
            }
            JSONArray dnisRows = getDnisConfigRows(trackId);
            List<String> prefixes = new ArrayList<>();
            for (int i = 0; i < dnisRows.length(); i++) {
                JSONObject row = dnisRows.getJSONObject(i);
                String headPrompt = row.optString("HeadPrompt", "").trim();
                String dnis = row.optString("Dnis", "").trim();
                if (headPrompt.equals(environmentPrefix) && !dnis.isEmpty()) {
                    String prefix = headPrompt + dnis + "_BG_";
                    if (!prefixes.contains(prefix)) {
                        prefixes.add(prefix);
                        log.info(trackId + " Will search for prompts with prefix: " + prefix);
                    }
                }
            }
            if (prefixes.isEmpty()) {
                log.warn(trackId + " No DnisConfig rows found for environment: " + environmentPrefix
                        + " — falling back to fixed prefix: " + environmentPrefix + "Dnis_BG_");
                prefixes.add(environmentPrefix + "Dnis_BG_");
            }
            JSONArray allPrompts = Genesys.getAllPrompts(trackId, guser);
            if (allPrompts == null || allPrompts.length() == 0) {
                log.warn(trackId + " No prompts found in Genesys Cloud");
                return result;
            }
            log.info(trackId + " Processing " + allPrompts.length() + " prompts from Genesys Cloud");

            for (int i = 0; i < allPrompts.length(); i++) {
                JSONObject prompt = allPrompts.getJSONObject(i);
                String promptName = prompt.optString("name", "").trim();
                if (promptName.isEmpty()) continue;
                String matchedPrefix = null;
                for (String prefix : prefixes) {
                    if (promptName.startsWith(prefix)) {
                        matchedPrefix = prefix;
                        break;
                    }
                }
                if (matchedPrefix == null) continue;
                log.info(trackId + " Found matching prompt: " + promptName);
                JSONObject promptInfo = getPromptInfo(trackId, guser, promptName);
                if (promptInfo != null) {
                    String displayName = extractDisplayNameFromPrefix(promptName, matchedPrefix);
                    promptInfo.put("displayName", displayName);
                    result.put(promptInfo);
                }
            }

            log.info(trackId + " Found " + result.length() + " prompts for environment " + environmentPrefix);
        } catch (Exception e) {
            log.error(trackId + " Error in getPromptsByEnvironment", e);
        }
        return result;
    }
    private static String extractDisplayNameFromPrefix(String promptName, String prefix) {
        if (promptName == null || promptName.isEmpty()) return "";
        if (prefix != null && promptName.startsWith(prefix)) {
            return promptName.substring(prefix.length());
        }
        return extractDisplayName(promptName);
    }

    public static JSONObject getPromptInfo(String trackId, GenesysUser guser, String promptName) {
        try {
            JSONObject prompt = Genesys.getPromptByName(trackId, guser, promptName);
            if (prompt == null) {
                log.warn(trackId + " Prompt not found: " + promptName + " - Will create on upload");
                JSONObject info = new JSONObject();
                info.put("name", promptName);
                info.put("displayName", extractDisplayName(promptName));
                info.put("found", false);
                info.put("id", "");
                info.put("resourceId", "");
                info.put("ttsText", "");
                info.put("audioUrl", "");
                info.put("hasAudio", false);
                info.put("needsCreation", true);
                return info;
            }
            String promptId = prompt.getString("id");
            JSONArray resources = Genesys.getPromptResources(trackId, guser, promptId);
            JSONObject info = new JSONObject();
            info.put("id", promptId);
            info.put("name", promptName);
            info.put("displayName", extractDisplayName(promptName));
            info.put("found", true);
            info.put("needsCreation", false);
            if (resources != null && resources.length() > 0) {
                JSONObject resource = resources.getJSONObject(0);
                info.put("resourceId", resource.optString("id", ""));
                info.put("language", resource.optString("language", ""));
                String uploadStatus = resource.optString("uploadStatus", "");
                info.put("uploadStatus", uploadStatus);
                if (resource.has("uploadUri") && !resource.isNull("uploadUri")) {
                    info.put("uploadUri", resource.getString("uploadUri"));
                }
                if (resource.has("ttsString") && !resource.isNull("ttsString")) {
                    info.put("ttsText", resource.getString("ttsString"));
                } else {
                    info.put("ttsText", "");
                }
                if (resource.has("mediaUri") && !resource.isNull("mediaUri")) {
                    info.put("audioUrl", resource.getString("mediaUri"));
                    info.put("hasAudio", true);
                } else {
                    info.put("audioUrl", "");
                    info.put("hasAudio", false);
                }
            } else {
                info.put("ttsText", "");
                info.put("audioUrl", "");
                info.put("hasAudio", false);
                info.put("resourceId", "");
                info.put("needsResourceCreation", true);
            }
            return info;
        } catch (Exception e) {
            log.error(trackId + " Error getting prompt info: " + promptName, e);
            JSONObject info = new JSONObject();
            info.put("name", promptName);
            info.put("displayName", extractDisplayName(promptName));
            info.put("found", false);
            info.put("id", "");
            info.put("resourceId", "");
            info.put("ttsText", "");
            info.put("audioUrl", "");
            info.put("hasAudio", false);
            info.put("needsCreation", true);
            return info;
        }
    }

    private static String extractDisplayName(String promptName) {
        if (promptName == null || promptName.isEmpty()) return "";
        int bgIdx = promptName.indexOf("_BG_");
        if (bgIdx >= 0) return promptName.substring(bgIdx + 4);
        return promptName;
    }

    public static String getAudioUrl(String trackId, String promptId) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) return null;
            return Genesys.getPromptAudioUrl(trackId, guser, promptId, null);
        } catch (Exception e) {
            log.error(trackId + " Error getting audio URL", e);
            return null;
        }
    }

    public static byte[] downloadAudio(String trackId, String audioUrl) {
        try {
            return Genesys.downloadAudio(trackId, audioUrl);
        } catch (Exception e) {
            log.error(trackId + " Error downloading audio", e);
            return null;
        }
    }

    public static boolean uploadAudioWithCreate(String trackId, String promptName, byte[] audioData) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) return false;
            JSONObject prompt = Genesys.getPromptByName(trackId, guser, promptName);
            String promptId;
            if (prompt == null) {
                log.info(trackId + " Creating new prompt: " + promptName);
                JSONObject newPrompt = Genesys.createPrompt(trackId, guser, promptName, "Auto-created prompt for " + promptName);
                if (newPrompt == null) {
                    log.error(trackId + " Failed to create prompt: " + promptName);
                    return false;
                }
                promptId = newPrompt.getString("id");
                log.info(trackId + " Created prompt with ID: " + promptId);
            } else {
                promptId = prompt.getString("id");
            }
            JSONArray resources = Genesys.getPromptResources(trackId, guser, promptId);
            String resourceId;
            if (resources == null || resources.length() == 0) {
                log.info(trackId + " Creating new resource for prompt: " + promptId);
                JSONObject newResource = Genesys.createPromptResource(trackId, guser, promptId, "it-it");
                if (newResource == null) {
                    log.error(trackId + " Failed to create resource for prompt: " + promptId);
                    return false;
                }
                resourceId = newResource.getString("id");
                log.info(trackId + " Created resource with ID: " + resourceId);
            } else {
                resourceId = resources.getJSONObject(0).getString("id");
            }
            return Genesys.uploadPromptAudio(trackId, guser, promptId, resourceId, audioData);
        } catch (Exception e) {
            log.error(trackId + " Error uploading audio with create", e);
            return false;
        }
    }

    public static boolean uploadAudio(String trackId, String promptId, String resourceId, byte[] audioData) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) return false;
            return Genesys.uploadPromptAudio(trackId, guser, promptId, resourceId, audioData);
        } catch (Exception e) {
            log.error(trackId + " Error uploading audio", e);
            return false;
        }
    }
    public static boolean deletePromptAudio(String trackId, String promptId, String resourceId, String language, String ttsText) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) {
                log.error(trackId + " GenesysUser could not be created for deletePromptAudio!");
                return false;
            }
            log.info(trackId + " Deleting audio for prompt: " + promptId + ", resource: " + resourceId);
            boolean result = Genesys.deletePromptAudio(trackId, guser, promptId, resourceId, language, ttsText);
            if (result) {
                log.info(trackId + " Successfully deleted audio for prompt: " + promptId);
            } else {
                log.error(trackId + " Failed to delete audio for prompt: " + promptId);
            }
            return result;
        } catch (Exception e) {
            log.error(trackId + " Error deleting prompt audio: " + promptId, e);
            return false;
        }
    }

    public static boolean clearTtsText(String trackId, String promptId, String resourceId) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) {
                log.error(trackId + " GenesysUser could not be created for clearTtsText!");
                return false;
            }
            if (resourceId == null || resourceId.isEmpty()) {
                JSONArray resources = Genesys.getPromptResources(trackId, guser, promptId);
                if (resources != null && resources.length() > 0) {
                    resourceId = resources.getJSONObject(0).optString("id", "");
                }
            }
            if (resourceId == null || resourceId.isEmpty()) {
                log.error(trackId + " No resource found for prompt: " + promptId);
                return false;
            }
            log.info(trackId + " Clearing TTS text for prompt: " + promptId + ", resource: " + resourceId);
            boolean result = Genesys.updatePromptTts(trackId, guser, promptId, resourceId, "");
            if (result) {
                log.info(trackId + " Successfully cleared TTS for prompt: " + promptId);
            }
            return result;
        } catch (Exception e) {
            log.error(trackId + " Error clearing TTS text: " + promptId, e);
            return false;
        }
    }

    public static boolean deletePrompt(String trackId, String promptId) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) {
                log.error(trackId + " GenesysUser could not be created for delete!");
                return false;
            }
            log.info(trackId + " Deleting prompt: " + promptId);
            boolean result = Genesys.deletePrompt(trackId, guser, promptId);
            if (result) {
                log.info(trackId + " Successfully deleted prompt: " + promptId);
            } else {
                log.error(trackId + " Failed to delete prompt: " + promptId);
            }
            return result;
        } catch (Exception e) {
            log.error(trackId + " Error deleting prompt: " + promptId, e);
            return false;
        }
    }

    public static boolean updateTtsText(String trackId, String promptName, String promptId, String resourceId, String ttsText) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) {
                log.error(trackId + " GenesysUser could not be created for TTS update!");
                return false;
            }
            if (promptId == null || promptId.isEmpty()) {
                if (promptName == null || promptName.isEmpty()) {
                    log.error(trackId + " Neither promptId nor promptName provided!");
                    return false;
                }
                JSONObject prompt = Genesys.getPromptByName(trackId, guser, promptName);
                if (prompt == null) {
                    log.info(trackId + " Creating new prompt for TTS: " + promptName);
                    JSONObject newPrompt = Genesys.createPrompt(trackId, guser, promptName, "Auto-created prompt for " + promptName);
                    if (newPrompt == null) {
                        log.error(trackId + " Failed to create prompt: " + promptName);
                        return false;
                    }
                    promptId = newPrompt.getString("id");
                } else {
                    promptId = prompt.getString("id");
                }
            }
            if (resourceId == null || resourceId.isEmpty()) {
                JSONArray resources = Genesys.getPromptResources(trackId, guser, promptId);
                if (resources == null || resources.length() == 0) {
                    log.info(trackId + " Creating new resource for TTS: " + promptId);
                    Properties props = ConfigServlet.getProperties();
                    String defaultLanguage = props.getProperty("prompt.defaultLanguage", "it-it");
                    JSONObject newResource = Genesys.createPromptResource(trackId, guser, promptId, defaultLanguage);
                    if (newResource == null) {
                        log.error(trackId + " Failed to create resource for prompt: " + promptId);
                        return false;
                    }
                    resourceId = newResource.getString("id");
                } else {
                    resourceId = resources.getJSONObject(0).getString("id");
                }
            }
            log.info(trackId + " Updating TTS text for prompt: " + promptId + ", resource: " + resourceId);
            boolean result = Genesys.updatePromptTts(trackId, guser, promptId, resourceId, ttsText);
            if (result) {
                log.info(trackId + " Successfully updated TTS for prompt: " + promptId);
            } else {
                log.error(trackId + " Failed to update TTS for prompt: " + promptId);
            }
            return result;
        } catch (Exception e) {
            log.error(trackId + " Error updating TTS: " + promptId, e);
            return false;
        }
    }

    public static void clearCache() {
        cachedDnisConfigTables = null;
    }
    public static JSONArray getDnisConfigRows(String trackId) {
        JSONArray combined = new JSONArray();
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) {
                log.error(trackId + " GenesysUser could not be created!");
                return combined;
            }
            List<JSONObject> tables = getAllDnisConfigTables(trackId, guser);
            if (tables == null || tables.isEmpty()) {
                log.warn(trackId + " No DnisConfig tables found!");
                return combined;
            }
            for (JSONObject table : tables) {
                String tableId = table.optString("id");
                String tableName = table.optString("name");
                JSONArray rows = Genesys.getAllDatabaseRows(trackId, guser, tableId);
                if (rows != null) {
                    for (int i = 0; i < rows.length(); i++) {
                        JSONObject row = rows.getJSONObject(i);
                        row.put("_tableName", tableName);
                        combined.put(row);
                    }
                }
            }
            log.info(trackId + " Retrieved " + combined.length() + " total rows from " + tables.size() + " DnisConfig table(s)");
        } catch (Exception e) {
            log.error(trackId + " Error getting DnisConfig rows", e);
        }
        return combined;
    }

    public static boolean addDnisConfigRow(String trackId, JSONObject rowData) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) { log.error(trackId + " GenesysUser could not be created!"); return false; }
            String tableId = getPrimaryDnisConfigTableId(trackId, guser);
            if (tableId == null) { log.error(trackId + " DnisConfig Table ID not found!"); return false; }
            if (!rowData.has("key") || rowData.optString("key", "").isEmpty()) { log.error(trackId + " Row data must have 'key' field!"); return false; }
            log.info(trackId + " Adding new row to DnisConfig: " + rowData.toString());
            boolean result = Genesys.addDatabaseRow(trackId, guser, tableId, rowData);
            log.info(trackId + (result ? " Successfully added" : " Failed to add") + " row to DnisConfig");
            return result;
        } catch (Exception e) {
            log.error(trackId + " Error adding DnisConfig row", e);
            return false;
        }
    }

    public static boolean updateDnisConfigRow(String trackId, JSONObject rowData) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) { log.error(trackId + " GenesysUser could not be created!"); return false; }
            String tableId = getPrimaryDnisConfigTableId(trackId, guser);
            if (tableId == null) { log.error(trackId + " DnisConfig Table ID not found!"); return false; }
            if (!rowData.has("key") || rowData.optString("key", "").isEmpty()) { log.error(trackId + " Row data must have 'key' field!"); return false; }
            log.info(trackId + " Updating row in DnisConfig: " + rowData.toString());
            boolean result = Genesys.putDatabaseRow(trackId, guser, tableId, rowData);
            log.info(trackId + (result ? " Successfully updated" : " Failed to update") + " row in DnisConfig");
            return result;
        } catch (Exception e) {
            log.error(trackId + " Error updating DnisConfig row", e);
            return false;
        }
    }

    public static boolean deleteDnisConfigRow(String trackId, String rowKey) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) { log.error(trackId + " GenesysUser could not be created!"); return false; }
            String tableId = getPrimaryDnisConfigTableId(trackId, guser);
            if (tableId == null) { log.error(trackId + " DnisConfig Table ID not found!"); return false; }
            log.info(trackId + " Deleting row from DnisConfig: " + rowKey);
            boolean result = Genesys.deleteDatabaseRow(trackId, guser, tableId, rowKey);
            log.info(trackId + (result ? " Successfully deleted" : " Failed to delete") + " row from DnisConfig");
            return result;
        } catch (Exception e) {
            log.error(trackId + " Error deleting DnisConfig row", e);
            return false;
        }
    }

    public static String buildPromptName(String environmentPrefix, String name) {
        return environmentPrefix + "Dnis_BG_" + name;
    }

    public static JSONObject createPromptWithPrefix(String trackId, String environmentPrefix, String name, 
                                                     String description, String ttsText) {
        try {
            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) {
                log.error(trackId + " GenesysUser could not be created!");
                return null;
            }

            String promptName = buildPromptName(environmentPrefix, name);
            log.info(trackId + " Creating prompt with name: " + promptName);

            JSONObject existingPrompt = Genesys.getPromptByName(trackId, guser, promptName);
            if (existingPrompt != null) {
                log.warn(trackId + " Prompt already exists: " + promptName);
                JSONObject result = new JSONObject();
                result.put("success", false);
                result.put("message", "Prompt already exists: " + promptName);
                result.put("promptId", existingPrompt.getString("id"));
                result.put("promptName", promptName);
                return result;
            }

            if (description == null || description.isEmpty()) {
                description = "Auto-created prompt for " + name;
            }
            JSONObject newPrompt = Genesys.createPrompt(trackId, guser, promptName, description);
            if (newPrompt == null) {
                log.error(trackId + " Failed to create prompt: " + promptName);
                return null;
            }

            String promptId = newPrompt.getString("id");
            log.info(trackId + " Created prompt with ID: " + promptId);

            Properties props = ConfigServlet.getProperties();
            String defaultLanguage = props.getProperty("prompt.defaultLanguage", "it-it");
            JSONObject newResource = Genesys.createPromptResource(trackId, guser, promptId, defaultLanguage);
            
            String resourceId = null;
            if (newResource != null) {
                resourceId = newResource.getString("id");
                log.info(trackId + " Created resource with ID: " + resourceId);

                if (ttsText != null && !ttsText.isEmpty()) {
                    boolean ttsResult = Genesys.updatePromptTts(trackId, guser, promptId, resourceId, ttsText);
                    log.info(trackId + " TTS update result: " + ttsResult);
                }
            }

            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("message", "Prompt created successfully");
            result.put("promptId", promptId);
            result.put("promptName", promptName);
            result.put("displayName", name);
            result.put("resourceId", resourceId != null ? resourceId : "");
            result.put("environment", environmentPrefix);
            return result;

        } catch (Exception e) {
            log.error(trackId + " Error creating prompt with prefix", e);
            return null;
        }
    }
    public static JSONObject createPromptPair(String trackId, String baseName) {
        JSONObject result = new JSONObject();
        try {
            if (baseName == null || baseName.trim().isEmpty()) {
                result.put("success", false);
                result.put("message", "baseName must not be empty");
                return result;
            }
            baseName = baseName.trim()
                               .replaceAll("_BG_A_", "_BG_")
                               .replaceAll("_BG_D_", "_BG_");

            if (!baseName.contains("_BG_")) {
                result.put("success", false);
                result.put("message", "baseName must contain '_BG_' (e.g. V_03075_BG_Kampanya)");
                return result;
            }

            GenesysUser guser = getGenesysUser(trackId);
            if (guser == null) {
                result.put("success", false);
                result.put("message", "Could not initialise Genesys credentials");
                return result;
            }

            int bgIdx = baseName.lastIndexOf("_BG_");
            String prefix = baseName.substring(0, bgIdx);
            String suffix = baseName.substring(bgIdx + 4);
            String asrName = prefix + "_BG_A_" + suffix;
            String tmfName = prefix + "_BG_D_" + suffix;

            Properties props = ConfigServlet.getProperties();
            String lang = props.getProperty("prompt.defaultLanguage", "it-it");

            JSONObject asrResult = createSingleShell(trackId, guser, asrName, lang);
            JSONObject tmfResult = createSingleShell(trackId, guser, tmfName, lang);

            result.put("success",       asrResult.optBoolean("success") || tmfResult.optBoolean("success"));
            result.put("asrName",       asrName);
            result.put("tmfName",       tmfName);
            result.put("asrPromptId",   asrResult.optString("promptId", ""));
            result.put("asrResourceId", asrResult.optString("resourceId", ""));
            result.put("tmfPromptId",   tmfResult.optString("promptId", ""));
            result.put("tmfResourceId", tmfResult.optString("resourceId", ""));
            if (!asrResult.optBoolean("success")) result.put("asrError", asrResult.optString("message"));
            if (!tmfResult.optBoolean("success")) result.put("tmfError", tmfResult.optString("message"));
        } catch (Exception e) {
            log.error(trackId + " Error in createPromptPair for: " + baseName, e);
            result.put("success", false);
            result.put("message", "Error: " + e.getMessage());
        }
        return result;
    }

    private static JSONObject createSingleShell(String trackId, GenesysUser guser,
                                                 String fullName, String language) {
        JSONObject out = new JSONObject();
        try {
            JSONObject existing = Genesys.getPromptByName(trackId, guser, fullName);
            if (existing != null) {
                log.warn(trackId + " Prompt already exists: " + fullName);
                out.put("success",    false);
                out.put("message",    "Prompt already exists: " + fullName);
                out.put("promptId",   existing.optString("id", ""));
                out.put("resourceId", "");
                return out;
            }
            JSONObject created = Genesys.createPrompt(trackId, guser, fullName, "Auto-created prompt");
            if (created == null || !created.has("id")) {
                out.put("success", false);
                out.put("message", "Genesys createPrompt returned no ID for: " + fullName);
                return out;
            }
            String promptId = created.getString("id");
            JSONObject resource = Genesys.createPromptResource(trackId, guser, promptId, language);
            String resourceId = (resource != null && resource.has("id")) ? resource.getString("id") : "";
            out.put("success",    true);
            out.put("promptId",   promptId);
            out.put("resourceId", resourceId);
            out.put("promptName", fullName);
        } catch (Exception e) {
            log.error(trackId + " Error creating shell for: " + fullName, e);
            out.put("success", false);
            out.put("message", "Error: " + e.getMessage());
        }
        return out;
    }

    public static JSONObject createPromptAndDnisConfig(String trackId, String environmentPrefix, String name,
                                                        String description, String ttsText, JSONObject dnisConfigData) {
        try {
            JSONObject promptResult = createPromptWithPrefix(trackId, environmentPrefix, name, description, ttsText);
            if (promptResult == null) {
                JSONObject error = new JSONObject();
                error.put("success", false);
                error.put("message", "Failed to create prompt");
                return error;
            }

            if (promptResult.optBoolean("success", false) && dnisConfigData != null) {
                dnisConfigData.put("key", promptResult.optString("promptName", name));
                dnisConfigData.put("HeadPrompt", environmentPrefix);
                
                boolean rowAdded = addDnisConfigRow(trackId, dnisConfigData);
                promptResult.put("dnisConfigAdded", rowAdded);
                if (!rowAdded) {
                    promptResult.put("dnisConfigMessage", "Prompt created but failed to add DnisConfig row");
                }
            }

            return promptResult;

        } catch (Exception e) {
            log.error(trackId + " Error in createPromptAndDnisConfig", e);
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Error: " + e.getMessage());
            return error;
        }
    }
}