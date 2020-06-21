import 'package:flutter/material.dart';

import '../i18n.dart';
import '../main.dart' as main;

class DrawerContent extends StatelessWidget {

    /// Constructor
    ///
    /// El parámetro [afterSearch] es una función a la que llamar cuando se vuelva de
    /// cualquier pantalla del menú.
    DrawerContent ({Key key, this.afterSearch }) : super(key: key);

    /// Función a ejecutar al volver de cualquier pantalla del menú.
    final Function afterSearch;

    @override
    Widget build (BuildContext ctx) => Drawer (
        child: Column (
            children: <Widget>[
                Expanded (
                    child: ListView (
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                            DrawerHeader (
                                child: Text (
                                    "Menú".i18n,
                                    style: Theme.of (ctx).textTheme.headline4
                                ),
                                decoration: BoxDecoration (
                                    color: Theme.of (ctx).cardColor
                                )
                            ),
                            ListTile (
                                leading: Icon (Icons.home),
                                title: Text ("Inicio".i18n),
                                onTap: () => Navigator.of (ctx).popUntil (
                                    ModalRoute.withName ("/")
                                )
                            ),
                            ListTile (
                                leading: Icon (Icons.favorite_border),
                                title: Text ("Palabras guardadas".i18n),
                                onTap: () {
                                    /* Primero cierra el menú lateral */
                                    Navigator.of (ctx).pop ();
                                    Navigator.of (ctx).pushNamed ("/saved")
                                            .whenComplete (
                                                /* Si afterSearch es null, se ejecuta una
                                                función vacía para evitar errores */
                                                this.afterSearch?? () {}
                                            );
                                }
                            ),
                        ]
                    ),
                ),
                Container (
                    child: Align (
                        alignment: FractionalOffset.bottomCenter,
                        child: Column (
                            children: <Widget>[
                                ListTile (
                                    leading: Icon (Icons.settings),
                                    title: Text ("Configuración".i18n),
                                    onTap: () {
                                        /* Primero cierra el menú lateral */
                                        Navigator.of (ctx).pop ();
                                        Navigator.of (ctx).pushNamed ("/settings")
                                                .whenComplete (
                                                    /* Si afterSearch es null, se ejecuta
                                                    una función vacía para evitar
                                                    errores */
                                                    this.afterSearch?? () {}
                                                );
                                    }
                                ),
                                ListTile (
                                    leading: Icon (Icons.help),
                                    title: Text ("Información de la aplicación".i18n),
                                    onTap: () {
                                        /* Primero cierra el menú lateral */
                                        Navigator.of (ctx).pop ();
                                        Navigator.of (ctx).pushNamed ("/info")
                                                .whenComplete (
                                                    /* Si afterSearch es null, se ejecuta
                                                    una función vacía para evitar
                                                    errores */
                                                    this.afterSearch?? () {}
                                                );
                                    }
                                ),
                                Divider (),
                                Padding (
                                    padding: const EdgeInsets.only (bottom: 10.0),
                                    child: Text (
                                        "Versión v%s".fill ([main.APP_VERSION]),
                                        style: Theme.of (ctx).textTheme.caption
                                    )
                                )
                            ]
                        )
                    )
                )
            ]
        )
    );


}
