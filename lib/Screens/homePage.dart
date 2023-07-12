import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

String androidPath = "";

class Recorder extends StatefulWidget {
  const Recorder({super.key});

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  @override
  void initState() {
    super.initState();

    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();

    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw "Microphone permission not granted";
    }
    await recorder.openRecorder();

    isRecorderReady = true;

    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  Future record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: "audio");
  }

  Future stop() async {
    if (!isRecorderReady) {
      return;
    }
    // ignore: await_only_futures
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    androidPath = audioFile.toString();
    // await recorder.stopRecorder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<RecordingDisposition>(
            stream: recorder.onProgress,
            builder: (context, snapshot) {
              final duration =
                  snapshot.hasData ? snapshot.data!.duration : Duration.zero;
              String twoDigits(int n) {
                return n.toString().padLeft(1);
              }

              final twoDigitMinutes =
                  twoDigits(duration.inMinutes.remainder(60));
              final twoDigitSeconds =
                  twoDigits(duration.inSeconds.remainder(60));

              return Text(
                "$twoDigitMinutes:$twoDigitSeconds",
                style: const TextStyle(
                  fontSize: 80.0,
                  fontWeight: FontWeight.bold,
                ),
              );

              // return Text("${duration.inSeconds} s");
            },
          ),
          const SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: () async {
              if (recorder.isRecording) {
                await stop();
              } else {
                await record();
              }
              setState(() {});
            },
            child: Icon(recorder.isRecording ? Icons.stop : Icons.mic_sharp,
                  size: 80.0),
          ),
          const SizedBox(height: 100.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(androidPath),
            ],
          ),
        ],
      )),
    );
  }
}
