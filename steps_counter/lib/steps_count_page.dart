import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pedometer/pedometer.dart';

class StepsCountPage extends StatefulWidget {
  const StepsCountPage({super.key});

  @override
  State<StepsCountPage> createState() => _StepsCountPageState();
}

class _StepsCountPageState extends State<StepsCountPage> {
  //initializes the pedometer plugin,
  //which has a stream where we can get anumber of steps since the phone was booted last
  // dispose the subscription once done

  late Pedometer pedometer;
  late StreamSubscription<int> _streamSubscription;
  Box<int> stepsBox = Hive.box('steps');
  late int todaySteps;

  @override
  void initState() {
    super.initState();
    startListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Your steps',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
        ),
      ),
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Steps',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              todaySteps.toString(),
              style: const TextStyle(
                fontSize: 60,
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  void startListening() {
    pedometer = Pedometer();
    _streamSubscription = pedometer.pedometerStream.listen(
      getTodaySteps,
      onDone: _onDone(),
      onError: _onError(),
      cancelOnError: true
    );
  }

  void _onDone() => print('These are the steps you took today');

  void _onError() => print('There\'s an error countind your steps today');

  Future<int> getTodaySteps(int value) async {
    print(value);
    int savedStepsCountKey = 999999;
    int? savedStepsCount = stepsBox.get(savedStepsCountKey, defaultValue: 0);
    int? todayDayNo = Jiffy(DateTime.now()).dayOfYear;

    if (value < savedStepsCount!) {
      savedStepsCount = 0;
      stepsBox.put(savedStepsCountKey, savedStepsCount);
    }
    int lastDaySavedKey = 888888;
    int? lastDaySaved = stepsBox.get(lastDaySavedKey, defaultValue: 0);

    if (lastDaySaved! < todayDayNo) {
      lastDaySaved = todayDayNo;
      savedStepsCount = value;

      stepsBox
        ..put(lastDaySavedKey, lastDaySaved)
        ..put(savedStepsCountKey, savedStepsCount);
    }
    setState(() {
      todaySteps = value - savedStepsCount!;
    });
    stepsBox.put(todayDayNo, todaySteps);
    return todaySteps;
  }

  void stopListening() {
    _streamSubscription.cancel();
  }
}
