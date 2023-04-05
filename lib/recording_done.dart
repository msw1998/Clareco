import 'package:clareco/dialer.dart';
import 'package:clareco/home.dart';
import 'package:flutter/material.dart';

class RecordingFinished extends StatelessWidget {
  const RecordingFinished({super.key});

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    var screenwidth = screensize.width;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recording is sent to our servers. We will send a text message to the number provided to let you know that a document is available.',
              style:
                  Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }
}
