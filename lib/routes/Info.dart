import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../i18n.dart';
import '../utils.dart' as utils;
import '../widgets/DrawerContent.dart';

class Info extends StatelessWidget {


    /// Crea uno de los elementos que se mostrarán en la lista con la información de una
    /// biblioteca.
    ///
    /// Como título se usará [name] y como subtítulo se pondrá la información, [info]
    Widget _createLibItem (String name, String info, { Widget logo }) => Card (
        margin: const EdgeInsets.all (10.0),
        child: Padding (
            padding: const EdgeInsets.all (5.0),
            child: ListTile (
                dense: false,
                leading: SizedBox(width: 60, height: 60, child: logo),
                title: Text (name),
                subtitle: SelectableText (info)
            )
        )
    );

    @override
    Widget build (BuildContext ctx) => Scaffold (
        appBar: AppBar (
            title: Text ("Información de la aplicación".i18n)
        ),
        /* Se usa drawer o endDrawer en función de la configuración */
        drawer: utils.settingsIsEndDrawer ()? null : DrawerContent (),
        endDrawer: utils.settingsIsEndDrawer ()? DrawerContent () : null,
        body: Container (
            child: Center (
                child: ListView (
                    children: <Widget>[
                        _createLibItem (
                            "Alojado en Github".i18n,
                            "Esta aplicación es de código abierto y cualquiera es libre de contribuir. Todo apoyo es bienvenido 😊\n\nEl repositorio está alojado en ".i18n
                                + "https://github.com/Foo-Manroot/da_rae",
                            logo: SvgPicture.asset ("resources/lib_icons/octocat.svg")
                        ),
                        _createLibItem (
                            "Flutter",
                            "Framework para el desarrollo de aplicaciones Android e iOS usando el lenguaje Dart.\n\nMás info en ".i18n
                                + "https://flutter.dev/",
                            logo: FlutterLogo ()
                        ),
                        Divider (),
                        ListTile (
                            title: Text ("Estas son las bibliotecas de código abierto usadas por esta aplicación:".i18n)
                        ),
                        Divider (),
                        _createLibItem (
                            "rae_scraper",
                            "Biblioteca para obtener toda la información necesaria del diccionario de la RAE".i18n
                                + "\n\nhttps://github.com/Foo-Manroot/rae_scraper",
                            logo: CircleAvatar (
                                backgroundImage: AssetImage ("resources/lib_icons/red_flag.jpg")
                            )
                        ),
                        _createLibItem (
                            "i18n_extension",
                            "Paquete para traducir el texto de la aplicación de manera sencilla".i18n
                            + "\n\nhttps://pub.dev/packages/i18n_extension",
                            logo: SvgPicture.asset ("resources/lib_icons/pub-dev-logo.svg")
                        ),
                        _createLibItem (
                            "sqflite / path",
                            "Paquetes para almacenar las palabras guardadas y el historial en una BDD SQLite".i18n
                            + "\n\nhttps://pub.dev/packages/sqflite\nhttps://pub.dev/packages/path",
                            logo: SvgPicture.asset ("resources/lib_icons/pub-dev-logo.svg")
                        ),
                        _createLibItem (
                            "logging",
                            "Permite configurar los mensajes que se registran en el sistema (errores, avisos...)".i18n
                            + "\n\nhttps://pub.dev/packages/logging",
                            logo: SvgPicture.asset ("resources/lib_icons/pub-dev-logo.svg")
                        ),
                        _createLibItem (
                            "flutter_typeahead",
                            "Ayuda a una implementación sencilla del autocompletado en el campo de búsqueda, mostrando las sugerencias de palabras del diccionario".i18n
                            + "\n\nhttps://pub.dev/packages/flutter_typeahead",
                            logo: SvgPicture.asset ("resources/lib_icons/pub-dev-logo.svg")
                        ),
                        _createLibItem (
                            "preferences",
                            "Paquete para crear una página de configuración y guardarla de manera rápida y sencilla".i18n
                            + "\n\nhttps://pub.dev/packages/preferences",
                            logo: SvgPicture.asset ("resources/lib_icons/pub-dev-logo.svg")
                        ),
                        _createLibItem (
                            "flutter_svg",
                            "Este paquete permite mostrar los recursos SVG como los símbolos que hay en esta lista a la izquierda 😉".i18n
                            + "\n\nhttps://pub.dev/packages/flutter_svg",
                            logo: SvgPicture.asset ("resources/lib_icons/pub-dev-logo.svg")
                        ),
                    ]
                )
            )
        )
    );
}
