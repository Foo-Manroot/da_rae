import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

    static var _t = Translations ("es") +
        {
            "es": "Diccionario de la RAE",
            "en": "Spanish dictionary",
        }
        +
        {
            "es": "Buscar palabra",
            "en": "Search word",
        }
        +
        {
            "es": "Palabra del día",
            "en": "Word of the day",
        }
        +
        {
            "es": "Definición",
            "en": "Definition",
        }
        +
        {
            "es": "Volver al inicio",
            "en": "Back to home"
        }
        +
        {
            "es": "Buscar definición de '%s'",
            "en": "Search definition of '%s'"
        }
        +
        {
            "es": "Buscar expresión '%s'",
            "en": "Search expression '%s'"
        }
        +
        {
            "es": "Cerrar",
            "en": "Close"
        }
        +
        {
            "es": "Buscando...",
            "en": "Searching..."
        }
        +
        {
            "es": "Mostrar opciones",
            "en": "Show options"
        }
        +
        {
            "es": "Añadir a 'palabras guardadas'",
            "en": "Add to 'saved words'"
        }
        +
        {
            "es": "Quitar de 'palabras guardadas'",
            "en": "Remove from 'saved words'"
        }
        +
        {
            "es": "Error: %s",
            "en": "Error: %s"
        }
        +
        {
            "es": "No se pudo obtener la definición",
            "en": "Couldn't load the definition of the word"
        }
        +
        {
            "es": "Palabra no encontrada :(",
            "en": "Word not found :("
        }
        +
        {
            "es": "Puedes informar de este error enviando una captura de pantalla al equipo de desarrollo.",
            "en": "You can report this error sending a screenshot to the development team."
        }
        +
        {
           "es": "Menú",
           "en": "Menu"
        }
        +
        {
           "es": "Configuración",
           "en": "Settings"
        }
        +
        {
           "es": "Versión v%s",
           "en": "Version v%s"
        }
        +
        {
            "es": "Información de la aplicación",
            "en": "Info about the app"
        }
        +
        {
            "es": "Error. No se pudo borrar la entrada.",
            "en": "Error. Couldn't delete the entry."
        }
        +
        {
            "es": "Entrada borrada con éxito.",
            "en": "Entry deleted successfully"
        }
        +
        {
            "es": "Deshacer",
            "en": "Undo"
        }
        +
        {
            "es": "Ver definición",
            "en": "See definition"
        }
        +
        {
            "es": "Eliminar",
            "en": "Delete"
        }
        +
        {
            "es": "Error al realizar la petición",
            "en": "Error requesting that data"
        }
        +
        {
            "es": "Aceptar",
            "en": "Accept"
        }
        +
        {
            "es": "Inicio",
            "en": "Home"
        }
        +
        {
            "es": "Palabras guardadas",
            "en": "Saved words"
        }
        +
        {
            "es": "Cargando...",
            "en": "Loading..."
        }
        +
        {
            "es": "Historial de búsquedas",
            "en": "Search history"
        }
        +
        {
            "es": "Tamaño máximo del historial",
            "en": "Max history size"
        }
        +
        {
            "es": "Tamaño máximo de la caché",
            "en": "Max cache size"
        }
        +
        {
            "es": "Límites",
            "en": "Limits"
        }
        +
        {
            "es": "General",
            "en": "General"
        }
        +
        {
            "es": "Tema",
            "en": "Theme"
        }
        +
        {
            "es": "Idioma",
            "en": "Language"
        }
        +
        {
            "es": "Menú desplegable a la derecha",
            "en": "Drawer menu on the right"
        }
        +
        {
            "es": "Reinicia la aplicación para que se cargue el nuevo tema",
            "en": "Reboot the app so the new theme gets applied"
        }
        +
        {
            "es": "Estas son las bibliotecas de código abierto usadas por esta aplicación",
            "en": "These are the open-source libraries used by this application"
        }
        +
        {
            "es": "Alojado en Github",
            "en": "Hosted in Github"
        }
        +
        {
            "es": "Esta aplicación es de código abierto y cualquiera es libre de contribuir. Todo apoyo es bienvenido 😊\n\nEl repositorio está alojado en ",
            "en": "This application is open-source and anybody is free to contribute. Any help is welcomed 😊\n\nThe repository is hosted in "
        }
        +
        {
            "es": "Framework para el desarrollo de aplicaciones Android e iOS usando el lenguaje Dart.\n\nMás info en ",
            "en": "Framework to develop Android and iOS applications using the Dart language.\n\nMore info in "
        }
        +
        {
            "es": "Estas son las bibliotecas de código abierto usadas por esta aplicación:",
            "en": "These are the open-source libraries used by this application:"
        }
        +
        {
            "es": "Biblioteca para obtener toda la información necesaria del diccionario de la RAE",
            "en": "Library to obtain all the needed information from the RAE dictionary"
        }
        +
        {
            "es": "Paquete para traducir el texto de la aplicación de manera sencilla",
            "en": "Package to easily translate the application's text"
        }
        +
        {
            "es": "Paquetes para almacenar las palabras guardadas y el historial en una BDD SQLite",
            "en": "Packages to store saved words and history in a SQLite DB"
        }
        +
        {
            "es": "Permite configurar los mensajes que se registran en el sistema (errores, avisos...)",
            "en": "Allows to configure the messages that get logged in the system (errors, warnings...)"
        }
        +
        {
            "es": "Ayuda a una implementación sencilla del autocompletado en el campo de búsqueda, mostrando las sugerencias de palabras del diccionario",
            "en": "Helps with the implementation of the autocompletion on the search field, showing suggestions from the dictionary"
        }
        +
        {
            "es": "Paquete para crear una página de configuración y guardarla de manera rápida y sencilla",
            "en": "Package to create a settings page and to easily and quickly save the config"
        }
        +
        {
            "es": "Este paquete permite mostrar los recursos SVG como los símbolos que hay en esta lista a la izquierda 😉",
            "en": "This package shows SVG resources, like the symbols at the left on this list 😉"
        }
        +
        {
            "es": "Nivel de detalle en el log",
            "en": "Log level"
        }
        +
        {
           "es": "Conjugación del verbo '%s'",
           "en": "Verb conjugation of '%s'"
        }
        +
        {
            "es": "Formas no personales",
            "en": "Non-personal verb forms"
        }
    ;

    String get i18n => localize (this, _t);
    String plural (int value) => localizePlural (value, this, _t);
    String fill (List<Object> params) => localizeFill (this, params);
    String capitalize () =>
            (this.isEmpty)? this : this[0].toUpperCase () + this.substring (1);

}

