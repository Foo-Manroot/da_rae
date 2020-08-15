import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:logging/logging.dart';
import 'package:preferences/preferences.dart';

import 'routes/Definition.dart';
import 'routes/Home.dart';
import 'routes/Info.dart';
import 'routes/Saved.dart';
import 'routes/Settings.dart';

import 'ScraperSingleton.dart';
import 'db/DbHandler.dart';
import 'utils.dart' as utils;

const String APP_VERSION = "1.1.0";

final _log = Logger ("main.dart");

void main () async {

    /* This configuration affects all the logging instances (especially, the logging from
    rae_scraper) */
    Logger.root.onRecord.listen ((record) {
        print ("${record.level.name.padRight (9)} - ${record.loggerName.padRight (23)}"
            + "@${record.time}: ${record.message}"
        );
    });

    WidgetsFlutterBinding.ensureInitialized ();
    await PrefService.init ();
    initSettings ();

    Logger.root.level = utils.settingsGetLogLevel ();

    _log.fine ("Settings initialization completed. Running app...");
    runApp (App ());
}


/// Inicializa las configuraciones que se pueda hacer en segundo plano
Future<void> initSettings () async {

    DbHandler.init ();

    int val = PrefService.getInt ("max_hist_size");
    if (val != null) {
        utils.setHistSize (val);
    }

    val = PrefService.getInt ("max_cache_size");
    if (val != null) {
        utils.setCacheSize (val);
    }
}

/* =================================================================================== */
/* =================================================================================== */
/* =================================================================================== */

class App extends StatefulWidget {

    @override
    _AppState createState () => _AppState ();
}


///
/// [WidgetsBindingObserver] permite controlar el estado de la aplicación.
///
class _AppState extends State<App> with WidgetsBindingObserver {


    @override
    Widget build (BuildContext ctx) => I18n (
        initialLocale: utils.settingsGetLocale (),
        child: MaterialApp (
            localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
            ],
            supportedLocales: [
                /* Por defecto se usa inglés */
                const Locale ("en"),
                const Locale ("es"),
            ],
    //        theme: ThemeData (
    //            primarySwatch: Colors.blueGrey,
    //            visualDensity: VisualDensity.adaptivePlatformDensity,
    //        ),
            theme: utils.settingsGetTheme (),
            home: HomePage (),
            routes: {
                "/search": (_) => Definition (),
                "/saved": (_) => Saved (),
                "/settings": (_) => Settings (),
                "/info": (_) => Info ()
            }
        )
    );



    /*****************************************************/
    /* Métodos para controlar el estado de la aplicación */
    /*****************************************************/

    ///
    /// Se alade como observador para que se notifiquen los cambios
    ///
    @override
    void initState () {

        super.initState ();
        WidgetsBinding.instance.addObserver (this);
        DbHandler.init ();

        _log.fine ("Main screen initialized");
    }


    @override
    void didChangeAppLifecycleState (AppLifecycleState state) {

        _log.finest ("Changed app state to $state");
        /* Por ejemplo: dejarla en segundo plano. No hace falta mantener las conexiones
        abiertas */
        if (state == AppLifecycleState.detached) {

            ScraperSingleton.dispose ();
        }
    }

    ///
    /// Limpia los recursos utilizados antes de terminar el proceso
    ///
    @override
    void dispose () {

        _log.finest ("================ Dispose of Main Widget ===============");

        ScraperSingleton.dispose ();
        DbHandler.dispose ();

        WidgetsBinding.instance.removeObserver (this);
        super.dispose ();
    }
}

