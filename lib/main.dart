import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:image/image.dart' as img;

String globalpath = "";

Future<void> main() async {
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras
  final firstCamera = cameras.first;

  runApp(
    MyApp(firstCamera: firstCamera),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final CameraDescription firstCamera;
  MyApp({Key key, this.firstCamera,}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lugar Mobile',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Report New Incident', camera: firstCamera,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;
  MyHomePage({Key key, this.title, this.camera,}) : super(key: key);
  final String title;
  
  @override
  _MyHomePageState createState() => _MyHomePageState(camera: camera);
}

class _MyHomePageState extends State<MyHomePage> {
  final CameraDescription camera;
  _MyHomePageState({Key key,this.camera,});

  int _counter = 0;
  String loc = "";
  var location = new Location();
  Map<String, double> userLocation;
  String description_text = "...";

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
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

    img.Image bigImage = img.decodeImage(new Io.File(globalpath).readAsBytesSync());
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
                  globalpath==""
                  ? Text(
                    'Provide photo (Optional)',
                  )
                  : Image.file(                
                    File(globalpath),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TakePictureScreen(camera: camera)),
                  );
                },
                color: Colors.red,
                child: Text("Take a photo", style: TextStyle(color: Colors.white),),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _getLocation().then((value) {
              setState(() {
                userLocation = value;
              });
            });
          _showDialog();

            //fetchData();
            FocusScope.of(context).detach();
        } ,
        tooltip: 'Add Photo',
        child: Text(
              'Send',
            ),
      ), 
    );
  }
}



// A screen that allows users to take a picture using a given camera
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // In order to display the current output from the Camera, you need to
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras
      widget.camera,
      // Define the resolution to use
      ResolutionPreset.medium,
    );

    // Next, you need to initialize the controller. This returns a Future
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Make sure to dispose of the controller when the Widget is disposed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until
      // the controller has finished initializing
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure the camera is initialized
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the path
            // package.
            final path = join(
              // In this example, store the picture in the temp directory. Find
              // the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            // Attempt to take a picture and log where it's been saved
            await _controller.takePicture(path);
            globalpath = path;
            // If the picture was taken, display it on a new screen
            Navigator.pop(context);         
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image
      body: Image.file(File(imagePath)),
    );
  }
}