package com.example.finanzas

import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.InputStream

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.example.finanzas/filepicker"
    private var result: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, methodResult ->
                when (call.method) {
                    "openJsonPicker" -> {
                        result = methodResult
                        openJsonFilePicker()
                    }
                    else -> methodResult.notImplemented()
                }
            }
    }

    private fun openJsonFilePicker() {
        val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
            type = "application/json"
            addCategory(Intent.CATEGORY_OPENABLE)
        }
        startActivityForResult(intent, 1001)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == 1001 && resultCode == RESULT_OK && data != null) {
            val uri = data.data
            if (uri != null) {
                try {
                    val inputStream: InputStream? = contentResolver.openInputStream(uri)
                    val jsonContent = inputStream?.bufferedReader().use { it?.readText() ?: "" }
                    result?.success(jsonContent)
                } catch (e: Exception) {
                    result?.error("FILE_ERROR", "Error al leer el archivo: ${e.message}", null)
                }
            }
        } else {
            result?.error("CANCELLED", "El usuario canceló la selección", null)
        }
    }
}