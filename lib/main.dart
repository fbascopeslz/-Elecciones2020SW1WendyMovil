import 'package:flutter/material.dart';
import 'package:proyecto_elecciones_2020/home_page.dart';
import 'package:proyecto_elecciones_2020/login.dart';
import 'package:proyecto_elecciones_2020/reconocimientoTexto.dart';
import 'global.dart';



void main() => runApp(Main());


class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //desactivar la etiquetita modo debug      
      debugShowCheckedModeBanner: false,

      title: NOMBRE_APP,
      home: LoginPage(),
      routes: <String, WidgetBuilder> {
        '/Login': (BuildContext context) => new LoginPage(),
        '/HomePage': (BuildContext context) => new HomePage(),
        '/ReconocimientoTexto': (BuildContext context) => new ReconocimientoTexto(),
        
      }
    );
  }

}//end class


