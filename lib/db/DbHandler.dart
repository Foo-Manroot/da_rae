import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';


import 'StoredDefinition.dart';

class DbHandler {

    static final _log = Logger ("DbHandler.dart");


    /// Nombre de la base de datos utilizada
    static const String dbName = "saved_searches.sqlite";

    /// Nombre de la tabla usada para guardar las búsquedas
    static const String tableSavedSearches = "saved_searches";

    /// Nombre de la tabla con el historial de búsquedas
    static const String tableHistory = "history";

    /// Lista con las palabras guardadas en la base de datos
    static List<String> savedKeys = [];

    /// Versión del esquema de la BDD.
    static const _version = 2;

    /// Única instancia permitida de una conexión con la BDD.
    static Future<Database> _instance;

    /// Número máximo de elementos en el historial
    static int MAX_HISTORY = 20 ;

    /// Inicializa la conexión con la BDD y va obteniendo los resultados iniciales.
    /// No es necesario, aunque puede resultar beneficioso.
    static Future<void> init () async {

        /* Esto inicializa savedKeys automáticamente */
        await DbHandler.listKeys ();
    }

    /// Crea las tablas por primera vez (se da por hecho que antes no existían)
    static void _createTables (Database db) {

        _log.finer ("Creating tables on DB...");
        Batch batch = db.batch ();

        /* Tabla principal con las palabras guardadas */
        batch.execute ('''
            CREATE TABLE $tableSavedSearches (
                searchTerm TEXT PRIMARY KEY,
                resultJson TEXT
            )
        ''');

        /* Para el historial de las últimas palabras buscadas */
        batch.execute ('''
            CREATE TABLE $tableHistory (
                searchTerm TEXT PRIMARY KEY,
                timestamp INTEGER
            )
        ''');

        batch.commit ();
        _log.fine ("Created tables on DB");
    }

    /// Obtiene la única instancia permitida para conectar con la BDD.
    static Future<Database> get instance async {

        _log.finer ("Getting an instance of DB");

        if (_instance == null) {

            _log.finest ("No DB instance was found. Creating one...");

            String path = await getDatabasesPath ();
            _instance = openDatabase (
                p.join (path, dbName),
                onCreate: (db, ver) => _createTables (db),
                version: _version
            );

            _log.finest ("DB instance created: $_instance");
        }

        return _instance;
    }


    /*************************************/
    /* Métodos de interacción con la BDD */
    /*************************************/


    /// Guarda la definición especificada en la BDD.
    /// Si se quiere comprobar, se debe realizar un SELECT ([getDefinition])
    ///
    /// Se debe dar por hecho que siempre se tiene éxito guardando.
    static void saveDefinition (StoredDefinition def) {

        _log.finer ("Saving definition of '${def.searchTerm}'");

        DbHandler.instance.then (
            (db) => db.insert (
                tableSavedSearches,
                def.toMap (),
                conflictAlgorithm: ConflictAlgorithm.ignore
            )
        ).whenComplete (
            () => _log.fine ("Definition of '${def.searchTerm}' finished saving")
        );

        /* Aprovecha para guardarlo también en memoria */
        savedKeys.add (def.searchTerm);
        _log.finer ("'${def.searchTerm}' added to savedKeys cache");
    }

    /// Elimina la entrada especificada, si existe.
    /// Devuelve [true] si la entrada se borró correctamente, o [false] si hubo algún
    /// problema o, directamente, esa entrada no existía.
    static Future<bool> deleteDefinition (String key) async {

        _log.finer ("Deleting definition with key '$key'");

        Database db = await DbHandler.instance;

        int result = await db.delete (
            tableSavedSearches,
            where: "searchTerm = ?",
            whereArgs: [ key ]
        );

        _log.finest ("Got this return value after deleting key '$key': $result");

        bool success = (result == 1);

        /* Aprovecha para eliminarlo también de memoria */
        if (success) {

            savedKeys.remove (key);
            _log.finest ("Key '$key' successfully removed from savedKeys cache");
        }

        return success;
    }

    /// Busca la definición de la palabra especificada y la devuelve, o devuelve [null]
    /// si no se encontró.
    static Future<StoredDefinition> getDefinition (String key) async {

        _log.finer ("Retrieving definition with key '$key'");

        Database db = await DbHandler.instance;

        List<Map<String, dynamic>> result = await db.query (
            tableSavedSearches,
            where: "searchTerm = ?",
            whereArgs: [ key ]
        );

        _log.finest ("Search with key '$key' returned ${result.length} elements: "
            + "$result"
        );

        return (result.length == 1)?
            StoredDefinition.fromMap (
                searchTerm: result [0]["searchTerm"],
                resultJson: result [0]["resultJson"]
            )
            : null;
    }


    /// Devuelve un listado con todas las claves guardadas en la BDD.
    /// También actualiza [DbHandler.savedKeys]
    static Future<List<String>> listKeys () async {

        _log.finer ("Retrieving all keys from DB");

        Database db = await DbHandler.instance;

        List<Map<String, dynamic>> results = await db.query (
            tableSavedSearches,
            columns: [ "searchTerm" ]
        );

        _log.finest ("Search for all keys returned ${results.length} elements: "
            + "$results"
        );

        savedKeys = List.generate (results.length,
            (i) { return results [i]["searchTerm"]; }
        );

        _log.finer ("Updated savedKeys cache: $savedKeys");
        return savedKeys;
    }

    /*************/
    /* Historial */
    /*************/


    /// Guarda la definición en el historial.
    /// Si se quiere comprobar, se debe realizar un SELECT ([getLastEntries])
    ///
    /// Se debe dar por hecho que siempre se tiene éxito guardando.
    static Future<void> addToHistory (String searchTerm) async {

        _log.fine ("Adding '$searchTerm' to history.");

        /* No debería ser nunca negativo y, si lo fuera, creo que no pasaría nada; pero
        por si las moscas... */
        if (MAX_HISTORY < 0) {

            _log.fine ("Cannot add '$searchTerm' to historty because MAX_HISTORY "
                + "is less '$MAX_HISTORY'"
            );
            return;
        }


        /* Primero debe comprobar si se ha alcanzado el límite de elementos */
        List<Map<String, dynamic>> contents = await getHistory (
            columns: [ "searchTerm", "timestamp" ]
        );

        _log.fine ("There are already ${contents.length} elements in history");

        /* Si se ha superado el límite, se elimina el elemento más antiguo hasta
        volver a entrar en los límites (puede que se haya cambiado MAX_HISTORY_SIZE).
        Como la lista está ordenada, el más antiguo siempre será el último */
        if (contents.length >= MAX_HISTORY) {

            _log.fine ("Reached MAX_HISTORY ($MAX_HISTORY) elements in history");
            contents.getRange (MAX_HISTORY, contents.length).forEach (
                /* No hace falta hacer await porque, aunque se borre después de que se
                haya insertado (o actualizado) el nuevo elemento, son operaciones
                independientes y el resultado es el mismo (que no se supere
                MAX_HISTORY) */
                (v) => deleteFromHistory (v ["searchTerm"])
            );
        }

        /* No se quiere guardar nada en el historial */
        if (MAX_HISTORY == 0) {

            _log.fine ("MAX_HISTORY is 0. Nothing will be saved in history.");
            return;
        }

        /* Finalmente, añade el nuevo elemento */
        Database db = await DbHandler.instance;

        Map<String, dynamic> data = {
            "searchTerm": searchTerm,
            "timestamp": DateTime.now ().millisecondsSinceEpoch
        };
        db.insert (
            tableHistory,
            data,
            /* Si ya se encuentra la clave primaria, se substituye porque así se
            actualiza el timestamp. Así, no hace falta buscar primero si ya
            existía el valor insertado */
            conflictAlgorithm: ConflictAlgorithm.replace
        );

        _log.fine ("Added element with key '$searchTerm' to history");
    }


    /// Devuelve todas las entradas contenidas en el historial.
    /// El valor devuelto es una lista donde cada elemento es un [Map] con todas las
    /// columnas especificadas de la tabla.
    ///
    /// Los resultados están ordenados de más reciente (índice 0) a más antiguo.
    static Future<List<Map<String, dynamic>>> getHistory (
        {List<String> columns = const [ "searchTerm", "timestamp" ]}
    ) async {

        _log.fine ("Retrieving history ordered by timestamp DESC");
        Database db = await DbHandler.instance;

        return await db.query (tableHistory, columns: columns, orderBy: "timestamp DESC");
    }


    /// Elimina la entrada especificada del historial.
    /// Devuelve [true] si la entrada se borró correctamente, o [false] si hubo algún
    /// problema o, directamente, esa entrada no existía.
    static Future<bool> deleteFromHistory (String key) async {

        _log.fine ("Deleting key '$key' from history");
        Database db = await DbHandler.instance;

        int result = await db.delete (
            tableHistory,
            where: "searchTerm = ?",
            whereArgs: [ key ]
        );

        _log.finer ("db.delete() returned '$result'");

        return (result == 1);
    }


    /*************/
    /*************/
    /*************/


    ///
    /// Cierra las conexiones con la base de datos
    ///
    static void dispose () {


        if (_instance != null) {

            _instance.then ((db) => db.close ());
            _log.fine ("DB connection closed");
        }

        _instance = null;
        _log.fine ("Instance disposed");
    }
}
