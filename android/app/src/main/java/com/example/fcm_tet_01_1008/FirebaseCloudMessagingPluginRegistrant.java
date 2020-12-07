package com.example.fcm_tet_01_1008;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
import fr.g123k.flutterappbadger.FlutterAppBadgerPlugin;


public final class FirebaseCloudMessagingPluginRegistrant{
    public static void registerWith(PluginRegistry registry) {
        if (alreadyRegisteredWith(registry)) {
            return;
        }
        FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
        FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
        SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
        FlutterAppBadgerPlugin.registerWith(registry.registrarFor("fr.g123k.flutterappbadger.FlutterAppBadgerPlugin"));
    }

    private static boolean alreadyRegisteredWith(PluginRegistry registry) {
        final String key = FirebaseCloudMessagingPluginRegistrant.class.getCanonicalName();
        if (registry.hasPlugin(key)) {
            return true;
        }
        registry.registrarFor(key);
        return false;
    }
}
