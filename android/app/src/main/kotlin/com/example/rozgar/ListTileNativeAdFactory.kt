package com.example.rozgar

import android.content.Context
import android.graphics.Color
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class ListTileNativeAdFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = NativeAdView(context)
        val layout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(32, 16, 32, 16)
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        val headline = TextView(context).apply {
            text = nativeAd.headline
            setTextColor(Color.BLACK)
            textSize = 16f
        }
        val body = TextView(context).apply {
            text = nativeAd.body
            setTextColor(Color.DKGRAY)
            textSize = 12f
        }
        val cta = Button(context).apply {
            text = nativeAd.callToAction ?: "Learn More"
        }
        val icon = ImageView(context).apply {
            layoutParams = LinearLayout.LayoutParams(80, 80)
        }

        nativeAd.icon?.drawable?.let { icon.setImageDrawable(it) }

        layout.addView(headline)
        layout.addView(body)
        layout.addView(icon)
        layout.addView(cta)
        adView.addView(layout)

        adView.headlineView = headline
        adView.bodyView = body
        adView.callToActionView = cta
        adView.iconView = icon
        adView.setNativeAd(nativeAd)

        return adView
    }
}
