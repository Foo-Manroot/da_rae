import 'package:rae_scraper/rae_scraper.dart';
import 'package:logging/logging.dart';

class ScraperSingleton {

    static final _log = Logger ("ScraperSingleton.dart");

    static Scraper _instance = Scraper ();

    static Scraper get instance {


        if (_instance == null) {

            _log.finer ("Creating new Scraper instance");
            _instance = Scraper ();
        }

        _log.fine ("Returning [Scraper] instance: $_instance");
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
        _log.info ("Scraper instance disposed");
    }
}
