package app.bumoumobile.com;

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.Toast

class ScreenDetectionBroadcast : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent != null) {
            when (intent.action) {
                Intent.ACTION_SCREEN_ON -> {
                    // Handle screen on event
                    Log.d("ScreenDetection", "Screen turned on")
                    Toast.makeText(context, "Screen On", Toast.LENGTH_SHORT).show()
                }
                Intent.ACTION_SCREEN_OFF -> {
                    // Handle screen off event
                    Log.d("ScreenDetection", "Screen turned off")
                    Toast.makeText(context, "Screen Off", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }
}