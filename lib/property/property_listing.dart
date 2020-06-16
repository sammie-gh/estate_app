import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:estateapp/models/model_propertysell.dart';
import 'package:estateapp/property/property_details.dart';
import 'package:estateapp/property/property_sell.dart';
import 'package:estateapp/utils/method_utils.dart';
import 'package:estateapp/utils/network_utils.dart';
//import 'package:flutter_launch/flutter_launch.dart';
import 'dart:math';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';


class PropertyListing extends StatefulWidget {
  @override
  _PropertyListingState createState() => _PropertyListingState();
}

class _PropertyListingState extends State<PropertyListing> {
  bool isFetching = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<PropertySellModel> propertySellList = [];
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    fetchSellPropertyData();
  }

  void launchWhatsApp({
    @required String phone,
    @required String message,
  }) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
//      throw Toast.show(
//          message: "Could not launch url",
//          duration: Delay.SHORT,
//          textColor: Colors.red);

    }
  }

//  void whatsAppOpen({@required String phone}) async {
//    bool whatsapp = await FlutterLaunch.hasApp(name: "whatsapp");
//
//    if (whatsapp) {
//      await FlutterLaunch.launchWathsApp(
//          phone: phone, message: "Hi, your message");
//      debugPrint("WhatsApp installed");
////      Toast.show(
////          message: "WhatsApp installed",
////          duration: Delay.SHORT,
////          textColor: Colors.lightGreenAccent);
//    } else {
//      debugPrint("WhatsApp is not installed");
////      Toast.show(
////          message: "WhatsApp installed",
////          duration: Delay.SHORT,
////          textColor: Colors.red);
//    }
//  }

  randomValues() {
    var rng = new Random();
    for (var i = 0; i < 10; i++) {
      print(rng.nextInt(100));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Rental Listing"),
      ),
      body: isFetching
          ? Center(child: CircularProgressIndicator())
          : _buildPropertyListWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, PropertySell.routeName);
        },
        heroTag: null,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPropertyListWidget() {
    if (propertySellList == null || propertySellList.length == 0) {
      return Center(
        child: Text(
          "No data found !!!",
          style: TextStyle(fontSize: 20),
        ),
      );
    }
//Listview
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 5.0),
      itemCount: propertySellList.length,
      itemBuilder: (BuildContext context, int index) {
        var sellModel = propertySellList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PropertyDetails(sellModel)));
          },
          child: Card(
            margin: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: Container(
              height: 150,
              child: Row(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          bottomLeft: Radius.circular(5.0)),
                      child: _buildImagewidget(sellModel)),
                  Expanded(
                    child: _buildPropertyInfoWidget(sellModel),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagewidget(PropertySellModel  sellModel) {
    return Hero(
      tag: sellModel.id,
      child: Container(
        height: 120.0,
        width: 120.0,
        child: sellModel.sellImages == null ||
                sellModel.sellImages.length == 0 ||
                sellModel.sellImages[0].isEmpty
            ? placeHolderAssetWidget()
            : fetchImageFromNetworkFileWithPlaceHolder(sellModel.sellImages[0]),
        /*CachedNetworkImage(
                imageUrl: sellModel.sellImages[0],
                placeholder: (context, url) => placeHolderAssetWidget(),
                errorWidget: (context, url, error) => placeHolderAssetWidget(),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.transparent, BlendMode.colorBurn)),
                  ),
                ),
              ),*/
      ),
    );
  }

  //Views
  Widget _buildPropertyInfoWidget(PropertySellModel sellModel) {
    var rng = new Random();
    for (var i = 0; i < 10; i++) {}

    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0),
              child: Text(
                "GH₵ : ${sellModel.sellPrice}",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0),
                child: Text(
                    "${sellModel.sellBedrooms} ${getPropertyTypeById(sellModel.sellType)}")),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0),
              child: Text(sellModel.sellCity),
            ),
            //Ghana post Text
            Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0),
              child: Text(
                  "Ghana Post Address : ${rng.nextInt(10000000).toString()}"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.phone,
                    color: Theme.of(context).primaryColor,
                  ),
//                  Padding(
//                    padding: const EdgeInsets.only(left: 5.0),
//                    child: Text(sellModel.sellContact),
//                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: FlatButton(
                        child: Text(sellModel.sellContact),
                        onPressed: () {
//                          whatsAppOpen(phone: sellModel.sellContact);
                          launchWhatsApp(phone: sellModel.sellContact, message: "Hi Im interested in your apartment");

                          //snack bar
                          final snackBar = SnackBar(
                              content: Text("Opening WhatsApp :" +
                                  sellModel.sellContact));
                          _scaffoldKey.currentState.showSnackBar(snackBar);
//                          debugPrint("Sending....");
                        },
                      )),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 0.0,
          top: 0.0,
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.favorite_border,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  fetchSellPropertyData() async {
    NetworkCheck networkCheck = NetworkCheck();
    networkCheck.checkInternet((isNetworkPresent) async {
      if (!isNetworkPresent) {
        final snackBar = SnackBar(
            content: Text("Please check your internet connection !!!"));

        _scaffoldKey.currentState.showSnackBar(snackBar);
        return;
      } else {
        setState(() {
          isFetching = true;
        });
      }
    });

    try {
      final propertySellReference =
          FirebaseDatabase.instance.reference().child("Property").child("Sell");

      propertySellReference.onValue.listen((Event event) {
        propertySellList = [];
        if (event.snapshot.value != null) {
          print("value: ${event.snapshot}");
          print("value: ${event.snapshot.key}");
          print("value: ${event.snapshot.value}");
          for (var value in event.snapshot.value.values) {
            print("valueData : ${value}");
            propertySellList.add(PropertySellModel.fromJson(value));
          }
        }

        print("propertySellList : ${propertySellList}");
        print("propertySellList : ${propertySellList.length}");
        setState(() {
          isFetching = false;
        });
      });
    } catch (error) {
      print("catch block : " + error.toString());

      setState(() {
        isFetching = false;
      });
    }
  }
}
