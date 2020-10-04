import 'package:flutter/material.dart';

import 'global.dart';
import 'package:http/http.dart' as http;
import "package:fluttertoast/fluttertoast.dart";
import 'package:barcode_scan/platform_wrapper.dart';
import 'dart:convert';
import 'dart:async';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String barcode = '';  

  Future _scan() async {    
    var result = await BarcodeScanner.scan();    
    print(result.type); // The result type (barcode, cancelled, failed)
    print(result.rawContent); // The barcode content
    print(result.format); // The barcode format (as enum)
    print(result.formatNote); // If a unknown format was scanned this field contains a note

    if (result != null && result.rawContent != '') {
      barcode = result.rawContent;
      verificarCodigoMesa();
    } else {
      Navigator.pop(context);

      Fluttertoast.showToast(
        msg: "Porfavor vuelva a escanear el codigo de barras",
        toastLength: Toast.LENGTH_SHORT,
      ); 
    }
  }


  Future<void> verificarCodigoMesa() async {    
    final response = await http.post(
      //url del servicio
      URL_VERCODMES,
      //parametros
      body: {
        "codigo": barcode.toString(),
        "idUsuario": globalIdUsuario.toString()
      }
    );

    //Cerrar el CircularProgressDialog
    Navigator.pop(context);
  
    if (response.statusCode == 200) { //200 -> response is succesful     
      var paquete = json.decode(response.body);      

      //error 0 => Ya se envio la imagen, mostrar la imagen
      //error 1 => Error del servidor
      //error 2 => El usuario no es delegado asignado a esa mesa
      //error 3 => Aun no se envio la imagen, mostrar informacion de la mesa

      switch (paquete['error']) {        
        case 0:                    
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Envio de imagen'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(paquete['message']),
                      SizedBox(height: 30),
                      Image.network(paquete['values']["imagen"]),
                      SizedBox(height: 20),
                      Text("HORA: " + paquete['values']["hora"]),
                      SizedBox(height: 5),
                      Text("FECHA: " + paquete['values']["fecha"]),
                      SizedBox(height: 5),
                      Text("TOTAL VOTOS: " + paquete['values']["cantidadVotosTotal"].toString()),
                      SizedBox(height: 5),
                      Text("VOTOS NULOS: " + paquete['values']["votosNulos"].toString()),
                      SizedBox(height: 5),
                      Text("VOTOS BLANCOS: " + paquete['values']["votosBlancos"].toString()),                                        
                    ]
                  ),
                ),

                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();                        
                    },
                    child: Text('ACEPTAR'),
                  ),                                  
                ],
              );
            }
          );          
        break;
          
        case 1:    
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Envio de imagen'),
                content: Text(paquete['message']),
                actions: <Widget>[                    
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();                        
                    },
                    child: Text('ACEPTAR'),
                  )
                ],
              );
            }
          );
          break;

        case 2:                    
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Envio de imagen'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(paquete['message']),
                    SizedBox(height: 30),
                    Text("CODIGO DE MESA ENVIADO: " + barcode.toString()),
                  ],
                ),
                actions: <Widget>[                                      
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();                        
                    },
                    child: Text('ACEPTAR'),
                  )
                ],
              );
            }
          );
        break;

        case 3:        
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Envio de imagen'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(paquete['message']),
                      SizedBox(height: 30),
                      Text("CODIGO MESA: " + paquete['values']["codigo"].toString()),
                      SizedBox(height: 5),
                      Text("DEPARTAMENTO: " + paquete['values']["departamento"]),
                      SizedBox(height: 5),
                      Text("PROVINCIA: " + paquete['values']["provincia"]),
                      SizedBox(height: 5),
                      Text("MUNICIPIO: " + paquete['values']["municipio"]),
                      SizedBox(height: 5),
                      Text("LOCALIDAD: " + paquete['values']["localidad"]),
                      SizedBox(height: 5),
                      Text("RECINTO: " + paquete['values']["recinto"]),                                       
                    ]
                  ),
                ),
                actions: <Widget>[                                      
                  FlatButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/ReconocimientoTexto');                        
                    },
                    child: Text('ACEPTAR'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();                        
                    },
                    child: Text('CANCELAR'),
                  ),                  
                ],
              );
            }
          );          
        break;

        default:
      }      

    } else {
      Fluttertoast.showToast(
        msg: "Fallo al conectar a Internet, porfavor intente de nuevo",
        toastLength: Toast.LENGTH_SHORT,
      );
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: new Text(NOMBRE_APP), backgroundColor: Colors.blue,),
      
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[

            new UserAccountsDrawerHeader(
              accountName: new Text(globalUsuario),              
              accountEmail: new Text(globalEmailUsuario),
                            
              currentAccountPicture: new GestureDetector(
                onTap: null,
                child: new CircleAvatar(
                  backgroundImage: AssetImage("assets/images/avatar.png"), //NetworkImage("https://hdnh.es/wp-content/uploads/2015/01/mono-con-pistola.jpg"),
                ),
              ),
  
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage("https://i.pinimg.com/originals/98/c1/66/98c166d9b25d2e2fc3141cc2f6c55150.jpg")
                )
              ),
            ),


            CustomListTile(
              Icons.add_a_photo, 
              'Enviar Resultados', 
              () async {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return Center(child: CircularProgressIndicator(),);
                  }
                );
                await _scan();
              }
            ),

            /*
            CustomListTile(
              Icons.add_a_photo, 
              'Reconocimiento texto', 
              () => Navigator.pushReplacementNamed(context, '/ReconocimientoTexto')
            ),        
            */  

            CustomListTile(
              Icons.exit_to_app, 
              'Cerrar sesion', 
              () {
                //Cerrar el actual y remplazarla por el Home                      
                Navigator.of(context).popUntil((route) => route.isFirst);                       
                Navigator.pushReplacementNamed(context, '/Login');
              } 
            ),
            

          ],
        ),
      ),
      
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/images/elecciones2020.jpg', width: 300,)
          ],
        ),
        
      ),
      
      
    );
  }
}



class CustomListTile extends StatelessWidget {
  IconData icon;
  String text;
  Function onTap;

  //Constructor
  CustomListTile(
    this.icon,
    this.text,
    this.onTap
  );

  @override
  Widget build(BuildContext context) {    
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),//(8.0, 0, 8.0, 0),    
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade400))
        ),
        child: InkWell(
          splashColor: Colors.blue,
          onTap: this.onTap,
          child: Container(
            height: 65,          
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(this.icon),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(this.text, style: TextStyle(
                        fontSize: 18.0
                      ),),
                    )
                  ],
                ),
                Icon(Icons.arrow_right)
              ],
            ),
          ),           
        ),
      ),
    );
  }

}