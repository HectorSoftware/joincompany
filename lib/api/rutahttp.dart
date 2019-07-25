import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:joincompany/main.dart';
import 'dart:convert';
import 'package:joincompany/models/DirectionModel.dart';
import 'package:joincompany/models/DirectionSModel.dart';

class GoogleMapsServices{
  Future<String> getRouteCoordinates(LatLng l1, LatLng l2, String apikey)async{
    try{
      String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$apikey";
      http.Response response = await http.get(url);
      Map values = jsonDecode(response.body);

      return values["routes"][0]["overview_polyline"]["points"];
    }catch(error, stackTrace) {
      await sentryA.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      await sentryH.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      return "";
    }
  }
}

class GoogleMapsSearchPlace{
  Future<DirectionsModel> getSearchPlace(LatLng l1, String apikey,String valor)async{
    try{
      String url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$valor&inputtype=textquery&fields=id,formatted_address,name,geometry&locationbias=circle:10000@${l1.latitude},${l1.longitude}&key=$apikey';
      http.Response response = await http.get(url);
      DirectionsModel directions = new DirectionsModel();
      DirectionModel direction = new DirectionModel();
      directions = DirectionsModel.fromJson(response.body);
      return directions;
    }catch(error, stackTrace) {
      await sentryA.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      await sentryH.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}