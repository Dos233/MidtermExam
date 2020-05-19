import 'dart:convert';
import 'package:loadinfo/newlocationscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  List infolist;
  List list=List();
  int counts=0;
  String selectedType="Kedah";
  double screenHeight, screenWidth;


  List<String> listType = [
    "Malaysia-Johor",
    "Kedah",
    "Kelantan",
    "Perak",
    "Selangor",
    "Melaka",
    "Negeri Sembilan",
    "Pahang",
    "Perlis",
    "Penang",
    "Sabah",
    "Sarawak",
    "Terengganu",
  ];


  void _loadData ({String value}) async{
    String urlLoadJobs = "http://slumberjer.com/visitmalaysia/load_destinations.php";
    http.post(urlLoadJobs, body: {}).then((res) {
      setState(() {
        var extractdata = json.decode(res.body);
        infolist = extractdata["locations"];
        loadPref();
      });
    }).catchError((err) {
      print(err);
    });
  }
  Future<void> savePref() async{
    final SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.setString('selectedType',selectedType);
  }
  Future<void> loadPref() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    print(prefs.getString('selectedType'));
    this.selectedType=prefs.getString('selectedType');
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    loadPref();
    // TODO: implement build
    if (infolist == null) {
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
      loadPref();
      for(int i=0;i<infolist.length;i++){
        if (infolist[i]['state']==selectedType) {
          list.add(infolist[i]);
        }
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.red,
            primaryColor: Colors.black
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text("Location Info"),
            actions: <Widget>[
              DropdownButton(
                hint: Text("Type"),
                icon: Icon(Icons.keyboard_arrow_down),
                iconSize: 26,
                elevation: 16,
                style: TextStyle(color: Colors.white),
                value: selectedType,
                items: listType.map((value){
                  return DropdownMenuItem(
                    child: new Text(
                      value,
                      style: TextStyle(
                        color: Color.fromRGBO(101, 255, 218, 50),
                      ),
                    ),
                    value: value,
                  );
                }).toList(),
                onChanged: (newValue){
                  setState(()  {
                    selectedType = newValue;
                    savePref();
                    list.clear();
                  });
                },
              )
            ],
          ),
          body: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
            Flexible(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                  children: List.generate(list.length,(index){
                    return Card(
                      color: Colors.brown,
                      elevation: 10,
                      child: Padding(
                        padding:EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (BuildContext context)=>LocationScreen(list: list,index: index,))
                                );
                              },
                              child: Container(
                                height: screenWidth / 4.5,
                                width: screenWidth / 4.5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                  Border.all(color: Colors.black),
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                      image: NetworkImage(
                                          "http://slumberjer.com/visitmalaysia/images/${list[index]['imagename']}"
                                      ),
                                  )
                                ),
                              ),
                            ),
                            Text(list[index]['loc_name'],
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text(list[index]['state'],
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }),
                )
            )
            ],
          ),
        ),
      );
    }
  }
}