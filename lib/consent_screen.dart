import 'package:clareco/dialer.dart';
import 'package:clareco/home.dart';
import 'package:flutter/material.dart';

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key, required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    print("Received number is $number");
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
              'I hereby give permission to record the conversation that is currently taking place and to further process it into a written document.',
              style:
                  Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20.0),
            Text(
              'I can rest assured that the processing of my personal data will be kept to a minimum and that all information I provide will be treated confidentially.',
              style:
                  Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 50.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Handle Accept button tap.
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyHomePage(number: number),
                          ),
                        );
                        print("Send number from consent is $number");
                      },
                      child: Icon(
                        Icons.check_circle_outline_outlined,
                        size: 40,
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10.0),
                      ),
                    ),
                    Text(
                      "Accept",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(width: screenwidth / 3),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Handle Decline button tap.
                        Navigator.pop(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DialPad(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.cancel,
                        size: 40,
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10.0),
                      ),
                    ),
                    Text(
                      "Reject",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 14),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
