package com.example.wallet

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class CustomHomeWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                setTextViewText(
                    R.id.widget_balance,
                    widgetData.getString(KEY_TOTAL_BALANCE, "$0.00") ?: "$0.00",
                )
                setTextViewText(
                    R.id.widget_income,
                    widgetData.getString(KEY_TOTAL_INCOME, "+$0.00") ?: "+$0.00",
                )
                setTextViewText(
                    R.id.widget_expense,
                    widgetData.getString(KEY_TOTAL_EXPENSE, "-$0.00") ?: "-$0.00",
                )
                setTextViewText(
                    R.id.widget_debits,
                    widgetData.getString(KEY_TOTAL_DEBITS, "$0.00") ?: "$0.00",
                )
                setTextViewText(
                    R.id.widget_people_debits,
                    widgetData.getString(KEY_TOTAL_PEOPLE_DEBITS, "$0.00") ?: "$0.00",
                )

                val openAppIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse(URI_OPEN),
                )
                setOnClickPendingIntent(R.id.widget_root, openAppIntent)

                val addTransactionIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse(URI_ADD_TRANSACTION),
                )
                setOnClickPendingIntent(R.id.widget_add_transaction, addTransactionIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    companion object {
        const val KEY_TOTAL_BALANCE = "total_balance"
        const val KEY_TOTAL_INCOME = "total_income"
        const val KEY_TOTAL_EXPENSE = "total_expense"
        const val KEY_TOTAL_DEBITS = "total_debits"
        const val KEY_TOTAL_PEOPLE_DEBITS = "total_people_debits"
        const val URI_OPEN = "wallet://open"
        const val URI_ADD_TRANSACTION = "wallet://add-transaction"
    }
}
