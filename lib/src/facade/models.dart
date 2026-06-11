import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_location_fluttify/src/android/android.export.g.dart';
import 'package:amap_location_fluttify/src/ios/ios.export.g.dart';

class Location {
  Location({
    required this.address,
    required this.latLng,
    required this.altitude,
    required this.bearing,
    required this.country,
    required this.province,
    required this.city,
    required this.cityCode,
    required this.adCode,
    required this.district,
    required this.poiName,
    required this.street,
    required this.streetNumber,
    required this.aoiName,
    required this.accuracy,
    required this.speed,
  });

  String? address;

  LatLng latLng;

  double? altitude;

  double? bearing;

  String? country;

  String? province;

  String? city;

  String? cityCode;

  String? adCode;

  String? district;

  String? poiName;

  String? street;

  String? streetNumber;

  String? aoiName;

  double? accuracy;

  double? speed;

  @override
  String toString() {
    return 'Location{\naddress: $address, \nlatLng: ${latLng.latitude}, ${latLng.longitude}, \naltitude: $altitude, \nbearing: $bearing, \ncountry: $country, \nprovince: $province, \ncity: $city, \ncityCode: $cityCode, \nadCode: $adCode, \ndistrict: $district, \npoiName: $poiName, \nstreet: $street, \nstreetNumber: $streetNumber, \naoiName: $aoiName, \naccuracy: $accuracy\n}';
  }
}

class BackgroundNotification {
  BackgroundNotification({
    required this.contentTitle,
    required this.contentText,
    this.when,
    required this.channelId,
    required this.channelName,
    this.enableLights = true,
    this.showBadge = true,
  });

  String contentTitle;
  String contentText;
  int? when;
  String channelId;
  String channelName;
  bool? enableLights;
  bool? showBadge;
}

class GeoFenceEvent {
  final String? customId;
  final String? fenceId;
  final GeoFenceStatus status;
  final GeoFence genFence;

  GeoFenceEvent({
    this.customId,
    this.fenceId,
    required this.status,
    required this.genFence,
  });

  @override
  String toString() {
    return 'GeoFenceEvent{customId: $customId, fenceId: $fenceId, status: $status, genFence: $genFence}';
  }
}

class GeoFence {
  final com_amap_api_fence_GeoFence? androidModel;
  final AMapGeoFenceRegion? iosModel;

  GeoFence.android(this.androidModel) : iosModel = null;

  GeoFence.ios(this.iosModel) : androidModel = null;

  Future<String?> get customId async {
    return platform(
      android: (pool) => androidModel!.getCustomId(),
      ios: (pool) => iosModel!.get_customID(),
    );
  }
}
