package com.vebto.bedrive
import android.app.DownloadManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Environment
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import java.io.File

class MainActivity: FlutterActivity() {
    private val downloadChannel = "bedrive/downloader"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, downloadChannel).setMethodCallHandler { call, result ->

            if (call.method == "download") {
                val entries = JSONArray(call.argument<String>("entries"))
                val headers = call.argument<Map<String, String>>("headers")
                val destination = call.argument<String?>("destination")
                val useOriginalName = call.argument<Boolean?>("userOriginalName")
                val downloadIds = mutableListOf<String>();

                for (i in 0 until entries.length()) {
                    val entry = entries.getJSONObject(i)
                    val downloadId = download(
                            entry.getString("name"),
                            if (useOriginalName == true) entry.getString("name") else entry.getString("file_name"),
                            entry.getString("url"),
                            headers,
                            destination
                    )
                    downloadIds.add(downloadId);
                }
                result.success(downloadIds);
            } else if (call.method == "viewDownloads") {
                startActivity(Intent(DownloadManager.ACTION_VIEW_DOWNLOADS))
                result.success("success")
            }
        }
    }

    private fun download(title: String, fileName: String, uri: String, headers: Map<String, String>?, destination: String?): String {
        val downloadManager = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager

        val request = DownloadManager.Request(Uri.parse(uri))
        headers?.forEach { request.addRequestHeader(it.key, it.value) }
        request.setTitle(title)
        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
        if (destination == null) {
            request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, fileName)
        } else {
            request.setDestinationUri(Uri.fromFile(File(context.filesDir.path + "com.bedrive/app_flutter/offlined-files", "xxx")))
            //request.setDestinationInExternalFilesDir(context, "offline-files", fileName)
        }
        request.setAllowedNetworkTypes(DownloadManager.Request.NETWORK_WIFI)

        val id = downloadManager.enqueue(request)
        return id.toString()
    }
}