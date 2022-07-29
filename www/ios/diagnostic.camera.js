/* globals cordova, require, exports, module */

/**
 *  Diagnostic Camera plugin for iOS
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 **/
var Diagnostic_Camera = (function(){
    /***********************
     *
     * Internal properties
     *
     *********************/
    var Diagnostic_Camera = {};

    var Diagnostic = require("cordova.plugins.diagnostic.Diagnostic");

    /********************
     *
     * Public properties
     *
     ********************/

    Diagnostic.photoLibraryAccessLevel = Diagnostic_Camera.photoLibraryAccessLevel = {
        "ADD_ONLY": "add_only",
        "READ_WRITE": "read_write"
    };
    
    /********************
     *
     * Internal functions
     *
     ********************/

    function mapFromLegacyCameraApi() {
        var params;
        if (typeof arguments[0]  === "function") {
            params = (arguments.length > 2 && typeof arguments[2]  === "object") ? arguments[2] : {};
            params.successCallback = arguments[0];
            if(arguments.length > 1 && typeof arguments[1]  === "function") {
                params.errorCallback = arguments[1];
            }
        }else { // if (typeof arguments[0]  === "object")
            params = arguments[0];
        }
        return params;
    }

    /*****************************
     *
     * Protected member functions
     *
     ****************************/


    /**********************
     *
     * Public API functions
     *
     **********************/

    /**
     * Checks if camera is enabled for use.
     * On iOS this returns true if both the device has a camera AND the application is authorized to use it.
     *
     * @param {Object} params - (optional) parameters:
     *  - {Function} successCallback - The callback which will be called when operation is successful.
     * This callback function is passed a single boolean parameter which is TRUE if camera is present and authorized for use.
     *  - {Function} errorCallback -  The callback which will be called when operation encounters an error.
     * This callback function is passed a single string parameter containing the error message.
     */
    Diagnostic_Camera.isCameraAvailable = function(params) {
        params = mapFromLegacyCameraApi.apply(this, arguments);

        params.successCallback = params.successCallback || function(){};
        return cordova.exec(Diagnostic._ensureBoolean(params.successCallback),
            params.errorCallback,
            'Diagnostic_Camera',
            'isCameraAvailable',
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
    Diagnostic_Camera.isCameraPresent = function(successCallback, errorCallback) {
        return cordova.exec(Diagnostic._ensureBoolean(successCallback),
            errorCallback,
            'Diagnostic_Camera',
            'isCameraPresent',
            []);
    };


    /**
     * Checks if the application is authorized to use the camera.
     *
     * @param {Object} params - (optional) parameters:
     *  - {Function} successCallback - The callback which will be called when operation is successful.
     * This callback function is passed a single boolean parameter which is TRUE if camera is authorized for use.
     *   - {Function} errorCallback -  The callback which will be called when operation encounters an error.
     * This callback function is passed a single string parameter containing the error message.
     */
    Diagnostic_Camera.isCameraAuthorized = function(params) {
        params = mapFromLegacyCameraApi.apply(this, arguments);

        return cordova.exec(Diagnostic._ensureBoolean(params.successCallback),
            params.errorCallback,
            'Diagnostic_Camera',
            'isCameraAuthorized',
            []);
    };

    /**
     * Returns the camera authorization status for the application.
     *
     * @param {Object} params - (optional) parameters:
     *  - {Function} successCallback - The callback which will be called when operation is successful.
     * This callback function is passed a single string parameter which indicates the authorization status as a constant in `cordova.plugins.diagnostic.permissionStatus`.
     *  - {Function} errorCallback -  The callback which will be called when operation encounters an error.
     * This callback function is passed a single string parameter containing the error message.
     */
    Diagnostic_Camera.getCameraAuthorizationStatus = function(params) {
        params = mapFromLegacyCameraApi.apply(this, arguments);

        return cordova.exec(params.successCallback,
            params.errorCallback,
            'Diagnostic_Camera',
            'getCameraAuthorizationStatus',
            []);
    };

    /**
     * Requests camera authorization for the application.
     * Should only be called if authorization status is NOT_REQUESTED. Calling it when in any other state will have no effect.
     *
     * @param {Object} params - (optional) parameters:
     * - {Function} successCallback - The callback which will be called when operation is successful.
     * This callback function is passed a single string parameter indicating whether access to the camera was granted or denied:
     * `cordova.plugins.diagnostic.permissionStatus.GRANTED` or `cordova.plugins.diagnostic.permissionStatus.DENIED_ALWAYS`
     * - {Function} errorCallback -  The callback which will be called when operation encounters an error.
     * This callback function is passed a single string parameter containing the error message.
     */
    Diagnostic_Camera.requestCameraAuthorization = function(params){
        params = mapFromLegacyCameraApi.apply(this, arguments);

        params.successCallback = params.successCallback || function(){};
        return cordova.exec(function(isGranted){
                params.successCallback(isGranted ? Diagnostic.permissionStatus.GRANTED : Diagnostic.permissionStatus.DENIED_ALWAYS);
            },
            params.errorCallback,
            'Diagnostic_Camera',
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
     * @param {Function} accessLevel - (optional) On iOS 14+, specifies the level of access to the photo library to query as a constant in cordova.plugins.diagnostic.photoLibraryAccessLevel`
     * - Possible values are:
     *      - ADD_ONLY - can add to but not read from Photo Library
     *      - READ_WRITE - can both add to and read from Photo Library
     * - Defaults to ADD_ONLY if not specified
     * - Has no effect on iOS 13 or below
     */
    Diagnostic_Camera.isCameraRollAuthorized = function(successCallback, errorCallback, accessLevel) {
        return cordova.exec(Diagnostic._ensureBoolean(successCallback),
            errorCallback,
            'Diagnostic_Camera',
            'isCameraRollAuthorized',
            [accessLevel]);
    };

    /**
     * Returns the authorization status for the application to use the Camera Roll in Photos app.
     *
     * @param {Function} successCallback - The callback which will be called when operation is successful.
     * This callback function is passed a single string parameter which indicates the authorization status as a constant in `cordova.plugins.diagnostic.permissionStatus`.
     * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
     * This callback function is passed a single string parameter containing the error message.
     * @param {Function} accessLevel - (optional) On iOS 14+, specifies the level of access to the photo library to query as a constant in cordova.plugins.diagnostic.photoLibraryAccessLevel`
     * - Possible values are:
     *      - ADD_ONLY - can add to but not read from Photo Library
     *      - READ_WRITE - can both add to and read from Photo Library
     * - Defaults to ADD_ONLY if not specified
     * - Has no effect on iOS 13 or below
     */
    Diagnostic_Camera.getCameraRollAuthorizationStatus = function(successCallback, errorCallback, accessLevel) {
        return cordova.exec(successCallback,
            errorCallback,
            'Diagnostic_Camera',
            'getCameraRollAuthorizationStatus',
            [accessLevel]
        );
    };

    /**
     * Requests camera roll authorization for the application.
     * Should only be called if authorization status is NOT_REQUESTED. Calling it when in any other state will have no effect.
     *
     * @param {Function} successCallback - The callback which will be called when operation is successful.
     * This callback function is passed a single string parameter indicating the new authorization status:
     * `cordova.plugins.diagnostic.permissionStatus.GRANTED` or `cordova.plugins.diagnostic.permissionStatus.DENIED_ALWAYS`
     * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
     * This callback function is passed a single string parameter containing the error message.
     * @param {Function} accessLevel - (optional) On iOS 14+, specifies the level of access to the photo library to request as a constant in cordova.plugins.diagnostic.photoLibraryAccessLevel`
     * - Possible values are:
     *      - ADD_ONLY - can add to but not read from Photo Library
     *      - READ_WRITE - can both add to and read from Photo Library
     * - Defaults to ADD_ONLY if not specified
     * - Has no effect on iOS 13 or below
     */
    Diagnostic_Camera.requestCameraRollAuthorization = function(successCallback, errorCallback, accessLevel) {
        return cordova.exec(function(status){
                successCallback(status === "authorized" ? Diagnostic.permissionStatus.GRANTED : Diagnostic.permissionStatus.DENIED_ALWAYS);
            },
            errorCallback,
            'Diagnostic_Camera',
            'requestCameraRollAuthorization',
            [accessLevel]);
    };

    /**
     * Presents limited library picker UI on iOS 14+
     * Should only be called if authorization status is LIMITED.
     * Calling it when in any other status will invoke the error callback.
     *
     * @param {Function} successCallback - The callback which will be called when operation is successful.
     * On iOS 15+, will be passed a list of image identifiers that were added by the user to the limited Photo Library selection.
     * @param {Function} errorCallback -  The callback which will be called when operation encounters an error.
     * This callback function is passed a single string parameter containing the error message.
     */
    Diagnostic_Camera.presentLimitedLibraryPicker = function(successCallback, errorCallback) {
        return cordova.exec(
            function (identifiers){
                if(identifiers){
                    try {
                        identifiers = JSON.parse(identifiers);
                    }catch (e){
                        return errorCallback("Unable to parse identifiers of images added to limited Photo Library: " + e.message);
                    }
                }
                successCallback(identifiers);
            },
            errorCallback,
            'Diagnostic_Camera',
            'presentLimitedLibraryPicker',
            []
        );
    };

    return Diagnostic_Camera;
});
module.exports = new Diagnostic_Camera();
