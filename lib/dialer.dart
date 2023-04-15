import 'package:clareco/consent_screen.dart';
import 'package:clareco/home.dart';
import 'package:clareco/profile.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';

import 'package:mailer/smtp_server/gmail.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DialPad extends StatefulWidget {
  @override
  _DialPadState createState() => _DialPadState();
}

class _DialPadState extends State<DialPad> {
  String _enteredNumber = '';
  final user = FirebaseAuth.instance.currentUser!;

  Future sendEmail(
    String title,
    String number,
  ) async {
    final email = "clareco.online@gmail.com";
    final smtpServer = gmail(email, "ecchdgaqniggqdkn");
// "heyobeentje11@hotmail.com",
    final message = Message()
      ..from = Address(email, "Clareco")
      ..recipients = ["heyobeentje11@hotmail.com"]
      ..subject = "User Name: $title : Here is the phone number"
      ..text =
          "User Email Address is: ${user.email} \n The Phone Number is $number";
    try {
      await send(message, smtpServer);
    } on MailerException catch (e) {
      print(e);
    }
  }

  void _updateEnteredNumber(String number) {
    setState(() {
      _enteredNumber += number;
    });
  }

  void _deleteLastDigit() {
    setState(() {
      if (_enteredNumber.isNotEmpty) {
        _enteredNumber = _enteredNumber.substring(0, _enteredNumber.length - 1);
      }
    });
  }

  void _onTickButtonPressed() async {
    print(_enteredNumber);
    if (_enteredNumber != '' && _enteredNumber != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green[800],
          margin: EdgeInsets.all(20),
          duration: Duration(seconds: 2),
          content: Text("Phone Number Recorded"),
        ),
      );
      sendEmail(user.displayName!, _enteredNumber);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConsentScreen(number: _enteredNumber),
        ),
      ).then((_) {
        setState(() {
          _enteredNumber = '';
        });
      });
      print("Sent number is ${_enteredNumber}");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[800],
          margin: EdgeInsets.all(20),
          duration: Duration(seconds: 2),
          content: Text("Please enter a valid phone number"),
        ),
      );
      setState(() {
        _enteredNumber = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var sizeFactor = screenSize.height * 0.09852217;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Image.asset(
          "assets/ClarecoLogoSmall.png",
          fit: BoxFit.contain,
          height: 40,
        ),
        centerTitle: true,
        actions: [
          InkWell(
            child: CircleAvatar(
              foregroundImage: NetworkImage(
                user.photoURL!,
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 5))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Please put in the mobile number where you want us to send the document to",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              _enteredNumber,
              style: TextStyle(
                color: Colors.white,
                fontSize: sizeFactor / 2,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNumberButton('1'),
                _buildNumberButton('2'),
                _buildNumberButton('3'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNumberButton('4'),
                _buildNumberButton('5'),
                _buildNumberButton('6'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNumberButton('7'),
                _buildNumberButton('8'),
                _buildNumberButton('9'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                //_buildActionButton(Icons.backspace, _deleteLastDigit),
                SizedBox(
                  height: sizeFactor,
                  width: sizeFactor,
                  child: InkWell(
                    onTap: _deleteLastDigit,
                    onLongPress: () {
                      setState(() {
                        _enteredNumber = '';
                      });
                    },
                    child: Icon(
                      Icons.backspace,
                      color: Colors.red[600],
                      size: sizeFactor / 2,
                    ),
                  ),
                ),
                _buildNumberButton('0'),
                _buildActionButton(Icons.check_circle, _onTickButtonPressed),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    var screenSize = MediaQuery.of(context).size;
    var sizeFactor = screenSize.height * 0.09852217;
    if (number == '0') {
      return ClipOval(
        child: Material(
          color: Colors.grey.shade600, // button color
          child: InkWell(
            onTap: () => _updateEnteredNumber(number),
            onLongPress: () => _updateEnteredNumber('+'),
            child: SizedBox(
              width: sizeFactor,
              height: sizeFactor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    number,
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  Text(
                    "+",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return ClipOval(
      child: Material(
        color: Colors.grey.shade600, // button color
        child: InkWell(
          onTap: () => _updateEnteredNumber(number),
          child: SizedBox(
            width: sizeFactor,
            height: sizeFactor,
            child: Center(
              child: Text(
                number,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    var screenSize = MediaQuery.of(context).size;
    var sizeFactor = screenSize.height * 0.09852217;
    return ClipOval(
      child: Material(
        color: Colors.green.shade600, // button color
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: sizeFactor,
            height: sizeFactor,
            child: Center(
              child: Icon(
                icon,
                size: sizeFactor / 2,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
