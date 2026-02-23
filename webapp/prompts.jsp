<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prompt Management</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/uikit@3.21.6/dist/css/uikit.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/uikit@3.21.6/dist/js/uikit.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/uikit@3.21.6/dist/js/uikit-icons.min.js"></script>
    <style>
        body { background-color: #f8f9fa; padding: 20px; }
        .nav-bar { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 15px 30px; margin: -20px -20px 20px -20px; display: flex; justify-content: space-between; align-items: center; }
        .nav-bar .nav-title { color: white; font-size: 20px; font-weight: bold; }
        .nav-bar .nav-links a { color: rgba(255,255,255,0.8); text-decoration: none; margin-left: 25px; font-weight: 500; transition: color 0.3s; }
        .nav-bar .nav-links a:hover, .nav-bar .nav-links a.active { color: white; }
        .env-selector { display: flex; gap: 10px; margin-bottom: 20px; justify-content: center; }
        .env-btn { padding: 10px 25px; border-radius: 25px; border: 2px solid #667eea; background: white; color: #667eea; font-weight: bold; cursor: pointer; transition: all 0.3s; }
        .env-btn:hover, .env-btn.active { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-color: transparent; }
        /* DNIS cards */
        .dnis-grid { display: flex; flex-wrap: wrap; gap: 16px; justify-content: center; margin-top: 20px; }
        .dnis-card { background: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); padding: 20px 28px; cursor: pointer; transition: all 0.25s; min-width: 200px; text-align: center; border: 2px solid transparent; }
        .dnis-card:hover { border-color: #667eea; transform: translateY(-2px); box-shadow: 0 6px 20px rgba(102,126,234,0.25); }
        .dnis-card .dnis-label { font-size: 22px; font-weight: 700; color: #333; }
        .dnis-card .dnis-sub { font-size: 12px; color: #888; margin-top: 4px; }
        /* Table */
        .prompt-card { border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); background: white; overflow: hidden; }
        .prompt-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        .prompt-table th { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 10px 8px; text-align: left; font-weight: 600; white-space: nowrap; }
        .prompt-table td { padding: 8px; border-bottom: 1px solid #e5e5e5; vertical-align: middle; }
        .prompt-table tr:hover { background: #f8f9fa; }
        .prompt-table tr:last-child td { border-bottom: none; }
        .col-id   { width: 45px;  text-align: center; color: #999; font-size: 12px; }
        .col-name { width: 160px; font-weight: 600; color: #333; word-break: break-word; }
        .col-tts  { max-width: 220px; word-break: break-word; color: #555; font-size: 12px; line-height: 1.4; }
        .col-audio{ width: 160px; }
        .action-buttons { display: flex; gap: 5px; flex-wrap: wrap; }
        .action-buttons button { padding: 4px 8px; font-size: 11px; }
        .no-content { color: #bbb; font-style: italic; font-size: 11px; }
        .btn-del-audio { background: #fd7e14; border-color: #fd7e14; color: white; }
        .btn-del-audio:hover { background: #e36910; }
        .section-header { display: flex; align-items: center; justify-content: space-between; padding: 12px 20px; background: #f1f3f9; border-bottom: 1px solid #dee2e6; flex-wrap: wrap; gap: 10px; }
        .back-btn { cursor: pointer; color: #667eea; font-weight: 600; display: flex; align-items: center; gap: 6px; }
        .back-btn:hover { color: #764ba2; }
        .filter-bar { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .filter-bar input { padding: 6px 12px; border: 1px solid #ced4da; border-radius: 20px; font-size: 13px; width: 260px; }
        .pagination { display: flex; align-items: center; gap: 8px; padding: 12px 20px; background: #f8f9fa; border-top: 1px solid #dee2e6; }
        .page-btn { padding: 5px 12px; border-radius: 4px; border: 1px solid #ced4da; background: white; cursor: pointer; font-size: 13px; }
        .page-btn:hover, .page-btn.active { background: #667eea; color: white; border-color: #667eea; }
        .page-info { color: #666; font-size: 13px; }
        .loading-container { text-align: center; padding: 50px; }
        .tts-truncated { max-height: 54px; overflow: hidden; position: relative; }
        .info-text { font-size: 11px; color: #666; }
        .header-group { text-align: center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .header-sub { background: rgba(0,0,0,0.15); }
    </style>
</head>
<body>
<div class="nav-bar">
    <div class="nav-title"><span uk-icon="icon: world; ratio: 1.2"></span> Calendario</div>
    <div class="nav-links">
        <a href="calendar.jsp"><span uk-icon="calendar"></span> Calendar</a>
        <a href="prompts.jsp" class="active"><span uk-icon="microphone"></span> Prompts</a>
    </div>
</div>
<div class="uk-container uk-container-large">
    <div class="uk-text-center uk-margin-bottom">
        <h1 class="uk-heading-medium"><span uk-icon="icon: microphone; ratio: 2"></span> Prompt Management</h1>
        <p class="uk-text-muted">Select a DNIS to manage its ASR and TMF prompts</p>
    </div>
    <div class="env-selector">
        <button class="env-btn active" id="btnEnvV" data-env="V_"><span uk-icon="check"></span> Valid (V_)</button>
        <button class="env-btn" id="btnEnvP" data-env="P_"><span uk-icon="server"></span> Production (P_)</button>
    </div>
    <!-- DNIS selection screen -->
    <div id="dnisScreen">
        <div id="dnisContainer">
            <div class="loading-container"><span uk-spinner="ratio: 2"></span><p class="uk-text-muted uk-margin-top">Loading DNIS list...</p></div>
        </div>
    </div>
    <!-- Prompt table screen (hidden initially) -->
    <div id="promptScreen" style="display:none;">
        <div class="prompt-card">
            <div class="section-header">
                <span class="back-btn" onclick="showDnisScreen()"><span uk-icon="arrow-left"></span> Back to DNIS list</span>
                <span style="font-weight:600; color:#444;">DNIS: <span id="selectedDnisLabel" style="color:#667eea;"></span></span>
                <div class="filter-bar">
                    <input type="text" id="filterInput" placeholder="🔍 Filter by name or TTS text..." oninput="applyFilter()">
                    <span id="filterCount" class="uk-text-muted" style="font-size:12px;"></span>
                </div>
            </div>
            <div style="overflow-x:auto;">
                <table class="prompt-table" id="promptTable">
                    <thead>
                        <tr>
                            <th class="col-id" rowspan="2">#</th>
                            <th style="width:160px;" rowspan="2">Name</th>
                            <th colspan="2" class="header-group" style="text-align:center;">ASR</th>
                            <th colspan="2" class="header-group" style="text-align:center;">TMF</th>
                            <th style="width:90px;" rowspan="2">Actions</th>
                        </tr>
                        <tr>
                            <th class="header-sub" style="width:220px;">TTS</th>
                            <th class="header-sub" style="width:150px;">Audio</th>
                            <th class="header-sub" style="width:220px;">TTS</th>
                            <th class="header-sub" style="width:150px;">Audio</th>
                        </tr>
                    </thead>
                    <tbody id="promptTableBody"></tbody>
                </table>
            </div>
            <div class="pagination" id="paginationBar"></div>
        </div>
    </div>
</div>

<!-- Upload Modal -->
<div id="uploadModal" uk-modal>
    <div class="uk-modal-dialog uk-modal-body">
        <h2 class="uk-modal-title"><span uk-icon="upload"></span> Upload Audio</h2>
        <button class="uk-modal-close-default" type="button" uk-close></button>
        <input type="hidden" id="upload_promptId">
        <input type="hidden" id="upload_resourceId">
        <input type="hidden" id="upload_promptName">
        <div class="uk-margin"><p>Uploading audio for: <strong id="upload_displayName"></strong></p></div>
        <div class="uk-margin">
            <label class="uk-form-label">Select Audio File (WAV only)</label>
            <div uk-form-custom="target: true">
                <input type="file" id="audioFileInput" accept=".wav">
                <input class="uk-input uk-form-width-large" type="text" placeholder="Select WAV file..." disabled>
            </div>
            <span class="info-text">Only WAV format accepted. Max 50MB.</span>
        </div>
        <div class="uk-margin uk-text-right">
            <button class="uk-button uk-button-default uk-modal-close" type="button">Cancel</button>
            <button class="uk-button uk-button-primary" type="button" id="btnConfirmUpload"><span uk-icon="upload"></span> Upload</button>
        </div>
    </div>
</div>

<!-- TTS Modal -->
<div id="ttsModal" uk-modal>
    <div class="uk-modal-dialog uk-modal-body">
        <h2 class="uk-modal-title"><span uk-icon="microphone"></span> Edit TTS Text</h2>
        <button class="uk-modal-close-default" type="button" uk-close></button>
        <input type="hidden" id="tts_promptId">
        <input type="hidden" id="tts_resourceId">
        <input type="hidden" id="tts_promptName">
        <div class="uk-margin"><p>Editing TTS for: <strong id="tts_displayName"></strong></p></div>
        <div class="uk-margin">
            <label class="uk-form-label">TTS Text</label>
            <textarea class="uk-textarea" id="ttsTextInput" rows="5" placeholder="Enter TTS text..."></textarea>
        </div>
        <div class="uk-margin uk-text-right">
            <button class="uk-button uk-button-default uk-modal-close" type="button">Cancel</button>
            <button class="uk-button uk-button-primary" type="button" id="btnConfirmTts"><span uk-icon="check"></span> Save TTS</button>
        </div>
    </div>
</div>

<script>
var API_BASE      = 'api/prompts';
var currentEnv    = 'V_';
var currentDnis   = '';
var allRows       = [];   // full dataset from server
var filteredRows  = [];   // after filter applied
var currentPage   = 1;
var PAGE_SIZE     = 100;

document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('btnEnvV').addEventListener('click', function() { setEnvironment('V_'); });
    document.getElementById('btnEnvP').addEventListener('click', function() { setEnvironment('P_'); });
    document.getElementById('btnConfirmUpload').addEventListener('click', uploadAudio);
    document.getElementById('btnConfirmTts').addEventListener('click', saveTtsText);
    document.getElementById('audioFileInput').addEventListener('change', function() {
        this.nextElementSibling.value = this.files.length > 0 ? this.files[0].name : '';
    });
    loadDnisList();
});

function setEnvironment(env) {
    currentEnv = env;
    document.querySelectorAll('.env-btn').forEach(function(b) { b.classList.remove('active'); });
    document.querySelector('.env-btn[data-env="' + env + '"]').classList.add('active');
    showDnisScreen();
    loadDnisList();
}

// ── DNIS SELECTION SCREEN ──────────────────────────────────────────────────────
function showDnisScreen() {
    document.getElementById('dnisScreen').style.display = '';
    document.getElementById('promptScreen').style.display = 'none';
    currentDnis = '';
}

function loadDnisList() {
    var container = document.getElementById('dnisContainer');
    container.innerHTML = '<div class="loading-container"><span uk-spinner="ratio: 2"></span><p class="uk-text-muted uk-margin-top">Loading DNIS list...</p></div>';
    fetch(API_BASE + '/dnis-list?env=' + encodeURIComponent(currentEnv))
    .then(function(r) { return r.json(); })
    .then(function(data) { renderDnisCards(data); })
    .catch(function(e) {
        container.innerHTML = '<p class="uk-text-danger uk-text-center">Failed to load DNIS list: ' + escapeHtml(e.message) + '</p>';
    });
}

function renderDnisCards(list) {
    var container = document.getElementById('dnisContainer');
    if (!list || list.length === 0) {
        container.innerHTML = '<div class="uk-text-center uk-padding"><span uk-icon="icon: warning; ratio:2" class="uk-text-warning"></span><p class="uk-text-muted uk-margin-top">No DNIS entries found for <strong>' + escapeHtml(currentEnv) + '</strong> environment.<br>Check the BG_DnisConfig table.</p></div>';
        return;
    }
    var html = '<div class="dnis-grid">';
    list.forEach(function(item) {
        html += '<div class="dnis-card" onclick="selectDnis(\'' + escapeHtml(item.dnis) + '\')">';
        html += '<div class="dnis-label">' + escapeHtml(item.dnis || '—') + '</div>';
        if (item.calledAddress) html += '<div class="dnis-sub">📞 ' + escapeHtml(item.calledAddress) + '</div>';
        if (item.abi)           html += '<div class="dnis-sub">ABI: ' + escapeHtml(item.abi) + '</div>';
        if (item.environment)   html += '<div class="dnis-sub uk-badge">' + escapeHtml(item.environment) + '</div>';
        html += '</div>';
    });
    html += '</div>';
    container.innerHTML = html;
}

// ── PROMPT TABLE SCREEN ────────────────────────────────────────────────────────
function selectDnis(dnis) {
    currentDnis = dnis;
    document.getElementById('selectedDnisLabel').textContent = dnis;
    document.getElementById('dnisScreen').style.display  = 'none';
    document.getElementById('promptScreen').style.display = '';
    document.getElementById('filterInput').value = '';
    loadPromptsForDnis();
}

function loadPromptsForDnis() {
    document.getElementById('promptTableBody').innerHTML =
        '<tr><td colspan="7" style="text-align:center;padding:40px;"><span uk-spinner></span> Loading prompts...</td></tr>';
    fetch(API_BASE + '/by-dnis?env=' + encodeURIComponent(currentEnv) + '&dnis=' + encodeURIComponent(currentDnis))
    .then(function(r) { return r.json(); })
    .then(function(data) {
        allRows = data;
        currentPage = 1;
        applyFilter();
    })
    .catch(function(e) {
        document.getElementById('promptTableBody').innerHTML =
            '<tr><td colspan="7" class="uk-text-danger" style="text-align:center;padding:30px;">Failed to load: ' + escapeHtml(e.message) + '</td></tr>';
    });
}

function applyFilter() {
    var q = (document.getElementById('filterInput').value || '').toLowerCase().trim();
    if (!q) {
        filteredRows = allRows.slice();
    } else {
        filteredRows = allRows.filter(function(row) {
            var name     = (row.name || '').toLowerCase();
            var asrTts   = ((row.asr || {}).ttsText || '').toLowerCase();
            var tmfTts   = ((row.tmf || {}).ttsText || '').toLowerCase();
            return name.indexOf(q) !== -1 || asrTts.indexOf(q) !== -1 || tmfTts.indexOf(q) !== -1;
        });
    }
    document.getElementById('filterCount').textContent =
        q ? ('Showing ' + filteredRows.length + ' / ' + allRows.length) : (allRows.length + ' prompts');
    currentPage = 1;
    renderPage();
}

function renderPage() {
    var start   = (currentPage - 1) * PAGE_SIZE;
    var pageRows = filteredRows.slice(start, start + PAGE_SIZE);
    var tbody = document.getElementById('promptTableBody');

    if (filteredRows.length === 0) {
        tbody.innerHTML = '<tr>' +
            '<td class="col-id">—</td>' +
            '<td class="col-name uk-text-muted">—</td>' +
            '<td class="col-tts uk-text-muted" colspan="2">No prompts found</td>' +
            '<td class="col-tts uk-text-muted" colspan="2">—</td>' +
            '<td></td>' +
            '</tr>';
        document.getElementById('paginationBar').innerHTML = '';
        return;
    }

    var html = '';
    pageRows.forEach(function(row) {
        var asr = row.asr || {};
        var tmf = row.tmf || {};
        html += '<tr>';
        html += '<td class="col-id">' + row.rowId + '</td>';
        html += '<td class="col-name">' + escapeHtml(row.name || '') + '</td>';
        // ASR TTS
        html += renderTtsCell(asr, row.name, 'ASR');
        // ASR Audio
        html += renderAudioCell(asr, row.name + '_asr', 'ASR');
        // TMF TTS
        html += renderTtsCell(tmf, row.name, 'TMF');
        // TMF Audio
        html += renderAudioCell(tmf, row.name + '_tmf', 'TMF');
        // Actions (delete whole pair)
        html += '<td>';
        if (asr.id && asr.found) {
            html += '<button class="uk-button uk-button-danger uk-button-small" style="font-size:11px;" ' +
                'onclick="confirmDeletePrompt(\'' + escapeHtml(asr.id) + '\',\'' + escapeHtml(tmf.id||'') + '\',\'' + escapeHtml(row.name) + '\')" ' +
                'title="Delete both ASR and TMF prompts">' +
                '<span uk-icon="icon:trash;ratio:0.8"></span> Del All</button>';
        }
        html += '</td>';
        html += '</tr>';
    });
    tbody.innerHTML = html;
    renderPagination();
}

function renderTtsCell(info, name, type) {
    var tts = (info.ttsText || '').trim();
    var pid = info.id || '';
    var rid = info.resourceId || '';
    var pname = info.name || '';
    var html = '<td class="col-tts">';
    if (tts) {
        html += '<div class="tts-truncated" title="' + escapeHtml(tts) + '">' + escapeHtml(tts.length > 120 ? tts.substring(0,120) + '…' : tts) + '</div>';
    } else {
        html += '<span class="no-content">No TTS</span>';
    }
    html += '<div class="action-buttons" style="margin-top:4px;">';
    html += '<button class="uk-button uk-button-default uk-button-small" onclick="openTtsModal(\'' + escapeHtml(pid) + '\',\'' + escapeHtml(rid) + '\',\'' + escapeHtml(pname) + '\',\'' + escapeHtml(name + ' [' + type + ']') + '\',\'' + escapeHtml(tts.replace(/'/g,"\\'").replace(/\n/g,"\\n")) + '\')">' +
        '<span uk-icon="icon:pencil;ratio:0.8"></span></button>';
    if (tts && pid) {
        html += '<button class="uk-button uk-button-danger uk-button-small" onclick="confirmClearTts(\'' + escapeHtml(pid) + '\',\'' + escapeHtml(rid) + '\',\'' + escapeHtml(name + ' [' + type + ']') + '\')">' +
            '<span uk-icon="icon:trash;ratio:0.8"></span></button>';
    }
    html += '</div></td>';
    return html;
}

function renderAudioCell(info, uiKey, type) {
    var hasAudio = info.hasAudio === true;
    var audioUrl = info.audioUrl || '';
    var pid      = info.id || '';
    var rid      = info.resourceId || '';
    var lang     = info.language || 'it-it';
    var tts      = (info.ttsText || '').replace(/'/g,"\\'").replace(/\n/g,"\\n");
    var pname    = info.name || '';
    var dname    = info.displayName || '';
    var html     = '<td class="col-audio"><div class="action-buttons">';
    if (hasAudio && audioUrl) {
        html += '<audio id="aud_' + escapeHtml(uiKey) + '" style="display:none;"><source src="' + API_BASE + '/audio?audioUrl=' + encodeURIComponent(audioUrl) + '" type="audio/wav"></audio>';
        html += '<button class="uk-button uk-button-default uk-button-small" onclick="togglePlay(\'' + escapeHtml(uiKey) + '\')" id="pb_' + escapeHtml(uiKey) + '"><span uk-icon="icon:play;ratio:0.8"></span></button>';
        html += '<button class="uk-button uk-button-secondary uk-button-small" onclick="downloadAudio(\'' + escapeHtml(audioUrl) + '\',\'' + escapeHtml(dname) + '_' + type + '\')"><span uk-icon="icon:download;ratio:0.8"></span></button>';
        if (pid) {
            html += '<button class="uk-button uk-button-small btn-del-audio" onclick="confirmDeleteAudio(\'' + escapeHtml(pid) + '\',\'' + escapeHtml(rid) + '\',\'' + escapeHtml(lang) + '\',\'' + tts + '\',\'' + escapeHtml(dname + ' [' + type + ']') + '\')"><span uk-icon="icon:trash;ratio:0.8"></span></button>';
        }
    } else {
        html += '<span class="no-content">No audio</span>&nbsp;';
    }
    if (pid) {
        html += '<button class="uk-button uk-button-primary uk-button-small" onclick="openUploadModal(\'' + escapeHtml(pid) + '\',\'' + escapeHtml(rid) + '\',\'' + escapeHtml(pname) + '\',\'' + escapeHtml(dname + ' [' + type + ']') + '\')"><span uk-icon="icon:upload;ratio:0.8"></span></button>';
    }
    html += '</div></td>';
    return html;
}

function renderPagination() {
    var totalPages = Math.ceil(filteredRows.length / PAGE_SIZE);
    if (totalPages <= 1) { document.getElementById('paginationBar').innerHTML = ''; return; }
    var html = '<span class="page-info">' + filteredRows.length + ' results &nbsp;|&nbsp; Page ' + currentPage + ' of ' + totalPages + '</span>&nbsp;&nbsp;';
    if (currentPage > 1) html += '<button class="page-btn" onclick="goToPage(' + (currentPage-1) + ')">‹ Prev</button>';
    // show max 7 page buttons around current
    var from = Math.max(1, currentPage - 3), to = Math.min(totalPages, currentPage + 3);
    for (var p = from; p <= to; p++) {
        html += '<button class="page-btn' + (p === currentPage ? ' active' : '') + '" onclick="goToPage(' + p + ')">' + p + '</button>';
    }
    if (currentPage < totalPages) html += '<button class="page-btn" onclick="goToPage(' + (currentPage+1) + ')">Next ›</button>';
    document.getElementById('paginationBar').innerHTML = html;
}

function goToPage(p) {
    currentPage = p;
    renderPage();
    document.getElementById('promptScreen').scrollIntoView({ behavior: 'smooth' });
}

// ── AUDIO CONTROLS ─────────────────────────────────────────────────────────────
function togglePlay(key) {
    var audio = document.getElementById('aud_' + key);
    var btn   = document.getElementById('pb_' + key);
    if (!audio) return;
    if (audio.paused) {
        document.querySelectorAll('audio').forEach(function(a) { a.pause(); });
        document.querySelectorAll('[id^="pb_"]').forEach(function(b) { b.innerHTML = '<span uk-icon="icon:play;ratio:0.8"></span>'; });
        audio.play();
        btn.innerHTML = '<span uk-icon="icon:ban;ratio:0.8"></span>';
    } else {
        audio.pause(); audio.currentTime = 0;
        btn.innerHTML = '<span uk-icon="icon:play;ratio:0.8"></span>';
    }
    audio.onended = function() { if (btn) btn.innerHTML = '<span uk-icon="icon:play;ratio:0.8"></span>'; };
}

function openUploadModal(promptId, resourceId, promptName, displayName) {
    document.getElementById('upload_promptId').value = promptId;
    document.getElementById('upload_resourceId').value = resourceId;
    document.getElementById('upload_promptName').value = promptName;
    document.getElementById('upload_displayName').textContent = displayName;
    document.getElementById('audioFileInput').value = '';
    document.getElementById('audioFileInput').nextElementSibling.value = '';
    UIkit.modal('#uploadModal').show();
}

function uploadAudio() {
    var promptId   = document.getElementById('upload_promptId').value;
    var resourceId = document.getElementById('upload_resourceId').value;
    var promptName = document.getElementById('upload_promptName').value;
    var fileInput  = document.getElementById('audioFileInput');
    if (!fileInput.files || fileInput.files.length === 0) { UIkit.notification({message:'Please select a WAV file!', status:'warning'}); return; }
    var file = fileInput.files[0];
    if (!file.name.toLowerCase().endsWith('.wav')) { UIkit.notification({message:'Only WAV files accepted.', status:'danger'}); return; }
    if (file.size > 50 * 1024 * 1024) { UIkit.notification({message:'File too large (max 50MB).', status:'danger'}); return; }
    var fd = new FormData();
    fd.append('audioFile', file);
    UIkit.notification({message:'Uploading...', status:'primary'});
    var url = API_BASE + '/upload?promptName=' + encodeURIComponent(promptName);
    if (promptId)   url += '&promptId='   + encodeURIComponent(promptId);
    if (resourceId) url += '&resourceId=' + encodeURIComponent(resourceId);
    fetch(url, { method:'POST', body:fd })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        if (res.success) { UIkit.notification({message:'Audio uploaded!', status:'success'}); UIkit.modal('#uploadModal').hide(); loadPromptsForDnis(); }
        else { UIkit.notification({message: res.message || 'Upload failed', status:'danger'}); }
    }).catch(function(e) { UIkit.notification({message:'Upload error: ' + e.message, status:'danger'}); });
}

function downloadAudio(audioUrl, name) {
    var a = document.createElement('a');
    a.href = API_BASE + '/download?audioUrl=' + encodeURIComponent(audioUrl);
    a.download = name + '.wav';
    document.body.appendChild(a); a.click(); document.body.removeChild(a);
}

function confirmDeleteAudio(pid, rid, lang, tts, name) {
    UIkit.modal.confirm('Delete audio for <strong>' + escapeHtml(name) + '</strong>? TTS and prompt record will be kept.')
    .then(function() {
        UIkit.notification({message:'Deleting audio...', status:'primary'});
        fetch(API_BASE + '/audio?promptId=' + encodeURIComponent(pid) + '&resourceId=' + encodeURIComponent(rid) + '&language=' + encodeURIComponent(lang) + '&ttsText=' + encodeURIComponent(tts), { method:'DELETE' })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            UIkit.notification({message: res.success ? 'Audio deleted.' : (res.message||'Failed'), status: res.success?'success':'danger'});
            if (res.success) setTimeout(loadPromptsForDnis, 1500);
        }).catch(function(e){ UIkit.notification({message:'Error: '+e.message, status:'danger'}); });
    }, function(){});
}

// ── TTS CONTROLS ───────────────────────────────────────────────────────────────
function openTtsModal(promptId, resourceId, promptName, displayName, currentTts) {
    document.getElementById('tts_promptId').value = promptId;
    document.getElementById('tts_resourceId').value = resourceId;
    document.getElementById('tts_promptName').value = promptName;
    document.getElementById('tts_displayName').textContent = displayName;
    document.getElementById('ttsTextInput').value = currentTts || '';
    UIkit.modal('#ttsModal').show();
}

function saveTtsText() {
    var promptId   = document.getElementById('tts_promptId').value;
    var resourceId = document.getElementById('tts_resourceId').value;
    var promptName = document.getElementById('tts_promptName').value;
    var ttsText    = document.getElementById('ttsTextInput').value;
    UIkit.notification({message:'Saving TTS...', status:'primary'});
    fetch(API_BASE + '/tts', { method:'POST', headers:{'Content-Type':'application/json'},
        body: JSON.stringify({promptId:promptId, resourceId:resourceId, promptName:promptName, ttsText:ttsText}) })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        if (res.success) { UIkit.notification({message:'TTS saved!', status:'success', timeout:4000}); UIkit.modal('#ttsModal').hide(); setTimeout(loadPromptsForDnis, 2000); }
        else { UIkit.notification({message: res.message||'Failed', status:'danger'}); }
    }).catch(function(e){ UIkit.notification({message:'Error: '+e.message, status:'danger'}); });
}

function confirmClearTts(pid, rid, name) {
    UIkit.modal.confirm('Clear TTS text for <strong>' + escapeHtml(name) + '</strong>? Audio and prompt record will be kept.')
    .then(function() {
        UIkit.notification({message:'Clearing TTS...', status:'primary'});
        fetch(API_BASE + '/tts?promptId=' + encodeURIComponent(pid) + '&resourceId=' + encodeURIComponent(rid), { method:'DELETE' })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            UIkit.notification({message: res.success ? 'TTS cleared.' : (res.message||'Failed'), status: res.success?'success':'danger'});
            if (res.success) setTimeout(loadPromptsForDnis, 1500);
        }).catch(function(e){ UIkit.notification({message:'Error: '+e.message, status:'danger'}); });
    }, function(){});
}

// ── DELETE FULL PROMPT PAIR ────────────────────────────────────────────────────
function confirmDeletePrompt(asrId, tmfId, name) {
    UIkit.modal.confirm('<p>Delete <strong>all prompts</strong> for <strong>"' + escapeHtml(name) + '"</strong>?</p><p class="uk-text-danger">Both ASR and TMF prompts will be permanently removed from Genesys Cloud. This cannot be undone.</p>')
    .then(function() {
        UIkit.notification({message:'Deleting...', status:'primary'});
        var dels = [];
        if (asrId) dels.push(fetch(API_BASE + '/prompt?promptId=' + encodeURIComponent(asrId), {method:'DELETE'}).then(function(r){return r.json();}));
        if (tmfId) dels.push(fetch(API_BASE + '/prompt?promptId=' + encodeURIComponent(tmfId), {method:'DELETE'}).then(function(r){return r.json();}));
        Promise.all(dels).then(function() {
            UIkit.notification({message:'Prompts deleted.', status:'success'});
            loadPromptsForDnis();
        }).catch(function(e){ UIkit.notification({message:'Error: '+e.message, status:'danger'}); });
    }, function(){});
}

function escapeHtml(text) {
    if (!text) return '';
    var d = document.createElement('div');
    d.textContent = text;
    return d.innerHTML;
}
</script>
</body>
</html>
