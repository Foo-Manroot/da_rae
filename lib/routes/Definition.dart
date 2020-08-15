import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:rae_scraper/rae_scraper.dart';

import '../i18n.dart';
import '../extra/unicorndial.dart';
import '../db/StoredDefinition.dart';
import '../db/DbHandler.dart';
import '../widgets/SearchBar.dart';
import '../utils.dart' as utils;
import '../widgets/DrawerContent.dart';

class Definition extends StatefulWidget {

    Definition ({Key key}) : super(key: key);

    final _log = Logger ("Definition.dart");

    @override
    DefinitionState createState () => DefinitionState ();
}


class DefinitionState extends State<Definition> {

    /// Indica si esta palabra está guardada en disco
    bool _saved;

    /// Clave usada para almacenar esta entrada (si es que está en disco).
    String _searchTerm;

    ///
    /// Crea los elementos necesarios para mostrar por pantalla un elemento [Acepc] que
    /// conste de un enlace.
    ///
    Widget _createLink (Acepc info, BuildContext ctx) {

        List<TextSpan> words = [ ];

        for (Palabra word in info.palabras) {

            words.add (
                utils.selectableWord (
                    word,
                    ctx,
                    actionText: "Buscar expresión '%s'".i18n.fill ([word.texto])
                )
            );
        }

        return Container (
            width: double.infinity,
            child: Card (
                color: Theme.of (ctx).highlightColor,
                margin: const EdgeInsets.all (5.0),
                child: Padding (
                    padding: const EdgeInsets.all (15.0),
                    child: SelectableText.rich (
                        TextSpan (children: words)
                    ),
                )
            )
        );
    }

    ///
    /// Crea los elementos necesarios para mostrar un elemento [Acepc] por pantalla.
    ///
    Widget _createAcepc (Acepc info, BuildContext ctx) {

        List<TextSpan> words = [
            TextSpan (
                text: "${info.num_acep}.  ",
                style: TextStyle (fontWeight: FontWeight.bold)
            )
        ];

        /* Uso -> se pone la abreviatura y, si se pulsa, se muestra el texto completo */
        if (info.uso.isNotEmpty) {

            for (Uso u in info.uso) {

                String fullText = u.significado.join (", ").capitalize ();
                words.add (
                    TextSpan (
                        text: "${u.abrev} ",
                        /* Si se pincha sobre la abreviatura, se muestra su explicación */
                        recognizer: TapGestureRecognizer ()..onTap = () =>
                            showModalBottomSheet (
                                context: ctx,
                                builder: (BuildContext ctx) => Container (
                                    padding: const EdgeInsets.all (20.0),
                                    child: Row (
                                        children: <Widget> [
                                            Expanded (child: Text ("$fullText")),
                                            CloseButton ()
                                        ]
                                    )
                                )
                            ),
                        style: TextStyle (
                            color: Theme.of (ctx).accentColor
                        )
                    )
                );
            }
        }

        for (Palabra word in info.palabras) {

            /* Igual que con el uso, si es una abreviatura se debe pinchar para mostrar
            su texto completo */
            if (word.abbr != null) {

                 words.add (
                    TextSpan (
                        text: "${word.abbr} ",
                        /* Si se pincha sobre la abreviatura, se muestra su explicación */
                        recognizer: TapGestureRecognizer ()..onTap = () =>
                            showModalBottomSheet (
                                context: ctx,
                                builder: (BuildContext ctx) => Container (
                                    padding: const EdgeInsets.all (20.0),
                                    child: Row (
                                        children: <Widget> [
                                            Expanded (child: Text ("${word.texto}")),
                                            CloseButton ()
                                        ]
                                    )
                                )
                            ),
                        style: TextStyle (
                            color: Theme.of (ctx).accentColor
                        )
                    )
                );

            } else {

                words.add (utils.selectableWord (word, ctx));
            }
        }

        return Container (
            width: double.infinity,
            child: Card (
                color: Theme.of (ctx).highlightColor,
                margin: const EdgeInsets.all (5.0),
                child: Padding (
                    padding: const EdgeInsets.all (15.0),
                    child: SelectableText.rich (
                        TextSpan (children: words)
                    ),
                )
            )
        );
    }


    ///
    /// Crea los elementos necesarios para mostrar un elemento [Expr] por pantalla.
    ///
    Widget _createExpr (Expr info, BuildContext ctx) {

        List<Widget> entries = [
            Padding (
                padding: const EdgeInsets.symmetric (vertical: 5),
                child: Text (
                    "${info.texto}",
                    style: TextStyle (fontStyle: FontStyle.italic)
                )
            )
        ];


        for (Acepc def in info.definiciones) {

            entries.add (this._createAcepc (def, ctx));
        }

        return Container (
            width: double.infinity,
            child: Card (
                color: Theme.of (ctx).highlightColor,
                margin: const EdgeInsets.all (5.0),
                child: Column (
                    children: entries
                )
            )
        );
    }


    ///
    /// Devuelve una tabla donde se presenta la conjugación del tiempo verbal
    /// especificado
    ///
    Widget _makeTiempoVerbal (TiempoVerbal t, BuildContext ctx) {


        List<TableRow> rows = [];

        /* Añade una persona perteneciente al tiempo verbal actual */
        Function addRow = (pronoun, conjugation) => rows.add (
            TableRow (
                children: <Widget>[
                    Text (pronoun),
                    Text (conjugation)
                ]
            ),
        );
        /* Añade una división entre las personas del discurso */
        Function addDivider = ([thickness = 0.75]) => rows.add (
            TableRow (
                children: <Widget>[
                    Divider (
                        indent: 5.0,
                        endIndent: 30.0,
                        thickness: thickness,
                        color: thickness > 1.0? Theme.of (ctx).accentColor : null
                    ),
                    /* Hace falta tener dos elementos no nulos, o no se puede dibujar */
                    (thickness > 1.0?
                        Divider (
                            indent: 5.0,
                            endIndent: 30.0,
                            thickness: thickness,
                            color: Theme.of (ctx).accentColor
                        )
                        :  Container ()
                    )
                ]
            )
        );


        /* Singular */
        if (t.sing_prim != null) {
            addRow ("Yo", t.sing_prim);
            addDivider ();
        }
        addRow ("Tú / vos", t.sing_seg [0]);
        addRow ("Usted", t.sing_seg [1]);
        if (t.sing_terc != null) {
            addDivider ();
            addRow ("Ella / él", t.sing_terc);
        }

        addDivider (1.5);

        /* Plural */
        if (t.plural_prim != null) {
            addRow ("Nosotras / nosotros", t.plural_prim);
            addDivider ();
        }
        addRow ("Vosotras / vosotros", t.plural_seg [0]);
        addRow ("Ustedes", t.plural_seg [1]);
        if (t.plural_terc != null) {
            addDivider ();
            addRow ("Ellas / ellos", t.plural_terc);
        }


        return Container (
            width: double.infinity,
            child: Column (
                children: [
                    Padding (
                        padding: const EdgeInsets.all (10.0),
                        child: Text (
                            "> ${t.nombre.capitalize ()} < ",
                            style: Theme.of (ctx).textTheme.bodyText1
                        )
                    ),
                    Card (
                        color: Theme.of (ctx).highlightColor,
                        margin: const EdgeInsets.all (5.0),
                        child: Padding (
                            padding: const EdgeInsets.all (10.0),
                            child: Table (
                                children: rows
                            )
                        )
                    )
                ]
            )
        );
    }


    ///
    /// Crea los elementos necesarios para mostrar un elemento [Conjug] por pantalla.
    ///
    Widget _createConjug (Conjug conjugation, BuildContext ctx) {

        List<Widget> entries = [];

        /* Cabecera para indicar que a continuación viene la conjugación */
        entries.add (
            Padding (
                padding: const EdgeInsets.all (10.0),
                child: Text (
                    "...",
                    style: Theme.of (ctx).textTheme.headline5
                )
            )
        );

        /* Formas no personales */
        entries.add (Divider ());
        entries.add (
            Padding (
                padding: const EdgeInsets.all (10.0),
                child: Text (
                    "Formas no personales".i18n,
                    style: Theme.of (ctx).textTheme.headline6
                )
            )
        );

        /* Infinitivo, Gerundio y Participio */
        entries.add (
            Container (
                width: double.infinity,
                child: Card (
                    color: Theme.of (ctx).highlightColor,
                    margin: const EdgeInsets.all (5.0),
                    child: Padding (
                        padding: const EdgeInsets.all (10.0),
                        child: Table (
                            children: <TableRow>[
                                TableRow (
                                    children: <Widget>[
                                        Text ("Infinitivo"),
                                        Text (conjugation.infinitivo)
                                    ]
                                ),
                                TableRow (
                                    children: <Widget>[
                                        Text ("Participio"),
                                        Text (conjugation.participio)
                                    ]
                                ),
                                TableRow (
                                    children: <Widget>[
                                        Text ("Gerundio"),
                                        Text (conjugation.gerundio)
                                    ]
                                )
                            ]
                        )
                    )
                )
            )
        );

        /* ========== */
        /* Indicativo */
        entries.add (Divider ());
        entries.add (
            Padding (
                padding: const EdgeInsets.all (10.0),
                child: Text ("Indicativo", style: Theme.of (ctx).textTheme.headline6)
            )
        );

        entries.add (_makeTiempoVerbal (conjugation.indicativo.presente, ctx));
        entries.add (_makeTiempoVerbal (conjugation.indicativo.pret_imperf, ctx));
        entries.add (_makeTiempoVerbal (conjugation.indicativo.pret_perf_simple, ctx));
        entries.add (_makeTiempoVerbal (conjugation.indicativo.futuro, ctx));
        entries.add (_makeTiempoVerbal (conjugation.indicativo.condicional, ctx));


        /* ========== */
        /* Subjuntivo */
        entries.add (Divider ());
        entries.add (
            Padding (
                padding: const EdgeInsets.all (10.0),
                child: Text ("Subjuntivo", style: Theme.of (ctx).textTheme.headline6)
            )
        );

        entries.add (_makeTiempoVerbal (conjugation.subjuntivo.presente, ctx));
        entries.add (_makeTiempoVerbal (conjugation.subjuntivo.futuro, ctx));
        entries.add (_makeTiempoVerbal (conjugation.subjuntivo.pret_imperf, ctx));

        /* ========== */
        /* Imperativo */
        entries.add (Divider ());
        entries.add (
            Padding (
                padding: const EdgeInsets.all (10.0),
                child: Text ("Imperativo", style: Theme.of (ctx).textTheme.headline6)
            )
        );

        entries.add (_makeTiempoVerbal (conjugation.imperativo.presente, ctx));



        return Container (
            width: double.infinity,
            margin: const EdgeInsets.all (5.0),
            child: Card (
                color: Theme.of (ctx).highlightColor,
                margin: const EdgeInsets.all (5.0),
                child: Column (
                    children: entries
                )
            )
        );
    }


    ///
    /// Obtiene las entradas correspondientes a la definición de la palabra especificada
    ///
    List<Widget> _getEntries (Future<Resultado> definition, bool isDef) => <Widget>[
        Padding (
            padding: const EdgeInsets.all (5.0),
            child: FutureBuilder <Resultado>(
                future: definition,

                /* Manejador para añadir el resultado cuando esté disponible */
                builder: (BuildContext ctx, AsyncSnapshot<Resultado> snapshot) {

                    List<Widget> children = [];

                    if (snapshot.hasData) {

                        widget._log.info ("AsyncSnapshot returned data");
                        Resultado result = snapshot.data;

                        // Solo agrega la parte de la definicion, si no me equivoco xD
                        if(isDef) {
                          /* Los datos ya están disponibles. Primero se inicia el guardado
                        en el historial. Como es una operación asíncrona y no importa su
                        resultado (se da por hecho que siempre se inserta con éxito), se
                        lanza y no se espera a que termine. */
                          DbHandler.addToHistory(result.palabra.texto);

                          for (Entrada e in result.entradas) {
                            List<Widget> defs = <Widget>[];

                            /* Añade el título y la etimología como cabeceras */
                            defs.add(
                                Padding(
                                    padding: const EdgeInsets.all (5),
                                    child: Text("...")
                                )
                            );
                            defs.add(
                                Container(
                                  /* Evita que se quede centrado, sino que se muestra
                                    al principio de la línea */
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric (
                                        vertical: 5,
                                        horizontal: 10
                                    ),
                                    child: Text(
                                        "${e.etim}",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic)
                                    )
                                )
                            );

                            /* Añade todas las definiciones pertenecientes a esta
                               entrada */
                            for (Definic d in e.definiciones) {
                              switch (d.clase) {
                                case ClaseAcepc.manual:
                                case ClaseAcepc.normal:
                                  Acepc acepc = (d as Acepc);
                                  defs.add(
                                      this._createAcepc(acepc, ctx)
                                  );
                                  break;

                                case ClaseAcepc.frase_hecha:
                                  Expr expr = (d as Expr);
                                  defs.add(
                                      this._createExpr(expr, ctx)
                                  );
                                  break;

                                case ClaseAcepc.enlace:
                                  Acepc acepc = (d as Acepc);
                                  defs.add(
                                      this._createLink(acepc, ctx)
                                  );

                                  break;

                                default:
                                  defs.add(
                                      Card(
                                          color: Theme
                                              .of(ctx)
                                              .highlightColor,
                                          margin: const EdgeInsets.all (5.0),
                                          child: Text("-> ${d.toString()}\n")
                                      )
                                  );
                              }
                            }

                            defs.add(Divider());
                            Container dictEntry = Container(
//                                color: Theme.of (ctx).highlightColor,
                                margin: const EdgeInsets.all (5.0),
                                child: Column(children: defs)
                            );

                            children.add(dictEntry);
                          }
                        }

                        /* Si se trata de un verbo, añade su cnjugación al final */
                        if (!isDef && result.conjug != null) {

                            children.add (this._createConjug (result.conjug, ctx));
                        }

                    } else if (snapshot.hasError) {
                        /* Hubo un error */
                        widget._log.severe ("AsyncSnapshot error: ${snapshot.error}");
                        children = <Widget>[
                            Icon (
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                            ),
                            Padding (
                                padding: const EdgeInsets.only (top: 16.0),
                                child: Text ("Error: %s".i18n.fill ([snapshot.error])),
                            )
                        ];

                    } else {


                        if (snapshot.connectionState == ConnectionState.done) {

                            widget._log.severe ("No data retrieved from AsyncSnapshot");
                            /* Terminó de cargar, pero no tiene datos (devolvió null) */
                            children = <Widget>[
                                Icon (
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 60,
                                ),
                                Padding (
                                    padding: const EdgeInsets.only (top: 16.0),
                                    child: Text ("Palabra no encontrada :(".i18n),
                                )
                            ];

                        } else {
                            /* En espera de los datos => circulito de "cargando..." */
                            children = <Widget>[
                                SizedBox (
                                    child: CircularProgressIndicator (),
                                    width: 60,
                                    height: 60,
                                ),
                                Padding (
                                    padding: EdgeInsets.only (top: 16.0),
                                    child: Text ("Buscando...".i18n),
                                )
                            ];
                        }

                    }

                    /* Añade un espacio en blanco para que los botones de acciones no
                    se superpongan a las definiciones */
                    children.add (Container (height: 100));

                    return Center (
                        child: Column (
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: children
                        )
                    );
                }
            )
        )
    ];


    ///
    /// Guarda (o borra) la entrada actual del almacenamiento local.
    ///
    Future<void> _changeSaved (Future<Resultado> res) async {

        bool success;

        if (_saved) {

            /* Elimina la entrada */
            success = await DbHandler.deleteDefinition (_searchTerm);
            widget._log.info ("Result deleted: $success");

        } else {

            Resultado r = await res;

            /* Guarda la entrada */
            DbHandler.saveDefinition (
                    StoredDefinition (searchTerm: _searchTerm, result: r)
            );
            success = true;
            widget._log.info ("Result saved: $success");
        }

        /* Actualiza el estado para que se dibuje el nuevo valor del icono (si es que se
        ha completado con éxito) */
        setState ( () { _saved = (success)? !_saved : _saved; } );
    }


    @override
    Widget build (BuildContext ctx) {

        Map<String, dynamic> args = ModalRoute.of (ctx).settings.arguments;

        widget._log.finer ("Args: $args");

        Future<Resultado> def = args ["result"];
        /* Es posible que _saved haya cambiado como consecuencia de un [setState()] */
        if (_saved == null) {

            _saved = args ["saved"];
            _searchTerm = args ["searchTerm"];
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(
                      icon: Icon(Icons.assignment),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text("Definición".i18n),
                      ),
                  ),
                  Tab(
                      icon: Icon(Icons.school),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text("Conjugación".i18n),
                      ),
                  )
                ],
              ),
              title: Text(_searchTerm),
            ),
            /* Se usa drawer o endDrawer en función de la configuración */
            drawer: utils.settingsIsEndDrawer ()? null : DrawerContent (),
            endDrawer: utils.settingsIsEndDrawer ()? DrawerContent () : null,
            body: TabBarView(
              children: [
                Container(
                  child: ListView(
                      children: _getEntries (def, true)
                  ),
                ),
                Container(
                  child: ListView(
                      children: _getEntries (def, false)
                  ),
                )
              ],
            ),
              floatingActionButton: UnicornDialer (
                  orientation: UnicornOrientation.VERTICAL,
                  parentButton: Icon (Icons.dehaze),
                  childButtons: <UnicornButton>[
                    UnicornButton (
                        hasLabel: true,
                        labelText: "Volver al inicio".i18n,
                        currentButton: FloatingActionButton (
                            heroTag: null,
                            mini: true,
                            child: Icon (Icons.home),
                            onPressed: () => Navigator.of (ctx).popUntil (
                                ModalRoute.withName ("/")
                            )
                        )
                    ),
                    UnicornButton (
                        hasLabel: true,
                        labelText: (_saved?
                        "Quitar de 'palabras guardadas'"
                            : "Añadir a 'palabras guardadas'".i18n
                        ),
                        currentButton: FloatingActionButton (
                            heroTag: null,
                            mini: true,
                            child: Icon (
                                _saved? Icons.favorite
                                    : Icons.favorite_border
                            ),
                            onPressed: () => this._changeSaved (def)
                        )
                    ),
                  ]
              )
          ),
        );
    }
}
