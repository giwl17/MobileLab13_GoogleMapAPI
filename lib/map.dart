import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Position? userLocation;
  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future _goToRMUTT() async {
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(14.036462698183556, 100.72544090489826), 15));
  }

  Future<void> _openOnGoogleMapApp(double latitude, double longitude) async {
    final Uri _url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    //'https://www.google.com/maps/dir/?api=1&origin=13.7929841,100.636345&destination=13.9880741,100.8068477');

    final bool nativeAppLaunchSucceeded = await launchUrl(
      _url,
      mode: LaunchMode.externalNonBrowserApplication,
    );
    if (!nativeAppLaunchSucceeded) {
      await launchUrl(
        _url,
        mode: LaunchMode.externalNonBrowserApplication,
      );
    }
  }

  Future<Position> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    userLocation = await Geolocator.getCurrentPosition();
    return userLocation!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Google Maps'),
        actions: [
          IconButton(
            onPressed: _goToRMUTT,
            icon: const Icon(Icons.maps_home_work_outlined),
          )
        ],
      ),
      body: FutureBuilder(
        future: _getLocation(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return GoogleMap(
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                  target:
                      LatLng(userLocation!.latitude, userLocation!.longitude),
                  zoom: 15),
              markers: {
                Marker(
                    markerId: MarkerId('1'),
                    position: LatLng(14.036462698183556, 100.72544090489826),
                    infoWindow: InfoWindow(
                        title: 'ภาควิชาวิศวกรรมคอมพิวเตอร์',
                        snippet: 'ภาควิชาวิศวกรรมคอมพิวเตอร์ มทร.ธัญบุรี'),
                    onTap: () => _openOnGoogleMapApp(
                        14.036462698183556, 100.72544090489826))
              },
              polylines: {
                Polyline(
                    polylineId: PolylineId("p1"),
                    color: Colors.red,
                    points: const [
                      LatLng(14.039618, 100.731428),
                      LatLng(14.031242, 100.731834),
                      LatLng(14.031383, 100.721086),
                      LatLng(14.040377, 100.721125),
                      LatLng(14.039618, 100.731428),
                    ]),
              },
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          mapController?.animateCamera(CameraUpdate.newLatLngZoom(
              LatLng(userLocation!.latitude, userLocation!.longitude), 18));
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                    'Your location has been send !\nlat: ${userLocation!.latitude} long: ${userLocation!.longitude} '),
              );
            },
          );
        },
        label: Text("Send Location"),
        icon: Icon(Icons.near_me),
      ),
    );
  }
}
