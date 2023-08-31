import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Staatliches',
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ConfettiController _controllerBottomCenter;

  static const int totalRound = 4;
  static const int totalGoal = 10;
  static const int breakTimeSet = 5;
  static const List setTimeList = [
    3,
    30,
    60,
    180,
    900,
    1200,
    1500,
    1800,
    2100,
    2400,
    2700,
    3000
  ];
  static int defaultTime = setTimeList[selectedButtonIndex];
  int totalSeconds = defaultTime;
  int lastSetTime = defaultTime;
  int currentRound = 0;
  int currentGoal = 0;
  bool isRunning = false;
  bool isSelected = false;
  bool isBreakTime = false;
  late Timer timer;
  //버튼 기본값
  static int selectedButtonIndex = 1;

  void setTotalSeconds(int time) {
    setState(() {
      !isBreakTime
          ? {totalSeconds = time, lastSetTime = time}
          : totalSeconds = time;
    });
  }

  void timerStart() {
    isRunning ? onPausePressed() : onStart();
  }

  void onStart() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      tiktok,
    );
    setState(() {
      isRunning = true;
    });
  }

  void onPausePressed() {
    timer.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void tiktok(Timer timer) {
    //휴식시간종료
    if (isBreakTime && totalSeconds == 0) {
      setState(() {
        isBreakTime = false;
        isRunning = false;
        totalSeconds = lastSetTime;
      });
      timer.cancel();
      //else문 방지트릭
      totalSeconds++;
    }
    //정상 중지
    if (totalSeconds == 0) {
      setState(() {
        currentRound = currentRound + 1;
        if (totalRound == currentRound) {
          currentGoal++;
          currentRound = 0;
        }
        if (totalGoal == currentGoal) {
          _controllerBottomCenter.play();
          currentGoal = 0;
        }
        isRunning = false;
        totalSeconds = lastSetTime;
      });
      timer.cancel();
      breakTime();
    } else {
      //일시중지 종료
      setState(() {
        totalSeconds = totalSeconds - 1;
      });
    }
  }

  List formatTime(int seconds) {
    var duration = Duration(seconds: seconds);
    String min = duration.toString().split(".").first.substring(2, 4);
    String sec = duration.toString().split(".").first.substring(5, 7);
    return [min, sec];
  }

  String formatButtonText(int seconds) {
    var duration = Duration(seconds: seconds);
    var min = duration.toString().split(".").first.substring(2, 4);
    var sec = duration.toString().split(".").first.substring(5, 7);
    var result = "";
    min == '00' ? result = '${sec}s' : result = '${min}m';
    result =
        result.substring(0, 1) == '0' ? result = result.substring(1) : result;
    return result;
  }

  void breakTime() {
    isBreakTime = true;
    setTotalSeconds(breakTimeSet);
    onStart();
  }

  //testing
  void plusRound() {
    setState(() {
      currentRound++;
      if (totalRound == currentRound) {
        currentGoal++;
        currentRound = 0;
      }
    });
  }

  void plusGoal() {
    setState(() {
      currentGoal++;
      if (totalGoal == currentGoal) {
        _controllerBottomCenter.play();
        currentGoal = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controllerBottomCenter =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    _controllerBottomCenter.dispose();
    super.dispose();
  }

  //custom radio button
  Widget customRadioButton(int index, int time) {
    return TextButton(
      onPressed: () => {
        setTotalSeconds(time),
        selectedButtonIndex = index,
      },
      style: OutlinedButton.styleFrom(
        fixedSize: const Size(20, 40),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        backgroundColor: selectedButtonIndex == index
            ? Colors.white
            : const Color.fromARGB(255, 255, 74, 54),
      ),
      child: Text(
        formatButtonText(time),
        style: TextStyle(
          fontFamily: 'Staatliches',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: selectedButtonIndex == index
              ? const Color.fromARGB(255, 255, 74, 54)
              : Colors.white,
        ),
      ),
    );
  }

  //get radio button list
  List<Widget> _getButtons() {
    List<Widget> buttons = [];
    int buttonIndex = 0;
    for (var value in setTimeList) {
      buttonIndex = setTimeList.indexOf(value);
      buttons.add(customRadioButton(buttonIndex, value));
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 74, 54),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 35),
        child: Column(
          children: <Widget>[
            const Text(
              'POMODORO',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "ITS BREAK TIME!!",
              style: TextStyle(
                fontSize: 20,
                color: isBreakTime ? Colors.white : Colors.white.withOpacity(0),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            //Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Text(
                    "${formatTime(totalSeconds)[0]}",
                    style: const TextStyle(
                      fontSize: 50,
                      color: Color.fromARGB(255, 255, 74, 54),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  " : ",
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Text(
                    "${formatTime(totalSeconds)[1]}",
                    style: const TextStyle(
                      fontSize: 50,
                      color: Color.fromARGB(255, 255, 74, 54),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 12,
                children: _getButtons(),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(0),
                backgroundColor: const Color.fromARGB(22, 26, 20, 20),
                fixedSize: const Size(60, 60),
                shape: const CircleBorder(),
              ),
              onPressed: timerStart,
              child: Icon(
                isRunning ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            // Bottom Part
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$currentRound/$totalRound',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: currentRound > 0
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    TextButton(
                      onPressed: plusRound,
                      child: const Text(
                        'ROUND',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$currentGoal/$totalGoal',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: currentGoal > 0
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    TextButton(
                      onPressed: plusGoal,
                      child: const Text(
                        'GOAL',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ConfettiWidget(
                confettiController: _controllerBottomCenter,
                blastDirection: -pi / 2,
                emissionFrequency: 0.1,
                numberOfParticles: 15,
                maxBlastForce: 20,
                minBlastForce: 5,
                gravity: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
