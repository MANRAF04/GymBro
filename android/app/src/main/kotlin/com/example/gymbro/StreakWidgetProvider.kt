package com.example.gymbro // This should match your application's package name

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin // Import for HomeWidgetPlugin
import android.app.PendingIntent
import android.content.Intent // Make sure this is android.content.Intent

class StreakWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            // Get the data from SharedPreferences
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.streak_widget_layout)

            val currentStreak = widgetData.getInt("currentStreak", 0)
            val hasExercisedToday = widgetData.getBoolean("hasExercisedToday", false)

            views.setTextViewText(R.id.widget_text, "$currentStreak Day Streak")

            if (hasExercisedToday) {
                views.setImageViewResource(R.id.widget_icon, R.drawable.ic_fire_active) // Ensure you have ic_fire_active.xml in drawable folders
            } else {
                views.setImageViewResource(R.id.widget_icon, R.drawable.ic_fire_inactive) // Ensure you have ic_fire_inactive.xml in drawable folders
            }
            
            // Intent to launch the main activity
            // Correctly get the launch intent for the package
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                val pendingIntent = PendingIntent.getActivity(
                    context, 
                    0, 
                    launchIntent, 
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}