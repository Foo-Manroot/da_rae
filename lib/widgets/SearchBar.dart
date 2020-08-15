import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../ScraperSingleton.dart';
import '../i18n.dart';
import '../utils.dart' as utils;


class SearchBar extends StatefulWidget implements PreferredSizeWidget {

    /// Constructor
    ///
    /// El parámetro [afterSearch] es una función a la que llamar cuando se vuelva
    /// de [Definition].
    SearchBar ({Key key, this.bottom, this.afterSearch })
        /* https://github.com/flutter/flutter/blob/e2610a450c5c4aa41db01dae5dc0f4be6cd53aff/packages/flutter/lib/src/material/app_bar.dart#L206 */
        : this.preferredSize = Size.fromHeight (
                kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0)
            ),
            super (key: key)
    ;

    final PreferredSizeWidget bottom;

    final Size preferredSize;


    /// Función a ejecutar al volver de [Definition]
    final Function afterSearch;

    final _log = Logger ("SearchBar.dart");

    @override
    _SearchBar createState () => _SearchBar ();
}

///
/// Es necesario hacer un [StatefulWidget] para poder limpiar el estado de
/// [_searchController] en [dispose()].
///
class _SearchBar extends State<SearchBar> {

    final TextEditingController _searchController = TextEditingController ();

    ///
    /// Realiza la petición para obtener la definición del texto introducido.
    ///
    void _search (BuildContext ctx, String text) async {


        if (text != "" ) {

            widget._log.fine ("Searching text '$text'");

            Navigator.of (ctx).pushNamed (
                "/search",
                arguments: await utils.searchDefinition (
                    searchTerm: text.trim ().toLowerCase (),
                    context: ctx
                )
            ).whenComplete (
                widget.afterSearch
            );
            /* Limpia el campo de texto (si hubiera algo) */
            _searchController.clear ();
        }
    }


    @override
    Widget build (BuildContext ctx) {

        List<Widget> actions = [
            IconButton (
                icon: Icon (Icons.search),
                onPressed: () => _search (ctx, _searchController.text),
            ),
        ];


        if (utils.settingsIsEndDrawer ()) {
            actions.add (
                IconButton (
                    icon: Icon (Icons.dehaze),
                    onPressed: () => Scaffold.of (ctx).openEndDrawer ()
                )
            );
        }

        return AppBar (
            title: Container (
                color: Theme.of (ctx).primaryColorLight,
                child: TypeAheadField (
                    textFieldConfiguration: TextFieldConfiguration (
                        decoration: InputDecoration (
                            hintText: "Buscar palabra".i18n,
                            contentPadding: EdgeInsets.all (10),
                        ),
                        controller: _searchController,
                        onSubmitted: (_) => _search (ctx, _searchController.text),
                    ),
                    suggestionsCallback: (s) async =>
                        await ScraperSingleton.instance.obtenerSugerencias (s)
                    ,
                    onSuggestionSelected: (s) => _search (ctx, s),
                    itemBuilder: (ctx, s) => ListTile (title: Text (s)),
                    /* Si no hay nada, mejor no mostrar ninguna lista */
                    noItemsFoundBuilder: (ctx) => null,
                ),
            ),
            actions: actions,
            bottom: this.widget.bottom
        );
    }



    @override
    void dispose () {

        _searchController.dispose ();
        super.dispose ();

        widget._log.info ("Disposed SearchBar widget: ${this.hashCode}");
    }
}

