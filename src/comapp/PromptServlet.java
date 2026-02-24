package comapp;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;
import comapp.business.PromptService;
import comapp.cloud.TrackId;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet(urlPatterns = { "/api/prompts", "/api/prompts/*" })
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 50,
    maxRequestSize = 1024 * 1024 * 60
)
public class PromptServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger log = LogManager.getLogger(PromptServlet.class);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String trackId = "GET_PROMPT_" + System.currentTimeMillis();
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                handleGetPrompts(request, response, trackId);
            } else if (pathInfo.equals("/audio")) {
                handleGetAudio(request, response, trackId, false);
            } else if (pathInfo.equals("/download")) {
                handleGetAudio(request, response, trackId, true);
            } else if (pathInfo.equals("/rows")) {
                handleGetDnisConfigRows(request, response, trackId);
            } else if (pathInfo.equals("/dnis-list")) {
                handleGetDnisList(request, response, trackId);
            } else if (pathInfo.equals("/by-dnis")) {
                handleGetPromptsByDnis(request, response, trackId);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            log.error(trackId + " Error in doGet", e);
            sendErrorResponse(response, "Internal server error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String trackId = "POST_PROMPT_" + System.currentTimeMillis();
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo != null && pathInfo.equals("/upload")) {
                handleUploadAudio(request, response, trackId);
            } else if (pathInfo != null && pathInfo.equals("/tts")) {
                handleUpdateTts(request, response, trackId);
            } else if (pathInfo != null && pathInfo.equals("/create")) {
                handleCreatePrompt(request, response, trackId);
            } else if (pathInfo != null && pathInfo.equals("/row")) {
                handleAddDnisConfigRow(request, response, trackId);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            log.error(trackId + " Error in doPost", e);
            sendErrorResponse(response, "Internal server error: " + e.getMessage());
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String trackId = "DELETE_PROMPT_" + System.currentTimeMillis();
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo != null && pathInfo.equals("/row")) {
                handleDeleteDnisConfigRow(request, response, trackId);
            } else if (pathInfo != null && pathInfo.equals("/audio")) {
                handleDeletePromptAudio(request, response, trackId);
            } else if (pathInfo != null && pathInfo.equals("/tts")) {
                handleClearTtsText(request, response, trackId);
            } else if (pathInfo != null && pathInfo.equals("/prompt")) {
                handleDeleteFullPrompt(request, response, trackId);
            } else {
                String promptId = request.getParameter("promptId");
                if (promptId == null || promptId.isEmpty()) {
                    sendErrorResponse(response, "Use /prompt, /audio, /tts or /row paths for delete operations");
                    return;
                }
                log.info(trackId + " Legacy full prompt delete: " + promptId);
                boolean success = PromptService.deletePrompt(trackId, promptId);
                JSONObject result = new JSONObject();
                result.put("success", success);
                result.put("message", success ? "Prompt deleted successfully" : "Failed to delete prompt");
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write(result.toString());
            }
        } catch (Exception e) {
            log.error(trackId + " Error in doDelete", e);
            sendErrorResponse(response, "Internal server error: " + e.getMessage());
        }
    }

    private void handleGetPrompts(HttpServletRequest request, HttpServletResponse response, String trackId) throws IOException {
        String env = request.getParameter("env");
        if (env == null || env.isEmpty()) {
            env = "V_";
        }
        log.info(trackId + " Getting prompts for environment: " + env);
        JSONArray prompts = PromptService.getPromptsByEnvironment(trackId, env);
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(prompts.toString());
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String trackId = "PUT_PROMPT_" + System.currentTimeMillis();
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo != null && pathInfo.equals("/row")) {
                handleUpdateDnisConfigRow(request, response, trackId);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            log.error(trackId + " Error in doPut", e);
            sendErrorResponse(response, "Internal server error: " + e.getMessage());
        }
    }

    private void handleDeletePromptAudio(HttpServletRequest request, HttpServletResponse response, String trackId) throws IOException {
        String promptId  = request.getParameter("promptId");
        String resourceId = request.getParameter("resourceId");
        String language  = request.getParameter("language");
        String ttsText   = request.getParameter("ttsText");
        if (promptId == null || promptId.isEmpty()) {
            sendErrorResponse(response, "promptId is required");
            return;
        }
        log.info(trackId + " Deleting audio for prompt: " + promptId);
        boolean success = PromptService.deletePromptAudio(trackId, promptId, resourceId, language, ttsText);
        JSONObject result = new JSONObject();
        result.put("success", success);
        result.put("message", success ? "Audio deleted successfully" : "Failed to delete audio");
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(result.toString());
    }

    private void handleClearTtsText(HttpServletRequest request, HttpServletResponse response, String trackId) throws IOException {
        String promptId  = request.getParameter("promptId");
        String resourceId = request.getParameter("resourceId");
        if (promptId == null || promptId.isEmpty()) {
            sendErrorResponse(response, "promptId is required");
            return;
        }
        log.info(trackId + " Clearing TTS for prompt: " + promptId);
        boolean success = PromptService.clearTtsText(trackId, promptId, resourceId);
        JSONObject result = new JSONObject();
        result.put("success", success);
        result.put("message", success ? "TTS text cleared successfully" : "Failed to clear TTS text");
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(result.toString());
    }

    private void handleDeleteFullPrompt(HttpServletRequest request, HttpServletResponse response, String trackId) throws IOException {
        String promptId = request.getParameter("promptId");
        if (promptId == null || promptId.isEmpty()) {
            sendErrorResponse(response, "promptId is required");
            return;
        }
        log.info(trackId + " Deleting full prompt: " + promptId);
        boolean success = PromptService.deletePrompt(trackId, promptId);
        JSONObject result = new JSONObject();
        result.put("success", success);
        result.put("message", success ? "Prompt deleted successfully" : "Failed to delete prompt");
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(result.toString());
    }

    private void handleGetDnisList(HttpServletRequest request, HttpServletResponse response, String trackId) throws IOException {
        log.info(trackId + " Getting full DNIS list (all environments)");
        JSONArray list = PromptService.getDnisList(trackId, null);
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(list.toString());
    }

    private void handleGetPromptsByDnis(HttpServletRequest request, HttpServletResponse response, String trackId) throws IOException {
        String dnis = request.getParameter("dnis");
        if (dnis == null || dnis.isEmpty()) { sendErrorResponse(response, "dnis parameter is required"); return; }
        // Show all environments (V_ and P_) in a single table
        log.info(trackId + " Getting prompts for all envs, dnis=" + dnis);
        JSONArray vRows = PromptService.getPromptsByEnvironmentAndDnis(trackId, "V_", dnis);
        JSONArray pRows = PromptService.getPromptsByEnvironmentAndDnis(trackId, "P_", dnis);
        // Merge: re-number rowIds and tag each row with its env
        JSONArray merged = new JSONArray();
        int idx = 1;
        for (int i = 0; i < vRows.length(); i++) {
            JSONObject row = vRows.getJSONObject(i);
            row.put("rowId", idx++);
            row.put("env", "V_");
            merged.put(row);
        }
        for (int i = 0; i < pRows.length(); i++) {
            JSONObject row = pRows.getJSONObject(i);
            row.put("rowId", idx++);
            row.put("env", "P_");
            merged.put(row);
        }
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(merged.toString());
    }

    private void handleGetDnisConfigRows(HttpServletRequest request, HttpServletResponse response, String trackId) throws IOException {
        log.info(trackId + " Getting DnisConfig rows");
        JSONArray rows = PromptService.getDnisConfigRows(trackId);
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(rows.toString());
    }

    private void handleAddDnisConfigRow(HttpServletRequest request, HttpServletResponse response, String trackId) throws IOException {
        String requestBody = request.getReader().lines().collect(java.util.stream.Collectors.joining());
        JSONObject requestJson = new JSONObject(requestBody);
        
        log.info(trackId + " Adding DnisConfig row: " + requestJson.toString());
        
        boolean success = PromptService.addDnisConfigRow(trackId, requestJson);
        
        JSONObject result = new JSONObject();
        result.put("success", success);
        result.put("message", success ? "Row added successfully" : "Failed to add row");
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(result.toString());
    }

    private void handleUpdateDnisConfigRow(HttpServletRequest request, HttpServletResponse response, String trackId) throws IOException {
        String requestBody = request.getReader().lines().collect(java.util.stream.Collectors.joining());
        JSONObject requestJson = new JSONObject(requestBody);
        
        log.info(trackId + " Updating DnisConfig row: " + requestJson.toString());
        
        boolean success = PromptService.updateDnisConfigRow(trackId, requestJson);
        
        JSONObject result = new JSONObject();
        result.put("success", success);
        result.put("message", success ? "Row updated successfully" : "Failed to update row");
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(result.toString());
    }

    private void handleDeleteDnisConfigRow(HttpServletRequest request, HttpServletResponse response, String trackId) throws IOException {
        String rowKey = request.getParameter("key");
        if (rowKey == null || rowKey.isEmpty()) {
            sendErrorResponse(response, "key parameter is required");
            return;
        }
        
        log.info(trackId + " Deleting DnisConfig row: " + rowKey);
        
        boolean success = PromptService.deleteDnisConfigRow(trackId, rowKey);
        
        JSONObject result = new JSONObject();
        result.put("success", success);
        result.put("message", success ? "Row deleted successfully" : "Failed to delete row");
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(result.toString());
    }

    private void handleCreatePrompt(HttpServletRequest request, HttpServletResponse response, String trackId) throws IOException {
        String requestBody = request.getReader().lines().collect(java.util.stream.Collectors.joining());
        JSONObject requestJson = new JSONObject(requestBody);

        // ── Pair-creation path (Add Prompt modal free-text input) ────────────────
        // Client sends { "baseName": "V_03075_BG_Kampanya" }.
        // Service splits on _BG_ and creates both _BG_A_ and _BG_D_ shells.
        if (requestJson.has("baseName")) {
            String baseName = requestJson.optString("baseName", "").trim();
            if (baseName.isEmpty()) {
                sendErrorResponse(response, "baseName must not be empty");
                return;
            }
            log.info(trackId + " Creating prompt pair for baseName: " + baseName);
            JSONObject result = PromptService.createPromptPair(trackId, baseName);
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write(result.toString());
            return;
        }

        // ── Exact-name path (used by "Create Missing" bulk flow) ─────────────────
        if (requestJson.has("exactName")) {
            String exactName = requestJson.optString("exactName", "").trim();
            if (exactName.isEmpty()) {
                sendErrorResponse(response, "exactName must not be empty");
                return;
            }
            log.info(trackId + " Creating prompt with exact name: " + exactName);
            try {
                comapp.cloud.GenesysUser guser = PromptService.getGenesysUser(trackId);
                if (guser == null) {
                    sendErrorResponse(response, "Could not initialise Genesys credentials");
                    return;
                }
                org.json.JSONObject created = comapp.cloud.Genesys.createPrompt(trackId, guser, exactName, "Auto-created missing prompt");
                if (created == null || !created.has("id")) {
                    sendErrorResponse(response, "Genesys createPrompt returned no ID for: " + exactName);
                    return;
                }
                String promptId = created.getString("id");
                log.info(trackId + " Prompt shell created, id=" + promptId + " — creating it-it resource");
                org.json.JSONObject resource = comapp.cloud.Genesys.createPromptResource(trackId, guser, promptId, "it-it");
                String resourceId = (resource != null && resource.has("id")) ? resource.getString("id") : "";
                JSONObject result = new JSONObject();
                result.put("success",    true);
                result.put("message",    "Prompt created successfully");
                result.put("promptId",   promptId);
                result.put("promptName", exactName);
                result.put("resourceId", resourceId);
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write(result.toString());
            } catch (Exception e) {
                log.error(trackId + " Error creating prompt with exactName: " + exactName, e);
                sendErrorResponse(response, "Error: " + e.getMessage());
            }
            return;
        }

        // ── Standard prefix-based path (existing behaviour) ───────────────────────
        String env = requestJson.optString("env", "V_");
        String name = requestJson.optString("name", "");
        String description = requestJson.optString("description", "");
        String ttsText = requestJson.optString("ttsText", "");
        boolean addToDataTable = requestJson.optBoolean("addToDataTable", false);

        if (name.isEmpty()) {
            sendErrorResponse(response, "name is required");
            return;
        }

        log.info(trackId + " Creating prompt with env: " + env + ", name: " + name);

        JSONObject result;
        if (addToDataTable) {
            JSONObject dnisConfigData = requestJson.optJSONObject("dnisConfig");
            if (dnisConfigData == null) {
                dnisConfigData = new JSONObject();
            }
            result = PromptService.createPromptAndDnisConfig(trackId, env, name, description, ttsText, dnisConfigData);
        } else {
            result = PromptService.createPromptWithPrefix(trackId, env, name, description, ttsText);
        }

        if (result == null) {
            sendErrorResponse(response, "Failed to create prompt");
            return;
        }

        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(result.toString());
    }

    private void handleGetAudio(HttpServletRequest request, HttpServletResponse response, String trackId, boolean download) throws IOException {
        String promptId = request.getParameter("promptId");
        String audioUrl = request.getParameter("audioUrl");
        if ((promptId == null || promptId.isEmpty()) && (audioUrl == null || audioUrl.isEmpty())) {
            sendErrorResponse(response, "promptId or audioUrl is required");
            return;
        }
        if (audioUrl == null || audioUrl.isEmpty()) {
            audioUrl = PromptService.getAudioUrl(trackId, promptId);
        }
        if (audioUrl == null || audioUrl.isEmpty()) {
            sendErrorResponse(response, "Audio not found for this prompt");
            return;
        }
        log.info(trackId + " Streaming audio from: " + audioUrl);
        byte[] audioData = PromptService.downloadAudio(trackId, audioUrl);
        if (audioData == null || audioData.length == 0) {
            sendErrorResponse(response, "Failed to download audio");
            return;
        }
        response.setContentType("audio/wav");
        response.setContentLength(audioData.length);
        if (download) {
            String fileName = "prompt_audio.wav";
            response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        }
        OutputStream out = response.getOutputStream();
        out.write(audioData);
        out.flush();
    }

    private void handleUpdateTts(HttpServletRequest request, HttpServletResponse response, String trackId) throws IOException {
        String requestBody = request.getReader().lines().collect(java.util.stream.Collectors.joining());
        JSONObject requestJson = new JSONObject(requestBody);
        String promptId = requestJson.optString("promptId", "");
        String resourceId = requestJson.optString("resourceId", "");
        String promptName = requestJson.optString("promptName", "");
        String ttsText = requestJson.optString("ttsText", "");
        log.info(trackId + " Updating TTS for prompt: " + (promptId.isEmpty() ? promptName : promptId) + " with text: " + ttsText);
        if (promptId.isEmpty() && promptName.isEmpty()) {
            sendErrorResponse(response, "promptId or promptName is required");
            return;
        }
        boolean success = PromptService.updateTtsText(trackId, promptName, promptId, resourceId, ttsText);
        JSONObject result = new JSONObject();
        result.put("success", success);
        result.put("message", success ? "TTS text updated successfully" : "Failed to update TTS text");
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(result.toString());
    }

    private void handleUploadAudio(HttpServletRequest request, HttpServletResponse response, String trackId) throws IOException, ServletException {
        String promptId = request.getParameter("promptId");
        String resourceId = request.getParameter("resourceId");
        String promptName = request.getParameter("promptName");
        boolean needsCreation = (promptId == null || promptId.isEmpty()) && (promptName != null && !promptName.isEmpty());
        if (!needsCreation && (promptId == null || promptId.isEmpty() || resourceId == null || resourceId.isEmpty())) {
            sendErrorResponse(response, "promptId and resourceId are required, or promptName for new prompt");
            return;
        }
        Part filePart = request.getPart("audioFile");
        if (filePart == null) {
            sendErrorResponse(response, "No audio file uploaded");
            return;
        }
        String fileName = getFileName(filePart);
        log.info(trackId + " Uploading audio file: " + fileName + " for prompt: " + (needsCreation ? promptName : promptId));
        InputStream inputStream = filePart.getInputStream();
        byte[] audioData = IOUtils.toByteArray(inputStream);
        inputStream.close();
        String validationError = AudioConverter.validateAudioFile(fileName, audioData);
        if (validationError != null) {
            log.warn(trackId + " Audio validation failed: " + validationError);
            sendErrorResponse(response, validationError);
            return;
        }
        boolean success;
        if (needsCreation) {
            log.info(trackId + " Creating new prompt and uploading audio: " + promptName);
            success = PromptService.uploadAudioWithCreate(trackId, promptName, audioData);
        } else {
            success = PromptService.uploadAudio(trackId, promptId, resourceId, audioData);
        }
        JSONObject result = new JSONObject();
        result.put("success", success);
        result.put("message", success ? "Audio uploaded successfully" : "Failed to upload audio");
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(result.toString());
    }

    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String token : contentDisposition.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "unknown.wav";
    }

    private void sendErrorResponse(HttpServletResponse response, String message) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        JSONObject error = new JSONObject();
        error.put("success", false);
        error.put("message", message);
        response.getWriter().write(error.toString());
    }
}