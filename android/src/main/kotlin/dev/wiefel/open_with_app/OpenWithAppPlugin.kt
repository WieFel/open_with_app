package dev.wiefel.open_with_app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.FileOutputStream

/** OpenWithAppPlugin */
class OpenWithAppPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.NewIntentListener, EventChannel.StreamHandler {
    private lateinit var initialFileChannel: MethodChannel
    private lateinit var fileStreamChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private var initialFile: String? = null
    private var activity: Activity? = null
    private var context: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        initialFileChannel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "open_with_app/initial_file")
        initialFileChannel.setMethodCallHandler(this)

        fileStreamChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "open_with_app/file_stream")
        fileStreamChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getInitialFile") {
            result.success(initialFile)
            initialFile = null
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        initialFileChannel.setMethodCallHandler(null)
        fileStreamChannel.setStreamHandler(null)
        context = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addOnNewIntentListener(this)
        handleIntent(binding.activity.intent)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addOnNewIntentListener(this)
        handleIntent(binding.activity.intent)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onNewIntent(intent: Intent): Boolean {
        handleIntent(intent)
        return false
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun handleIntent(intent: Intent) {
        if (Intent.ACTION_VIEW == intent.action || Intent.ACTION_SEND == intent.action) {
            val uri = intent.data ?: intent.getParcelableExtra(Intent.EXTRA_STREAM)
            if (uri != null) {
                val filePath = copyToTempFile(uri)
                if (filePath != null) {
                    if (eventSink != null) {
                        eventSink?.success(filePath)
                    } else {
                        initialFile = filePath
                    }
                }
            }
        }
    }

    private fun copyToTempFile(uri: Uri): String? {
        try {
            val ctx = context ?: return null
            val inputStream = ctx.contentResolver.openInputStream(uri) ?: return null
            
            var fileName: String? = null
            
            ctx.contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val displayNameIndex = cursor.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME)
                    if (displayNameIndex != -1) {
                        val name = cursor.getString(displayNameIndex)
                        if (!name.isNullOrEmpty()) {
                            fileName = name
                        }
                    }
                }
            }
            
            if (fileName == null) {
                fileName = uri.lastPathSegment
            }
            
            if (fileName.isNullOrEmpty()) {
                fileName = "imported_file"
            }

            // Decode the filename to handle cases like "My%20File.txt" -> "My File.txt"
            fileName = Uri.decode(fileName)
            
            // Sanitize filename (take only the last part if it contains separators)
            fileName = File(fileName).name

            val tempDir = ctx.cacheDir
            val tempFile = File(tempDir, fileName)

            if (tempFile.exists()) {
                tempFile.delete()
            }
            
            val outputStream = FileOutputStream(tempFile)
            inputStream.copyTo(outputStream)

            inputStream.close()
            outputStream.close()

            return tempFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }
}
