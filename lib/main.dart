import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:workmanager/workmanager.dart';
import 'package:workmanager_tester/logger.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.log("Callback dispatched.");
  Workmanager().executeTask((task, inputData) async {
    Logger.log("Task started: $task");
    final port = IsolateNameServer.lookupPortByName("Worktest_ui");
    if (port != null) {
      Logger.log("Ui is alive.");
    } else {
      Logger.log("Ui is dead.");
    }
    return true;
  });
}

const colors = [
  Color(0xFF673AB7),
  Color(0xFFFF5722),
  Color(0xFF009688),
  Color(0xFFFFC107),
  Color(0xFFE91E63),
  Color(0xFF3F51B5),
  Color(0xFF8BC34A),
  Color(0xFF795548),
  Color(0xFF607D8B),
];
int appIndex = 0;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FGBGEvents.instance.stream.listen((fgbg) {
    Logger.log("App state switched to: ${fgbg.name}");
  });
  Workmanager().initialize(callbackDispatcher);
  Workmanager().cancelAll();
  Workmanager().registerPeriodicTask(
    "Worktest_task",
    "Worktest_task",
    frequency: Duration(hours: 1),
  );
  IsolateNameServer.registerPortWithName(ReceivePort().sendPort, "Worktest_ui");
  final info = await PackageInfo.fromPlatform();
  try {
    appIndex = (int.parse(info.packageName.split(".").last.substring(1)));
  } catch (e) {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkTest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: colors[appIndex % 9]),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final listenable = ValueNotifier(1);
  MyHomePage({super.key});

  void _refresh() {
    Future.delayed(Duration(seconds: 1), () {
      listenable.value = listenable.value + 1;
      _refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    _refresh();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Workmanager test $appIndex"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Text("Workmanager set to fire hourly"),
            ListenableBuilder(
              listenable: listenable,
              builder:
                  (context, child) => FutureBuilder(
                    future: Logger.getLogs(),
                    builder:
                        (context, snapshot) =>
                            snapshot.hasData ? Text(snapshot.data!) : Center(),
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: Logger.deleteLogs,
        tooltip: 'Delete logs',
        child: const Icon(Icons.delete),
      ),
    );
  }
}
