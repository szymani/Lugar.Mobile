import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;


String globalpath = "";

//void main() => runApp(MyApp());

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Report New Incident', camera: firstCamera,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;
  MyHomePage({Key key, this.title, this.camera,}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      
      loc = " asda";
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
    // var result = await get('http://10.160.41.211:5000/api/reports/add?' +
    // 'ImageUrl=' + 'Filip' + 
    // '&Description=' + description_text +
    // '&Longtitude=' + userLocation["latitude"].toString() + 
    // '&Latitude=' + userLocation["longitude"].toString() + 
    // '&Category=' + 'no');

    // var body =  '{ImageData:' + '"Filip"' + 
    // ',Description:' + description_text +
    // ',Longtitude:' + userLocation["latitude"].toString() + 
    // ',Latitude:' + userLocation["longitude"].toString() + 
    // ',Category:' + '"no"}';


    File imageFile = new File(globalpath);
    List<int> imageBytes = imageFile.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    var data =  jsonEncode(
    {
      'ImageData': "Filip",
      'Description': description_text,
      'Longtitude': userLocation["latitude"].toString(),
      'Latitude': userLocation["longitude"].toString(),
      'Category': "no",
      "imageData": base64Image,
    });

    var url = 'http://10.160.41.211:5000/api/reports/add';
    http.post(url,
        headers: {"Content-Type": "application/json"},
        body: data,
    );
    return currentLocation;  
  }

  // void fetchData() async {
  //   var result = await get('http://10.160.41.211:5000/api/reports/add?' +
  //   'ImageUrl=' + 'Daniel' + 
  //   '&Description=' + description_text +
  //   '&Longtitude=' + userLocation["longitude"].toString() + 
  //   '&Latitude=' + userLocation["longitude"].toString() + 
  //   '&Category=' + 'garbagesadasdsad');
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      drawer: Drawer(

      ),
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[   
            

            Container(
              margin:EdgeInsets.all(8.0),
              child: 
                globalpath==""
                ? CircularProgressIndicator()
                : Image.file(
                  
                  File(globalpath),
                  height: 200,
                  width: 150,
                  fit:BoxFit.fill
                )
                ,
                
                
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
            //fetchData();
            FocusScope.of(context).detach();
        } ,
        tooltip: 'Add Photo',
        child: Text(
              'Send',
            ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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