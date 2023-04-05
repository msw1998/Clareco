import 'package:clareco/dialer.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.number});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String number;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final RecorderController recorderController = RecorderController()
    ..updateFrequency = const Duration(milliseconds: 100)
    ..androidEncoder = AndroidEncoder.aac
    ..androidOutputFormat = AndroidOutputFormat.mpeg4
    ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
    ..sampleRate = 44100;
  final recordingPlayer = AssetsAudioPlayer();
  bool _playAudio = false;
  bool isRecorderReady = false;
  bool isPaused = false;
  String? pathToAudio;
  int _elapsedTime = 0;
  int _pausedTime = 0;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();

    initRecorder();
  }

  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }

  void initRecorder() async {
    final status = await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    final directory = await getTemporaryDirectory();
    pathToAudio = path.join(directory.path, '${widget.number}.m4a');
    // Directory directory = Directory('/storage/emulated/0/SoundRecorder/');
    // pathToAudio = path.join(directory.path, 'temp.wav');
    print("path to audio is ${pathToAudio}");
    bool hasexisted = await directory.exists();
    if (!hasexisted) {
      print("Directory not present");
      directory.create();
      print("created dirctory: ${directory}");
    } else {
      print("Directory is already present");
    }

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }

    isRecorderReady = true;
  }

  Future sendEmail(
    String title,
  ) async {
    final email = "clareco.online@gmail.com";
    final smtpServer = gmail(email, "ecchdgaqniggqdkn");
// heyobeentje11@hotmail.com
    final message = Message()
      ..from = Address(email, "Clareco")
      ..recipients = ["msw7798@gmail.com","sadiqr240@gmail.com"]
      ..subject = "User Name: $title : Here is the latest recording"
      ..text =
          "Please find attached the recorded file \nUser Email Address is: ${user.email}"
      ..attachments = [FileAttachment(File(pathToAudio!))];
    try {
      await send(message, smtpServer);
      File file = File(pathToAudio!);
      if (await file.exists()) {
        print("Deletting the audio file");
        await file.delete();
      }
    } on MailerException catch (e) {
      print(e);
    }
  }

  Future stop() async {
    if (!isRecorderReady) return;
    recorderController.reset();
    final path = await recorderController.stop();

    setState(() {
      _elapsedTime = 0;
      _pausedTime = 0;
      isPaused = false;
    });
    final audioFile = File(path!);
    print('Recorded audio : $audioFile');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green[800],
        margin: EdgeInsets.all(20),
        content: Text("Recording Done"),
      ),
    );
    sendEmail(user.displayName!);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.info,
          color: Color.fromARGB(255, 162, 181, 234),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            20.0,
          ),
        ),
        content: const Text(
            "Recording is sent to our servers. We will send a text message to the number provided to let you know that a document is available."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              "Okay",
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 162, 181, 234),
              ),
            ),
          ),
        ],
      ),
    );
    // Navigator.pop(context);
  }

  Future record() async {
    if (!isRecorderReady) return;
    // await recorder.startRecorder(toFile: pathToAudio, codec: Codec.pcm16WAV);
    await recorderController.record(path: pathToAudio);
  }

  Future pauseRecording() async {
    if (!isRecorderReady) return;
    print("In pause recording");
    await recorderController.pause();
    setState(() {
      isPaused = true;
    });
  }

  Future resumeRecording() async {
    if (!isRecorderReady) return;
    setState(() {
      isPaused = false;
    });

    await recorderController.record();
  }

  Future<void> playFunc() async {
    recordingPlayer.open(
      Audio.file(pathToAudio!),
      autoStart: true,
      showNotification: true,
    );
  }

  Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    bool recordingStatus = false;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        // backgroundColor: Colors.black,
        title: Text("Recording"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset(
                'assets/ClarecoLogo.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: 32,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: recorderController.isRecording
                  ? AudioWaveforms(
                      enableGesture: true,
                      size: Size(MediaQuery.of(context).size.width / 1.5, 150),
                      recorderController: recorderController,
                      waveStyle: const WaveStyle(
                        waveCap: StrokeCap.round,
                        waveColor: Color.fromARGB(255, 162, 181, 234),
                        scaleFactor: 150,
                        extendWaveform: true,
                        showMiddleLine: false,
                      ),
                      padding: const EdgeInsets.only(left: 18),
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: 150,
                    ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      if (recorderController.isRecording) {
                        await stop();
                      } else if (!isPaused) {
                        await record();
                      }
                      setState(() {});
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        recorderController.isRecording ? Icons.stop : Icons.mic,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                recorderController.isRecording || isPaused
                    ? InkWell(
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (isPaused) {
                            print("Paused Pressed false");
                            await resumeRecording();
                          } else {
                            await pauseRecording();
                          }
                          setState(() {});
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Icon(
                            isPaused ? Icons.play_arrow : Icons.pause,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : Text("")
              ],
            ),
            // SizedBox(
            //   height: 20,
            // ),
            // ElevatedButton.icon(
            //   style:
            //       ElevatedButton.styleFrom(elevation: 9.0, primary: Colors.red),
            //   onPressed: () {
            //     setState(() {
            //       _playAudio = !_playAudio;
            //     });
            //     if (_playAudio) playFunc();
            //     if (!_playAudio) stopPlayFunc();
            //   },
            //   icon: _playAudio
            //       ? Icon(
            //           Icons.stop,
            //         )
            //       : Icon(Icons.play_arrow),
            //   label: _playAudio
            //       ? Text(
            //           "Stop",
            //           style: TextStyle(
            //             fontSize: 28,
            //           ),
            //         )
            //       : Text(
            //           "Play",
            //           style: TextStyle(
            //             fontSize: 28,
            //           ),
            //         ),
            // ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
