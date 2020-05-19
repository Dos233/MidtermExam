import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'destination.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InfoPage extends StatefulWidget {
  final Destination destination;

  const InfoPage({Key key, this.destination}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  double screenHeight, screenWidth;
  List<Marker> allMarkers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    allMarkers.add(Marker(
        markerId: MarkerId('myMarker'),
        draggable: false,
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(double.parse(widget.destination.latitude),
            double.parse(widget.destination.longitude))));

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget.destination.locname),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Container(
                  height: screenHeight / 3,
                  width: screenWidth / 1.5,
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl:
                    "http://slumberjer.com/visitmalaysia/images/${widget.destination.imagename}",
                    placeholder: (context, url) =>
                    new CircularProgressIndicator(),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  ),
                ),
                SizedBox(height: 6),
                Container(
                    width: screenWidth / 1.2,
                    //height: screenHeight / 2,
                    child: Card(
                        elevation: 6,
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                Table(
                                    defaultColumnWidth: FlexColumnWidth(1.0),
                                    children: [
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 30,
                                              child: Text("Description",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ))),
                                        ),
                                        TableCell(
                                            child: Container(
                                              height: 220,
                                              child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  height: 200,
                                                  child: Text(
                                                    " " +
                                                        widget.destination
                                                            .description,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                            )),
                                      ]),
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 200,
                                              child: Text("URL",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ))),
                                        ),
                                        TableCell(
                                            child: Column(children: <Widget>[
                                              GestureDetector(
                                                onTap: () => _launchUrlDialog(),
                                                child: Container(
                                                    alignment: Alignment.centerLeft,
                                                    height: 200,
                                                    child: Text(
                                                      " " + widget.destination.url,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    )),
                                              )
                                            ])),
                                      ]),
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 30,
                                              child: Text("Address",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ))),
                                        ),
                                        TableCell(
                                            child: Container(
                                              height: 80,
                                              child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  height: 30,
                                                  child: Text(
                                                    " " +
                                                        widget.destination.address,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                            )),
                                      ]),
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 30,
                                              child: Text("Phone",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ))),
                                        ),
                                        TableCell(
                                            child: Column(children: <Widget>[
                                              GestureDetector(
                                                  onTap: () => _phoneCallDialog(),
                                                  child: Container(
                                                    alignment: Alignment.centerLeft,
                                                    height: 50,
                                                    child: Text(
                                                        " " +
                                                            widget.destination
                                                                .contact,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        )),
                                                  )),
                                            ])),
                                      ]),
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 80,
                                              child: Text("Google Map",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ))),
                                        ),
                                        TableCell(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 100,
                                            child: GoogleMap(
                                              initialCameraPosition:
                                              CameraPosition(
                                                target: LatLng(
                                                    double.parse(widget
                                                        .destination.latitude),
                                                    double.parse(widget
                                                        .destination
                                                        .longitude)),
                                                zoom: 12,
                                              ),
                                              markers: Set.from(allMarkers),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ]),
                                SizedBox(height:3),
                              ],
                            )))),
              ],
            ),
          ),
        ));
  }

  _phoneCallDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: new Text(
            "Phone Call " + '?',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Yes",
                style: TextStyle(
                  color: Color.fromRGBO(101, 255, 218, 50),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
                _phoneCall('tel:' + widget.destination.contact);
              },
            ),
            new FlatButton(
              child: new Text(
                "No",
                style: TextStyle(
                  color: Color.fromRGBO(101, 255, 218, 50),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  _launchUrlDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: new Text(
            "Url link " + '?',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Yes",
                style: TextStyle(
                  color: Color.fromRGBO(101, 255, 218, 50),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
                _lauchUrl('http:' + widget.destination.url);
              },
            ),
            new FlatButton(
              child: new Text(
                "No",
                style: TextStyle(
                  color: Color.fromRGBO(101, 255, 218, 50),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _phoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _lauchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}