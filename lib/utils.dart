import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:preferences/preferences.dart';
import 'package:rae_scraper/rae_scraper.dart';

import 'ScraperSingleton.dart';
import 'db/DbHandler.dart';
import 'i18n.dart';

/*===============*/
/* CONFIGURACIÓN */
/*===============*/


const int DEFAULT_HIST_SIZE = 20;
const int DEFAULT_CACHE_SIZE = 100;
const String DEFAULT_LANG = "English";
const String DEFAULT_THEME = "Dark";
const bool DEFAULT_END_DRAWER = true;
const String DEFAULT_LOG_LEVEL = "WARNING";

final _log = Logger ("utils.dart");


/// Obtiene el valor configurado para la internacionalización.
Locale settingsGetLocale () {


    Locale initialLocale;
    String localeStr = PrefService.get ("lang");

    _log.info ("Configured locale: $localeStr");

    /* Cambia el idioma a uno de los implementados (por defecto, inglés) */
    switch (localeStr) {

        case "Español":
            initialLocale = Locale ("es");
            break;

        case "English":
        default:
            initialLocale = Locale ("en");
            break;
    }

    _log.fine ("Returned locale: $initialLocale");

    return initialLocale;
}

/// Obtiene el valor configurado para el tema de la interfaz.
ThemeData settingsGetTheme () {

    /* Por defecto, el tema es "dark" */
    ThemeData theme;
    String themeStr = PrefService.get ("ui_theme");

    _log.info ("Configured UI theme: $themeStr");

    switch (themeStr) {

        case "Bright":
            theme = ThemeData.light ();
            _log.fine ("Returned theme 'Light'");
            break;

        case "Dark":
        default:
            _log.fine ("Returned theme 'Dark'");
            theme = ThemeData.dark ();
    }

    return theme;
}

/// Obtiene la configuración y devuelve [true] si se debería poner el menú desplegable a
/// la derecha (endDrawer), o [false] si se debería poner a la izquierda.
bool settingsIsEndDrawer () {

    bool isEndDrawer = PrefService.getBool ("end_drawer")?? true;
    _log.fine ("Configured 'end_drawer': $isEndDrawer");

    /* Por defecto, se pone a la derecha (endDrawer) */
    return isEndDrawer;
}

/// Obtiene la configuración y devuelve el [Level] configurado para el logger.
Level settingsGetLogLevel () {

    String config = PrefService.getString ("log_level");

    _log.fine ("Configured log level: $config");

    Level configLevel;
    Level defaultLevel = Level.WARNING;

    if (config != null) {

        for (Level l in Level.LEVELS) {

            if (l.name == config) {

                configLevel = l;
                _log.finer ("Found matching Level: $l");
                break;
            }
        }

    }

    Level l = configLevel?? defaultLevel;

    _log.fine ("Returning level $l");
    return l;
}

/* ====== */

/// Cambia el tamaño de la caché del scraper
void setCacheSize (int newVal) {

    /* No debería tener un valor negativo; pero por si acaso... */
    _log.info ("Previous cache max: ${ScraperSingleton.instance.MAX_CACHE_SIZE}");
    ScraperSingleton.instance.MAX_CACHE_SIZE = (newVal < 0)? DEFAULT_CACHE_SIZE : newVal;
    _log.info ("New cache max: ${ScraperSingleton.instance.MAX_CACHE_SIZE}");
}


/// Cambia el tamaño del historial guardado en la BDD
void setHistSize (int newVal) {

    /* No debería tener un valor negativo; pero por si acaso... */
    _log.info ("Previous max history: ${DbHandler.MAX_HISTORY}");
    DbHandler.MAX_HISTORY = (newVal < 0)? DEFAULT_HIST_SIZE : newVal;
    _log.info ("New max history: ${DbHandler.MAX_HISTORY}");
}

/// Cambia el nivel de detalle del log
void setLogLevel (String newVal) {

    /* Si no es un nivel aceptado, se deja el que estaba */
    Level newLevel = Logger.root.level;

    for (Level l in Level.LEVELS) {

        if (l.name == newVal) {

            newLevel = l;
            break;
        }
    }

    Logger.root.level = newLevel;
}


/*=======================*/
/* ACCIONES PARA WIDGETS */
/*=======================*/


///
/// Función a ejecutar cuando se pulsa sobre una palabra para buscar su definición.
///
/// [afterSearch] es una función a ejecutar al volver de [Definition].
///
void _searchWord (BuildContext ctx, Palabra word, { Function afterSearch }) async {

    _log.finer ("Searching for word '$word' with afterSearch function: "
        + "$afterSearch"
    );

    if (afterSearch == null) {
        afterSearch = () {};
    }

    /* Primero borra el aviso modal */
    Navigator.of (ctx).pop ();

    /* Luego crea otra instancia de [Definition] con la nueva búsqueda */
    Navigator.of (ctx).pushNamed (
        "/search",
        arguments: await searchDefinition (
                searchWord: word,
                context: ctx
            )
    ).whenComplete (afterSearch);
}


///
/// Crea una de las filas de la lista de acciones que se muestra al pulsar sobre una
/// palabra.
///
/// @param action: Function
///         Función a ejecutar cuando se pulse sobre la fila.
///
/// @param icon: Icon
///         Icono indicativo de la acción a tomar.
///
/// @param description: String
///         Texto que se mostrará al lado del icono como descripción de la acción.
///
Widget _makeActionRow ({
      @required Function action
    , @required IconData icon
    , @required String description
}) => InkWell (
    child: Padding (
        padding: const EdgeInsets.all (20.0),
        child: Row (
            children: <Widget>[
                Expanded (child: Text (description)),
                Icon (icon)
            ],
        )
    ),
    onTap: action
);



///
/// Crea un [TextSpan] que se puede seleccionar para buscar esa palabra en concreto.
/// También aplica un estilo diferente a cada palabra para distinguir las que se pueden
/// buscar y las que no.
///
/// [actionText] es el texto con el que describir la acción que no es la de "Cancelar"
/// [afterSearch] es una función a ejecutar al volver de [Definition].
TextSpan selectableWord (Palabra word, BuildContext ctx,
    { TextStyle style, String actionText, Function afterSearch }
) {

    _log.finest ("Creating widget [selectableWord] for word: '$word', "
        + "actionText '$actionText' and afterSearch = '$afterSearch'"
    );

    if (afterSearch == null) {
        afterSearch = () {};
    }


    /* Si no tiene ningún enlace, se muestra la palabra sin más */
    if (word.enlaceRecurso == null) {

        _log.finest ("The word '$word' has no [enlaceRecurso]");

        return TextSpan (
            text: word.texto,
            style: TextStyle (
                color: Theme.of (ctx).unselectedWidgetColor
            )
        );
    }

    _log.finest ("The word '$word' has [enlaceRecurso]: ${word.enlaceRecurso}");

    return TextSpan (
        text: word.texto,
        /* Permite realizar una búsqueda para esta palabra */
        recognizer: TapGestureRecognizer ()..onTap = () => showDialog (
            context: ctx,
            builder: (BuildContext ctx) => SimpleDialog (
                children: <Widget> [
                            _makeActionRow (
                                icon: Icons.search,
                                /* Busca la palabra seleccionada */
                                action: () => _searchWord (
                                        ctx,
                                        word,
                                        afterSearch: afterSearch
                                ),
                                description: actionText == null?
                                        "Buscar definición de '%s'".i18n
                                                .fill ([word.texto])
                                        : actionText
                            ),
                            Divider (),
                            _makeActionRow (
                                icon: Icons.close,
                                action: () => Navigator.pop (ctx),
                                description: "Cerrar".i18n
                            ),
                        ]
            )
        ),
        style: style
    );
}



/// Salta un pop-up informando del error concreto
void _showErrordialog (Exception ex, BuildContext ctx) {

    _log.fine ("Showing error dialog for exception.");
    _log.severe (ex);

    showDialog (
        context: ctx,
        barrierDismissible: false,
        builder: (BuildContext ctx) => AlertDialog (
            title: Text ("Error al realizar la petición".i18n),
            content: SingleChildScrollView (
                child: ListBody (
                    children: <Widget>[
                        Text (("Puedes informar de este error enviando una captura de "
                                + "pantalla al equipo de desarrollo.").i18n),
                        Divider (),
                        Text ("$ex")
                    ]
                )
            ),
            actions: <Widget>[
                FlatButton (
                    child: Text ("Aceptar".i18n),
                    onPressed: () => Navigator.of (ctx).pop ()
                )
            ]
        )
    );
}


///
/// Realiza la petición para obtener la definición del texto introducido, o la lee de
/// los datos guardados, si es que está disponible.
///
/// Si se proporciona el argumento [searchWord], se omite [searchTerm]. Si no se
/// proporciona ninguno de los dos, se lanza un [ArgumentError].
///
Future<Map<String, dynamic>> searchDefinition (
    {String searchTerm, Palabra searchWord,
    @required BuildContext context}
) async {

    _log.finest ("Searching definition with searchTerm = '$searchTerm' and "
        + "searchWord = '$searchWord'"
    );

    if (searchWord != null) {

        /* Chapuza cutriplus para lidiar con la palabra del día */
        if (
            (searchWord.enlaceRecurso != null)
            &&
            searchWord.enlaceRecurso.contains ("?m=wotd")
        ) {

            _log.finest ("Taken modification path to search for word of the day.");

            Uri uri = Uri.parse (searchWord.enlaceRecurso);
            searchWord = null;
            /* La ruta empieza por "/", así que se elimina. También se decodifica para
            No guardar en el historial cosas como "Travesa%C3%B1o" (Travesaño) */
            searchTerm = Uri.decodeComponent (uri.path.replaceAll ("/", ""));

        } else {

            searchTerm = searchWord.texto.trim ().toLowerCase ();
        }
    }

    _log.fine ("Search term: $searchTerm");

    /* [savedKeys] debería estar inicializada y actualizada */
    if (DbHandler.savedKeys.contains (searchTerm)) {

        _log.info ("Search term '$searchTerm' found in DB cache (savedKeys)");

        String jsonRes = (
            await DbHandler.getDefinition (searchTerm)
        ).resultJson;

        /* La palabra estaba guardada */
        return { "result": Future.value (
                    Resultado.fromJson (
                        jsonDecode (jsonRes)
                    )
                )
                , "saved": true
                , "searchTerm": searchTerm
        };

    } else {

        if (searchWord != null) {

            _log.finest ("Taken 'searchWord != null' path");

            /* Se realiza la petición al enlace directo, que es más rápido */
            return {
                "result": searchWord.obtenerDef (
                    ScraperSingleton.instance,
                    manejadorError: (err) => _log.severe (err),
                    manejadorExcepc: (e) => _showErrordialog (e, context)
                ),
                "saved": false,
                "searchTerm": searchTerm
            };

        } else {

            _log.finest ("Taken 'searchWord == null' path");

            if (searchTerm == null) {

                throw ArgumentError ("No search term specified");
            }

            /* Se debe hacer una petición para obtener la entrada */
            return {
                "result": ScraperSingleton.instance.obtenerDef (
                    searchTerm,
                    manejadorError: (err) => _log.severe (err),
                    manejadorExcepc: (e) => _showErrordialog (e, context)
                ),
                "saved": false,
                "searchTerm": searchTerm
            };
        }
    }
}


