import 'package:flutter/material.dart';
import 'CustomerModel.dart';

enum status{
  cliente,
  planificado,
  culminada
}

class Place {
  const Place({
    @required this.id,
    @required this.customer,
    @required this.address,
    @required this.latitude,
    @required this.longitude,
    @required this.statusTask,
    @required this.customerAddress,
  })  : assert(id != null),
        assert(customer != null),
        assert(address != null),
        assert(latitude != null),
        assert(longitude != null),
        assert(statusTask != null);

  final int id;
  final String address;
  final String customer;
  final double latitude;
  final double longitude;
  final status statusTask;
  final CustomerWithAddressModel customerAddress;

  Place copyWith({
    int id,
    String address,
    String customer,
    double latitude,
    double longitude,
    status t, //0 : azul / 1 : rojo / 2 : verde
    CustomerWithAddressModel customerAddress,
  }) {
    return Place(
      id: id ?? this.id,
      address: address ?? this.address,
      customer: customer ?? this.customer,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      statusTask: t ?? this.statusTask,
      customerAddress: customerAddress ?? this.customerAddress,
    );
  }
}