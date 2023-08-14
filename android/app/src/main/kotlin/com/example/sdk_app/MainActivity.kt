package com.example.sdk_app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel



class MainActivity : FlutterActivity() {
    private val CHANNEL = "mnemonic_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            // This method is invoked on the main thread.
            if (call.method == "saveMnemonic") {
                val key = call.argument<String?>("key") ?: "null"
                val mnemonic = call.argument<String?>("mnemonic") ?: "null"
                val useBlockstore = call.argument<Boolean?>("useBlockstore") ?: false
                val forceBlockstore = call.argument<Boolean?>("forceBlockstore") ?: false

                val mnemonicStorageHelper = MnemonicStorageHelper(this@MainActivity)
                mnemonicStorageHelper.save(
                    key,
                    mnemonic,
                    useBlockstore,
                    forceBlockstore,
                    onSuccess = {
                        result.success("Success")
                    },
                    onFailure = { message ->
                        result.error("FAILURE", message, null)
                    }
                )
                result.success("Success")
            } else if (call.method == "readMnemonic") {
                val key = call.argument<String?>("key") ?: "null"
                val mnemonicStorageHelper = MnemonicStorageHelper(this@MainActivity)
                mnemonicStorageHelper.read(key, onSuccess = { value ->
                    result.success(value)
                })
            } else if (call.method == "deleteMnemonic") {
                val key = call.argument<String?>("key") ?: "null"
                val mnemonicStorageHelper = MnemonicStorageHelper(this@MainActivity)
                mnemonicStorageHelper.delete(key);
            }
        }
    }
}