import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'CustomerModel.dart';

class Place {
  const Place({
    @required this.id,
    @required this.customer,
    @required this.address,
    @required this.latitude,
    @required this.longitude,
    @required this.status,
    @required this.CustomerAddress,
  })  : assert(id != null),
        assert(customer != null),
        assert(address != null),
        assert(latitude != null),
        assert(longitude != null),
        assert(status != null);

  final int id;
  final String address;
  final String customer;
  final double latitude;
  final double longitude;
  final int status;
  final CustomerWithAddressModel CustomerAddress;

  Place copyWith({
    int id,
    String address,
    String customer,
    double latitude,
    double longitude,
    int status, //0 : azul / 1 : rojo / 2 : verde
    CustomerWithAddressModel CustomerAddress,
  }) {
    return Place(
      id: id ?? this.id,
      address: address ?? this.address,
      customer: customer ?? this.customer,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      CustomerAddress: CustomerAddress ?? this.CustomerAddress,
    );
  }
}