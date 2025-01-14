import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:beat_the_virus/provider/AuthenticateProvider.dart';
import 'package:beat_the_virus/utility/Size_Config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'LoginScreen.dart';

class EmailConfirmationScreen extends StatefulWidget {
  final String email;

  EmailConfirmationScreen({
    Key key,
    @required this.email,
  }) : super(key: key);

  @override
  _EmailConfirmationScreenState createState() =>
      _EmailConfirmationScreenState(email);
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  bool _isLoading = false;
  String email;
  final TextEditingController _confirmationCodeController =
      TextEditingController();
  bool _isTimeOver = false;

  final _formKey = GlobalKey<FormState>();

  _EmailConfirmationScreenState(this.email);

  @override
  void dispose() {
    _confirmationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
            Color(0xFF3d8fa5),
            Color(0xFF76e2ff),
          ])),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
              child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  children: [
                Image.asset(
                  'assets/icons/btvlogolow.png',
                  height: SizeConfig.screenHeight * 0.25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Email Confirmation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Vivaldi',
                          fontSize: SizeConfig.safeBlockHorizontal * 15)),
                ),
                Container(
                    width: SizeConfig.screenWidth * 0.70,
                    height: SizeConfig.screenHeight * 0.30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Form(
                            key: _formKey,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 15.0),
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                              text:
                                                  'An email confirmation code is sent to ',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.0),
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: "'" +
                                                        widget.email +
                                                        "' .",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                TextSpan(
                                                    text:
                                                        'Please type the code to confirm your email.',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16.0))
                                              ])),
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                        controller: _confirmationCodeController,
                                        decoration: InputDecoration(
                                            counterText: '',
                                            border: OutlineInputBorder(),
                                            labelText:
                                                "Enter Confirmation Code"),
                                        validator: (value) => value.length != 6
                                            ? "The confirmation code is invalid"
                                            : null,
                                      ),
                                      if (_isLoading)
                                        CircularProgressIndicator()
                                      else
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _isTimeOver
                                                ? TextButton.icon(
                                                    onPressed: () {},
                                                    icon: Icon(Icons.refresh),
                                                    label: Text('Resend Code'))
                                                : TweenAnimationBuilder<
                                                        Duration>(
                                                    tween: Tween(
                                                        begin: Duration(
                                                            minutes: 1),
                                                        end: Duration.zero),
                                                    duration:
                                                        Duration(minutes: 1),
                                                    onEnd: () {
                                                      setState(() {
                                                        _isTimeOver = true;
                                                      });
                                                    },
                                                    builder:
                                                        (BuildContext context,
                                                            Duration value,
                                                            Widget child) {
                                                      final minutes =
                                                          value.inMinutes;
                                                      final seconds =
                                                          value.inSeconds % 60;
                                                      return RichText(
                                                        text: TextSpan(
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                            children: <
                                                                TextSpan>[
                                                              TextSpan(
                                                                  text:
                                                                      'Resend Code in',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          SizeConfig.blockSizeHorizontal *
                                                                              4)),
                                                              TextSpan(
                                                                  text:
                                                                      '  $minutes:$seconds',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          SizeConfig.blockSizeHorizontal *
                                                                              4,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic))
                                                            ]),
                                                      );
                                                    }),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _submitCode(context),
                                              child: Text("CONFIRM"),
                                            ),
                                          ],
                                        )
                                    ])))))
              ]))),
    );
  }

  Future<void> _submitCode(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      // Invalid
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    AuthenticateProvider auth =
        Provider.of<AuthenticateProvider>(context, listen: false);
    FocusScope.of(context).unfocus();
    try {
      SignUpResult result = await auth.confirmRegisterWithCode(
          email, _confirmationCodeController.text);
      if (result.isSignUpComplete) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    } catch (e) {
      _showErrorDialog(e.message);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => AlertDialog(
                title: Row(
                  children: [
                    Text('An Error Occured!'),
                    Icon(Icons.report_problem, color: Colors.red),
                  ],
                ),
                content: Text(message),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text('Okay'),
                      onPressed: () {
                        _confirmationCodeController.clear();
                        _isLoading = false;
                        Navigator.of(ctx).pop();
                      })
                ]));
  }

  // void _resendCode(BuildContext context) async {
  //   if (_formKey.currentState.validate()) {
  //     FocusScope.of(context).unfocus();
  //     await Provider.of<AuthenticateProvider>(context, listen: false)
  //         .resendCode(email)
  //         .then((ResendSignUpCodeResult result) {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('Code Sent Successfully'),
  //         duration: Duration(seconds: 2),
  //       ));
  //     });
  //   }
  // }
}
