/**
 *  Diagnostic plugin for Android
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 **/
var Diagnostic = function(){};

/**
 * Checks if location is enabled.
 * On iOS this returns true if both the device setting for Location Services is ON, AND the application is authorized to use location.
 * When location is enabled, the locations returned are by a mixture GPS hardware, network triangulation and Wifi network IDs.
 *
 * @param {Function} successCallback - The callback which will be called when diagnostic is successful. 
 * This callback function is passed a single boolean parameter with the diagnostic result.
 * @param {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
 * This callback function is passed a single string parameter containing the error message.
 */
Diagnostic.prototype.isLocationEnabled = function(successCallback, errorCallback) {
	return cordova.exec(successCallback,
						errorCallback,
						'Diagnostic',
						'isLocationEnabled',
						[]);
};

/**
 * Checks the device setting for Location Services
 * Returns true if Location Services is enabled.
 *
 * @param {Function} successCallback - The callback which will be called when diagnostic is successful. 
 * This callback function is passed a single boolean parameter with the diagnostic result.
 * @param {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
 * This callback function is passed a single string parameter containing the error message.
 */
Diagnostic.prototype.isLocationEnabledSetting = function(successCallback, errorCallback) {
	return cordova.exec(successCallback,
						errorCallback,
						'Diagnostic',
						'isLocationEnabledSetting',
						[]);
};


/**
 * Checks if the application is authorized to use location.
 * Returns true if application is authorized to use location.
 *
 * @param {Function} successCallback - The callback which will be called when diagnostic is successful. 
 * This callback function is passed a single boolean parameter with the diagnostic result.
 * @param {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
 * This callback function is passed a single string parameter containing the error message.
 */
Diagnostic.prototype.isLocationAuthorized = function(successCallback, errorCallback) {
	return cordova.exec(successCallback,
						errorCallback,
						'Diagnostic',
						'isLocationAuthorized',
						[]);
};

/**
 * Checks if Wi-Fi connection exists.
 * On iOS this returns true if the device is connected to a network by WiFi.
 *
 * @param {Function} successCallback - The callback which will be called when diagnostic is successful. 
 * This callback function is passed a single boolean parameter with the diagnostic result.
 * @param {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
 * This callback function is passed a single string parameter containing the error message.
 */
Diagnostic.prototype.isWifiEnabled = function(successCallback, errorCallback) {
	return cordova.exec(successCallback,
						errorCallback,
						'Diagnostic',
						'isWifiEnabled',
						[]);
};

/**
 * Checks if camera exists and is available.
 *
 * @param {Function} successCallback - The callback which will be called when diagnostic is successful. 
 * This callback function is passed a single boolean parameter with the diagnostic result.
 * @param {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
 * This callback function is passed a single string parameter containing the error message.
 */
Diagnostic.prototype.isCameraEnabled = function(successCallback, errorCallback) {
	return cordova.exec(successCallback,
						errorCallback,
						'Diagnostic',
						'isCameraEnabled',
						[]);
};

/**
 * Checks if the device has Bluetooth capabilities and if so that Bluetooth is switched on
 *
 * @param {Function} successCallback - The callback which will be called when diagnostic is successful. 
 * This callback function is passed a single boolean parameter with the diagnostic result.
 * @param {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
 * This callback function is passed a single string parameter containing the error message.
 */
Diagnostic.prototype.isBluetoothEnabled = function(successCallback, errorCallback) {
	return cordova.exec(successCallback,
		errorCallback,
		'Diagnostic',
		'isBluetoothEnabled',
		[]);
};

/**
 * Switch to settings app. Opens settings page for this app.
 *
 * @param {Function} successCallback - The callback which will be called when switch to settings is successful.
 * @param {Function} errorCallback - The callback which will be called when switch to settings encounters an error.
 * This callback function is passed a single string parameter containing the error message.
 * This works only on iOS 8+. iOS 7 and below will invoke the errorCallback.
 */
Diagnostic.prototype.switchToSettings = function(successCallback, errorCallback) {
	return cordova.exec(successCallback,
		errorCallback,
		'Diagnostic',
		'switchToSettings',
		[]);
};

module.exports = new Diagnostic();

