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
        .col-chk  { width: 32px;  text-align: center; }
        .col-id   { width: 40px;  text-align: center; color: #999; font-size: 12px; }
        .col-name { width: 150px; font-weight: 600; color: #333; word-break: break-word; }
        .col-tts  { max-width: 200px; word-break: break-word; color: #555; font-size: 12px; line-height: 1.4; }
        .col-audio{ width: 170px; }
        .col-del  { width: 44px;  text-align: center; }
        .action-buttons { display: flex; gap: 4px; flex-wrap: wrap; margin-top: 4px; }
        .action-buttons button { padding: 3px 7px; font-size: 11px; }
        .no-content { color: #bbb; font-style: italic; font-size: 11px; }
        .btn-del-audio { background: #fd7e14; border-color: #fd7e14; color: white; }
        .btn-del-audio:hover { background: #e36910; }
        .btn-clear-tts { background: #dc3545; border-color: #dc3545; color: white; }
        .btn-clear-tts:hover { background: #b02a37; }
        .btn-del-all { background: none; border: none; color: #dc3545; cursor: pointer; padding: 4px 6px; font-size: 18px; line-height: 1; }
        .btn-del-all:hover { color: #a71d2a; }
        .csv-toolbar { display: flex; gap: 10px; align-items: center; padding: 10px 20px; background: #f1f3f9; border-bottom: 1px solid #dee2e6; flex-wrap: wrap; }
        .csv-toolbar .sel-count { font-size: 13px; color: #555; }
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
    <div id="dnisScreen">
        <div id="dnisContainer">
            <div class="loading-container"><span uk-spinner="ratio: 2"></span><p class="uk-text-muted uk-margin-top">Loading DNIS list...</p></div>
        </div>
    </div>
    <div id="promptScreen" style="display:none;">
        <div class="prompt-card">
            <div class="section-header">
                <span class="back-btn" onclick="showDnisScreen()"><span uk-icon="arrow-left"></span> Back to DNIS list</span>
                <span style="font-weight:600; color:#444;">DNIS: <span id="selectedDnisLabel" style="color:#667eea;"></span></span>
                <div class="filter-bar">
                    <input type="text" id="filterInput" placeholder="🔍 Filter by name or TTS text..." oninput="debounceFilter()">
                    <span id="filterCount" class="uk-text-muted" style="font-size:12px;"></span>
                </div>
                <button class="uk-button uk-button-primary uk-button-small" onclick="openAddPromptModal()">
                    <span uk-icon="icon:plus;ratio:0.8"></span> Add Prompt
                </button>
            </div>
            <div class="csv-toolbar" id="csvToolbar">
                    <label style="display:flex;align-items:center;gap:6px;cursor:pointer;">
                        <input type="checkbox" id="selectAllChk" title="Select / Deselect all on this page"> <span style="font-size:13px;font-weight:600;">Select All</span>
                    </label>
                    <span class="sel-count" id="selCount">0 selected</span>
                    <button class="uk-button uk-button-primary uk-button-small" onclick="exportSelectedCsv()" id="btnExportCsv" disabled>
                        <span uk-icon="icon:download;ratio:0.8"></span> Export CSV
                    </button>
                    <button class="uk-button uk-button-default uk-button-small" onclick="exportAllCsv()">
                        <span uk-icon="icon:table;ratio:0.8"></span> Export All CSV
                    </button>
                    <button class="uk-button uk-button-danger uk-button-small" onclick="deleteSelectedPrompts()" id="btnDeleteSelected" disabled>
                        <span uk-icon="icon:trash;ratio:0.8"></span> Delete Selected
                    </button>
                    <button class="uk-button uk-button-primary uk-button-small" onclick="createMissingPrompts()" id="btnCreateMissing">
                        <span uk-icon="icon:plus-circle;ratio:0.8"></span> Create Missing
                    </button>
                </div>
                <div style="overflow-x:auto;">
                <table class="prompt-table" id="promptTable">
                    <thead>
                        <tr>
                            <th class="col-chk"><input type="checkbox" id="selectAllChkHeader" title="Select all" onchange="toggleSelectAll(this.checked)"></th>
                            <th class="col-id">#</th>
                            <th style="width:150px;">Name</th>
                            <th style="width:200px;">ASR TTS</th>
                            <th style="width:180px;">ASR Audio</th>
                            <th style="width:200px;">TMF TTS</th>
                            <th style="width:180px;">TMF Audio</th>
                            <th class="col-del" title="Actions">⚙</th>
                        </tr>
                    </thead>
                    <tbody id="promptTableBody"></tbody>
                </table>
                </div>
            <div class="pagination" id="paginationBar"></div>
        </div>
    </div>
</div>

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

<div id="addPromptModal" uk-modal>
    <div class="uk-modal-dialog uk-modal-body">
        <h2 class="uk-modal-title"><span uk-icon="plus-circle"></span> Add New Prompt</h2>
        <button class="uk-modal-close-default" type="button" uk-close></button>
        <div class="uk-margin">
            <label class="uk-form-label">Base Prompt Name</label>
            <input class="uk-input" type="text" id="addPrompt_name"
                   placeholder="e.g. V_03075_BG_test" oninput="updateAddPromptPreview()">
            <div style="font-size:11px; margin-top:6px; color:#888; min-height:32px;">
                <span id="addPrompt_previewAsr" style="display:block; color:#667eea;"></span>
                <span id="addPrompt_previewTmf" style="display:block; color:#764ba2;"></span>
            </div>
        </div>
        <div class="uk-margin">
            <label class="uk-form-label">ASR TTS Text <span class="uk-text-muted" style="font-size:11px;">(optional)</span></label>
            <textarea class="uk-textarea" id="addPrompt_asrTts" rows="3" placeholder="Enter TTS text for ASR prompt..."></textarea>
        </div>
        <div class="uk-margin">
            <label class="uk-form-label">TMF TTS Text <span class="uk-text-muted" style="font-size:11px;">(optional)</span></label>
            <textarea class="uk-textarea" id="addPrompt_tmfTts" rows="3" placeholder="Enter TTS text for TMF prompt..."></textarea>
        </div>
        <div class="uk-margin">
            <label class="uk-form-label">ASR Audio File <span class="uk-text-muted" style="font-size:11px;">(WAV, optional)</span></label>
            <input type="file" class="uk-input" id="addPrompt_asrAudio" accept=".wav">
        </div>
        <div class="uk-margin">
            <label class="uk-form-label">TMF Audio File <span class="uk-text-muted" style="font-size:11px;">(WAV, optional)</span></label>
            <input type="file" class="uk-input" id="addPrompt_tmfAudio" accept=".wav">
        </div>
        <div class="uk-margin uk-text-right">
            <button class="uk-button uk-button-default uk-modal-close" type="button">Cancel</button>
            <button class="uk-button uk-button-primary" type="button" onclick="saveNewPrompt()">
                <span uk-icon="check"></span> Create Prompts
            </button>
        </div>
    </div>
</div>

<script>
var API_BASE      = 'api/prompts';
var currentEnv    = 'V_';
var currentDnis   = '';
var allRows       = [];
var filteredRows  = [];
var currentPage   = 1;
var PAGE_SIZE     = 100;
var _filterTimer  = null;

document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('btnConfirmUpload').addEventListener('click', uploadAudio);
    document.getElementById('btnConfirmTts').addEventListener('click', saveTtsText);
    document.getElementById('audioFileInput').addEventListener('change', function() {
        this.nextElementSibling.value = this.files.length > 0 ? this.files[0].name : '';
    });
    document.getElementById('selectAllChk').addEventListener('change', function() {
        toggleSelectAll(this.checked);
    });
    loadDnisList();
});

function showDnisScreen() {
    document.getElementById('dnisScreen').style.display = '';
    document.getElementById('promptScreen').style.display = 'none';
    currentDnis = '';
}

function loadDnisList() {
    var container = document.getElementById('dnisContainer');
    container.innerHTML = '<div class="loading-container"><span uk-spinner="ratio: 2"></span><p class="uk-text-muted uk-margin-top">Loading DNIS list...</p></div>';
    fetch(API_BASE + '/dnis-list')
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
        '<tr><td colspan="8" style="text-align:center;padding:40px;"><span uk-spinner></span> Loading prompts...</td></tr>';
    fetch(API_BASE + '/by-dnis?dnis=' + encodeURIComponent(currentDnis))
    .then(function(r) { return r.json(); })
    .then(function(data) {
        allRows = data;
        currentPage = 1;
        var hdr = document.getElementById('selectAllChkHeader');
        if (hdr) hdr.checked = false;
        var top = document.getElementById('selectAllChk');
        if (top) top.checked = false;
        applyFilter();
    })
    .catch(function(e) {
        document.getElementById('promptTableBody').innerHTML =
            '<tr><td colspan="8" class="uk-text-danger" style="text-align:center;padding:30px;">Failed to load: ' + escapeHtml(e.message) + '</td></tr>';
    });
}

function debounceFilter() {
    clearTimeout(_filterTimer);
    _filterTimer = setTimeout(applyFilter, 300);
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
            '<td class="col-chk"></td>' +
            '<td class="col-id">—</td>' +
            '<td class="col-name uk-text-muted">—</td>' +
            '<td class="col-tts uk-text-muted" colspan="4">No prompts found</td>' +
            '<td class="col-del"></td>' +
            '</tr>';
        document.getElementById('paginationBar').innerHTML = '';
        updateSelCount();
        return;
    }

    var html = '';
    pageRows.forEach(function(row) {
        var asr = row.asr || {};
        var tmf = row.tmf || {};
        html += '<tr id="tr_' + row.rowId + '">';
        html += '<td class="col-chk"><input type="checkbox" class="row-chk" data-rowid="' + row.rowId + '" onchange="updateSelCount()"></td>';
        html += '<td class="col-id">' + row.rowId + '</td>';
        var envLabel = row.env || '';
        var envDisplay = envLabel.replace('_', '');
        var envColor  = envLabel === 'V_' ? '#28a745' : (envLabel === 'P_' ? '#1e87f0' : '#6c757d');
        html += '<td class="col-name">' +
            (envLabel ? '<span class="uk-label" style="background:' + envColor + ';font-size:10px;padding:1px 5px;margin-right:4px;border-radius:3px;">' + envDisplay + '</span>' : '') +
            escapeHtml(row.name || '') + '</td>';
        html += renderTtsCell(asr, row.name, 'ASR');
        html += renderAudioCell(asr, row.name + '_asr', 'ASR');
        html += renderTtsCell(tmf, row.name, 'TMF');
        html += renderAudioCell(tmf, row.name + '_tmf', 'TMF');
        html += '<td class="col-del" style="white-space:nowrap;">';
        html += '<button class="uk-button uk-button-default uk-button-small" title="Inline edit row" ' +
            'onclick="startInlineEdit(' + row.rowId + ')" style="margin-bottom:3px;">' +
            '<span uk-icon="icon:pencil;ratio:0.8"></span></button><br>';
        html += '<button class="btn-del-all" title="Delete both ASR and TMF prompts" ' +
            'onclick="confirmDeletePrompt(\'' + escapeHtml(asr.id||'') + '\',\'' + escapeHtml(tmf.id||'') + '\',\'' + escapeHtml(row.name) + '\')">🗑</button>';
        html += '</td>';
        html += '</tr>';
    });
    tbody.innerHTML = html;
    updateSelCount();
    renderPagination();
}

function renderTtsCell(info, name, type) {
    if (info.needsCreation) {
        return '<td class="col-tts"><span class="uk-label uk-label-danger" title="' + escapeHtml(info.name || '') + '">Not Created</span></td>';
    }
    var tts  = (info.ttsText || '').trim();
    var pid  = info.id || '';
    var rid  = info.resourceId || '';
    var pname = info.name || '';
    var safeLabel = escapeHtml(name + ' [' + type + ']');
    var safeTts   = escapeHtml(tts.replace(/'/g,"\\'").replace(/\n/g,"\\n"));
    var html = '<td class="col-tts">';
    if (tts) {
        html += '<div class="tts-truncated" title="' + escapeHtml(tts) + '">' +
            escapeHtml(tts.length > 100 ? tts.substring(0,100) + '…' : tts) + '</div>';
    } else {
        html += '<span class="no-content">No TTS</span>';
    }
    html += '<div class="action-buttons">';
    html += '<button class="uk-button uk-button-default uk-button-small" title="Edit TTS" ' +
        'onclick="openTtsModal(\'' + escapeHtml(pid) + '\',\'' + escapeHtml(rid) + '\',\'' +
        escapeHtml(pname) + '\',\'' + safeLabel + '\',\'' + safeTts + '\')">' +
        '<span uk-icon="icon:pencil;ratio:0.8"></span></button>';
    if (tts && pid) {
        html += '<button class="uk-button btn-clear-tts uk-button-small" title="Clear TTS text" ' +
            'onclick="confirmClearTts(\'' + escapeHtml(pid) + '\',\'' + escapeHtml(rid) + '\',\'' + safeLabel + '\')">' +
            '<span uk-icon="icon:trash;ratio:0.8"></span> TTS</button>';
    }
    html += '</div></td>';
    return html;
}

function renderAudioCell(info, uiKey, type) {
    if (info.needsCreation) {
        return '<td class="col-audio"><span class="uk-label uk-label-danger">Not Created</span></td>';
    }
    var hasAudio = info.hasAudio === true;
    var audioUrl = info.audioUrl || '';
    var pid      = info.id || '';
    var rid      = info.resourceId || '';
    var lang     = info.language || 'it-it';
    var tts      = (info.ttsText || '').replace(/'/g,"\\'").replace(/\n/g,"\\n");
    var pname    = info.name || '';
    var dname    = info.displayName || '';
    var safeLabel = escapeHtml(dname + ' [' + type + ']');
    var html     = '<td class="col-audio"><div class="action-buttons">';
    if (hasAudio && audioUrl) {
        html += '<audio id="aud_' + escapeHtml(uiKey) + '" style="display:none;">' +
            '<source src="' + API_BASE + '/audio?audioUrl=' + encodeURIComponent(audioUrl) + '" type="audio/wav"></audio>';
        html += '<button class="uk-button uk-button-default uk-button-small" title="Play" ' +
            'onclick="togglePlay(\'' + escapeHtml(uiKey) + '\')" id="pb_' + escapeHtml(uiKey) + '">' +
            '<span uk-icon="icon:play;ratio:0.8"></span></button>';
        html += '<button class="uk-button uk-button-secondary uk-button-small" title="Download" ' +
            'onclick="downloadAudio(\'' + escapeHtml(audioUrl) + '\',\'' + escapeHtml(dname) + '_' + type + '\')">' +
            '<span uk-icon="icon:download;ratio:0.8"></span></button>';
        if (pid) {
            html += '<button class="uk-button btn-del-audio uk-button-small" title="Delete audio file" ' +
                'onclick="confirmDeleteAudio(\'' + escapeHtml(pid) + '\',\'' + escapeHtml(rid) + '\',\'' +
                escapeHtml(lang) + '\',\'' + tts + '\',\'' + safeLabel + '\')">' +
                '<span uk-icon="icon:trash;ratio:0.8"></span></button>';
        }
    } else {
        html += '<span class="no-content">No audio</span>&nbsp;';
    }
    if (pid) {
        html += '<button class="uk-button uk-button-primary uk-button-small" title="Upload audio" ' +
            'onclick="openUploadModal(\'' + escapeHtml(pid) + '\',\'' + escapeHtml(rid) + '\',\'' +
            escapeHtml(pname) + '\',\'' + safeLabel + '\')">' +
            '<span uk-icon="icon:upload;ratio:0.8"></span></button>';
    }
    html += '</div></td>';
    return html;
}

function renderPagination() {
    var totalPages = Math.ceil(filteredRows.length / PAGE_SIZE);
    if (totalPages <= 1) { document.getElementById('paginationBar').innerHTML = ''; return; }
    var html = '<span class="page-info">' + filteredRows.length + ' results &nbsp;|&nbsp; Page ' + currentPage + ' of ' + totalPages + '</span>&nbsp;&nbsp;';
    if (currentPage > 1) html += '<button class="page-btn" onclick="goToPage(' + (currentPage-1) + ')">‹ Prev</button>';
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
function deleteSelectedPrompts() {
    var selectedIds = getSelectedRowIds();
    if (selectedIds.length === 0) {
        UIkit.notification({message: 'No rows selected!', status: 'warning'});
        return;
    }
    var promptIdsToDelete = [];
    selectedIds.forEach(function(rowId) {
        var row = filteredRows.find(function(r) { return r.rowId === rowId; });
        if (!row) return;
        if (row.asr && row.asr.id) promptIdsToDelete.push(row.asr.id);
        if (row.tmf && row.tmf.id) promptIdsToDelete.push(row.tmf.id);
    });

    if (promptIdsToDelete.length === 0) {
        UIkit.notification({message: 'Selected rows have no prompts to delete.', status: 'warning'});
        return;
    }

    UIkit.modal.confirm(
        '<p>Are you sure you want to delete <strong>' + selectedIds.length + '</strong> selected prompt record(s)?</p>' +
        '<p class="uk-text-danger"><strong>This action cannot be undone.</strong> A total of <strong>' + promptIdsToDelete.length + '</strong> prompt(s) (ASR/TMF) will be permanently removed from Genesys Cloud.</p>'
    ).then(function() {
        UIkit.notification({message: 'Deleting ' + promptIdsToDelete.length + ' prompt(s)...', status: 'primary'});

        var dels = promptIdsToDelete.map(function(pid) {
            return fetch(API_BASE + '/prompt?promptId=' + encodeURIComponent(pid), {method: 'DELETE'})
                   .then(function(r) { return r.json(); });
        });

        Promise.all(dels).then(function(results) {
            var failed = results.filter(function(res) { return !res.success; }).length;
            if (failed === 0) {
                UIkit.notification({message: selectedIds.length + ' prompt(s) deleted successfully.', status: 'success'});
            } else {
                UIkit.notification({message: (promptIdsToDelete.length - failed) + ' deleted, ' + failed + ' failed.', status: 'warning'});
            }
            document.querySelectorAll('.row-chk').forEach(function(c) { c.checked = false; });
            var hdr = document.getElementById('selectAllChkHeader');
            if (hdr) hdr.checked = false;
            var top = document.getElementById('selectAllChk');
            if (top) top.checked = false;
            loadPromptsForDnis();
        }).catch(function(e) {
            UIkit.notification({message: 'Error: ' + e.message, status: 'danger'});
        });
    }, function() {});
}

function startInlineEdit(rowId) {
    var row = allRows.find(function(r) { return r.rowId === rowId; });
    if (!row) return;
    var asr = row.asr || {};
    var tmf = row.tmf || {};
    var tr = document.getElementById('tr_' + rowId);
    if (!tr) return;

    var asrTts  = escapeHtml(asr.ttsText  || '');
    var tmfTts  = escapeHtml(tmf.ttsText  || '');
    var asrId   = escapeHtml(asr.id       || '');
    var tmfId   = escapeHtml(tmf.id       || '');
    var asrRid  = escapeHtml(asr.resourceId || '');
    var tmfRid  = escapeHtml(tmf.resourceId || '');
    var asrName = escapeHtml(asr.name     || '');
    var tmfName = escapeHtml(tmf.name     || '');

    var asrTtsCell  = asr.needsCreation
        ? '<td class="col-tts"><span class="uk-label uk-label-danger">Not Created</span></td>'
        : '<td class="col-tts"><textarea class="uk-textarea" id="edit_asr_tts_' + rowId + '" rows="3" style="font-size:12px;">' + asrTts + '</textarea></td>';

    var tmfTtsCell  = tmf.needsCreation
        ? '<td class="col-tts"><span class="uk-label uk-label-danger">Not Created</span></td>'
        : '<td class="col-tts"><textarea class="uk-textarea" id="edit_tmf_tts_' + rowId + '" rows="3" style="font-size:12px;">' + tmfTts + '</textarea></td>';

    var asrAudioCell = asr.needsCreation
        ? '<td class="col-audio"><span class="uk-label uk-label-danger">Not Created</span></td>'
        : '<td class="col-audio"><input type="file" id="edit_asr_audio_' + rowId + '" accept=".wav" style="font-size:11px;"></td>';

    var tmfAudioCell = tmf.needsCreation
        ? '<td class="col-audio"><span class="uk-label uk-label-danger">Not Created</span></td>'
        : '<td class="col-audio"><input type="file" id="edit_tmf_audio_' + rowId + '" accept=".wav" style="font-size:11px;"></td>';

    var envLabel   = row.env || '';
    var envDisplay = envLabel.replace('_', '');
    var envColor   = envLabel === 'V_' ? '#28a745' : (envLabel === 'P_' ? '#1e87f0' : '#6c757d');
    var envBadge   = envLabel
        ? '<span class="uk-label" style="background:' + envColor + ';font-size:10px;padding:1px 5px;margin-right:4px;border-radius:3px;">' + envDisplay + '</span>'
        : '';

    tr.innerHTML =
        '<td class="col-chk"><input type="checkbox" class="row-chk" data-rowid="' + rowId + '" onchange="updateSelCount()"></td>' +
        '<td class="col-id">' + rowId + '</td>' +
        '<td class="col-name">' + envBadge + escapeHtml(row.name || '') + '</td>' +
        asrTtsCell + asrAudioCell + tmfTtsCell + tmfAudioCell +
        '<td class="col-del" style="white-space:nowrap;">' +
        '<button class="uk-button uk-button-primary uk-button-small" style="margin-bottom:3px;" onclick="saveInlineEdit(' + rowId + ',\'' + asrId + '\',\'' + asrRid + '\',\'' + asrName + '\',\'' + tmfId + '\',\'' + tmfRid + '\',\'' + tmfName + '\')"><span uk-icon="icon:check;ratio:0.8"></span> Save</button><br>' +
        '<button class="uk-button uk-button-default uk-button-small" onclick="renderPage()"><span uk-icon="icon:close;ratio:0.8"></span></button>' +
        '</td>';
}

function saveInlineEdit(rowId, asrId, asrRid, asrName, tmfId, tmfRid, tmfName) {
    var asrTtsEl    = document.getElementById('edit_asr_tts_'   + rowId);
    var tmfTtsEl    = document.getElementById('edit_tmf_tts_'   + rowId);
    var asrAudioEl  = document.getElementById('edit_asr_audio_' + rowId);
    var tmfAudioEl  = document.getElementById('edit_tmf_audio_' + rowId);

    var tasks = [];

    if (asrTtsEl && asrId) {
        tasks.push(fetch(API_BASE + '/tts', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ promptId: asrId, resourceId: asrRid, promptName: asrName, ttsText: asrTtsEl.value })
        }).then(function(r) { return r.json(); }));
    }
    if (tmfTtsEl && tmfId) {
        tasks.push(fetch(API_BASE + '/tts', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ promptId: tmfId, resourceId: tmfRid, promptName: tmfName, ttsText: tmfTtsEl.value })
        }).then(function(r) { return r.json(); }));
    }
    if (asrAudioEl && asrAudioEl.files && asrAudioEl.files.length > 0 && asrId) {
        var fd = new FormData();
        fd.append('audioFile', asrAudioEl.files[0]);
        var url = API_BASE + '/upload?promptId=' + encodeURIComponent(asrId) + '&resourceId=' + encodeURIComponent(asrRid) + '&promptName=' + encodeURIComponent(asrName);
        tasks.push(fetch(url, { method: 'POST', body: fd }).then(function(r) { return r.json(); }));
    }
    if (tmfAudioEl && tmfAudioEl.files && tmfAudioEl.files.length > 0 && tmfId) {
        var fd2 = new FormData();
        fd2.append('audioFile', tmfAudioEl.files[0]);
        var url2 = API_BASE + '/upload?promptId=' + encodeURIComponent(tmfId) + '&resourceId=' + encodeURIComponent(tmfRid) + '&promptName=' + encodeURIComponent(tmfName);
        tasks.push(fetch(url2, { method: 'POST', body: fd2 }).then(function(r) { return r.json(); }));
    }

    if (tasks.length === 0) {
        UIkit.notification({ message: 'Nothing to save.', status: 'warning' });
        renderPage();
        return;
    }

    UIkit.notification({ message: 'Saving changes...', status: 'primary' });
    Promise.all(tasks).then(function(results) {
        var failed = results.filter(function(r) { return !r.success; }).length;
        if (failed === 0) {
            UIkit.notification({ message: 'Row saved successfully.', status: 'success' });
        } else {
            UIkit.notification({ message: (results.length - failed) + ' saved, ' + failed + ' failed.', status: 'warning' });
        }
        loadPromptsForDnis();
    }).catch(function(e) {
        UIkit.notification({ message: 'Error: ' + e.message, status: 'danger' });
    });
}

function openAddPromptModal() {
    document.getElementById('addPrompt_name').value     = '';
    document.getElementById('addPrompt_asrTts').value   = '';
    document.getElementById('addPrompt_tmfTts').value   = '';
    document.getElementById('addPrompt_asrAudio').value = '';
    document.getElementById('addPrompt_tmfAudio').value = '';
    updateAddPromptPreview();
    UIkit.modal('#addPromptModal').show();
}

function updateAddPromptPreview() {
    var base = (document.getElementById('addPrompt_name').value || '').trim();
    var asrEl = document.getElementById('addPrompt_previewAsr');
    var tmfEl = document.getElementById('addPrompt_previewTmf');
    if (!base || base.indexOf('_BG_') === -1) {
        if (asrEl) asrEl.textContent = '— (name must contain _BG_)';
        if (tmfEl) tmfEl.textContent = '';
        return;
    }
    var idx = base.lastIndexOf('_BG_');
    var pre = base.substring(0, idx);
    var suf = base.substring(idx + 4);
    if (asrEl) asrEl.textContent = pre + '_BG_A_' + suf;
    if (tmfEl) tmfEl.textContent = pre + '_BG_D_' + suf;
}

function saveNewPrompt() {
    var baseName = (document.getElementById('addPrompt_name').value || '').trim();
    if (!baseName) { UIkit.notification({ message: 'Prompt name is required.', status: 'warning' }); return; }
    if (baseName.indexOf('_BG_') === -1) {
        UIkit.notification({ message: 'Name must contain _BG_ (e.g. V_03075_BG_test).', status: 'warning' });
        return;
    }

    UIkit.notification({ message: 'Creating prompt pair...', status: 'primary' });

    fetch(API_BASE + '/create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ baseName: baseName })
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        if (!res.success) {
            UIkit.notification({ message: res.message || 'Failed to create prompts.', status: 'danger' });
            return;
        }

        var asrTts   = document.getElementById('addPrompt_asrTts').value;
        var tmfTts   = document.getElementById('addPrompt_tmfTts').value;
        var asrFile  = document.getElementById('addPrompt_asrAudio').files[0];
        var tmfFile  = document.getElementById('addPrompt_tmfAudio').files[0];
        var tasks    = [];

        if (asrTts.trim() && res.asrPromptId) {
            tasks.push(fetch(API_BASE + '/tts', {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ promptId: res.asrPromptId, resourceId: res.asrResourceId || '', ttsText: asrTts })
            }).then(function(r) { return r.json(); }));
        }
        if (tmfTts.trim() && res.tmfPromptId) {
            tasks.push(fetch(API_BASE + '/tts', {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ promptId: res.tmfPromptId, resourceId: res.tmfResourceId || '', ttsText: tmfTts })
            }).then(function(r) { return r.json(); }));
        }
        if (asrFile && res.asrPromptId) {
            var fd = new FormData();
            fd.append('audioFile', asrFile);
            tasks.push(fetch(API_BASE + '/upload?promptId=' + encodeURIComponent(res.asrPromptId) +
                '&resourceId=' + encodeURIComponent(res.asrResourceId || '') +
                '&promptName=' + encodeURIComponent(res.asrName || ''),
                { method: 'POST', body: fd }).then(function(r) { return r.json(); }));
        }
        if (tmfFile && res.tmfPromptId) {
            var fd2 = new FormData();
            fd2.append('audioFile', tmfFile);
            tasks.push(fetch(API_BASE + '/upload?promptId=' + encodeURIComponent(res.tmfPromptId) +
                '&resourceId=' + encodeURIComponent(res.tmfResourceId || '') +
                '&promptName=' + encodeURIComponent(res.tmfName || ''),
                { method: 'POST', body: fd2 }).then(function(r) { return r.json(); }));
        }

        return Promise.all(tasks);
    })
    .then(function() {
        UIkit.notification({ message: 'Prompt pair created successfully.', status: 'success' });
        UIkit.modal('#addPromptModal').hide();
        loadPromptsForDnis();
    })
    .catch(function(e) {
        UIkit.notification({ message: 'Error: ' + e.message, status: 'danger' });
    });
}

function createMissingPrompts() {
    var missingNames = [];
    allRows.forEach(function(row) {
        if (row.asr && row.asr.needsCreation && row.asr.name) missingNames.push(row.asr.name);
        if (row.tmf && row.tmf.needsCreation && row.tmf.name) missingNames.push(row.tmf.name);
    });

    if (missingNames.length === 0) {
        UIkit.notification({ message: 'No missing prompts — all calendar entries already exist in Genesys.', status: 'success' });
        return;
    }

    UIkit.modal.confirm(
        '<p>The following <strong>' + missingNames.length + '</strong> prompt(s) exist in the calendar but are <strong>not yet created</strong> in Genesys Cloud:</p>' +
        '<ul style="max-height:180px;overflow-y:auto;font-size:12px;text-align:left;">' +
            missingNames.map(function(n) { return '<li>' + escapeHtml(n) + '</li>'; }).join('') +
        '</ul>' +
        '<p class="uk-text-warning">Empty prompt shells (no TTS, no audio) will be created. <strong>This cannot be undone.</strong></p>'
    ).then(function() {
        UIkit.notification({ message: 'Creating ' + missingNames.length + ' missing prompt(s)...', status: 'primary' });

        var creates = missingNames.map(function(exactName) {
            return fetch(API_BASE + '/create', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ exactName: exactName })
            }).then(function(r) { return r.json(); });
        });

        Promise.all(creates).then(function(results) {
            var succeeded = results.filter(function(r) { return r.success; }).length;
            var failed    = results.length - succeeded;
            if (failed === 0) {
                UIkit.notification({ message: succeeded + ' prompt(s) created successfully.', status: 'success' });
            } else {
                UIkit.notification({
                    message: succeeded + ' created, ' + failed + ' failed. Check server logs for details.',
                    status: 'warning'
                });
            }
            loadPromptsForDnis();
        }).catch(function(e) {
            UIkit.notification({ message: 'Error during bulk creation: ' + e.message, status: 'danger' });
        });
    }, function() {});
}

function updateSelCount() {
    var checked = document.querySelectorAll('.row-chk:checked');
    var total   = document.querySelectorAll('.row-chk');
    var n = checked.length;
    var el = document.getElementById('selCount');
    if (el) el.textContent = n + ' selected';
    var btn = document.getElementById('btnExportCsv');
    if (btn) btn.disabled = (n === 0);
    var btnDel = document.getElementById('btnDeleteSelected');
    if (btnDel) btnDel.disabled = (n === 0);
    var hdr = document.getElementById('selectAllChkHeader');
    if (hdr) hdr.checked = (total.length > 0 && n === total.length);
    var top = document.getElementById('selectAllChk');
    if (top) top.checked = (total.length > 0 && n === total.length);
}

function toggleSelectAll(checked) {
    document.querySelectorAll('.row-chk').forEach(function(c) { c.checked = checked; });
    var hdr = document.getElementById('selectAllChkHeader');
    if (hdr) hdr.checked = checked;
    var top = document.getElementById('selectAllChk');
    if (top) top.checked = checked;
    updateSelCount();
}

function getSelectedRowIds() {
    var ids = [];
    document.querySelectorAll('.row-chk:checked').forEach(function(c) {
        ids.push(parseInt(c.getAttribute('data-rowid'), 10));
    });
    return ids;
}

function buildCsvFromRows(rows) {
    var header = ['#','Name','TTS ASR','Has Audio ASR','TTS TMF','Has Audio TMF'];
    var lines  = [header.map(csvEscape).join(',')];
    rows.forEach(function(row) {
        var asr = row.asr || {};
        var tmf = row.tmf || {};
        lines.push([
            row.rowId,
            csvEscape(row.name || ''),
            csvEscape(asr.ttsText || ''),
            asr.hasAudio ? 'Yes' : 'No',
            csvEscape(tmf.ttsText || ''),
            tmf.hasAudio ? 'Yes' : 'No'
        ].join(','));
    });
    return lines.join('\r\n');
}

function csvEscape(val) {
    val = String(val);
    if (val.indexOf(',') !== -1 || val.indexOf('"') !== -1 || val.indexOf('\n') !== -1) {
        return '"' + val.replace(/"/g, '""') + '"';
    }
    return val;
}

function downloadCsv(csvContent, filename) {
    var blob = new Blob(['\uFEFF' + csvContent], { type: 'text/csv;charset=utf-8;' });
    var url  = URL.createObjectURL(blob);
    var a    = document.createElement('a');
    a.href = url; a.download = filename;
    document.body.appendChild(a); a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

function exportSelectedCsv() {
    var ids = getSelectedRowIds();
    if (ids.length === 0) { UIkit.notification({message:'No rows selected!', status:'warning'}); return; }
    var selected = filteredRows.filter(function(r) { return ids.indexOf(r.rowId) !== -1; });
    var csv = buildCsvFromRows(selected);
    downloadCsv(csv, 'prompts_' + currentDnis + '_selected.csv');
}

function exportAllCsv() {
    if (filteredRows.length === 0) { UIkit.notification({message:'No data to export!', status:'warning'}); return; }
    var csv = buildCsvFromRows(filteredRows);
    downloadCsv(csv, 'prompts_' + currentDnis + '_all.csv');
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
