import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rae_scraper/rae_scraper.dart';

class StoredDefinition {

    final String searchTerm;
    final String resultJson;

    /// Constructor
    StoredDefinition (
        {@required this.searchTerm,
        @required Resultado result }
    ): resultJson = jsonEncode (result.toJson ());

    /// Constructor a partir de un resultado en formato JSON
    StoredDefinition.fromMap ({ @required this.searchTerm, @required this.resultJson });

    /// Crea un [Resultado] a partir de la cadena que había guardada en la BDD.
    Resultado toResult () => Resultado.fromJson (jsonDecode (resultJson));


    /// Convierte este objeto en un [Map] para poder guardarlo en la BDD.
    Map<String, String> toMap () => {
        "searchTerm": searchTerm,
        "resultJson": resultJson
    };
}
