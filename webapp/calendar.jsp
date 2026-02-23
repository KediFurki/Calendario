<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calendar Management</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/uikit@3.21.6/dist/css/uikit.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/uikit@3.21.6/dist/js/uikit.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/uikit@3.21.6/dist/js/uikit-icons.min.js"></script>
    <style>
        body { background-color: #f8f9fa; padding: 20px; }
        .nav-bar { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 15px 30px; margin: -20px -20px 20px -20px; display: flex; justify-content: space-between; align-items: center; }
        .nav-bar .nav-title { color: white; font-size: 20px; font-weight: bold; }
        .nav-bar .nav-links a { color: rgba(255,255,255,0.8); text-decoration: none; margin-left: 25px; font-weight: 500; transition: color 0.3s; }
        .nav-bar .nav-links a:hover, .nav-bar .nav-links a.active { color: white; }
        .calendar-card { border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin-bottom: 15px; transition: all 0.3s ease; }
        .calendar-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,0.12); }
        .calendar-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 15px 20px; border-radius: 8px 8px 0 0; cursor: pointer; text-decoration: none; }
        .calendar-header:hover { background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%); color: white; }
        .calendar-body { padding: 20px; background: white; border-radius: 0 0 8px 8px; }
        .day-input-group { display: grid; grid-template-columns: repeat(7, 1fr); gap: 10px; }
        @media (max-width: 960px) { .day-input-group { grid-template-columns: repeat(4, 1fr); } }
        @media (max-width: 640px) { .day-input-group { grid-template-columns: repeat(2, 1fr); } }
        .day-box { text-align: center; }
        .day-box label { font-weight: bold; display: block; margin-bottom: 5px; color: #333; }
        .special-days-section { margin-top: 20px; padding-top: 20px; border-top: 1px solid #e5e5e5; }
        .special-day-item { display: flex; align-items: center; justify-content: space-between; padding: 10px 15px; background: #f8f9fa; border-radius: 5px; margin-bottom: 8px; }
        .special-day-item:hover { background: #e9ecef; }
        .new-calendar-btn { background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); border: none; color: white; padding: 12px 30px; border-radius: 25px; font-weight: bold; cursor: pointer; transition: all 0.3s ease; }
        .new-calendar-btn:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(17,153,142,0.4); color: white; }
        .section-title { color: #667eea; font-weight: bold; margin-bottom: 15px; }
        .info-text { font-size: 12px; color: #666; }
        .hidden { display: none; }
        .calendar-header-content { display: flex; justify-content: space-between; align-items: center; width: 100%; }
        .calendar-header-left { display: flex; align-items: center; gap: 10px; }
        .btn-delete-header { background: rgba(255,255,255,0.2); border: 1px solid rgba(255,255,255,0.5); color: white; padding: 5px 12px; border-radius: 5px; font-size: 12px; cursor: pointer; transition: all 0.2s; }
        .btn-delete-header:hover { background: #dc3545; border-color: #dc3545; }
        .time-slot-container { background: #f8f9fa; border-radius: 8px; padding: 10px; min-height: 80px; }
        .time-slot-item { display: flex; align-items: center; gap: 5px; background: white; padding: 5px 10px; border-radius: 5px; margin-bottom: 5px; border: 1px solid #e5e5e5; }
        .time-slot-item:last-child { margin-bottom: 0; }
        .time-picker-row { display: flex; align-items: center; gap: 5px; margin-bottom: 8px; }
        .time-picker-row select { padding: 4px 8px; border: 1px solid #ddd; border-radius: 4px; font-size: 13px; min-width: 60px; }
        .time-picker-row .separator { font-weight: bold; color: #666; }
        .btn-add-time-slot { font-size: 11px; padding: 3px 8px; }
        .btn-remove-time-slot { background: none; border: none; color: #dc3545; cursor: pointer; padding: 2px 5px; font-size: 14px; }
        .btn-remove-time-slot:hover { color: #a71d2a; }
        .day-box-enhanced { text-align: center; background: white; border-radius: 8px; padding: 10px; border: 1px solid #e5e5e5; }
        .day-box-enhanced label { font-weight: bold; display: block; margin-bottom: 8px; color: #333; font-size: 14px; }
    </style>
</head>
<body>
<div class="nav-bar">
    <div class="nav-title"><span uk-icon="icon: world; ratio: 1.2"></span> Calendario</div>
    <div class="nav-links">
        <a href="calendar.jsp" class="active"><span uk-icon="calendar"></span> Calendar</a>
        <a href="prompts.jsp"><span uk-icon="microphone"></span> Prompts</a>
    </div>
</div>
<div class="uk-container uk-container-large">
    <div class="uk-text-center uk-margin-large-bottom">
        <h1 class="uk-heading-medium"><span uk-icon="icon: calendar; ratio: 2"></span> Calendar Management</h1>
        <p class="uk-text-muted">Manage your service hours and special days</p>
    </div>
    <div class="uk-text-center uk-margin-bottom">
        <button class="new-calendar-btn" id="btnAddCalendar"><span uk-icon="plus-circle"></span> Add New Calendar</button>
    </div>
    <div id="newCalendarForm" class="uk-card uk-card-default uk-card-body uk-margin-bottom hidden">
        <h3 class="uk-card-title"><span uk-icon="plus"></span> Create New Calendar</h3>
        <form id="createCalendarForm" class="uk-form-stacked">
            <div class="uk-margin">
                <label class="uk-form-label">Calendar Name (Key) *</label>
                <input class="uk-input" type="text" id="new_key" placeholder="E.g.: Support_TR, Sales_EU" required>
                <span class="info-text">A unique name without spaces. Use underscore instead.</span>
            </div>
            <div class="uk-margin">
                <label class="uk-form-label">Weekly Working Hours</label>
                <span class="info-text">Click "Add" to add working hours for each day. You can add up to 4 time slots per day.</span>
                <div class="day-input-group uk-margin-small-top">
                    <div class="day-box-enhanced"><label>Mon</label><div class="time-slot-container" id="newTimeSlots_mon"><p class="uk-text-muted uk-text-small uk-margin-remove">No hours set</p></div><button type="button" class="uk-button uk-button-default uk-button-small btn-add-time-slot-new" data-day="mon"><span uk-icon="icon: plus; ratio: 0.7"></span> Add</button><input type="hidden" id="new_mon" value=""></div>
                    <div class="day-box-enhanced"><label>Tue</label><div class="time-slot-container" id="newTimeSlots_tue"><p class="uk-text-muted uk-text-small uk-margin-remove">No hours set</p></div><button type="button" class="uk-button uk-button-default uk-button-small btn-add-time-slot-new" data-day="tue"><span uk-icon="icon: plus; ratio: 0.7"></span> Add</button><input type="hidden" id="new_tue" value=""></div>
                    <div class="day-box-enhanced"><label>Wed</label><div class="time-slot-container" id="newTimeSlots_wed"><p class="uk-text-muted uk-text-small uk-margin-remove">No hours set</p></div><button type="button" class="uk-button uk-button-default uk-button-small btn-add-time-slot-new" data-day="wed"><span uk-icon="icon: plus; ratio: 0.7"></span> Add</button><input type="hidden" id="new_wed" value=""></div>
                    <div class="day-box-enhanced"><label>Thu</label><div class="time-slot-container" id="newTimeSlots_thu"><p class="uk-text-muted uk-text-small uk-margin-remove">No hours set</p></div><button type="button" class="uk-button uk-button-default uk-button-small btn-add-time-slot-new" data-day="thu"><span uk-icon="icon: plus; ratio: 0.7"></span> Add</button><input type="hidden" id="new_thu" value=""></div>
                    <div class="day-box-enhanced"><label>Fri</label><div class="time-slot-container" id="newTimeSlots_fri"><p class="uk-text-muted uk-text-small uk-margin-remove">No hours set</p></div><button type="button" class="uk-button uk-button-default uk-button-small btn-add-time-slot-new" data-day="fri"><span uk-icon="icon: plus; ratio: 0.7"></span> Add</button><input type="hidden" id="new_fri" value=""></div>
                    <div class="day-box-enhanced"><label>Sat</label><div class="time-slot-container" id="newTimeSlots_sat"><p class="uk-text-muted uk-text-small uk-margin-remove">No hours set</p></div><button type="button" class="uk-button uk-button-default uk-button-small btn-add-time-slot-new" data-day="sat"><span uk-icon="icon: plus; ratio: 0.7"></span> Add</button><input type="hidden" id="new_sat" value=""></div>
                    <div class="day-box-enhanced"><label>Sun</label><div class="time-slot-container" id="newTimeSlots_sun"><p class="uk-text-muted uk-text-small uk-margin-remove">No hours set</p></div><button type="button" class="uk-button uk-button-default uk-button-small btn-add-time-slot-new" data-day="sun"><span uk-icon="icon: plus; ratio: 0.7"></span> Add</button><input type="hidden" id="new_sun" value=""></div>
                </div>
            </div>
            <div class="uk-margin">
                <label class="uk-form-label">Closed Day Message</label>
                <input class="uk-input" type="text" id="new_msg" placeholder="E.g.: We are currently closed. Please call during working hours.">
            </div>
            <div class="special-days-section">
                <div class="uk-flex uk-flex-between uk-flex-middle uk-margin-bottom">
                    <h4 class="section-title uk-margin-remove"><span uk-icon="star"></span> Special Days & Holidays (Optional)</h4>
                    <button type="button" class="uk-button uk-button-secondary uk-button-small" id="btnAddNewSpecialDay"><span uk-icon="plus"></span> Add Special Day</button>
                </div>
                <div id="newCalendarSpecialDaysList"><p class="uk-text-muted uk-text-small">No special days added yet. You can add them now or later after creating the calendar.</p></div>
            </div>
            <div class="uk-margin uk-text-right">
                <button type="button" class="uk-button uk-button-default" id="btnCancelCreate">Cancel</button>
                <button type="button" class="uk-button uk-button-primary" id="btnCreateCalendar"><span uk-icon="check"></span> Create Calendar</button>
            </div>
        </form>
    </div>
    <div id="calendarList"><p class="uk-text-center uk-text-muted" id="loadingMessage"><span uk-spinner></span> Loading calendars...</p></div>
</div>
<div id="addSpecialDayModal" uk-modal>
    <div class="uk-modal-dialog uk-modal-body">
        <h2 class="uk-modal-title"><span uk-icon="star"></span> Add Special Day</h2>
        <button class="uk-modal-close-default" type="button" uk-close></button>
        <form id="specialDayForm" class="uk-form-stacked">
            <input type="hidden" id="sd_calendarKey">
            <div class="uk-margin">
                <label class="uk-form-label">Date *</label>
                <input class="uk-input" type="text" id="sd_date" placeholder="DD.MM or DD.MM.YYYY" required>
                <span class="info-text">For yearly holidays: 01.01 (New Year) | For specific dates: 21.04.2026</span>
            </div>
            <div class="uk-margin">
                <label class="uk-form-label">Working Hours</label>
                <div class="time-picker-row"><label style="min-width: 50px;">From:</label><select id="sd_from_hour"></select><span class="separator">:</span><select id="sd_from_min"></select></div>
                <div class="time-picker-row"><label style="min-width: 50px;">To:</label><select id="sd_to_hour"></select><span class="separator">:</span><select id="sd_to_min"></select></div>
                <span class="info-text">Leave as 00:00 - 00:00 for closed all day</span>
            </div>
            <div class="uk-margin">
                <label class="uk-form-label">Message</label>
                <input class="uk-input" type="text" id="sd_msg" placeholder="E.g.: New Year's Day - Office Closed">
            </div>
            <div class="uk-margin uk-text-right">
                <button class="uk-button uk-button-default uk-modal-close" type="button">Cancel</button>
                <button class="uk-button uk-button-primary" type="button" id="btnSaveSpecialDay"><span uk-icon="check"></span> Save</button>
            </div>
        </form>
    </div>
</div>
<script>
var API_BASE = 'api/calendar';
var calendarsData = [];
var specialDaysData = [];
var newCalendarSpecialDays = [];
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('btnAddCalendar').addEventListener('click', showNewCalendarForm);
    document.getElementById('btnCancelCreate').addEventListener('click', hideNewCalendarForm);
    document.getElementById('btnCreateCalendar').addEventListener('click', createCalendar);
    document.getElementById('btnSaveSpecialDay').addEventListener('click', saveSpecialDay);
    document.getElementById('btnAddNewSpecialDay').addEventListener('click', showAddSpecialDayForNewCalendar);
    document.querySelectorAll('.btn-add-time-slot-new').forEach(function(btn) {
        btn.addEventListener('click', function() { addTimeSlotForNewCalendar(this.getAttribute('data-day')); });
    });
    loadAllData();
});
function loadAllData() {
    Promise.all([
        fetch(API_BASE + '/serviceHours').then(function(r) { return r.json(); }),
        fetch(API_BASE + '/specialDays').then(function(r) { return r.json(); })
    ]).then(function(results) {
        calendarsData = results[0];
        specialDaysData = results[1];
        renderCalendarList();
    }).catch(function(error) {
        console.error('Error loading data:', error);
        UIkit.notification({message: 'Failed to load data!', status: 'danger'});
        document.getElementById('loadingMessage').innerHTML = '<span uk-icon="warning"></span> Failed to load calendars.';
    });
}
function renderCalendarList() {
    var container = document.getElementById('calendarList');
    if (calendarsData.length === 0) {
        container.innerHTML = '<div class="uk-text-center uk-padding"><span uk-icon="icon: calendar; ratio: 3" class="uk-text-muted"></span><p class="uk-text-muted uk-margin-top">No calendars found. Click "Add New Calendar" to create one.</p></div>';
        return;
    }
    var html = '<ul uk-accordion="multiple: true">';
    for (var i = 0; i < calendarsData.length; i++) {
        var cal = calendarsData[i];
        var relatedSpecialDays = specialDaysData.filter(function(sd) { return sd.key && sd.key.startsWith(cal.key + '.'); });
        html += '<li class="calendar-card"><a class="uk-accordion-title calendar-header" href="#"><div class="calendar-header-content"><div class="calendar-header-left"><span uk-icon="calendar"></span> <strong>' + escapeHtml(cal.key) + '</strong><span class="uk-badge uk-margin-small-left">' + relatedSpecialDays.length + ' special days</span></div><button type="button" class="btn-delete-header btn-delete-cal-header" data-key="' + escapeHtml(cal.key) + '" onclick="event.preventDefault(); event.stopPropagation();"><span uk-icon="icon: trash; ratio: 0.8"></span> Delete</button></div></a><div class="uk-accordion-content calendar-body">' + renderEditForm(cal, i) + renderSpecialDaysSection(cal.key, relatedSpecialDays, i) + '</div></li>';
    }
    html += '</ul>';
    container.innerHTML = html;
    attachDynamicEventListeners();
}
function renderEditForm(cal, index) {
    var days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    var dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    var html = '<form id="editForm_' + index + '" class="uk-form-stacked"><div class="uk-margin"><label class="uk-form-label section-title">Weekly Working Hours</label><span class="info-text">Click "Add Time Slot" to add working hours. You can add up to 4 time slots per day.</span><div class="day-input-group uk-margin-small-top">';
    for (var d = 0; d < days.length; d++) {
        var day = days[d];
        var dayLabel = dayLabels[d];
        var currentValue = cal[day] || '';
        html += '<div class="day-box-enhanced"><label>' + dayLabel + '</label><div class="time-slot-container" id="timeSlots_' + index + '_' + day + '" data-day="' + day + '" data-index="' + index + '">' + renderTimeSlots(currentValue, index, day) + '</div><button type="button" class="uk-button uk-button-default uk-button-small btn-add-time-slot" data-index="' + index + '" data-day="' + day + '"><span uk-icon="icon: plus; ratio: 0.7"></span> Add</button><input type="hidden" id="edit_' + day + '_' + index + '" value="' + escapeHtml(currentValue) + '"></div>';
    }
    html += '</div></div><div class="uk-margin"><label class="uk-form-label">Closed Day Message</label><input class="uk-input" type="text" id="edit_msg_' + index + '" value="' + escapeHtml(cal.msg_off_days || '') + '"></div><div class="uk-margin"><button type="button" class="uk-button uk-button-primary uk-button-small btn-update" data-key="' + escapeHtml(cal.key) + '" data-index="' + index + '"><span uk-icon="check"></span> Save Changes</button><button type="button" class="uk-button uk-button-warning uk-button-small btn-reset-times" data-key="' + escapeHtml(cal.key) + '" data-index="' + index + '"><span uk-icon="refresh"></span> Reset Times</button></div></form>';
    return html;
}
function renderTimeSlots(value, index, day) {
    if (!value || value.trim() === '') return '<p class="uk-text-muted uk-text-small uk-margin-remove">No hours set (Closed)</p>';
    var slots = value.split(' ').filter(function(s) { return s.trim() !== ''; });
    var html = '';
    for (var i = 0; i < slots.length; i++) {
        var slot = slots[i];
        var isClosed = (slot === '00:00-00:00');
        html += '<div class="time-slot-item"><span>' + (isClosed ? '<span class="uk-label uk-label-danger">Closed</span>' : escapeHtml(slot)) + '</span><button type="button" class="btn-remove-time-slot" data-index="' + index + '" data-day="' + day + '" data-slot="' + i + '">&times;</button></div>';
    }
    return html;
}
function renderSpecialDaysSection(calKey, specialDays, index) {
    var html = '<div class="special-days-section"><div class="uk-flex uk-flex-between uk-flex-middle uk-margin-bottom"><h4 class="section-title uk-margin-remove"><span uk-icon="star"></span> Special Days & Holidays</h4><button class="uk-button uk-button-secondary uk-button-small btn-add-special" data-key="' + escapeHtml(calKey) + '"><span uk-icon="plus"></span> Add Special Day</button></div><div id="specialDaysList_' + index + '">';
    if (specialDays.length === 0) {
        html += '<p class="uk-text-muted uk-text-small">No special days defined for this calendar.</p>';
    } else {
        for (var j = 0; j < specialDays.length; j++) {
            var sd = specialDays[j];
            var datePart = sd.key.substring(sd.key.indexOf('.') + 1);
            var isClosed = (sd.hour === '00:00-00:00' || !sd.hour);
            var hourDisplay = isClosed ? '<span class="uk-label uk-label-danger">Closed</span>' : escapeHtml(sd.hour);
            html += '<div class="special-day-item"><div><strong>' + escapeHtml(datePart) + '</strong>' + (sd.msg_off_days ? ' - ' + escapeHtml(sd.msg_off_days) : '') + '<br><small class="uk-text-muted">Hours: ' + hourDisplay + '</small></div><button class="uk-button uk-button-danger uk-button-small btn-delete-special" data-key="' + escapeHtml(sd.key) + '"><span uk-icon="trash"></span></button></div>';
        }
    }
    html += '</div></div>';
    return html;
}
function attachDynamicEventListeners() {
    document.querySelectorAll('.btn-update').forEach(function(btn) { btn.addEventListener('click', function() { updateCalendar(this.getAttribute('data-key'), this.getAttribute('data-index')); }); });
    document.querySelectorAll('.btn-delete-cal-header').forEach(function(btn) { btn.addEventListener('click', function(e) { e.preventDefault(); e.stopPropagation(); deleteCalendar(this.getAttribute('data-key')); }); });
    document.querySelectorAll('.btn-reset-times').forEach(function(btn) { btn.addEventListener('click', function() { resetCalendarTimes(this.getAttribute('data-key'), this.getAttribute('data-index')); }); });
    document.querySelectorAll('.btn-add-time-slot').forEach(function(btn) { btn.addEventListener('click', function() { addTimeSlot(this.getAttribute('data-index'), this.getAttribute('data-day')); }); });
    document.querySelectorAll('.btn-remove-time-slot').forEach(function(btn) { btn.addEventListener('click', function() { removeTimeSlot(this.getAttribute('data-index'), this.getAttribute('data-day'), this.getAttribute('data-slot')); }); });
    document.querySelectorAll('.btn-add-special').forEach(function(btn) { btn.addEventListener('click', function() { openAddSpecialDayModal(this.getAttribute('data-key')); }); });
    document.querySelectorAll('.btn-delete-special').forEach(function(btn) { btn.addEventListener('click', function() { deleteSpecialDay(this.getAttribute('data-key')); }); });
}
function addTimeSlot(index, day) {
    var hiddenInput = document.getElementById('edit_' + day + '_' + index);
    var currentValue = hiddenInput.value.trim();
    var slots = currentValue ? currentValue.split(' ').filter(function(s) { return s.trim() !== ''; }) : [];
    if (slots.length >= 4) { UIkit.notification({message: 'Maximum 4 time slots allowed per day!', status: 'warning'}); return; }
    showTimePickerModal(index, day);
}
function showTimePickerModal(index, day) {
    var modalHtml = '<div id="timePickerModal" class="uk-flex-top" uk-modal><div class="uk-modal-dialog uk-modal-body uk-margin-auto-vertical"><button class="uk-modal-close-default" type="button" uk-close></button><h2 class="uk-modal-title">Add Time Slot</h2><div class="time-picker-row"><label style="min-width: 50px;">From:</label><select id="tp_from_hour">' + generateHourOptions() + '</select><span class="separator">:</span><select id="tp_from_min">' + generateMinuteOptions() + '</select></div><div class="time-picker-row"><label style="min-width: 50px;">To:</label><select id="tp_to_hour">' + generateHourOptions(17) + '</select><span class="separator">:</span><select id="tp_to_min">' + generateMinuteOptions() + '</select></div><div class="uk-margin-top uk-text-right"><button class="uk-button uk-button-default uk-modal-close" type="button">Cancel</button><button class="uk-button uk-button-primary" type="button" id="btnConfirmTimeSlot" data-index="' + index + '" data-day="' + day + '">Add</button></div></div></div>';
    var oldModal = document.getElementById('timePickerModal');
    if (oldModal) oldModal.remove();
    document.body.insertAdjacentHTML('beforeend', modalHtml);
    var modal = UIkit.modal('#timePickerModal');
    modal.show();
    document.getElementById('btnConfirmTimeSlot').addEventListener('click', function() {
        var fromHour = document.getElementById('tp_from_hour').value;
        var fromMin = document.getElementById('tp_from_min').value;
        var toHour = document.getElementById('tp_to_hour').value;
        var toMin = document.getElementById('tp_to_min').value;
        var timeSlot = fromHour + ':' + fromMin + '-' + toHour + ':' + toMin;
        var fromTotal = parseInt(fromHour) * 60 + parseInt(fromMin);
        var toTotal = parseInt(toHour) * 60 + parseInt(toMin);
        if (toTotal <= fromTotal) { UIkit.notification({message: 'End time must be after start time!', status: 'warning'}); return; }
        var idx = this.getAttribute('data-index');
        var d = this.getAttribute('data-day');
        var hiddenInput = document.getElementById('edit_' + d + '_' + idx);
        var currentValue = hiddenInput.value.trim();
        if (currentValue) { hiddenInput.value = currentValue + ' ' + timeSlot; } else { hiddenInput.value = timeSlot; }
        var container = document.getElementById('timeSlots_' + idx + '_' + d);
        container.innerHTML = renderTimeSlots(hiddenInput.value, idx, d);
        container.querySelectorAll('.btn-remove-time-slot').forEach(function(btn) { btn.addEventListener('click', function() { removeTimeSlot(btn.getAttribute('data-index'), btn.getAttribute('data-day'), btn.getAttribute('data-slot')); }); });
        modal.hide();
        document.getElementById('timePickerModal').remove();
    });
}
function generateHourOptions(defaultHour) {
    var html = '';
    defaultHour = defaultHour || 8;
    for (var h = 0; h < 24; h++) {
        var hStr = h < 10 ? '0' + h : '' + h;
        var selected = (h === defaultHour) ? ' selected' : '';
        html += '<option value="' + hStr + '"' + selected + '>' + hStr + '</option>';
    }
    return html;
}
function generateMinuteOptions(defaultMin) {
    var minutes = ['00', '15', '30', '45'];
    var html = '';
    defaultMin = defaultMin || '00';
    for (var i = 0; i < minutes.length; i++) {
        var selected = (minutes[i] === defaultMin) ? ' selected' : '';
        html += '<option value="' + minutes[i] + '"' + selected + '>' + minutes[i] + '</option>';
    }
    return html;
}
function removeTimeSlot(index, day, slotIndex) {
    var hiddenInput = document.getElementById('edit_' + day + '_' + index);
    var currentValue = hiddenInput.value.trim();
    var slots = currentValue.split(' ').filter(function(s) { return s.trim() !== ''; });
    slots.splice(parseInt(slotIndex), 1);
    hiddenInput.value = slots.join(' ');
    var container = document.getElementById('timeSlots_' + index + '_' + day);
    container.innerHTML = renderTimeSlots(hiddenInput.value, index, day);
    container.querySelectorAll('.btn-remove-time-slot').forEach(function(btn) { btn.addEventListener('click', function() { removeTimeSlot(btn.getAttribute('data-index'), btn.getAttribute('data-day'), btn.getAttribute('data-slot')); }); });
}
function addTimeSlotForNewCalendar(day) {
    var hiddenInput = document.getElementById('new_' + day);
    var currentValue = hiddenInput.value.trim();
    var slots = currentValue ? currentValue.split(' ').filter(function(s) { return s.trim() !== ''; }) : [];
    if (slots.length >= 4) { UIkit.notification({message: 'Maximum 4 time slots allowed per day!', status: 'warning'}); return; }
    showTimePickerModalForNewCalendar(day);
}
function showTimePickerModalForNewCalendar(day) {
    var modalHtml = '<div id="timePickerModalNew" class="uk-flex-top" uk-modal><div class="uk-modal-dialog uk-modal-body uk-margin-auto-vertical"><button class="uk-modal-close-default" type="button" uk-close></button><h2 class="uk-modal-title">Add Time Slot</h2><div class="time-picker-row"><label style="min-width: 50px;">From:</label><select id="tp_new_from_hour">' + generateHourOptions() + '</select><span class="separator">:</span><select id="tp_new_from_min">' + generateMinuteOptions() + '</select></div><div class="time-picker-row"><label style="min-width: 50px;">To:</label><select id="tp_new_to_hour">' + generateHourOptions(17) + '</select><span class="separator">:</span><select id="tp_new_to_min">' + generateMinuteOptions() + '</select></div><div class="uk-margin-top uk-text-right"><button class="uk-button uk-button-default uk-modal-close" type="button">Cancel</button><button class="uk-button uk-button-primary" type="button" id="btnConfirmTimeSlotNew" data-day="' + day + '">Add</button></div></div></div>';
    var oldModal = document.getElementById('timePickerModalNew');
    if (oldModal) oldModal.remove();
    document.body.insertAdjacentHTML('beforeend', modalHtml);
    var modal = UIkit.modal('#timePickerModalNew');
    modal.show();
    document.getElementById('btnConfirmTimeSlotNew').addEventListener('click', function() {
        var fromHour = document.getElementById('tp_new_from_hour').value;
        var fromMin = document.getElementById('tp_new_from_min').value;
        var toHour = document.getElementById('tp_new_to_hour').value;
        var toMin = document.getElementById('tp_new_to_min').value;
        var timeSlot = fromHour + ':' + fromMin + '-' + toHour + ':' + toMin;
        var fromTotal = parseInt(fromHour) * 60 + parseInt(fromMin);
        var toTotal = parseInt(toHour) * 60 + parseInt(toMin);
        if (toTotal <= fromTotal) { UIkit.notification({message: 'End time must be after start time!', status: 'warning'}); return; }
        var d = this.getAttribute('data-day');
        var hiddenInput = document.getElementById('new_' + d);
        var currentValue = hiddenInput.value.trim();
        if (currentValue) { hiddenInput.value = currentValue + ' ' + timeSlot; } else { hiddenInput.value = timeSlot; }
        updateNewCalendarTimeSlotDisplay(d);
        modal.hide();
        document.getElementById('timePickerModalNew').remove();
    });
}
function updateNewCalendarTimeSlotDisplay(day) {
    var hiddenInput = document.getElementById('new_' + day);
    var container = document.getElementById('newTimeSlots_' + day);
    var value = hiddenInput.value.trim();
    if (!value) { container.innerHTML = '<p class="uk-text-muted uk-text-small uk-margin-remove">No hours set</p>'; return; }
    var slots = value.split(' ').filter(function(s) { return s.trim() !== ''; });
    var html = '';
    for (var i = 0; i < slots.length; i++) {
        var isClosed = (slots[i] === '00:00-00:00');
        html += '<div class="time-slot-item"><span>' + (isClosed ? '<span class="uk-label uk-label-danger">Closed</span>' : escapeHtml(slots[i])) + '</span><button type="button" class="btn-remove-time-slot-new" data-day="' + day + '" data-slot="' + i + '">&times;</button></div>';
    }
    container.innerHTML = html;
    container.querySelectorAll('.btn-remove-time-slot-new').forEach(function(btn) { btn.addEventListener('click', function() { removeTimeSlotFromNewCalendar(btn.getAttribute('data-day'), btn.getAttribute('data-slot')); }); });
}
function removeTimeSlotFromNewCalendar(day, slotIndex) {
    var hiddenInput = document.getElementById('new_' + day);
    var currentValue = hiddenInput.value.trim();
    var slots = currentValue.split(' ').filter(function(s) { return s.trim() !== ''; });
    slots.splice(parseInt(slotIndex), 1);
    hiddenInput.value = slots.join(' ');
    updateNewCalendarTimeSlotDisplay(day);
}
function resetCalendarTimes(key, index) {
    UIkit.modal.confirm('<p>Are you sure you want to reset all working hours for <strong>' + key + '</strong>?</p><p class="uk-text-warning">All time slots will be cleared!</p>').then(function() {
        var days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
        for (var i = 0; i < days.length; i++) {
            var day = days[i];
            var hiddenInput = document.getElementById('edit_' + day + '_' + index);
            hiddenInput.value = '00:00-00:00';
            var container = document.getElementById('timeSlots_' + index + '_' + day);
            container.innerHTML = '<div class="time-slot-item"><span><span class="uk-label uk-label-danger">Closed</span></span><button type="button" class="btn-remove-time-slot" data-index="' + index + '" data-day="' + day + '" data-slot="0">&times;</button></div>';
        }
        document.querySelectorAll('.btn-remove-time-slot').forEach(function(btn) { btn.addEventListener('click', function() { removeTimeSlot(btn.getAttribute('data-index'), btn.getAttribute('data-day'), btn.getAttribute('data-slot')); }); });
        UIkit.notification({message: 'All time slots reset to Closed (00:00-00:00). Click "Save Changes" to apply.', status: 'success'});
    }, function() {});
}
function showNewCalendarForm() {
    document.getElementById('newCalendarForm').classList.remove('hidden');
    document.getElementById('new_key').focus();
    newCalendarSpecialDays = [];
    renderNewCalendarSpecialDays();
    var days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    for (var i = 0; i < days.length; i++) {
        var day = days[i];
        document.getElementById('new_' + day).value = '00:00-00:00';
        updateNewCalendarTimeSlotDisplay(day);
    }
}
function hideNewCalendarForm() {
    document.getElementById('newCalendarForm').classList.add('hidden');
    document.getElementById('createCalendarForm').reset();
    newCalendarSpecialDays = [];
    renderNewCalendarSpecialDays();
    var days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    for (var i = 0; i < days.length; i++) {
        var day = days[i];
        document.getElementById('new_' + day).value = '';
        document.getElementById('newTimeSlots_' + day).innerHTML = '<p class="uk-text-muted uk-text-small uk-margin-remove">No hours set</p>';
    }
}
function showAddSpecialDayForNewCalendar() {
    var calendarName = document.getElementById('new_key').value.trim();
    if (!calendarName) { UIkit.notification({message: 'Please enter a calendar name first!', status: 'warning'}); document.getElementById('new_key').focus(); return; }
    var modalHtml = '<div id="newSpecialDayModal" class="uk-flex-top" uk-modal><div class="uk-modal-dialog uk-modal-body uk-margin-auto-vertical"><button class="uk-modal-close-default" type="button" uk-close></button><h2 class="uk-modal-title"><span uk-icon="star"></span> Add Special Day</h2><div class="uk-margin"><label class="uk-form-label">Date *</label><input class="uk-input" type="text" id="nsd_date" placeholder="DD.MM or DD.MM.YYYY"><span class="info-text">For yearly holidays: 01.01 | For specific dates: 21.04.2026</span></div><div class="uk-margin"><label class="uk-form-label">Working Hours</label><div class="time-picker-row"><label style="min-width: 50px;">From:</label><select id="nsd_from_hour">' + generateHourOptions(0) + '</select><span class="separator">:</span><select id="nsd_from_min">' + generateMinuteOptions() + '</select></div><div class="time-picker-row"><label style="min-width: 50px;">To:</label><select id="nsd_to_hour">' + generateHourOptions(0) + '</select><span class="separator">:</span><select id="nsd_to_min">' + generateMinuteOptions() + '</select></div><span class="info-text">Leave as 00:00 - 00:00 for closed all day</span></div><div class="uk-margin"><label class="uk-form-label">Message (optional)</label><input class="uk-input" type="text" id="nsd_msg" placeholder="E.g.: New Year\'s Day"></div><div class="uk-margin uk-text-right"><button class="uk-button uk-button-default uk-modal-close" type="button">Cancel</button><button class="uk-button uk-button-primary" type="button" id="btnConfirmNewSpecialDay">Add</button></div></div></div>';
    var oldModal = document.getElementById('newSpecialDayModal');
    if (oldModal) oldModal.remove();
    document.body.insertAdjacentHTML('beforeend', modalHtml);
    var modal = UIkit.modal('#newSpecialDayModal');
    modal.show();
    document.getElementById('btnConfirmNewSpecialDay').addEventListener('click', function() {
        var date = document.getElementById('nsd_date').value.trim();
        if (!date) { UIkit.notification({message: 'Please enter a date!', status: 'warning'}); return; }
        var dateRegex = /^(\d{2})\.(\d{2})(\.(\d{4}))?$/;
        if (!dateRegex.test(date)) { UIkit.notification({message: 'Invalid date format! Use DD.MM or DD.MM.YYYY', status: 'warning'}); return; }
        var fromHour = document.getElementById('nsd_from_hour').value;
        var fromMin = document.getElementById('nsd_from_min').value;
        var toHour = document.getElementById('nsd_to_hour').value;
        var toMin = document.getElementById('nsd_to_min').value;
        var hour = fromHour + ':' + fromMin + '-' + toHour + ':' + toMin;
        var msg = document.getElementById('nsd_msg').value.trim();
        newCalendarSpecialDays.push({ date: date, hour: hour, msg_off_days: msg });
        renderNewCalendarSpecialDays();
        modal.hide();
        document.getElementById('newSpecialDayModal').remove();
    });
}
function renderNewCalendarSpecialDays() {
    var container = document.getElementById('newCalendarSpecialDaysList');
    if (newCalendarSpecialDays.length === 0) { container.innerHTML = '<p class="uk-text-muted uk-text-small">No special days added yet. You can add them now or later after creating the calendar.</p>'; return; }
    var html = '';
    for (var i = 0; i < newCalendarSpecialDays.length; i++) {
        var sd = newCalendarSpecialDays[i];
        var isClosed = (sd.hour === '00:00-00:00' || !sd.hour);
        var hourDisplay = isClosed ? '<span class="uk-label uk-label-danger">Closed</span>' : escapeHtml(sd.hour);
        html += '<div class="special-day-item"><div><strong>' + escapeHtml(sd.date) + '</strong>' + (sd.msg_off_days ? ' - ' + escapeHtml(sd.msg_off_days) : '') + '<br><small class="uk-text-muted">Hours: ' + hourDisplay + '</small></div><button type="button" class="uk-button uk-button-danger uk-button-small btn-remove-new-special" data-index="' + i + '"><span uk-icon="trash"></span></button></div>';
    }
    container.innerHTML = html;
    document.querySelectorAll('.btn-remove-new-special').forEach(function(btn) { btn.addEventListener('click', function() { var index = parseInt(this.getAttribute('data-index')); newCalendarSpecialDays.splice(index, 1); renderNewCalendarSpecialDays(); }); });
}
function createCalendar() {
    var key = document.getElementById('new_key').value.trim();
    if (!key) { UIkit.notification({message: 'Please enter a calendar name!', status: 'warning'}); return; }
    if (key.indexOf(' ') >= 0) { UIkit.notification({message: 'Calendar name cannot contain spaces. Use underscore instead.', status: 'warning'}); return; }
    var data = { key: key, mon: document.getElementById('new_mon').value.trim(), tue: document.getElementById('new_tue').value.trim(), wed: document.getElementById('new_wed').value.trim(), thu: document.getElementById('new_thu').value.trim(), fri: document.getElementById('new_fri').value.trim(), sat: document.getElementById('new_sat').value.trim(), sun: document.getElementById('new_sun').value.trim(), msg_off_days: document.getElementById('new_msg').value.trim() };
    fetch(API_BASE + '/serviceHours', { method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(data) })
    .then(function(response) { return response.json(); })
    .then(function(result) {
        if (result.success) {
            if (newCalendarSpecialDays.length > 0) { saveNewCalendarSpecialDays(key); }
            else { UIkit.notification({message: 'Calendar created successfully!', status: 'success'}); hideNewCalendarForm(); loadAllData(); }
        } else { UIkit.notification({message: result.message, status: 'danger'}); }
    })
    .catch(function(error) { console.error('Error:', error); UIkit.notification({message: 'Server connection failed!', status: 'danger'}); });
}
function saveNewCalendarSpecialDays(calendarKey) {
    var promises = [];
    for (var i = 0; i < newCalendarSpecialDays.length; i++) {
        var sd = newCalendarSpecialDays[i];
        var generatedKey = calendarKey + '.' + sd.date;
        var data = { key: generatedKey, hour: sd.hour, msg_off_days: sd.msg_off_days };
        promises.push(fetch(API_BASE + '/specialDays', { method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(data) }));
    }
    Promise.all(promises)
    .then(function() { UIkit.notification({message: 'Calendar and special days created successfully!', status: 'success'}); hideNewCalendarForm(); loadAllData(); })
    .catch(function(error) { console.error('Error saving special days:', error); UIkit.notification({message: 'Calendar created but some special days failed to save.', status: 'warning'}); hideNewCalendarForm(); loadAllData(); });
}
function updateCalendar(key, index) {
    var data = { key: key, mon: document.getElementById('edit_mon_' + index).value.trim(), tue: document.getElementById('edit_tue_' + index).value.trim(), wed: document.getElementById('edit_wed_' + index).value.trim(), thu: document.getElementById('edit_thu_' + index).value.trim(), fri: document.getElementById('edit_fri_' + index).value.trim(), sat: document.getElementById('edit_sat_' + index).value.trim(), sun: document.getElementById('edit_sun_' + index).value.trim(), msg_off_days: document.getElementById('edit_msg_' + index).value.trim() };
    fetch(API_BASE + '/serviceHours', { method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(data) })
    .then(function(response) { return response.json(); })
    .then(function(result) { if (result.success) { UIkit.notification({message: 'Calendar updated successfully!', status: 'success'}); loadAllData(); } else { UIkit.notification({message: result.message, status: 'danger'}); } })
    .catch(function(error) { console.error('Error:', error); UIkit.notification({message: 'Server connection failed!', status: 'danger'}); });
}
function deleteCalendar(key) {
    UIkit.modal.confirm('<p>Are you sure you want to delete calendar <strong>' + key + '</strong>?</p><p class="uk-text-danger">All related special days will also be deleted!</p>').then(function() {
        fetch(API_BASE + '/serviceHours?key=' + encodeURIComponent(key), { method: 'DELETE' })
        .then(function(response) { return response.json(); })
        .then(function(result) { if (result.success) { UIkit.notification({message: 'Calendar and related special days deleted!', status: 'success'}); loadAllData(); } else { UIkit.notification({message: result.message, status: 'danger'}); } })
        .catch(function(error) { console.error('Error:', error); UIkit.notification({message: 'Server connection failed!', status: 'danger'}); });
    }, function() {});
}
function openAddSpecialDayModal(calendarKey) {
    document.getElementById('sd_calendarKey').value = calendarKey;
    document.getElementById('sd_date').value = '';
    document.getElementById('sd_msg').value = '';
    document.getElementById('sd_from_hour').innerHTML = generateHourOptions(0);
    document.getElementById('sd_from_min').innerHTML = generateMinuteOptions('00');
    document.getElementById('sd_to_hour').innerHTML = generateHourOptions(0);
    document.getElementById('sd_to_min').innerHTML = generateMinuteOptions('00');
    UIkit.modal('#addSpecialDayModal').show();
}
function saveSpecialDay() {
    var calendarKey = document.getElementById('sd_calendarKey').value;
    var date = document.getElementById('sd_date').value.trim();
    if (!date) { UIkit.notification({message: 'Please enter a date!', status: 'warning'}); return; }
    var dateRegex = /^(\d{2})\.(\d{2})(\.(\d{4}))?$/;
    if (!dateRegex.test(date)) { UIkit.notification({message: 'Invalid date format! Use DD.MM or DD.MM.YYYY', status: 'warning'}); return; }
    var generatedKey = calendarKey + '.' + date;
    var fromHour = document.getElementById('sd_from_hour').value;
    var fromMin = document.getElementById('sd_from_min').value;
    var toHour = document.getElementById('sd_to_hour').value;
    var toMin = document.getElementById('sd_to_min').value;
    var hour = fromHour + ':' + fromMin + '-' + toHour + ':' + toMin;
    var data = { key: generatedKey, hour: hour, msg_off_days: document.getElementById('sd_msg').value.trim() };
    fetch(API_BASE + '/specialDays', { method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(data) })
    .then(function(response) { return response.json(); })
    .then(function(result) { if (result.success) { UIkit.notification({message: 'Special day added successfully!', status: 'success'}); UIkit.modal('#addSpecialDayModal').hide(); loadAllData(); } else { UIkit.notification({message: result.message, status: 'danger'}); } })
    .catch(function(error) { console.error('Error:', error); UIkit.notification({message: 'Server connection failed!', status: 'danger'}); });
}
function deleteSpecialDay(key) {
    UIkit.modal.confirm('Delete special day <strong>' + key + '</strong>?').then(function() {
        fetch(API_BASE + '/specialDays?key=' + encodeURIComponent(key), { method: 'DELETE' })
        .then(function(response) { return response.json(); })
        .then(function(result) { if (result.success) { UIkit.notification({message: 'Special day deleted!', status: 'success'}); loadAllData(); } else { UIkit.notification({message: result.message, status: 'danger'}); } })
        .catch(function(error) { console.error('Error:', error); UIkit.notification({message: 'Server connection failed!', status: 'danger'}); });
    }, function() {});
}
function escapeHtml(text) { if (!text) return ''; var div = document.createElement('div'); div.textContent = text; return div.innerHTML; }
</script>
</body>
</html>