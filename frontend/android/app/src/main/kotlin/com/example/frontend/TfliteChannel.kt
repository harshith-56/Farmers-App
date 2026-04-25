package com.example.frontend

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.Interpreter
import java.nio.ByteBuffer
import java.nio.ByteOrder

class TfliteChannel(private val flutterEngine: FlutterEngine, private val activity: Activity) {

    companion object {
        const val CHANNEL = "com.example.frontend/tflite"
    }

    private var interpreter: Interpreter? = null

    init {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "loadModel" -> {
                        val modelBytes = call.argument<ByteArray>("modelBytes")
                            ?: return@setMethodCallHandler result.error("LOAD_ERROR", "modelBytes missing", null)
                        try {
                            loadModel(modelBytes)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("LOAD_ERROR", "${e.javaClass.simpleName}: ${e.message}", null)
                        }
                    }
                    "runInference" -> {
                        val inputBytes = call.argument<ByteArray>("inputBytes")
                        if (inputBytes == null) {
                            result.error("INVALID_ARG", "inputBytes is null", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val output = runInference(inputBytes)
                            result.success(output)
                        } catch (e: Exception) {
                            result.error("INFERENCE_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun loadModel(bytes: ByteArray) {
        val buffer = ByteBuffer.allocateDirect(bytes.size).apply {
            order(ByteOrder.nativeOrder())
            put(bytes)
            rewind()
        }
        val opts = Interpreter.Options().apply { numThreads = 2 }
        interpreter?.close()
        interpreter = Interpreter(buffer, opts)
    }

    private fun runInference(inputBytes: ByteArray): Map<String, Any> {
        val interp = interpreter ?: throw Exception("Model not loaded, call loadModel first")

        // inputBytes is a flat float32 array: 1 * 224 * 224 * 3 * 4 bytes
        val inputBuffer = ByteBuffer.allocateDirect(inputBytes.size).apply {
            order(ByteOrder.nativeOrder())
            put(inputBytes)
            rewind()
        }

        // Output shape: [1, numClasses]
        val numClasses = 12
        val outputBuffer = Array(1) { FloatArray(numClasses) }

        interp.run(inputBuffer, outputBuffer)

        val scores = outputBuffer[0]
        var maxIdx = 0
        for (i in 1 until scores.size) {
            if (scores[i] > scores[maxIdx]) maxIdx = i
        }

        return mapOf(
            "classIndex" to maxIdx,
            "confidence" to scores[maxIdx].toDouble()
        )
    }
}
