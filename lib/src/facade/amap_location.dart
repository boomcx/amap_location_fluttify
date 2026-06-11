// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'dart:io';

import 'package:amap_location_fluttify/src/android/android.export.g.dart';
import 'package:amap_location_fluttify/src/ios/ios.export.g.dart';
import 'package:core_location_fluttify/core_location_fluttify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'enums.dart';
import 'extensions.dart';
import 'models.dart';

part 'delegates.dart';

class AmapLocation with _Holder, _Community, _Pro {
  static AmapLocation instance = AmapLocation._();

  AmapLocation._() {
    initAndroidListener();
  }
}

mixin _Community on _Holder {
  Future<void> init({required String iosKey}) {
    return platform(
      android: (pool) async {
        final context = await android_app_Application.get();

        _androidClient ??= await com_amap_api_location_AMapLocationClient
            .create__android_content_Context(context);
      },
      ios: (pool) async {
        await AmapCore.init(iosKey);
        _iosClient ??= await AMapLocationManager.create__();
      },
    );
  }

  Future<Location> fetchLocation({
    LocationAccuracy mode = LocationAccuracy.Low,
    bool? needAddress,
    Duration? timeout,
  }) async {
    final completer = Completer<Location>();
    return platform(
      android: (pool) async {
        assert(_androidClient != null,
            '请先在main方法中调用AmapLocation.instance.init()进行初始化!');
        if (_androidLocationDelegate == null) {
          _androidLocationDelegate = _AndroidLocationDelegate();
          await _androidClient!.setLocationListener(_androidLocationDelegate);
        }

        _androidLocationDelegate!._onLocationChanged = (location) async {
          if (!completer.isCompleted) {
            completer.complete(Location(
              address: await location.getAddress(),
              latLng: LatLng(
                await location.getLatitude(),
                await location.getLongitude(),
              ),
              altitude: await location.getAltitude(),
              bearing: await location.getBearing(),
              country: await location.getCountry(),
              province: await location.getProvince(),
              city: await location.getCity(),
              cityCode: await location.getCityCode(),
              adCode: await location.getAdCode(),
              district: await location.getDistrict(),
              poiName: await location.getPoiName(),
              street: await location.getStreet(),
              streetNumber: await location.getStreetNum(),
              aoiName: await location.getAoiName(),
              accuracy: await location.getAccuracy(),
              speed: await location.speed,
            ));
          }
        };

        final options =
            await com_amap_api_location_AMapLocationClientOption.create__();
        await options.setOnceLocation(true);
        if (mode != null) {
          switch (mode) {
            case LocationAccuracy.High:
              await options.setLocationMode(
                  com_amap_api_location_AMapLocationClientOption_AMapLocationMode
                      .Hight_Accuracy);
              break;
            case LocationAccuracy.Low:
              await options.setLocationMode(
                  com_amap_api_location_AMapLocationClientOption_AMapLocationMode
                      .Battery_Saving);
              break;
            case LocationAccuracy.DeviceSensor:
              await options.setLocationMode(
                  com_amap_api_location_AMapLocationClientOption_AMapLocationMode
                      .Device_Sensors);
              break;
          }
        }
        if (needAddress != null) await options.setNeedAddress(needAddress);
        if (timeout != null) {
          await options.setHttpTimeOut(timeout.inMilliseconds);
        }

        await options.setSensorEnable(true);

        await _androidClient!.setLocationOption(options);

        await _androidClient!.startLocation();

        return completer.future;
      },
      ios: (pool) async {
        assert(_iosClient != null,
            '请先在main方法中调用AmapLocation.instance.init()进行初始化!');
        if (mode != null) {
          switch (mode) {
            case LocationAccuracy.High:
              await _iosClient!.set_desiredAccuracy(10);
              break;
            case LocationAccuracy.DeviceSensor:
            case LocationAccuracy.Low:
              await _iosClient!.set_desiredAccuracy(100);
              break;
          }
        }
        if (timeout != null) {
          await _iosClient!.set_locationTimeout(timeout.inSeconds);
        }

        await _iosClient!.requestLocationWithReGeocode_completionBlock(
          needAddress ?? true,
          (location, regeocode, error) async {
            if (!completer.isCompleted) {
              completer.complete(Location(
                address: await regeocode?.get_formattedAddress(),
                latLng: LatLng(
                  await location.coordinate.then((it) => it.latitude),
                  await location.coordinate.then((it) => it.longitude),
                ),
                altitude: await location.altitude,
                bearing: await location.course,
                country: await regeocode?.get_country(),
                province: await regeocode?.get_province(),
                city: await regeocode?.get_city(),
                cityCode: await regeocode?.get_citycode(),
                adCode: await regeocode?.get_adcode(),
                district: await regeocode?.get_district(),
                poiName: await regeocode?.get_POIName(),
                street: await regeocode?.get_street(),
                streetNumber: await regeocode?.get_number(),
                aoiName: await regeocode?.get_AOIName(),
                accuracy: await location.horizontalAccuracy,
                speed: await location.speed,
              ));
            }
          },
        );
        return completer.future;
      },
    );
  }

  Stream<Location> listenLocation({
    LocationAccuracy mode = LocationAccuracy.Low,
    bool? needAddress,
    Duration? timeout,
    int? interval,
    double? distanceFilter,
  }) async* {
    _locationController ??= StreamController<Location>();

    if (Platform.isAndroid) {
      assert(_androidClient != null,
          '请先在main方法中调用AmapLocation.instance.init()进行初始化!');
      if (_androidLocationDelegate == null) {
        _androidLocationDelegate = _AndroidLocationDelegate();
        await _androidClient!.setLocationListener(_androidLocationDelegate);
      }
      _androidLocationDelegate!._onLocationChanged = (location) async {
        _locationController!.add(Location(
          address: await location.getAddress(),
          latLng: LatLng(
            await location.getLatitude(),
            await location.getLongitude(),
          ),
          altitude: await location.getAltitude(),
          bearing: await location.getBearing(),
          country: await location.getCountry(),
          province: await location.getProvince(),
          city: await location.getCity(),
          cityCode: await location.getCityCode(),
          adCode: await location.getAdCode(),
          district: await location.getDistrict(),
          poiName: await location.getPoiName(),
          street: await location.getStreet(),
          streetNumber: await location.getStreetNum(),
          aoiName: await location.getAoiName(),
          accuracy: await location.getAccuracy(),
          speed: await location.getSpeed(),
        ));
      };

      final options =
          await com_amap_api_location_AMapLocationClientOption.create__();
      await options.setOnceLocation(false);
      if (mode != null) {
        switch (mode) {
          case LocationAccuracy.High:
            await options.setLocationMode(
                com_amap_api_location_AMapLocationClientOption_AMapLocationMode
                    .Hight_Accuracy);
            break;
          case LocationAccuracy.Low:
            await options.setLocationMode(
                com_amap_api_location_AMapLocationClientOption_AMapLocationMode
                    .Battery_Saving);
            break;
          case LocationAccuracy.DeviceSensor:
            await options.setLocationMode(
                com_amap_api_location_AMapLocationClientOption_AMapLocationMode
                    .Device_Sensors);
            break;
        }
      }
      if (needAddress != null) await options.setNeedAddress(needAddress);
      if (timeout != null) await options.setHttpTimeOut(timeout.inSeconds);
      if (interval != null) await options.setInterval(interval);

      await options.setSensorEnable(true);

      await _androidClient!.setLocationOption(options);

      await _androidClient!.startLocation();

      yield* _locationController!.stream;
    } else if (Platform.isIOS) {
      assert(
          _iosClient != null, '请先在main方法中调用AmapLocation.instance.init()进行初始化!');
      if (mode != null) {
        switch (mode) {
          case LocationAccuracy.High:
            await _iosClient!.set_desiredAccuracy(10);
            break;
          case LocationAccuracy.Low:
          case LocationAccuracy.DeviceSensor:
            await _iosClient!.set_desiredAccuracy(100);
            break;
        }
      }
      if (timeout != null) {
        await _iosClient!.set_locationTimeout(timeout.inSeconds);
      }
      if (distanceFilter != null) {
        await _iosClient!.set_distanceFilter(distanceFilter);
      }

      if (_iosLocationDelegate == null) {
        _iosLocationDelegate = _IOSLocationDelegate();
        await _iosClient!.set_delegate(_iosLocationDelegate);
      }
      _iosLocationDelegate!._onLocationChanged = (location, regeocode) async {
        _locationController!.add(Location(
          address: await regeocode?.get_formattedAddress(),
          latLng: LatLng(
            await location.coordinate.then((it) => it.latitude),
            await location.coordinate.then((it) => it.longitude),
          ),
          altitude: await location.altitude,
          bearing: await location.course,
          country: await regeocode?.get_country(),
          province: await regeocode?.get_province(),
          city: await regeocode?.get_city(),
          cityCode: await regeocode?.get_citycode(),
          adCode: await regeocode?.get_adcode(),
          district: await regeocode?.get_district(),
          poiName: await regeocode?.get_POIName(),
          street: await regeocode?.get_street(),
          streetNumber: await regeocode?.get_number(),
          aoiName: await regeocode?.get_AOIName(),
          accuracy: await location.horizontalAccuracy,
          speed: await location.speed,
        ));
      };

      await _iosClient!.set_locatingWithReGeocode(true);
      await _iosClient!.startUpdatingLocation();

      yield* _locationController!.stream;
    }
  }

  Future<void> stopLocation() {
    return platform(
      android: (pool) async {
        await _locationController?.close();
        _locationController = null;

        _androidLocationDelegate = null;

        await _androidClient?.stopLocation();
      },
      ios: (pool) async {
        await _locationController?.close();
        _locationController = null;

        _iosLocationDelegate = null;

        await _iosClient?.stopUpdatingLocation();
      },
    );
  }

  @Deprecated('此方法与直接使用权限请求插件请求定位权限的效果一样')
  Future<void> requireAlwaysAuth() {
    return platform(
      android: (pool) async {},
      ios: (pool) async {
        assert(_iosClient != null, '请先在main方法中调用AmapLocation.init()进行初始化!');
        final onRequireAuth = (manager) async {
          await manager?.requestAlwaysAuthorization();
        };
        await _iosClient!.set_delegate(
          _iosLocationDelegate!.._onRequireAlwaysAuth = onRequireAuth,
        );
      },
    );
  }

  Future<void> enableBackgroundLocation(
    int id,
    BackgroundNotification bgNotification,
  ) {
    return platform(
      android: (pool) async {
        final notification = await android_app_Notification.create(
          contentTitle: bgNotification.contentTitle,
          contentText: bgNotification.contentText,
          when: bgNotification.when,
          channelId: bgNotification.channelId,
          channelName: bgNotification.channelName,
          enableLights: bgNotification.enableLights ?? true,
          showBadge: bgNotification.showBadge ?? true,
        );
        await checkClient();
        await _androidClient?.enableBackgroundLocation(id, notification);
        pool..add(notification);
      },
      ios: (pool) async {
        await _iosClient!.set_allowsBackgroundLocationUpdates(true);
        await _iosClient!.set_pausesLocationUpdatesAutomatically(false);
      },
    );
  }

  Future<void> disableBackgroundLocation(bool var1) {
    return platform(
      android: (pool) async {
        await checkClient();
        await _androidClient?.disableBackgroundLocation(var1);
      },
      ios: (pool) async {
        await _iosClient!.set_allowsBackgroundLocationUpdates(false);
        await _iosClient!.set_pausesLocationUpdatesAutomatically(true);
      },
    );
  }

  Future<void> checkClient() async {
    if (Platform.isAndroid) {
      final context = await android_app_Application.get();

      _androidClient ??= await com_amap_api_location_AMapLocationClient
          .create__android_content_Context(context);
    } else if (Platform.isIOS) {
      _iosClient ??= await AMapLocationManager.create__();
    }
  }

  Future<void> dispose() async {
    await _locationController?.close();
    _locationController = null;

    await _geoFenceEventController?.close();
    _geoFenceEventController = null;

    _androidLocationDelegate = null;
    _iosLocationDelegate = null;

    if (Platform.isAndroid) {
      await MethodChannel(
        'me.yohom/amap_location_fluttify',
        kAmapLocationFluttifyMethodCodec,
      ).invokeMethod(
          'com.amap.api.fence.GeoFenceClient::unregisterBroadcastReceiver');
    }

    if (_androidClient != null) {
      await _androidClient!.onDestroy();
      await _androidClient!.release__();
    }
    if (_iosClient != null) await _iosClient!.release__();

    final isCurrentPlugin = (Ref it) => it.tag__ == 'amap_location_fluttify';
    await gGlobalReleasePool.where(isCurrentPlugin).release_batch();
    gGlobalReleasePool.removeWhere(isCurrentPlugin);

    _androidClient = null;
    _iosClient = null;
  }
}

mixin _Pro on _Holder {
  void initAndroidListener() {
    if (Platform.isAndroid) {
      MethodChannel(
        'com.amap.api.fence.GeoFenceClient::addGeoFenceX::Callback',
        kAmapLocationFluttifyMethodCodec,
      ).setMethodCallHandler((call) async {
        if (call.method ==
            'Callback::com.amap.api.fence.GeoFenceClient::addGeoFenceX') {
          final args = await call.arguments as Map;
          final status = args['status'] as int;
          final customId = args['customId'] as String;
          final fenceId = args['fenceId'] as String;
          debugPrint(
              '收到围栏消息: status: $status, customId: $customId, fenceId:$fenceId');
          final fence = com_amap_api_fence_GeoFence()
            ..refId = (args['fence'] as Ref).refId;
          _geoFenceEventController?.add(
            GeoFenceEvent(
              customId: customId,
              fenceId: fenceId,
              status: GeoFenceStatusX.fromAndroid(status),
              genFence: GeoFence.android(fence),
            ),
          );
        }
      });
    }
  }

  Stream<GeoFenceEvent> addCircleGeoFence({
    required LatLng center,
    required double radius,
    String customId = '',
    List<GeoFenceActiveAction> activeActions = const [
      GeoFenceActiveAction.In,
      GeoFenceActiveAction.Out,
      GeoFenceActiveAction.Stayed,
    ],
  }) async* {
    _geoFenceEventController ??= StreamController<GeoFenceEvent>.broadcast();

    if (Platform.isAndroid) {
      final context = await android_app_Application.get();
      _androidGeoFenceClient ??= await com_amap_api_fence_GeoFenceClient
          .create__android_content_Context(context);

      final point = await com_amap_api_location_DPoint.create__double__double(
          center.latitude, center.longitude);

      await _androidGeoFenceClient!.addCircleGeoFence(
        activeActions.getActiveAction(),
        point,
        radius,
        customId,
      );
    } else if (Platform.isIOS) {
      _iosGeoFenceClient ??= await AMapGeoFenceManager.create__();
      _iosLocationDelegate ??= _IOSLocationDelegate();

      await _iosGeoFenceClient!.set_delegate(
        _iosLocationDelegate!
          .._onGeoFenceStatusChanged = (region, customId, error) async {
            _geoFenceEventController!.add(
              GeoFenceEvent(
                customId: customId,
                fenceId: await region.get_identifier(),
                status: GeoFenceStatusX.fromIOS(await region.get_fenceStatus()),
                genFence: GeoFence.ios(region),
              ),
            );
          },
      );

      await _iosGeoFenceClient!
          .set_activeActionX(activeActions.getActiveAction());

      final centerPoint = await AMapLocationPoint.create__();
      await centerPoint?.set_latitude(center.latitude);
      await centerPoint?.set_longitude(center.longitude);
      await _iosGeoFenceClient!
          .addCircleRegionForMonitoringWithCenter_radius_customID(
              centerPoint!, radius, customId);
    }

    yield* _geoFenceEventController!.stream;
  }

  Stream<GeoFenceEvent> addPoiGeoFence({
    required String keyword,
    String? poiType,
    String? city,
    int? aroundRadius,
    String customId = '',
    List<GeoFenceActiveAction> activeActions = const [
      GeoFenceActiveAction.In,
      GeoFenceActiveAction.Out,
      GeoFenceActiveAction.Stayed,
    ],
  }) async* {
    _geoFenceEventController ??= StreamController<GeoFenceEvent>.broadcast();

    if (Platform.isAndroid) {
      final context = await android_app_Application.get();
      _androidGeoFenceClient ??= await com_amap_api_fence_GeoFenceClient
          .create__android_content_Context(context);

      await _androidGeoFenceClient!.addPoiGeoFence(
        keyword: keyword,
        poiType: poiType,
        city: city,
        aroundRadius: aroundRadius ?? 1000,
        customId: customId,
        activeAction: activeActions.getActiveAction(),
      );
    } else if (Platform.isIOS) {
      _iosGeoFenceClient ??= await AMapGeoFenceManager.create__();
      _iosLocationDelegate ??= _IOSLocationDelegate();

      await _iosGeoFenceClient!.set_delegate(
        _iosLocationDelegate!
          .._onGeoFenceStatusChanged = (region, customId, error) async {
            _geoFenceEventController!.add(
              GeoFenceEvent(
                customId: customId,
                fenceId: await region.get_identifier(),
                status: GeoFenceStatusX.fromIOS(await region.get_fenceStatus()),
                genFence: GeoFence.ios(region),
              ),
            );
          },
      );

      await _iosGeoFenceClient!
          .set_activeActionX(activeActions.getActiveAction());

      await _iosGeoFenceClient!.addPOIRegionForMonitoringWithKeyword_poiType_city_customID(
          keyword, poiType ?? '', city ?? '', customId);
    }

    yield* _geoFenceEventController!.stream;
  }

  Stream<GeoFenceEvent> addPolygonGeoFence({
    required List<LatLng> pointList,
    String customId = '',
    List<GeoFenceActiveAction> activeActions = const [
      GeoFenceActiveAction.In,
      GeoFenceActiveAction.Out,
      GeoFenceActiveAction.Stayed,
    ],
  }) async* {
    _geoFenceEventController ??= StreamController<GeoFenceEvent>.broadcast();

    if (Platform.isAndroid) {
      final context = await android_app_Application.get();
      _androidGeoFenceClient ??= await com_amap_api_fence_GeoFenceClient
          .create__android_content_Context(context);

      final polygon = <com_amap_api_location_DPoint>[];
      for (final point in pointList) {
        polygon.add(
            await com_amap_api_location_DPoint.create__double__double(
                point.latitude, point.longitude));
      }

      await _androidGeoFenceClient!.addPolygonGeoFence(
        polygon: polygon,
        customId: customId,
        activeAction: activeActions.getActiveAction(),
      );
    } else if (Platform.isIOS) {
      _iosGeoFenceClient ??= await AMapGeoFenceManager.create__();
      _iosLocationDelegate ??= _IOSLocationDelegate();

      await _iosGeoFenceClient!.set_delegate(
        _iosLocationDelegate!
          .._onGeoFenceStatusChanged = (region, customId, error) async {
            _geoFenceEventController!.add(
              GeoFenceEvent(
                customId: customId,
                fenceId: await region.get_identifier(),
                status: GeoFenceStatusX.fromIOS(await region.get_fenceStatus()),
                genFence: GeoFence.ios(region),
              ),
            );
          },
      );

      await _iosGeoFenceClient!
          .set_activeActionX(activeActions.getActiveAction());

      final coordinates = <AMapLocationPoint>[];
      for (final point in pointList) {
        final locationPoint = await AMapLocationPoint.create__();
        await locationPoint?.set_latitude(point.latitude);
        await locationPoint?.set_longitude(point.longitude);
        if (locationPoint != null) coordinates.add(locationPoint);
      }
      await _iosGeoFenceClient!
          .addPolygonRegionForMonitoringWithCoordinates_customID(
              coordinates, customId);
    }

    yield* _geoFenceEventController!.stream;
  }

  Stream<GeoFenceEvent> addDistrictGeoFence({
    required String keyword,
    String customId = '',
    required List<GeoFenceActiveAction> activeActions,
  }) async* {
    _geoFenceEventController ??= StreamController<GeoFenceEvent>.broadcast();

    if (Platform.isAndroid) {
      final context = await android_app_Application.get();
      _androidGeoFenceClient ??= await com_amap_api_fence_GeoFenceClient
          .create__android_content_Context(context);

      await _androidGeoFenceClient!.addDistrictGeoFence(
        keyword: keyword,
        customId: customId,
        activeAction: activeActions.getActiveAction(),
      );
    } else if (Platform.isIOS) {
      _iosGeoFenceClient ??= await AMapGeoFenceManager.create__();
      _iosLocationDelegate ??= _IOSLocationDelegate();

      await _iosGeoFenceClient!.set_delegate(
        _iosLocationDelegate!
          .._onGeoFenceStatusChanged = (region, customId, error) async {
            _geoFenceEventController!.add(
              GeoFenceEvent(
                customId: customId,
                fenceId: await region.get_identifier(),
                status: GeoFenceStatusX.fromIOS(await region.get_fenceStatus()),
                genFence: GeoFence.ios(region),
              ),
            );
          },
      );

      await _iosGeoFenceClient!
          .set_activeActionX(activeActions.getActiveAction());

      await _iosGeoFenceClient!
          .addDistrictRegionForMonitoringWithDistrictName_customID(
              keyword, customId);
    }

    yield* _geoFenceEventController!.stream;
  }
}

mixin _Holder on _Pro {
  com_amap_api_location_AMapLocationClient? _androidClient;
  AMapLocationManager? _iosClient;

  _AndroidLocationDelegate? _androidLocationDelegate;
  _IOSLocationDelegate? _iosLocationDelegate;

  StreamController<Location>? _locationController;
  StreamController<GeoFenceEvent>? _geoFenceEventController;

  com_amap_api_fence_GeoFenceClient? _androidGeoFenceClient;
  AMapGeoFenceManager? _iosGeoFenceClient;
}
