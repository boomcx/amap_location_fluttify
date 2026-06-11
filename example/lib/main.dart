import 'package:amap_core_fluttify/amap_core_fluttify.dart';
import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AmapLocation.instance.updatePrivacyShow(isShow: true, isAgree: true);
  await AmapLocation.instance.init(iosKey: 'f6422eadda731fb0d9ffb3260a5cf899');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Location? _location;
  String? _fenceStatus;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('获取单次定位'),
              onPressed: () async {
                if (await requestPermission()) {
                  final location = await AmapLocation.instance.fetchLocation();
                  setState(() => _location = location);
                }
              },
            ),
            ElevatedButton(
              child: const Text('获取连续定位'),
              onPressed: () async {
                if (await requestPermission()) {
                  await AmapLocation.instance.enableBackgroundLocation(
                    10,
                    BackgroundNotification(
                      contentTitle: 'contentTitle',
                      channelId: 'channelId',
                      contentText: 'contentText',
                      channelName: 'channelName',
                    ),
                  );
                  AmapLocation.instance.listenLocation().listen(
                    (event) => setState(() => _location = event),
                  );
                }
              },
            ),
            ElevatedButton(
              child: const Text('停止定位'),
              onPressed: () async {
                if (await requestPermission()) {
                  await AmapLocation.instance.stopLocation();
                  setState(() => _location = null);
                }
              },
            ),
            ElevatedButton(
              child: const Text('添加圆形围栏'),
              onPressed: () async {
                if (await requestPermission()) {
                  AmapLocation.instance
                      .addCircleGeoFence(
                        center: LatLng(29, 119),
                        radius: 1000,
                        customId: 'testid',
                      )
                      .listen((event) {
                        setState(() {
                          _fenceStatus =
                              '状态: ${event.status}, 围栏id: ${event.fenceId}, 自定义id: ${event.customId}';
                        });
                      });
                }
              },
            ),
            ElevatedButton(
              child: const Text('添加多边形围栏'),
              onPressed: () async {
                if (await requestPermission()) {
                  AmapLocation.instance
                      .addPolygonGeoFence(
                        pointList: <LatLng>[
                          LatLng(29.255201, 119.353437),
                          LatLng(28.974455, 119.508619),
                          LatLng(29.172496, 119.560804),
                          LatLng(29.306707, 119.422101),
                        ],
                        customId: 'testid',
                      )
                      .listen((event) {
                        setState(() {
                          _fenceStatus =
                              '状态: ${event.status}, 围栏id: ${event.fenceId}, 自定义id: ${event.customId}';
                        });
                      });
                }
              },
            ),
            ElevatedButton(
              child: const Text('添加poi围栏'),
              onPressed: () async {
                if (await requestPermission()) {
                  AmapLocation.instance
                      .addPoiGeoFence(
                        keyword: '肯德基',
                        customId: 'testid',
                        city: '兰溪',
                        aroundRadius: 10000,
                      )
                      .listen((event) {
                        setState(() {
                          _fenceStatus =
                              '状态: ${event.status}, 围栏id: ${event.fenceId}, 自定义id: ${event.customId}';
                        });
                      });
                }
              },
            ),
            ElevatedButton(
              child: const Text('添加行政区划围栏'),
              onPressed: () async {
                if (await requestPermission()) {
                  AmapLocation.instance.addDistrictGeoFence(keyword: '兰溪').listen((
                    event,
                  ) {
                    setState(() {
                      _fenceStatus =
                          '状态: ${event.status}, 围栏id: ${event.fenceId}, 自定义id: ${event.customId}';
                    });
                  });
                }
              },
            ),
            ElevatedButton(
              child: const Text('释放资源'),
              onPressed: () {
                AmapLocation.instance.dispose();
              },
            ),
            Expanded(
              child: ListView(
                // expanded: true,
                // scrollable: true,
                children: [
                  if (_location != null)
                    Center(
                      child: Text(
                        _location.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_fenceStatus != null)
                    Center(
                      child: Text(
                        _fenceStatus.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> requestPermission() async {
  final permissions = await Permission.locationWhenInUse.request();

  if (permissions.isGranted) {
    return true;
  } else {
    // toast('需要定位权限!');
    // ScaffoldMessenger.of().showSnackBar(
    //   const SnackBar(content: Text('需要定位权限!')),
    // );
    print('需要定位权限!');
    return false;
  }
}
