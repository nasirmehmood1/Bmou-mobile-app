package app.bumoumobile.com

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import android.widget.Toast
import androidx.annotation.RequiresApi

class ScreenDetectionService : Service() {

    private lateinit var screenDetectionBroadcast: BroadcastReceiver

    companion object {
        private const val CHANNEL_ID = "ScreenDetectionServiceChannel"
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate() {
        super.onCreate()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Screen Detection Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }

        // Create a notification
        val notification: Notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("Screen Detection Service")
            .setContentText("Listening for screen events")
            .setSmallIcon(R.mipmap.ic_launcher) // Replace with your app's notification icon
            .build()

        // Start the service in the foreground
        startForeground(1, notification)

        // Initialize and register the BroadcastReceiver
        screenDetectionBroadcast = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent != null) {
                    when (intent.action) {
                        Intent.ACTION_SCREEN_ON -> {
                            Log.d("ScreenDetectionService", "Screen turned on")
                            val activityIntent = Intent(context, ModeDetectionActivity::class.java)
                            Handler(Looper.getMainLooper()).post {
                                // Check if context is not null
                                context?.let {
                                    // Launch the activity
                                    val activityIntent = Intent(context.applicationContext, ModeDetectionActivity::class.java)
                                    activityIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                    it.startActivity(activityIntent)

                                    // Show a Toast message
                                    Toast.makeText(it, "Activity Launched", Toast.LENGTH_SHORT).show()
                                }
                            }

                            Toast.makeText(context, "Screen On", Toast.LENGTH_SHORT).show()
                        }
                        Intent.ACTION_SCREEN_OFF -> {
                            Log.d("ScreenDetectionService", "Screen turned off")
                            Toast.makeText(context, "Screen Off", Toast.LENGTH_SHORT).show()
                        }
                    }
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_SCREEN_OFF)
        }

        registerReceiver(screenDetectionBroadcast, filter)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(screenDetectionBroadcast)
    }

    override fun onBind(intent: Intent?): IBinder? {
        // This service is not meant to bind, so return null
        return null
    }
}
