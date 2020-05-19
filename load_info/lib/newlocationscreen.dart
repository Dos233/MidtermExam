import 'package:flutter/material.dart';
import 'package:loadinfo/mainscreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toast/toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';


class LocationScreen extends StatefulWidget {
  LocationScreen({Key key,this.list,this.index}) : super(key: key);
  int index;
  List list;

  @override
  _LocationScreenState createState() {
    return _LocationScreenState(list: list,index: index);
  }
}

class _LocationScreenState extends State<LocationScreen> {
  _LocationScreenState({Key key,this.list,this.index});
    List list;
    int index;
  Position _currentPosition;
  String curaddress;
  String curstate;
  double latitude, longitude;
  double screenHeight, screenWidth;
  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }
  _openGooglemap(int index) async {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Text(
          "Use the Googlemap application to open the recipient's location?",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          MaterialButton(
              onPressed: () async {
                Navigator.of(context).pop(false);
                String clatitude = latitude.toString();
                String clongitude = longitude.toString();
                String googleUrl =
                    'https://www.google.com/maps/search/?api=1&query=$clatitude,$clongitude';
                if (await canLaunch(googleUrl)) {
                  await launch(googleUrl);
                } else {
                  throw 'Could not open the map.';
                }
              },
              child: Text(
                "yes",
                style: TextStyle(
                  color: Color.fromRGBO(101, 255, 218, 50),
                ),
              )),
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                "No",
                style: TextStyle(
                  color: Color.fromRGBO(101, 255, 218, 50),
                ),
              )),
        ],
      ),
    );
  }

  _getLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    _currentPosition = await geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .timeout(Duration(seconds: 15), onTimeout: () {
      Toast.show("Can't detect your location", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    });
    final coordinates =
    new Coordinates(_currentPosition.latitude, _currentPosition.longitude);
    var addresses = await Geocoder.local
        .findAddressesFromCoordinates(coordinates)
        .timeout(Duration(seconds: 15), onTimeout: () {
      Toast.show("Can't find your address", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    });
    var first = addresses.first;
    setState(() {
      curaddress = first.locality;
      curstate = first.adminArea;
      print(curstate);
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });

    print("${first.featureName} : ${first.addressLine}");
  }

  _launchURL() async{
    String dummy=list[index]['url'];
    var url = 'http://{$dummy}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  _launchPhone() async {
    String dummy=list[index]['contact'];
    var url = 'tel:{$dummy}';
    
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.red,
          primaryColor: Colors.black
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("Location Info Page"),),
        body: Card(
          elevation: 10,
          child: Column(
            children: <Widget>[
              Container(
                  height: screenWidth / 1.7,
                  width: screenWidth / 1.5,
                  decoration: BoxDecoration(
                    //border: Border.all(color: Colors.black),
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                              "http://slumberjer.com/visitmalaysia/images/${list[index]['imagename']}")))),
              Table(
                defaultColumnWidth: FlexColumnWidth(1.0),
                border: TableBorder.all(color: Colors.black),
                children: [
                  TableRow(children: [
                    TableCell(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 40,
                        child: Text("Description",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                      ),
                    ),
                    TableCell(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 30,
                        child: Text("url",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                      ),
                    ),
                    TableCell(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 40,
                        child: Text("address",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                      ),
                    ),
                    TableCell(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 30,
                        child: Text("phone",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                      ),
                    )
                  ]
                  ),
                  TableRow(children: [
                    TableCell(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 180,
                        child: Text(list[index]['description'],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                            )),
                      ),
                    ),
                    TableCell(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 180,
                        child: FlatButton(onPressed: (){
                          _launchURL();
                        }, child: Text(list[index]['url'],
                            style: TextStyle(
                              color: Colors.black,
                            )),)
                      ),
                    ),
                    TableCell(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 180,
                        child: Text(list[index]['address'],
                            style: TextStyle(
                              color: Colors.black,
                            )),
                      ),
                    ),
                    TableCell(
                      child: Container(
                          alignment: Alignment.centerLeft,
                          height: 180,
                          child: FlatButton(onPressed: (){
                            _launchPhone();
                          }, child: Text(list[index]['contact'],
                              style: TextStyle(
                                color: Colors.black,
                              )),)
                      ),
                    )
                  ]
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    minWidth: 110,
                    height: 50,
                    child: Text('Back'),
                    color: Colors.black,
                    textColor: Colors.white,
                    elevation: 10,
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>MainScreen()));
                    },
                  ),
                  SizedBox(width: 20,),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    minWidth: 110,
                    height: 50,
                    child: Text('Open Map'),
                    color: Colors.black,
                    textColor: Colors.white,
                    elevation: 10,
                    onPressed: (){
                      _openGooglemap(index);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}