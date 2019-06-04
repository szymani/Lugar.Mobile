import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' show get;
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
      home: MyHomePage(title: 'Report New Incident'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
    var result = await get('http://10.160.41.211:5000/api/reports/add?' +
    'ImageUrl=' + 'Filip' + 
    '&Description=' + description_text +
    '&Longtitude=' + userLocation["latitude"].toString() + 
    '&Latitude=' + userLocation["longitude"].toString() + 
    '&Category=' + 'no');
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
              userLocation == null
                ? CircularProgressIndicator()
                : Text("Location:" +
                    userLocation["longitude"].toString() +
                    " " +
                    userLocation["latitude"].toString()
                ),
           Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              maxLength: 100,
              minLines: 4,
              maxLines: 5,           
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
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.display1,
            // ),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                onPressed: () {
                  _getLocation().then((value) {
                    setState(() {
                      userLocation = value;
                    });
                  });
                  //fetchData();
                  FocusScope.of(context).detach();
                },
                color: Colors.red,
                child: Text("Send Report", style: TextStyle(color: Colors.white),),
              ),
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Send Report',
      //   child: Text(
      //         'Send',
      //       ),
      //), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
