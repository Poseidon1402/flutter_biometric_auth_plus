package mg.nexus.flutter_biometric_auth_plus

import android.content.Context
import android.os.Build
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricManager.Authenticators.*
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.Executor

/**
 * FlutterBiometricAuthPlusPlugin
 *
 * Advanced Android biometric authentication plugin supporting:
 * - Fingerprint recognition
 * - Face recognition (2D and 3D)
 * - Iris recognition
 * - Device credentials (PIN, Pattern, Password)
 * - Strong and Weak biometric authentication levels
 * - Modern BiometricPrompt API (Android 10+)
 */
class FlutterBiometricAuthPlusPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    // Channel for communication between Flutter and Android
    private lateinit var channel: MethodChannel

    // Android context
    private var context: Context? = null

    // Current activity (needed for biometric prompt)
    private var activity: FragmentActivity? = null

    // Biometric manager for capability checks
    private var biometricManager: BiometricManager? = null

    // Executor for biometric operations
    private lateinit var executor: Executor

    // Current biometric prompt (for cancellation)
    private var currentPrompt: BiometricPrompt? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_biometric_auth_plus")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        biometricManager = BiometricManager.from(context!!)
        executor = ContextCompat.getMainExecutor(context!!)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${Build.VERSION.RELEASE}")
            }
            "canCheckBiometrics" -> {
                handleCanCheckBiometrics(result)
            }
            "getAvailableBiometrics" -> {
                handleGetAvailableBiometrics(result)
            }
            "hasEnrolledBiometrics" -> {
                handleHasEnrolledBiometrics(result)
            }
            "canAuthenticateWithBiometricsStrong" -> {
                handleCanAuthenticateWithBiometricsStrong(result)
            }
            "canAuthenticateWithBiometricsWeak" -> {
                handleCanAuthenticateWithBiometricsWeak(result)
            }
            "canAuthenticateWithDeviceCredential" -> {
                handleCanAuthenticateWithDeviceCredential(result)
            }
            "authenticate" -> {
                handleAuthenticate(call, result)
            }
            "getBiometricInfo" -> {
                handleGetBiometricInfo(result)
            }
            "cancelAuthentication" -> {
                handleCancelAuthentication(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * Check if device has biometric hardware
     */
    private fun handleCanCheckBiometrics(result: Result) {
        try {
            val canAuthenticate = biometricManager?.canAuthenticate(BIOMETRIC_WEAK)
            val hasHardware = canAuthenticate != BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE
            result.success(hasHardware)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to check biometric capability: ${e.message}", null)
        }
    }

    /**
     * Get list of available biometric types on the device
     *
     * Note: Android's BiometricManager API doesn't provide a direct way to query
     * specific biometric types. This method uses heuristics and device characteristics
     * to determine likely available biometric types.
     */
    private fun handleGetAvailableBiometrics(result: Result) {
        try {
            val availableBiometrics = mutableListOf<String>()

            // Check if any biometric is enrolled
            val canAuthenticateStrong = biometricManager?.canAuthenticate(BIOMETRIC_STRONG)
            val canAuthenticateWeak = biometricManager?.canAuthenticate(BIOMETRIC_WEAK)

            if (canAuthenticateStrong == BiometricManager.BIOMETRIC_SUCCESS ||
                canAuthenticateWeak == BiometricManager.BIOMETRIC_SUCCESS) {

                // Most Android devices have fingerprint sensors if they support strong biometrics
                if (canAuthenticateStrong == BiometricManager.BIOMETRIC_SUCCESS) {
                    availableBiometrics.add("fingerprint")
                }

                // Face recognition is typically available on devices with weak biometrics
                // or newer devices with strong face authentication
                // We can check device manufacturer and model for better accuracy
                val manufacturer = Build.MANUFACTURER.lowercase()
                val model = Build.MODEL.lowercase()

                // Known devices with face unlock
                val hasFaceUnlock = when {
                    // Google Pixel devices with face unlock (Pixel 4 and later have strong face auth)
                    manufacturer.contains("google") && (
                        model.contains("pixel 4") ||
                        model.contains("pixel 5") ||
                        model.contains("pixel 6") ||
                        model.contains("pixel 7") ||
                        model.contains("pixel 8")
                    ) -> true

                    // Samsung devices often have face unlock
                    manufacturer.contains("samsung") && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P -> true

                    // OnePlus devices
                    manufacturer.contains("oneplus") && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P -> true

                    // Xiaomi/Redmi devices
                    (manufacturer.contains("xiaomi") || manufacturer.contains("redmi")) &&
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.P -> true

                    // Oppo devices
                    manufacturer.contains("oppo") && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P -> true

                    // Huawei devices
                    manufacturer.contains("huawei") && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P -> true

                    // If device supports weak biometrics but not strong, it likely has face unlock
                    canAuthenticateWeak == BiometricManager.BIOMETRIC_SUCCESS &&
                        canAuthenticateStrong != BiometricManager.BIOMETRIC_SUCCESS -> true

                    else -> false
                }

                if (hasFaceUnlock) {
                    availableBiometrics.add("face")
                }

                // Iris recognition is very rare, primarily on Samsung Galaxy S8/S9/Note 8/Note 9
                val hasIris = manufacturer.contains("samsung") && (
                    model.contains("sm-g950") ||  // Galaxy S8
                    model.contains("sm-g955") ||  // Galaxy S8+
                    model.contains("sm-g960") ||  // Galaxy S9
                    model.contains("sm-g965") ||  // Galaxy S9+
                    model.contains("sm-n950") ||  // Galaxy Note 8
                    model.contains("sm-n960")     // Galaxy Note 9
                )

                if (hasIris) {
                    availableBiometrics.add("iris")
                }
            }

            result.success(availableBiometrics)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to get available biometrics: ${e.message}", null)
        }
    }

    /**
     * Check if user has enrolled biometrics
     */
    private fun handleHasEnrolledBiometrics(result: Result) {
        try {
            val canAuthenticate = biometricManager?.canAuthenticate(BIOMETRIC_WEAK)
            val hasEnrolled = canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS
            result.success(hasEnrolled)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to check enrolled biometrics: ${e.message}", null)
        }
    }

    /**
     * Check if device supports strong biometric authentication
     */
    private fun handleCanAuthenticateWithBiometricsStrong(result: Result) {
        try {
            val canAuthenticate = biometricManager?.canAuthenticate(BIOMETRIC_STRONG)
            val canUseStrong = canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS
            result.success(canUseStrong)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to check strong biometrics: ${e.message}", null)
        }
    }

    /**
     * Check if device supports weak biometric authentication
     */
    private fun handleCanAuthenticateWithBiometricsWeak(result: Result) {
        try {
            val canAuthenticate = biometricManager?.canAuthenticate(BIOMETRIC_WEAK)
            val canUseWeak = canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS
            result.success(canUseWeak)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to check weak biometrics: ${e.message}", null)
        }
    }

    /**
     * Check if device credentials (PIN, Pattern, Password) are set
     */
    private fun handleCanAuthenticateWithDeviceCredential(result: Result) {
        try {
            val canAuthenticate = biometricManager?.canAuthenticate(DEVICE_CREDENTIAL)
            val hasCredential = canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS
            result.success(hasCredential)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to check device credential: ${e.message}", null)
        }
    }

    /**
     * Perform biometric authentication
     */
    private fun handleAuthenticate(call: MethodCall, result: Result) {
        if (activity == null) {
            result.error("NO_ACTIVITY", "Plugin requires a foreground activity", null)
            return
        }

        try {
            // Extract parameters
            val title = call.argument<String>("title") ?: "Authenticate"
            val subtitle = call.argument<String>("subtitle")
            val description = call.argument<String>("description")
            val negativeButtonText = call.argument<String>("negativeButtonText") ?: "Cancel"
            val confirmationRequired = call.argument<Boolean>("confirmationRequired") ?: false
            val allowDeviceCredential = call.argument<Boolean>("allowDeviceCredential") ?: false
            val biometricStrength = call.argument<String>("biometricStrength") ?: "strong"

            // Determine authenticators based on settings
            val authenticators = when {
                allowDeviceCredential && biometricStrength == "strong" ->
                    BIOMETRIC_STRONG or DEVICE_CREDENTIAL
                allowDeviceCredential && biometricStrength == "weak" ->
                    BIOMETRIC_WEAK or DEVICE_CREDENTIAL
                biometricStrength == "strong" ->
                    BIOMETRIC_STRONG
                else ->
                    BIOMETRIC_WEAK
            }

            // Check if authentication is possible
            val canAuthenticate = biometricManager?.canAuthenticate(authenticators)
            if (canAuthenticate != BiometricManager.BIOMETRIC_SUCCESS) {
                val errorMessage = getAuthenticationErrorMessage(canAuthenticate)
                result.success(mapOf(
                    "success" to false,
                    "errorCode" to "BIOMETRIC_UNAVAILABLE",
                    "errorMessage" to errorMessage
                ))
                return
            }

            // Build prompt info
            val promptInfoBuilder = BiometricPrompt.PromptInfo.Builder()
                .setTitle(title)
                .setConfirmationRequired(confirmationRequired)
                .setAllowedAuthenticators(authenticators)

            subtitle?.let { promptInfoBuilder.setSubtitle(it) }
            description?.let { promptInfoBuilder.setDescription(it) }

            // Negative button is only shown when device credential is not allowed
            if (!allowDeviceCredential) {
                promptInfoBuilder.setNegativeButtonText(negativeButtonText)
            }

            val promptInfo = promptInfoBuilder.build()

            // Create authentication callback
            val authenticationCallback = object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(authResult: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(authResult)

                    // Determine authentication type
                    val authenticationType = authResult.authenticationType
                    val usedDeviceCredential = authenticationType == BiometricPrompt.AUTHENTICATION_RESULT_TYPE_DEVICE_CREDENTIAL

                    result.success(mapOf(
                        "success" to true,
                        "authenticationMethod" to if (usedDeviceCredential) "deviceCredential" else "biometric",
                        "usedDeviceCredential" to usedDeviceCredential
                    ))
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)

                    result.success(mapOf(
                        "success" to false,
                        "errorCode" to getErrorCode(errorCode),
                        "errorMessage" to errString.toString()
                    ))
                }

                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    // Don't send result here - user can retry
                    // This is called when biometric is valid but not recognized
                }
            }

            // Create and show biometric prompt
            currentPrompt = BiometricPrompt(activity!!, executor, authenticationCallback)
            currentPrompt?.authenticate(promptInfo)

        } catch (e: Exception) {
            result.error("ERROR", "Authentication failed: ${e.message}", null)
        }
    }

    /**
     * Get comprehensive biometric information
     */
    private fun handleGetBiometricInfo(result: Result) {
        try {
            val info = mutableMapOf<String, Any>()

            // Hardware availability
            info["hasHardware"] = biometricManager?.canAuthenticate(BIOMETRIC_WEAK) !=
                BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE

            // Enrollment status
            info["hasEnrolledBiometrics"] = biometricManager?.canAuthenticate(BIOMETRIC_WEAK) ==
                BiometricManager.BIOMETRIC_SUCCESS

            // Biometric strength support
            info["supportsStrongBiometric"] = biometricManager?.canAuthenticate(BIOMETRIC_STRONG) ==
                BiometricManager.BIOMETRIC_SUCCESS
            info["supportsWeakBiometric"] = biometricManager?.canAuthenticate(BIOMETRIC_WEAK) ==
                BiometricManager.BIOMETRIC_SUCCESS

            // Device credential
            info["hasDeviceCredential"] = biometricManager?.canAuthenticate(DEVICE_CREDENTIAL) ==
                BiometricManager.BIOMETRIC_SUCCESS

            // Available biometric types
            val types = mutableListOf<String>()
            if (hasFingerprint()) types.add("fingerprint")
            if (hasFaceRecognition()) types.add("face")
            if (hasIrisRecognition()) types.add("iris")
            info["availableBiometricTypes"] = types

            // Android version
            info["androidVersion"] = Build.VERSION.SDK_INT

            result.success(info)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to get biometric info: ${e.message}", null)
        }
    }

    /**
     * Cancel current authentication
     */
    private fun handleCancelAuthentication(result: Result) {
        try {
            currentPrompt?.cancelAuthentication()
            currentPrompt = null
            result.success(null)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to cancel authentication: ${e.message}", null)
        }
    }

    /**
     * Helper: Check if fingerprint is available
     * Fingerprint is the most common biometric on Android devices
     */
    private fun hasFingerprint(): Boolean {
        return biometricManager?.canAuthenticate(BIOMETRIC_STRONG) == BiometricManager.BIOMETRIC_SUCCESS
    }

    /**
     * Helper: Check if face recognition is available
     * Uses device manufacturer and model detection for better accuracy
     */
    private fun hasFaceRecognition(): Boolean {
        val canAuthenticateWeak = biometricManager?.canAuthenticate(BIOMETRIC_WEAK)
        val canAuthenticateStrong = biometricManager?.canAuthenticate(BIOMETRIC_STRONG)

        if (canAuthenticateWeak != BiometricManager.BIOMETRIC_SUCCESS) {
            return false
        }

        val manufacturer = Build.MANUFACTURER.lowercase()
        val model = Build.MODEL.lowercase()

        // Check for known face unlock devices
        return when {
            manufacturer.contains("google") && model.contains("pixel 4") -> true
            manufacturer.contains("samsung") && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P -> true
            // If weak biometrics work but not strong, likely face unlock
            canAuthenticateWeak == BiometricManager.BIOMETRIC_SUCCESS &&
                canAuthenticateStrong != BiometricManager.BIOMETRIC_SUCCESS -> true
            else -> false
        }
    }

    /**
     * Helper: Check if iris recognition is available
     * Only available on specific Samsung devices
     */
    private fun hasIrisRecognition(): Boolean {
        val manufacturer = Build.MANUFACTURER.lowercase()
        val model = Build.MODEL.lowercase()

        // Iris scanner only on Samsung Galaxy S8/S9/Note 8/Note 9
        return manufacturer.contains("samsung") && (
            model.contains("sm-g950") ||
            model.contains("sm-g955") ||
            model.contains("sm-g960") ||
            model.contains("sm-g965") ||
            model.contains("sm-n950") ||
            model.contains("sm-n960")
        ) && biometricManager?.canAuthenticate(BIOMETRIC_STRONG) == BiometricManager.BIOMETRIC_SUCCESS
    }

    /**
     * Helper: Convert error code to string
     */
    private fun getErrorCode(errorCode: Int): String {
        return when (errorCode) {
            BiometricPrompt.ERROR_CANCELED -> "CANCELED"
            BiometricPrompt.ERROR_HW_NOT_PRESENT -> "HW_NOT_PRESENT"
            BiometricPrompt.ERROR_HW_UNAVAILABLE -> "HW_UNAVAILABLE"
            BiometricPrompt.ERROR_LOCKOUT -> "LOCKOUT"
            BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> "LOCKOUT_PERMANENT"
            BiometricPrompt.ERROR_NEGATIVE_BUTTON -> "NEGATIVE_BUTTON"
            BiometricPrompt.ERROR_NO_BIOMETRICS -> "NO_BIOMETRICS"
            BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL -> "NO_DEVICE_CREDENTIAL"
            BiometricPrompt.ERROR_NO_SPACE -> "NO_SPACE"
            BiometricPrompt.ERROR_TIMEOUT -> "TIMEOUT"
            BiometricPrompt.ERROR_UNABLE_TO_PROCESS -> "UNABLE_TO_PROCESS"
            BiometricPrompt.ERROR_USER_CANCELED -> "USER_CANCELED"
            BiometricPrompt.ERROR_VENDOR -> "VENDOR_ERROR"
            else -> "UNKNOWN_ERROR"
        }
    }

    /**
     * Helper: Get human-readable error message for authentication status
     */
    private fun getAuthenticationErrorMessage(status: Int?): String {
        return when (status) {
            BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE ->
                "Biometric hardware is currently unavailable"
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED ->
                "No biometrics enrolled. Please set up biometric authentication in device settings"
            BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE ->
                "No biometric hardware available on this device"
            BiometricManager.BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED ->
                "A security update is required for biometric authentication"
            BiometricManager.BIOMETRIC_ERROR_UNSUPPORTED ->
                "Biometric authentication is not supported on this device"
            BiometricManager.BIOMETRIC_STATUS_UNKNOWN ->
                "Biometric authentication status is unknown"
            else ->
                "Biometric authentication is not available"
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
        biometricManager = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity as? FragmentActivity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity as? FragmentActivity
    }

    override fun onDetachedFromActivity() {
        activity = null
        currentPrompt = null
    }
}
