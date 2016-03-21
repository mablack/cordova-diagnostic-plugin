/**
 *  Diagnostic plugin for iOS
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 **/
var Diagnostic = (function(){

	// Callback function to execute upon change in location authorization status
	var _onLocationAuthorizationStatusChangeCallback = null;

	// Callback function to execute upon change in Bluetooth state
	var _onBluetoothStateChangeCallback = function(){};

	/********************
	 * Internal functions
	 ********************/

	function ensureBoolean(callback){
		return function(result){
			callback(!!result);
		}
	}

	/**********************
	 * Public API functions
	 **********************/
	var Diagnostic = {};

	/**
	 * Checks if location is enabled.
	 * On iOS this returns true if both the device setting for Location Services is ON, AND the application is authorized to use location.
	 * When location is enabled, the locations returned are by a mixture GPS hardware, network triangulation and Wifi network IDs.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single boolean parameter which is TRUE if location is available for use.
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isLocationEnabled = function(successCallback, errorCallback) {
		return cordova.exec(ensureBoolean(successCallback),
			errorCallback,
			'Diagnostic',
			'isLocationEnabled',
			[]);
	};

	/**
	 * Checks the device setting for Location Services
	 * Returns true if Location Services is enabled.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single boolean parameter which is TRUE if Location Services is enabled.
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isLocationEnabledSetting = function(successCallback, errorCallback) {
		return cordova.exec(ensureBoolean(successCallback),
			errorCallback,
			'Diagnostic',
			'isLocationEnabledSetting',
			[]);
	};


	/**
	 * Checks if the application is authorized to use location.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single boolean parameter which is TRUE if application is authorized to use location either "when in use" (only in foreground) OR "always" (foreground and background).
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isLocationAuthorized = function(successCallback, errorCallback) {
		return cordova.exec(ensureBoolean(successCallback),
			errorCallback,
			'Diagnostic',
			'isLocationAuthorized',
			[]);
	};

	/**
	 * Returns the location authorization status for the application.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single string parameter which indicates the location authorization status.
	 * Possible values are: "unknown", "denied", "not_determined", "authorized_always", "authorized_when_in_use"
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.getLocationAuthorizationStatus = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'getLocationAuthorizationStatus',
			[]);
	};

	/**
	 * Requests location authorization for the application.
	 * Authorization can be requested to use location either "when in use" (only in foreground) or "always" (foreground and background).
	 * Should only be called if authorization status is NOT_DETERMINED. Calling it when in any other state will have no effect.
	 *
	 * @param {Function} successCallback - The callback which will be called on successfully requesting location authorization.
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 * @param {String} mode - (optional) location authorization mode: "always" or "when_in_use". If not specified, defaults to "when_in_use".
	 */
	Diagnostic.requestLocationAuthorization = function(successCallback, errorCallback, mode) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'requestLocationAuthorization',
			[mode && mode === "always"]);
	};

	/**
	 * Called by native element of the plugin on a change in location authorization status
	 * NOTE: this should not be invoked manually; it is present in the public API so it is visible to the native part of the plugin.
	 * To be notified of a change in location authorization status, register a handler using registerLocationAuthorizationStatusHandler()
	 * @param {String} status - new location authorization status
	 * @private
	 * @deprecated
	 */
	Diagnostic._onLocationAuthorizationStatusChange = function(status){
		if(_onLocationAuthorizationStatusChangeCallback){
			_onLocationAuthorizationStatusChangeCallback(status);
		}
	};

	/**
	 * Registers a function to be called when a change in location authorization status occurs.
	 * @param {Function} fn - function call when a change in location authorization status occurs.
	 * This callback function is passed a single string parameter containing new status.
	 * Possible values are: "unknown", "denied", "not_determined", "authorized_always" or "authorized_when_in_use"
	 * @deprecated
	 */
	Diagnostic.registerLocationAuthorizationStatusChangeHandler = function(fn){
		console.warn("registerLocationAuthorizationStatusChangeHandler() is deprecated and will be removed in a future version. Update your code pass this function to requestLocationAuthorization() as successCallback, which will now be invoked when a change in location authorization status occurs");
		_onLocationAuthorizationStatusChangeCallback = fn;
	};

	/**
	 * Checks if camera is enabled for use.
	 * On iOS this returns true if both the device has a camera AND the application is authorized to use it.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single boolean parameter which is TRUE if camera is present and authorized for use.
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isCameraEnabled = function(successCallback, errorCallback) {
		return cordova.exec(ensureBoolean(successCallback),
			errorCallback,
			'Diagnostic',
			'isCameraEnabled',
			[]);
	};

	/**
	 * Checks if camera hardware is present on device.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single boolean parameter which is TRUE if camera is present
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isCameraPresent = function(successCallback, errorCallback) {
		return cordova.exec(ensureBoolean(successCallback),
			errorCallback,
			'Diagnostic',
			'isCameraPresent',
			[]);
	};


	/**
	 * Checks if the application is authorized to use the camera.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single boolean parameter which is TRUE if camera is authorized for use.
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isCameraAuthorized = function(successCallback, errorCallback) {
		return cordova.exec(ensureBoolean(successCallback),
			errorCallback,
			'Diagnostic',
			'isCameraAuthorized',
			[]);
	};

	/**
	 * Returns the camera authorization status for the application.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single string parameter which indicates the authorization status.
	 * Possible values are: "unknown", "denied", "not_determined", "authorized"
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.getCameraAuthorizationStatus = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'getCameraAuthorizationStatus',
			[]);
	};

	/**
	 * Requests camera authorization for the application.
	 * Should only be called if authorization status is NOT_DETERMINED. Calling it when in any other state will have no effect.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single boolean parameter indicating whether access to the camera was granted or denied.
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.requestCameraAuthorization = function(successCallback, errorCallback) {
		return cordova.exec(ensureBoolean(successCallback),
			errorCallback,
			'Diagnostic',
			'requestCameraAuthorization',
			[]);
	};

	/**
	 * Checks if the application is authorized to use the Camera Roll in Photos app.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single boolean parameter which is TRUE if access to Camera Roll is authorized.
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isCameraRollAuthorized = function(successCallback, errorCallback) {
		return cordova.exec(ensureBoolean(successCallback),
			errorCallback,
			'Diagnostic',
			'isCameraRollAuthorized',
			[]);
	};

	/**
	 * Returns the authorization status for the application to use the Camera Roll in Photos app.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single string parameter which indicates the authorization status.
	 * Possible values are: "unknown", "denied", "not_determined", "authorized"
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.getCameraRollAuthorizationStatus = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'getCameraRollAuthorizationStatus',
			[]);
	};

	/**
	 * Requests camera roll authorization for the application.
	 * Should only be called if authorization status is NOT_DETERMINED. Calling it when in any other state will have no effect.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single string parameter indicating the new authorization status: "denied" or "authorized"
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.requestCameraRollAuthorization = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'requestCameraRollAuthorization',
			[]);
	};

	/**
	 * Checks if Wi-Fi connection exists.
	 * On iOS this returns true if the device is connected to a network by WiFi.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single boolean parameter which is TRUE if device is connected by WiFi.
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isWifiEnabled = function(successCallback, errorCallback) {
		return cordova.exec(ensureBoolean(successCallback),
			errorCallback,
			'Diagnostic',
			'isWifiEnabled',
			[]);
	};


	/**
	 * Checks if the device has Bluetooth LE capabilities and if so that Bluetooth is switched on
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single boolean parameter which is TRUE if device has Bluetooth LE and Bluetooth is switched on.
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isBluetoothEnabled = function(successCallback, errorCallback) {
		return cordova.exec(ensureBoolean(successCallback),
			errorCallback,
			'Diagnostic',
			'isBluetoothEnabled',
			[]);
	};

	/**
	 * Returns the state of Bluetooth LE on the device.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single string parameter which indicates the bluetooth state.
	 * Possible values are: "unknown", "resetting", "unsupported", "unauthorized", "powered_off", "powered_on"
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.getBluetoothState = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'getBluetoothState',
			[]);
	};

	/**
	 * Called by native element of the plugin on a change in Bluetooth state
	 * NOTE: this should not be invoked manually; it is present in the public API so it is visible to the native part of the plugin.
	 * To be notified of a change in Bluetooth state, register a handler using registerLocationAuthorizationStatusHandler()
	 * @param {String} status - new location authorization status
	 * @private
	 */
	Diagnostic._onBluetoothStateChange = function(state){
		_onBluetoothStateChangeCallback(state);
	};

	/**
	 * Registers a function to be called when a change in Bluetooth state occurs.
	 * @param {Function} fn - function call when a change in Bluetooth state occurs.
	 * This callback function is passed a single string parameter containing new state.
	 * Possible values are: "unknown", "resetting", "unsupported", "unauthorized", "powered_off", "powered_on"
	 */
	Diagnostic.registerBluetoothStateChangeHandler = function(fn){
		_onBluetoothStateChangeCallback = fn;
	};

	/**
	 * Switch to settings app. Opens settings page for this app.
	 *
	 * @param {Function} successCallback - The callback which will be called when switch to settings is successful.
	 * @param {Function} errorCallback - The callback which will be called when switch to settings encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 * This works only on iOS 8+. iOS 7 and below will invoke the errorCallback.
	 */
	Diagnostic.switchToSettings = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'switchToSettings',
			[]);
	};

	/**
	 * Checks if the application is authorized to use the microphone for recording audio.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single boolean parameter which is TRUE if access to microphone is authorized.
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isMicrophoneAuthorized = function(successCallback, errorCallback) {
		return cordova.exec(ensureBoolean(successCallback),
			errorCallback,
			'Diagnostic',
			'isMicrophoneAuthorized',
			[]);
	};

	/**
	 * Returns the authorization status for the application to use the microphone for recording audio.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single string parameter which indicates the authorization status.
	 * Possible values are: "unknown", "denied", "not_determined", "authorized"
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.getMicrophoneAuthorizationStatus = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'getMicrophoneAuthorizationStatus',
			[]);
	};

	/**
	 * Requests access to microphone if authorization was never granted nor denied, will only return access status otherwise.
	 *
	 * @param {Function} successCallback - The callback which will be called when switch to settings is successful.
	 * @param {Function} errorCallback - The callback which will be called when an error occurs.
	 * This callback function is passed a single string parameter containing the error message.
	 * This works only on iOS 7+.
	 */
	Diagnostic.requestMicrophoneAuthorization = function(successCallback, errorCallback) {
		return cordova.exec(successCallback,
			errorCallback,
			'Diagnostic',
			'requestMicrophoneAuthorization',
			[]);
	};

	/**
	 * Checks if remote (push) notifications are enabled.
	 * On iOS 8+, returns true if app is registered for remote notifications AND "Allow Notifications" switch is ON AND alert style is not set to "None" (i.e. "Banners" or "Alerts").
	 * On iOS <=7, returns true if app is registered for remote notifications AND alert style is not set to "None" (i.e. "Banners" or "Alerts") - same as isRegisteredForRemoteNotifications().
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single boolean parameter which is TRUE if remote (push) notifications are enabled.
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isRemoteNotificationsEnabled = function(successCallback, errorCallback) {
		return cordova.exec(ensureBoolean(successCallback),
			errorCallback,
			'Diagnostic',
			'isRemoteNotificationsEnabled',
			[]);
	};

	/**
	 * Indicates the current setting of notification types for the app in the Settings app.
	 * Note: on iOS 8+, if "Allow Notifications" switch is OFF, all types will be returned as disabled.
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single object parameter where the key is the notification type and the value is a boolean indicating whether it's enabled:
	 * "alert" => alert style is not set to "None" (i.e. "Banners" or "Alerts");
	 * "badge" => "Badge App Icon" switch is ON;
	 * "sound" => "Sounds"/"Alert Sound" switch is ON.
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.getRemoteNotificationTypes = function(successCallback, errorCallback) {
		return cordova.exec(function(sTypes){
				var oTypes = JSON.parse(sTypes);
				for(var type in oTypes){
					oTypes[type] = parseInt(oTypes[type]) === 1 ;
				}
				successCallback(oTypes);
			},
			errorCallback,
			'Diagnostic',
			'getRemoteNotificationTypes',
			[]);
	};

	/**
	 * Indicates if the app is registered for remote notifications on the device.
	 * On iOS 8+, returns true if the app is registered for remote notifications and received its device token,
	 * or false if registration has not occurred, has failed, or has been denied by the user.
	 * Note that user preferences for notifications in the Settings app will not affect this.
	 * On iOS <=7, returns true if app is registered for remote notifications AND alert style is not set to "None" (i.e. "Banners" or "Alerts") - same as isRemoteNotificationsEnabled().
	 *
	 * @param {Function} successCallback - The callback which will be called when operation is successful.
	 * This callback function is passed a single boolean parameter which is TRUE if the device is registered for remote (push) notifications.
	 * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
	 * This callback function is passed a single string parameter containing the error message.
	 */
	Diagnostic.isRegisteredForRemoteNotifications = function(successCallback, errorCallback) {
		return cordova.exec(ensureBoolean(successCallback),
			errorCallback,
			'Diagnostic',
			'isRegisteredForRemoteNotifications',
			[]);
	};

	return Diagnostic;
})();



module.exports = Diagnostic;
