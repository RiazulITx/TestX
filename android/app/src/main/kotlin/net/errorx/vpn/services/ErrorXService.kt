package net.errorx.vpn.services

import android.annotation.SuppressLint
import android.app.Notification.FOREGROUND_SERVICE_IMMEDIATE
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
import android.os.Binder
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import net.errorx.vpn.GlobalState
import net.errorx.vpn.MainActivity
import net.errorx.vpn.extensions.getActionPendingIntent
import net.errorx.vpn.models.VpnOptions
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async


class ErrorXService : Service(), BaseServiceInterface {

    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): ErrorXService = this@ErrorXService
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }

    override fun onUnbind(intent: Intent?): Boolean {
        return super.onUnbind(intent)
    }

    private val CHANNEL = "ErrorX"

    private val notificationId: Int = 1

    private val notificationBuilderDeferred: Deferred<NotificationCompat.Builder> by lazy {
        CoroutineScope(Dispatchers.Main).async {
            val stopText = GlobalState.getText("stop")

            val intent = Intent(
                this@ErrorXService, MainActivity::class.java
            )

            val pendingIntent = if (Build.VERSION.SDK_INT >= 31) {
                PendingIntent.getActivity(
                    this@ErrorXService,
                    0,
                    intent,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
            } else {
                PendingIntent.getActivity(
                    this@ErrorXService,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT
                )
            }

            with(NotificationCompat.Builder(this@ErrorXService, CHANNEL)) {
                setSmallIcon(net.errorx.vpn.R.drawable.ic_stat_name)
                setContentTitle("ErrorX")
                setContentIntent(pendingIntent)
                setCategory(NotificationCompat.CATEGORY_SERVICE)
                priority = NotificationCompat.PRIORITY_MIN
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    foregroundServiceBehavior = FOREGROUND_SERVICE_IMMEDIATE
                }
                addAction(
                    0,
                    stopText, // 使用 suspend 函数获取的文本
                    getActionPendingIntent("STOP")
                )
                setOngoing(true)
                setShowWhen(false)
                setOnlyAlertOnce(true)
                setAutoCancel(true)
            }
        }
    }

    private suspend fun getNotificationBuilder(): NotificationCompat.Builder {
        return notificationBuilderDeferred.await()
    }

    override fun start(options: VpnOptions) = 0

    override fun stop() {
        stopSelf()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        }
    }


    @SuppressLint("ForegroundServiceType")
    override suspend fun startForeground(title: String, content: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            var channel = manager?.getNotificationChannel(CHANNEL)
            if (channel == null) {
                channel =
                    NotificationChannel(CHANNEL, "ErrorX", NotificationManager.IMPORTANCE_LOW)
                manager?.createNotificationChannel(channel)
            }
        }
        val notification =
            getNotificationBuilder()
                .setContentTitle(title)
                .setContentText(content).build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            try {
                startForeground(notificationId, notification, FOREGROUND_SERVICE_TYPE_DATA_SYNC)
            } catch (_: Exception) {
                startForeground(notificationId, notification)
            }
        } else {
            startForeground(notificationId, notification)
        }
    }
}