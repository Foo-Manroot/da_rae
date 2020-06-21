import 'package:flutter/material.dart';

import '../db/DbHandler.dart';
import '../db/StoredDefinition.dart';
import '../i18n.dart';
import '../utils.dart' as utils;
import '../widgets/DrawerContent.dart';

/// Pantalla dedicada a mostrar las palabras guardadas
class Saved extends StatefulWidget {

    Saved ({Key key}) : super(key: key);

    @override
    SavedState createState () => SavedState ();
}

class SavedState extends State<Saved> {

    ///
    /// Guarda (o borra) la entrada seleccionada del almacenamiento local.
    ///
    Future<void> _deleteItem (BuildContext ctx, String searchTerm) async {

        /* Primero guarda la entrada en memoria por si se quiere deshacer la acción */
        StoredDefinition temp = await DbHandler.getDefinition (searchTerm);

        /* Elimina la entrada */
        bool success = await DbHandler.deleteDefinition (searchTerm);

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
                action: SnackBarAction (
                    label: "Deshacer".i18n,
                    onPressed: () async {

                        DbHandler.saveDefinition (temp);

                        /* Se debe dar por hecho que siempre se tiene éxito al guardar.
                        Se llama a [setState()] para que se actualice la lista */
                        setState ( () {} );
                    }
                )
            )
        );
    }




    /// Redirecciona a [Definition] para mostrar la definición
    Future<void> _sowEntry (BuildContext ctx, String searchTerm) async {

        StoredDefinition stored = await DbHandler.getDefinition (searchTerm);

        Navigator.of (ctx).pushNamed (
            "/search",
            arguments: {
                "saved": true,
                "searchTerm": searchTerm,
                "result": Future.value (stored.toResult ())
            }
        ).whenComplete (
            () {
                /* Se llama a [setState()] para que se actualice la lista */
                setState ( () { } );
            }
        );
    }


    List<Widget> _getEntries (BuildContext ctx, Future<List<String>> dbKeys) => <Widget>[
        Container (
            child: FutureBuilder <List<String>>(
                future: dbKeys,
                /* Manejador para añadir el resultado cuando esté disponible */
                builder: (BuildContext ctx, AsyncSnapshot<List<String>> snapshot) {

                    List<Widget> children = [ Divider () ];

                    if (snapshot.hasData) {

                        /* Ordena los elementos de manera alfabética */
                        snapshot.data.sort (
                            (a, b) => a.toLowerCase ().compareTo (b.toLowerCase ())
                        );

                        /* Los datos ya están disponibles */
                        for (String searchTerm in snapshot.data) {

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
                                                    onPressed: () => _sowEntry (
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
                                                    onPressed: () => _deleteItem (
                                                        ctx, searchTerm
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
                                child: Text ("Buscando...".i18n),
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
    Widget build (BuildContext ctx) {

        Future<List<String>> arg = DbHandler.listKeys ();

        return Scaffold (
            appBar: AppBar (
                title: Text ("Palabras guardadas".i18n)
            ),
            /* Se usa drawer o endDrawer en función de la configuración */
            drawer: utils.settingsIsEndDrawer ()? null : DrawerContent (),
            endDrawer: utils.settingsIsEndDrawer ()? DrawerContent () : null,
            body: Container (
                child: Center (
                    child: ListView (
                        children: _getEntries (ctx, arg)
                    )
                )
            )
        );
    }
}
