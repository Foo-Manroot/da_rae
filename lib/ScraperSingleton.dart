import 'package:rae_scraper/rae_scraper.dart';

class ScraperSingleton {

    static Scraper _instance = Scraper ();

    static Scraper get instance {

        if (_instance == null) {
            _instance = Scraper ();
        }

        return _instance;
    }

    ///
    /// Elimina de manera segura la instancia de [Scraper]
    ///
    static void dispose () {

        if (_instance != null) {
            _instance.dispose ();
        }

        _instance = null;
    }
}
