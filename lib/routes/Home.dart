import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rae_scraper/rae_scraper.dart';

import '../ScraperSingleton.dart';
import '../db/DbHandler.dart';
import '../i18n.dart';
import '../utils.dart' as utils;
import '../widgets/DrawerContent.dart';
import '../widgets/SearchBar.dart';


class HomePage extends StatefulWidget {

    HomePage ({Key key}) : super(key: key);

    final _log = Logger ("Home.dart");

    @override
    HomePageState createState () => HomePageState ();
}

class HomePageState extends State<HomePage> {

    ///
    /// Borra la entrada seleccionada del historial.
    ///
    Future<void> _deleteHistoryItem (BuildContext ctx, String key) async {

        /* Elimina la entrada */
        bool success = await DbHandler.deleteFromHistory (key);

        widget._log.info ("Entry deleted from history: $success");

        /* No lo ha conseguido => muestra un SnackBar indicando el error y sale */
        if ( ! success) {

            Scaffold.of (ctx).showSnackBar (
                SnackBar (
                    content: Text ("Error. No se pudo borrar la entrada.".i18n)
                )
            );
            return;
        }


        /* Éxito => se llama a [setState()] para que se actualice la lista */
        setState ( () { } );

        /* Muestra un mensaje para deshacer el cambio, si se prefiere */
        Scaffold.of (ctx).showSnackBar (
            SnackBar (
                content: Text ("Entrada borrada con éxito.".i18n),
            )
        );
    }

    /// Redirecciona a [Definition] para mostrar la definición
    Future<void> _sowHistoryEntry (BuildContext ctx, String searchTerm) async {

        widget._log.fine ("Showing history entry: $searchTerm");

        Navigator.of (ctx).pushNamed (
            "/search",
            arguments: await utils.searchDefinition (
                context: ctx,
                searchTerm: searchTerm
            )
        ).whenComplete (
            () {
                /* Se llama a [setState()] para que se actualice el historial */
                setState ( () { } );
            }
        );
    }


    ///
    /// Obtiene la palabra del día y la muestra como una palabra seleccionable
    ///
    Widget _wordOfTheDay (BuildContext ctx) => Container (
        margin: const EdgeInsets.all (10.0),
        color: Theme.of (ctx).cardColor,
        child: FutureBuilder<Palabra> (
                future: ScraperSingleton.instance.palabraDelDia (),
                builder: (BuildContext ctx, AsyncSnapshot<Palabra> snapshot) {

                    List<Widget> children = <Widget>[
                        Text (
                            "Palabra del día".i18n,
                            style: Theme.of (ctx).textTheme.headline6
                        )
                    ];

                    if (snapshot.hasData) {

                        Palabra wotd = snapshot.data;

                        children.addAll (<Widget>[
                            Padding (
                                padding: const EdgeInsets.all (10.0),
                                child: SelectableText.rich (
                                    TextSpan (
                                        text: wotd.texto,
                                        /* Se busca directamente la palabra, sin mostrar
                                        el mensajito para pulsar en "buscar" */
                                        recognizer: TapGestureRecognizer ()
                                            ..onTap = () async {
                                                Navigator.of (ctx).pushNamed (
                                                    "/search",
                                                    arguments: await utils
                                                        .searchDefinition (
                                                            searchWord: wotd,
                                                            context: ctx
                                                        )
                                                ).whenComplete (
                                                    () => setState ( (){} )
                                                );
                                            }
                                    ),
                                    style: TextStyle (
                                        fontSize: Theme.of (ctx)
                                                        .textTheme
                                                        .headline4
                                                        .fontSize,
                                        color: Theme.of (ctx).accentColor
                                    )
/*                                        utils.selectableWord (
                                            wotd,
                                            ctx,
                                            style: TextStyle (
                                                fontSize: Theme.of (ctx)
                                                                .textTheme
                                                                .headline4
                                                                .fontSize,
                                                color: Theme.of (ctx).accentColor
                                            ),
                                            afterSearch: () => setState (() {})
                                    )*/
                                )
                            )
                        ]);

                    } else if (snapshot.hasError) {

                        children.addAll (<Widget>[
                            Padding (
                                padding: EdgeInsets.only (top: 16.0),
                                child: Icon (
                                    Icons.error_outline,
                                )
                            ),
                            Padding (
                                padding: const EdgeInsets.only (top: 16.0),
                                child: Text ("Error: %s".i18n.fill ([snapshot.error])),
                            )
                        ]);
                    } else {
                        /* En espera de los datos => circulito de "cargando..." */
                        children.addAll (<Widget>[
                            Padding (
                                padding: EdgeInsets.only (top: 16.0),
                                child: CircularProgressIndicator ()
                            ),
                            Padding (
                                padding: EdgeInsets.only (top: 16.0),
                                child: Text ("Buscando...".i18n),
                            )
                        ]);
                    }

                    return Container (
                        padding: const EdgeInsets.all (15.0),
                        child: Column (
                            children: children
                        )
                    );
                }
        )
    );


    /// Lista con las búsquedas recientes
    List<Widget> _recentSearches (BuildContext ctx) => <Widget>[
        Container (
            child: FutureBuilder <List<Map<String, dynamic>>>(
                future: DbHandler.getHistory (),
                /* Manejador para añadir el resultado cuando esté disponible */
                builder: (BuildContext ctx,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot
                ) {

                    List<Widget> children = [
                        Text (
                            "Historial de búsquedas".i18n,
                            style: Theme.of (ctx).textTheme.headline6
                        ),
                        Divider ()
                    ];

                    if (snapshot.hasData) {
                        /* Los datos ya están disponibles */

                        /* Los elementos ya están ordenados por timestamp, de más
                        reciente a más antiguo */
                        for (Map<String, dynamic> elem in snapshot.data) {

                            String searchTerm = elem ["searchTerm"];
                            int timestamp = elem ["timestamp"];

                            /* Simplemente es un texto con la palabra guardada. La
                            definición se cargará sólo si se pincha en ella */
                            Widget item = Card (
                                child: Column (
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                        ListTile (
                                            leading: Icon (Icons.book),
                                            title: Text (
                                                searchTerm.capitalize (),
                                                style: Theme.of (ctx).textTheme.headline5
                                            ),
                                            subtitle: Text (
                                                DateTime.fromMillisecondsSinceEpoch (
                                                    timestamp
                                                ).toString ()
                                            )
                                        ),
                                        ButtonBar (
                                            children: <Widget>[
                                                /* Botón para ver la definición */
                                                FlatButton (
                                                    child: Text (
                                                        "Ver definición"
                                                            .i18n
                                                            .toUpperCase ()
                                                    ),
                                                    onPressed: () => _sowHistoryEntry (
                                                        ctx,
                                                        searchTerm
                                                    )
                                                ),
                                                /* Botón para eliminar de la BDD */
                                                FlatButton (
                                                    child: Text (
                                                        "Eliminar"
                                                            .i18n
                                                            .toUpperCase ()
                                                    ),
                                                    onPressed: () => _deleteHistoryItem (
                                                        ctx,
                                                        searchTerm
                                                    )
                                                )
                                            ],
                                            buttonTextTheme: ButtonTextTheme.accent
                                        )
                                    ]
                                )
                            );

                            children.add (item);
                            children.add (Divider ());
                        }

                    } else if (snapshot.hasError) {
                        /* Hubo un error */
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
                        /* En espera de los datos => circulito de "cargando..." */
                        children = <Widget>[
                            SizedBox (
                                child: CircularProgressIndicator (),
                                width: 60,
                                height: 60,
                            ),
                            Padding (
                                padding: EdgeInsets.only (top: 16.0),
                                child: Text ("Cargando...".i18n),
                            )
                        ];
                    }

                    /* Al final esto va a ser lo que haya en [Scaffold.body] */
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


    @override
    Widget build (BuildContext ctx) => Scaffold (
        appBar: SearchBar (afterSearch: () => setState (() {})),
        /* Se usa drawer o endDrawer en función de la configuración */
        drawer: utils.settingsIsEndDrawer ()?
                    null : DrawerContent (afterSearch: () => setState (() {}))
        ,
        endDrawer: utils.settingsIsEndDrawer ()?
                    DrawerContent (afterSearch: () => setState (() {})) : null
        ,
        body: Container (
            color: Theme.of (ctx).primaryColor,
            child: ListView (
                children: <Widget>[
                    /* Palabra del día */
                    _wordOfTheDay (ctx),
                    /* Búsquedas recientes */
                    Container (
                        margin: const EdgeInsets.fromLTRB (10.0, 0.0, 10.0, 10.0),
                        child: Column (
                            children: _recentSearches (ctx)
                        )
                    )
                ]
            )
        )
    );

}

