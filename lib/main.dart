import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'camera.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lugar Mobile',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Report New Incident',),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title,}) : super(key: key);
  final String title;
  
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String loc = "";
  var location = new Location();
  Map<String, double> userLocation;
  String description_text = "...";
  String imagePath = "";

  Future<Map<String, double>> _getLocation() async {
    var currentLocation = <String, double>{};
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    userLocation = currentLocation;
    //File imageFile = new File(globalpath);
    // List<int> imageBytes = imageFile.readAsBytesSync();        //working but huge
    // String base64Image = base64Encode(imageBytes);

    img.Image bigImage = img.decodeImage(new Io.File(imagePath).readAsBytesSync());
    img.Image smallImage = img.copyResize(bigImage,height: 120);
    List<int> imageBytes = smallImage.getBytes();   
    String base64Image = base64Encode(imageBytes);

    var data =  jsonEncode(
    {
      'Description': description_text,
      'Longtitude': userLocation["latitude"].toString(),
      'Latitude': userLocation["longitude"].toString(),
      'Category': "ios",
      "imageData": base64Image,
    });
    var url = 'http://10.160.41.211:5000/api/reports/add';
    http.post(url,
        headers: {"Content-Type": "application/json"},
        body: data,
    ); 
    return currentLocation;  
  }

  void _showDialog()
  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Sending complete"),
            content: new Text("Thank you for your cooperation"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
    );
  }

  Future<void> makePhoto() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    imagePath = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text("Start"),
              trailing: Icon(Icons.arrow_forward),
              onTap: ()
              {
                Navigator.of(context).pop();
              }
            ),
            ListTile(
              title: Text("History"),
              trailing: Icon(Icons.arrow_forward),
            ),
            ListTile(
              title: Text("Incident map"),
              trailing: Icon(Icons.arrow_forward),
            ),
            ListTile(
              title: Text("Settings"),
              trailing: Icon(Icons.arrow_forward),
            ),
            ListTile(
              title: Text("Your Account"),
              trailing: Icon(Icons.arrow_forward),
            ),
            ListTile(
              title: Text("About"),
              trailing: Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[   
            Flexible(
              child: Container(
                margin:EdgeInsets.all(8.0),
                child: 
                  imagePath==""
                  ? Text(
                    'Provide photo (Optional)',
                  )
                  : Image.file(                
                    File(imagePath),
                    fit:BoxFit.fill
                  ),           
              ), 
            ),
           
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                maxLength: 100,
                minLines: 3,
                maxLines: 3,           
                onChanged: (text) {
                  setState(() {
                    description_text = text;
                  });
                },
                decoration: InputDecoration(
                  helperText: "Description",
                  border: OutlineInputBorder(),             
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                onPressed: () {
                  makePhoto();
                },
                color: Colors.red,
                child: Text("Take a photo", style: TextStyle(color: Colors.white),),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Photo',
        child: Text(
              'Send',
        ),
        onPressed: (){
          _getLocation().then((value) {
              setState(() {
                userLocation = value;
              });
            });
          _showDialog();
          FocusScope.of(context).detach();
        },
      ), 
    );
  }
}

