<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Genesys Calendar Manager</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/uikit@3.17.11/dist/css/uikit.min.css" />
    
    <script src="https://cdn.jsdelivr.net/npm/uikit@3.17.11/dist/js/uikit.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/uikit@3.17.11/dist/js/uikit-icons.min.js"></script>
    
    <style>
        .day-label { font-weight: 600; font-size: 0.9rem; color: #666; margin-bottom: 5px; display: block; }
        .uk-card { border-radius: 8px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); }
    </style>
</head>
<body class="uk-background-muted uk-height-viewport uk-padding-small">

    <div class="uk-container uk-container-small uk-margin-medium-top">
        
        <div class="uk-text-center uk-margin-bottom">
            <h2 class="uk-text-primary uk-text-uppercase" style="letter-spacing: 2px;">
                <span uk-icon="icon: calendar; ratio: 1.5"></span> Calendario
            </h2>
            <p class="uk-text-meta">Genesys Cloud Schedule Management System</p>
        </div>

        <div class="uk-card uk-card-default uk-card-body">
            
            <div class="uk-margin-medium-bottom">
                <label class="uk-form-label uk-text-bold">Select Calendar / Department</label>
                <div class="uk-form-controls">
                    <select class="uk-select uk-form-large" id="calendarKey" onchange="loadData()">
                        <option value="" disabled selected>Choose a calendar...</option>
                        
                        <option value="IT_Support">IT Support</option>
                        <option value="Sales_Team">Sales Team</option>
                        <option value="Customer_Service">Customer Service</option>
                        
                    </select>
                </div>
            </div>

            <hr class="uk-divider-icon">

            <form id="scheduleForm" onsubmit="return false;">
                
                <div class="uk-grid-small uk-child-width-1-2@s" uk-grid>
                    <div>
                        <span class="day-label">Monday (mon)</span>
                        <input class="uk-input" type="text" name="mon" id="mon" placeholder="09:00-18:00">
                    </div>
                    <div>
                        <span class="day-label">Tuesday (tue)</span>
                        <input class="uk-input" type="text" name="tue" id="tue" placeholder="09:00-18:00">
                    </div>
                    <div>
                        <span class="day-label">Wednesday (wed)</span>
                        <input class="uk-input" type="text" name="wed" id="wed" placeholder="09:00-18:00">
                    </div>
                    <div>
                        <span class="day-label">Thursday (thu)</span>
                        <input class="uk-input" type="text" name="thu" id="thu" placeholder="09:00-18:00">
                    </div>
                    <div>
                        <span class="day-label">Friday (fri)</span>
                        <input class="uk-input" type="text" name="fri" id="fri" placeholder="09:00-18:00">
                    </div>
                    <div>
                        <span class="day-label uk-text-warning">Saturday (sat)</span>
                        <input class="uk-input" type="text" name="sat" id="sat" placeholder="CLOSED">
                    </div>
                    <div>
                        <span class="day-label uk-text-danger">Sunday (sun)</span>
                        <input class="uk-input" type="text" name="sun" id="sun" placeholder="CLOSED">
                    </div>
                    
                    <div class="uk-width-1-1">
                        <span class="day-label" style="color:#d32f2f">Out of Hours Message (msg)</span>
                        <input class="uk-input" type="text" name="msg" id="msg" placeholder="We are currently closed. Please call back later.">
                    </div>
                </div>

                <div class="uk-margin-medium-top uk-text-right">
                    <button class="uk-button uk-button-default uk-margin-small-right" type="button" onclick="clearForm()">Clear</button>
                    <button class="uk-button uk-button-primary" type="button" onclick="saveData()">
                        <span uk-icon="check"></span> Save Changes
                    </button>
                </div>

            </form>
        </div>
        
        <div class="uk-text-center uk-margin-top uk-text-small uk-text-muted">
            Powered by Calendario v1.0
        </div>
    </div>

    <script>
        function loadData() {
            var key = document.getElementById("calendarKey").value;
            if(!key) return;

            document.getElementById("scheduleForm").reset();
            UIkit.notification({message: '<span uk-icon=\'refresh\'></span> Loading data from Genesys...', status: 'primary', pos: 'top-center', timeout: 1500});

            fetch('api/engine?key=' + key)
            .then(res => res.json())
            .then(data => {
                if(data.status === 'success') {
                    var row = data.data;
                    
                    document.getElementById('mon').value = row.mon || "";
                    document.getElementById('tue').value = row.tue || "";
                    document.getElementById('wed').value = row.wed || "";
                    document.getElementById('thu').value = row.thu || "";
                    document.getElementById('fri').value = row.fri || "";
                    document.getElementById('sat').value = row.sat || "";
                    document.getElementById('sun').value = row.sun || "";
                    document.getElementById('msg').value = row.msg || "";
                    
                    UIkit.notification({message: '<span uk-icon=\'check\'></span> Data loaded!', status: 'success', pos: 'top-center'});
                } else {
                    UIkit.notification({message: 'No data found for this calendar.', status: 'warning', pos: 'top-center'});
                }
            })
            .catch(err => {
                console.error(err);
                UIkit.notification({message: 'Connection Error!', status: 'danger'});
            });
        }

        function saveData() {
            var key = document.getElementById("calendarKey").value;
            if(!key) { 
                UIkit.modal.alert('Please select a calendar first!'); 
                return; 
            }

            var formData = new URLSearchParams(new FormData(document.getElementById('scheduleForm')));
            formData.append("key", key);

            UIkit.notification({message: 'Saving changes...', status: 'primary', pos: 'top-center'});

            fetch('api/engine', {
                method: 'POST',
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                if(data.status === 'success') {
                    UIkit.modal.alert('Changes saved successfully to Genesys Cloud!').then(function() {
                        loadData();
                    });
                } else {
                    UIkit.modal.alert('Error: ' + data.msg);
                }
            })
            .catch(err => {
                console.error(err);
                UIkit.notification({message: 'Save failed! Check logs.', status: 'danger'});
            });
        }

        function clearForm() {
            document.getElementById("scheduleForm").reset();
        }
    </script>
</body>
</html>