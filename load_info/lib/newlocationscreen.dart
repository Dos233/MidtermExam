import 'package:flutter/material.dart';
import 'package:loadinfo/mainscreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toast/toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

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
  _LocationScreenState({Key key, this.list, this.index});

  List list;
  int index;
  List<Marker> allmarker = [];
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController gmcontroller;
  MarkerId markerId1 = MarkerId("12");
  Set<Marker> markers = Set();
  double latitude=40.7128;
  double longitude=-74.0060;
  CameraPosition _userpos;
  Position _currentPosition;
  String curaddress;
  double screenHeight, screenWidth;

  @override
  void initState() {
    super.initState();
    setState(() {
      _getLocation();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _launchURL() async {
    String dummy = list[index]['url'];
    var url = 'http://{$dummy}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchPhone() async {
    String dummy = list[index]['contact'];
    var url = 'tel:{$dummy}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  _getLocation() async {
    final Geolocator geolocator = Geolocator()
      ..forceAndroidLocationManager;
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //debugPrint('location: ${_currentPosition.latitude}');
    final coordinates =
    new Coordinates(_currentPosition.latitude, _currentPosition.longitude);
    var addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        print("Good"+'{$addresses}');
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });

    print("${first.featureName} : ${first.addressLine}");
  }

  _loadMapDialog() {
    try {
      if (_currentPosition.latitude == null) {
        Toast.show("Location not available. Please wait...", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _getLocation(); //_getCurrentLocation();
        return;
      }
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 100,
      );

      markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: 'Delivery Location',
          )));

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, newSetState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: Text(
                  "Select New Delivery Location",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                titlePadding: EdgeInsets.all(5),
                //content: Text(curaddress),
                actions: <Widget>[
                  Text(
                    curaddress,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: screenHeight / 2 ?? 600,
                    width: screenWidth ?? 360,
                    child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: _userpos,
                        markers: Set.from(allmarker),
                        onMapCreated: (controller) {
                          _controller.complete(controller);
                        },
                        onTap: (newLatLng) {

                        }),
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    //minWidth: 200,
                    height: 30,
                    child: Text('Close'),
                    color: Color.fromRGBO(101, 255, 218, 50),
                    textColor: Colors.black,
                    elevation: 10,
                    onPressed: () =>
                    {markers.clear(), Navigator.of(context).pop(false)},
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      print(e);
      return;
    }
  }

      @override
      Widget build(BuildContext context) {
        screenHeight = MediaQuery
            .of(context)
            .size
            .height;
        screenWidth = MediaQuery
            .of(context)
            .size
            .width;
        allmarker.add(Marker(
            markerId: MarkerId('myMarker'),
            draggable: false,
            onTap: () {
              print('Marker Tapped');
            },
            position: LatLng(latitude,
                longitude)));
        // TODO: implement build
        if (latitude == null) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primarySwatch: Colors.red,
                primaryColor: Colors.black
            ),
            home: Scaffold(
                appBar: AppBar(
                  title: Text('location List'),
                ),
                body: Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Loading location",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ))),
          );
        }else{
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
                                child: FlatButton(onPressed: () {
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
                                child: FlatButton(onPressed: () {
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
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => MainScreen()));
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
                          onPressed: () {
                            setState(() {
                              _getLocation();
                            });
                            _loadMapDialog();
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
    }