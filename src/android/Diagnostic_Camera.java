/*
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
*/
package cordova.plugins;

/*
 * Imports
 */

import android.Manifest;
import android.content.pm.PackageManager;
import android.hardware.Camera;
import android.os.Build;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Objects;

/**
 * Diagnostic plugin implementation for Android
 */
public class Diagnostic_Camera extends CordovaPlugin{


    /*************
     * Constants *
     *************/


    /**
     * Tag for debug log messages
     */
    public static final String TAG = "Diagnostic_Camera";

    protected static final String cameraPermission = "CAMERA";
    protected static String[] storagePermissions;
    static {
        if (android.os.Build.VERSION.SDK_INT >= 33) { // Build.VERSION_CODES.TIRAMISU / Android 13
            storagePermissions = new String[]{ "READ_MEDIA_IMAGES", "READ_MEDIA_VIDEO" };
        } else {
            storagePermissions = new String[]{ "READ_EXTERNAL_STORAGE", "WRITE_EXTERNAL_STORAGE" };
        }
    }


    /*************
     * Variables *
     *************/

    /**
     * Singleton class instance
     */
    public static Diagnostic_Camera instance = null;

    private Diagnostic diagnostic;

    /**
     * Current Cordova callback context (on this thread)
     */
    protected CallbackContext currentContext;


    /*************
     * Public API
     ************/

    /**
     * Constructor.
     */
    public Diagnostic_Camera() {}

    /**
     * Sets the context of the Command. This can then be used to do things like
     * get file paths associated with the Activity.
     *
     * @param cordova The context of the main Activity.
     * @param webView The CordovaWebView Cordova is running in.
     */
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        Log.d(TAG, "initialize()");
        instance = this;
        diagnostic = Diagnostic.getInstance();

        super.initialize(cordova, webView);
    }


    /**
     * Executes the request and returns PluginResult.
     *
     * @param action            The action to execute.
     * @param args              JSONArry of arguments for the plugin.
     * @param callbackContext   The callback id used when calling back into JavaScript.
     * @return                  True if the action was valid, false if not.
     */
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Diagnostic.instance.currentContext = currentContext = callbackContext;

        try {
            if(action.equals("isCameraPresent")) {
                callbackContext.success(isCameraPresent() ? 1 : 0);
            } else if(action.equals("requestCameraAuthorization")) {
                requestCameraAuthorization(args, callbackContext);
            } else if(action.equals("getCameraAuthorizationStatus")) {
                getCameraAuthorizationStatus(args, callbackContext);
            } else {
                diagnostic.handleError("Invalid action");
                return false;
            }
        }catch(Exception e ) {
            diagnostic.handleError("Exception occurred: ".concat(Objects.requireNonNull(e.getMessage())));
            return false;
        }
        return true;
    }

    public boolean isCameraPresent() {
        int numberOfCameras = Camera.getNumberOfCameras();
        PackageManager pm = this.cordova.getActivity().getPackageManager();
        final boolean deviceHasCameraFlag = android.os.Build.VERSION.SDK_INT >= 32 ? pm.hasSystemFeature(PackageManager.FEATURE_CAMERA_ANY) : pm.hasSystemFeature(PackageManager.FEATURE_CAMERA);
        boolean result = (deviceHasCameraFlag && numberOfCameras>0 );
        return result;
    }


    /************
     * Internals
     ***********/

    private String[] getPermissions(boolean storage){
        String[] permissions = {cameraPermission};
        if(storage){
            permissions = Diagnostic.instance.concatStrings(permissions, storagePermissions);
        }
        return permissions;
    }

    private void requestCameraAuthorization(JSONArray args, CallbackContext callbackContext) throws Exception{
        boolean storage = args.getBoolean(0);
        String[] permissions = getPermissions(storage);
        int requestId = Diagnostic.instance.storeContextByRequestId(callbackContext);
        Diagnostic.instance._requestRuntimePermissions(Diagnostic.instance.stringArrayToJsonArray(permissions), requestId);
    }

    private void getCameraAuthorizationStatus(JSONArray args, CallbackContext callbackContext) throws Exception{
        boolean storage = args.getBoolean(0);
        String[] permissions = getPermissions(storage);
        JSONObject statuses = Diagnostic.instance._getPermissionsAuthorizationStatus(permissions);
        callbackContext.success(statuses);
    }
}
