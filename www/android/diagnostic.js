/**
 *  Diagnostic plugin for Android
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 **/
var Diagnostic = (function(){

	/**********************
	 * Internal properties
	 *********************/
	var Diagnostic = {};

	var runtimeStoragePrefix = "__diag_rtm_";

	var runtimeGroupsMap;

	/********************
	 * Public properties
	 ********************/

	/**
	 * "Dangerous" permissions that need to be requested at run-time (Android 6.0/API 23 and above)
	 * See http://developer.android.com/guide/topics/security/permissions.html#perm-groups
	 * @type {Object}
	 */
	Diagnostic.runtimePermission = {
		"READ_CALENDAR": "READ_CALENDAR",
		"WRITE_CALENDAR": "WRITE_CALENDAR",
		"CAMERA": "CAMERA",
		"READ_CONTACTS": "READ_CONTACTS",
		"WRITE_CONTACTS": "WRITE_CONTACTS",
		"GET_ACCOUNTS": "GET_ACCOUNTS",
		"ACCESS_FINE_LOCATION": "ACCESS_FINE_LOCATION",
		"ACCESS_COARSE_LOCATION": "ACCESS_COARSE_LOCATION",
		"RECORD_AUDIO": "RECORD_AUDIO",
		"READ_PHONE_STATE": "READ_PHONE_STATE",
		"CALL_PHONE": "CALL_PHONE",
		"ADD_VOICEMAIL": "ADD_VOICEMAIL",
		"USE_SIP": "USE_SIP",
		"PROCESS_OUTGOING_CALLS": "PROCESS_OUTGOING_CALLS",
		"READ_CALL_LOG": "READ_CALL_LOG",
		"WRITE_CALL_LOG": "WRITE_CALL_LOG",
		"SEND_SMS": "SEND_SMS",
		"RECEIVE_SMS": "RECEIVE_SMS",
		"READ_SMS": "READ_SMS",
		"RECEIVE_WAP_PUSH": "RECEIVE_WAP_PUSH",
		"RECEIVE_MMS": "RECEIVE_MMS",
		"WRITE_EXTERNAL_STORAGE": "WRITE_EXTERNAL_STORAGE",
		"READ_EXTERNAL_STORAGE": "READ_EXTERNAL_STORAGE",
		"BODY_SENSORS": "BODY_SENSORS"
	};

	/**
	 * Permission groups indicate which associated permissions will also be requested if a given permission is requested.
	 * See http://developer.android.com/guide/topics/security/permissions.html#perm-groups
	 * @type {Object}
	 */
	Diagnostic.runtimePermissionGroups = {
		"CALENDAR": ["READ_CALENDAR", "WRITE_CALENDAR"],
		"CAMERA": ["CAMERA"],
		"CONTACTS": ["READ_CONTACTS", "WRITE_CONTACTS", "GET_ACCOUNTS"],
		"LOCATION": ["ACCESS_FINE_LOCATION", "ACCESS_COARSE_LOCATION"],
		"MICROPHONE": ["RECORD_AUDIO"],
		"PHONE": ["READ_PHONE_STATE", "CALL_PHONE", "ADD_VOICEMAIL", "USE_SIP", "PROCESS_OUTGOING_CALLS", "READ_CALL_LOG", "WRITE_CALL_LOG"],
		"SENSORS": ["BODY_SENSORS"],
		"SMS": ["SEND_SMS", "RECEIVE_SMS", "READ_SMS", "RECEIVE_WAP_PUSH", "RECEIVE_MMS"],
		"STORAGE": ["READ_EXTERNAL_STORAGE", "WRITE_EXTERNAL_STORAGE"]
	};

	Diagnostic.runtimePermissionStatus = {
		"GRANTED": "GRANTED", //  permission has already been granted or the device is running Android 5.1 (API level 22) or lower
		"DENIED": "DENIED", // User denied access to this permission
		"NOT_REQUESTED": "NOT_REQUESTED", // app has not yet requested this permission
		"DENIED_ALWAYS": "DENIED_ALWAYS" // User denied access to this permission and checked "Never Ask Again" box.
	};


	Diagnostic.firstRequestedPermissions;


	/********************
	 * Internal functions
	 ********************/

	function checkForInvalidPermissions(permissions, errorCallback){
		if(typeof(permissions) !== "object") permissions = [permissions];
		var valid = true, invalidPermissions = [];
		permissions.forEach(function(permission){
			if(!Diagnostic.runtimePermission[permission]){
				invalidPermissions.push(permission);
			}
		});
		if(invalidPermissions.length > 0){
			errorCallback("Invalid permissions specified: "+result.invalidPermissions.join(", "));
			valid = false;
		}
		return valid;
	}

	/**
	 * Maintains a locally persisted list of which permissions have been requested in order to resolve the returned status of STATUS_NOT_REQUESTED_OR_DENIED_ALWAYS to either NOT_REQUESTED or DENIED_ALWAYS.
	 * Since requesting a given permission implicitly requests all other permissions in the same group (e.g. requesting READ_CALENDAR will also grant/deny WRITE_CALENDAR),
	 * flag every permission in the groups that were requested.
	 * @param {Array} permissions - list of requested permissions
	 */
	function updateFirstRequestedPermissions(permissions){
		var groups = {};

		permissions.forEach(function(permission){
			groups[runtimeGroupsMap[permission]] = 1;
		});


		for(var group in groups){
			Diagnostic.runtimePermissionGroups[group].forEach(function(permission){
				if(!Diagnostic.firstRequestedPermissions[permission]){
					setPermissionFirstRequested(permission);
				}
			});
		}
	}

	function setPermissionFirstRequested(permission){
		localStorage.setItem(runtimeStoragePrefix+permission, 1);
		getFirstRequestedPermissions();
	}

	function getFirstRequestedPermissions(){
		if(!runtimeGroupsMap){
			buildRuntimeGroupsMap();
		}
		Diagnostic.firstRequestedPermissions = {};
		for(var permission in Diagnostic.runtimePermission){
			if(localStorage.getItem(runtimeStoragePrefix+permission) == 1){
				Diagnostic.firstRequestedPermissions[permission] = 1;
			}
		}
		return Diagnostic.firstRequestedPermissions;
	}

	function resolveStatus(permission, status){
		if(status == "STATUS_NOT_REQUESTED_OR_DENIED_ALWAYS"){
			status = Diagnostic.firstRequestedPermissions[permission] ? Diagnostic.runtimePermissionStatus.DENIED_ALWAYS : Diagnostic.runtimePermissionStatus.NOT_REQUESTED;
		}
		return status;
	}

	function buildRuntimeGroupsMap(){
		runtimeGroupsMap = {};
		for(var group in Diagnostic.runtimePermissionGroups){
			var permissions = Diagnostic.runtimePermissionGroups[group];
			for(var i=0; i<permissions.length; i++){
				runtimeGroupsMap[permissions[i]] = group;
			}
		}
	}


	/**********************
	 * Public API functions
	 **********************/

	/**
	 * Checks if location is enabled.
	 * On Android, this returns true if Location Mode is enabled and any mode is selected (e.g. Battery saving, Device only, High accuracy)
	 *
	 * @param {Function} successCallback - The callback which will be called when diagnostic is successful.
	 * This callback function is passed a single boolean parameter with the diagnostic result.
	 * @param {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
	 *  This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isLocationEnabled = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'isLocationEnabled',
			[]);
	};

	/**
	 * Checks if location mode is set to return high-accuracy locations from GPS hardware.
	 * Returns true if Location mode is enabled and is set to either:
	 * Device only = GPS hardware only (high accuracy)
	 * High accuracy = GPS hardware, network triangulation and Wifi network IDs (high and low accuracy)
	 *
	 * @param {Function} successCallback -  The callback which will be called when diagnostic is successful.
	 * This callback function is passed a single boolean parameter with the diagnostic result.
	 * @param {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
	 *  This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isGpsLocationEnabled = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'isGpsLocationEnabled',
			[]);
	};

	/**
	 * Checks if location mode is set to return low-accuracy locations from network triangulation/WiFi access points.
	 * Returns true if Location mode is enabled and is set to either:
	 * Battery saving = network triangulation and Wifi network IDs (low accuracy)
	 * High accuracy = GPS hardware, network triangulation and Wifi network IDs (high and low accuracy)
	 *
	 * @param {Function} successCallback -  The callback which will be called when diagnostic is successful.
	 * This callback function is passed a single boolean parameter with the diagnostic result.
	 * @param {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
	 *  This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isNetworkLocationEnabled = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'isNetworkLocationEnabled',
			[]);
	};

	/**
	 * Returns the current location mode setting for the device.
	 *
	 * @param {Function} successCallback -  The callback which will be called when diagnostic is successful.
	 * This callback function is passed a single string parameter with the diagnostic result. Values that may be passed to the success callback:
	 * "high_accuracy" - GPS hardware, network triangulation and Wifi network IDs (high and low accuracy);
	 * "device_only" - GPS hardware only (high accuracy);
	 * "battery_saving" - network triangulation and Wifi network IDs (low accuracy);
	 * "location_off" - Location is turned off
	 * @param {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
	 *  This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.getLocationMode = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'getLocationMode',
			[]);
	};

	/**
	 * Checks if Wifi is connected/enabled.
	 * On Android this returns true if the WiFi setting is set to enabled.
	 *
	 * @param {Function} successCallback -  The callback which will be called when diagnostic is successful.
	 * This callback function is passed a single boolean parameter with the diagnostic result.
	 * @param {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
	 *  This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isWifiEnabled = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'isWifiEnabled',
			[]);
	};

	/**
	 * Checks if exists camera.
	 *
	 * @param {Function} successCallback -  The callback which will be called when diagnostic is successful.
	 * This callback function is passed a single boolean parameter with the diagnostic result.
	 * @param {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
	 *  This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isCameraEnabled = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'isCameraEnabled',
			[]);
	};

	/**
	 * Checks if Bluetooth is enabled
	 *
	 * @param {Function} successCallback -  The callback which will be called when diagnostic is successful.
	 * This callback function is passed a single boolean parameter with the diagnostic result.
	 * @param {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
	 *  This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isBluetoothEnabled = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'isBluetoothEnabled',
			[]);
	};

	/**
	 * Switches to the Location page in the Settings app
	 */
	Diagnostic.switchToLocationSettings = function() {
		return cordova.exec(null,
			null,
			'Diagnostic',
			'switchToLocationSettings',
			[]);
	};

	/**
	 * Switches to the Mobile Data page in the Settings app
	 */
	Diagnostic.switchToMobileDataSettings = function() {
		return cordova.exec(null,
			null,
			'Diagnostic',
			'switchToMobileDataSettings',
			[]);
	};

	/**
	 * Switches to the Bluetooth page in the Settings app
	 */
	Diagnostic.switchToBluetoothSettings = function() {
		return cordova.exec(null,
			null,
			'Diagnostic',
			'switchToBluetoothSettings',
			[]);
	};

	/**
	 * Switches to the WiFi page in the Settings app
	 */
	Diagnostic.switchToWifiSettings = function() {
		return cordova.exec(null,
			null,
			'Diagnostic',
			'switchToWifiSettings',
			[]);
	};

	/**
	 * Enables/disables WiFi on the device.
	 *
	 * @param {Function} successCallback - function to call on successful setting of WiFi state
	 * @param {Function} errorCallback - function to call on failure to set WiFi state.
	 * This callback function is passed a single string parameter containing the error message.
	 * @param {Boolean} state - WiFi state to set: TRUE for enabled, FALSE for disabled.
	 */
	Diagnostic.setWifiState = function(successCallback, errorCallback, state) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'setWifiState',
			[state]);
	};

	/**
	 * Enables/disables Bluetooth on the device.
	 *
	 * @param {Function} successCallback - function to call on successful setting of Bluetooth state
	 * @param {Function} errorCallback - function to call on failure to set Bluetooth state.
	 * This callback function is passed a single string parameter containing the error message.
	 * @param {Boolean} state - Bluetooth state to set: TRUE for enabled, FALSE for disabled.
	 */
	Diagnostic.setBluetoothState = function(successCallback, errorCallback, state) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'setBluetoothState',
			[state]);
	};


	/*********************************
	 * Android 6.0 runtime permissions
	 *********************************/

	/**
	 * Returns the current authorisation status for a given permission.
	 *
	 * @param {Function} successCallback - function to call on successful retrieval of status.
	 * This callback function is passed a single {String} argument which defines the current authorisation status as a value in Diagnostic.runtimePermissionStatus.
	 * @param {Function} errorCallback - function to call on failure to retrieve authorisation status.
	 * This callback function is passed a single string parameter containing the error message.
	 * @param {String} permission - permission to request authorisation status for, defined as a value in Diagnostic.runtimePermission
	 */
	Diagnostic.getPermissionAuthorizationStatus = function(successCallback, errorCallback, permission){
		if(!checkForInvalidPermissions(permission, errorCallback)) return;

		function onSuccess(status){
			successCallback(resolveStatus(permission, status));
		}

		return cordova.exec(
			onSuccess,
			errorCallback,
			'Diagnostic',
			'getPermissionAuthorizationStatus',
			[permission]);
	};

	/**
	 * Returns the current authorisation status for a given permission.
	 *
	 * @param {Function} successCallback - function to call on successful retrieval of status.
	 * This callback function is passed a single {Object} argument which defines a key/value map, where the key is the permission defined as a value in Diagnostic.runtimePermissio, and the value is the current authorisation statuses as a value in Diagnostic.runtimePermissionStatus.
	 * @param {Function} errorCallback - function to call on failure to retrieve authorisation statuses.
	 * This callback function is passed a single string parameter containing the error message.
	 * @param {Array} permissions - list of permissions to request authorisation statuses for, defined as values in Diagnostic.runtimePermission
	 */
	Diagnostic.getPermissionsAuthorizationStatus = function(successCallback, errorCallback, permissions){
		if(!checkForInvalidPermissions(permissions, errorCallback)) return;

		function onSuccess(statuses){
			for(var permission in statuses){
				statuses[permission] = resolveStatus(permission, statuses[permission]);
			}
			successCallback(statuses);
		}

		return cordova.exec(
			onSuccess,
			errorCallback,
			'Diagnostic',
			'getPermissionsAuthorizationStatus',
			[permissions]);
	};


	/**
	 * Requests app to be granted authorisation for a runtime permission.
	 * @param {Function} successCallback - function to call on successful request for runtime permission.
	 * This callback function is passed a single {String} argument which defines the resulting authorisation status as a value in Diagnostic.runtimePermissionStatus.
	 * @param {Function} errorCallback - function to call on failure to request authorisation.
	 * This callback function is passed a single string parameter containing the error message.
	 * @param {String} permission - permission to request authorisation for, defined as a value in Diagnostic.runtimePermission
	 */
	Diagnostic.requestRuntimePermission = function(successCallback, errorCallback, permission) {
		if(!checkForInvalidPermissions(permission, errorCallback)) return;

		function onSuccess(status){
			successCallback(resolveStatus(permission, status[permission]));

			updateFirstRequestedPermissions([permission]);
		}

		return cordova.exec(
			onSuccess,
			errorCallback,
			'Diagnostic',
			'requestRuntimePermission',
			[permission]);
	};

	/**
	 * Requests app to be granted authorisation for runtime permissions.
	 * @param {Function} successCallback - function to call on successful request for runtime permissions.
	 * This callback function is passed a single {String} argument which defines the resulting authorisation status as a value in Diagnostic.runtimePermissionStatus.
	 * @param {Function} errorCallback - function to call on failure to request authorisation.
	 * This callback function is passed a single string parameter containing the error message.
	 * @param {Array} permissions - permissions to request authorisation for, defined as values in Diagnostic.runtimePermission
	 */
	Diagnostic.requestRuntimePermissions = function(successCallback, errorCallback, permissions){
		if(!checkForInvalidPermissions(permissions, errorCallback)) return;

		function onSuccess(statuses){
			for(var permission in statuses){
				statuses[permission] = resolveStatus(permission, statuses[permission]);
			}
			successCallback(statuses);
			updateFirstRequestedPermissions(permissions);
		}

		return cordova.exec(
			onSuccess,
			errorCallback,
			'Diagnostic',
			'requestRuntimePermissions',
			[permissions]);

	};


	/**************************
	 * iOS runtime equivalents
	 **************************/

	Diagnostic.requestLocationAuthorization = function(successCallback, errorCallback){
		Diagnostic.requestRuntimePermissions(successCallback, errorCallback, [
			Diagnostic.runtimePermission.ACCESS_COARSE_LOCATION,
			Diagnostic.runtimePermission.ACCESS_FINE_LOCATION
		]);
	};

	Diagnostic.getLocationAuthorizationStatus = function(successCallback, errorCallback){
		Diagnostic.getPermissionsAuthorizationStatus(successCallback, errorCallback, [
			Diagnostic.runtimePermission.ACCESS_COARSE_LOCATION,
			Diagnostic.runtimePermission.ACCESS_FINE_LOCATION
		]);
	};

	Diagnostic.requestCameraAuthorization = function(successCallback, errorCallback){
		Diagnostic.requestRuntimePermission(successCallback, errorCallback, Diagnostic.runtimePermission.CAMERA);
	};

	Diagnostic.getCameraAuthorizationStatus = function(successCallback, errorCallback){
		Diagnostic.getPermissionAuthorizationStatus(successCallback, errorCallback, [
			Diagnostic.runtimePermission.CAMERA
		]);
	};


	/**************
	 * Constructor
	 **************/
	getFirstRequestedPermissions();

	return Diagnostic;
});

module.exports = new Diagnostic();

