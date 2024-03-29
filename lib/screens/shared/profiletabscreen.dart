import 'dart:async';
import 'dart:convert';
import 'package:barterit/screens/shared/registrationscreen.dart';
import 'package:http/http.dart' as http;
import 'package:barterit/models/user.dart';
import 'package:barterit/appconfig/myconfig.dart';
import 'package:barterit/screens/shared/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileTabScreen extends StatefulWidget {
  final User user;
  const ProfileTabScreen({super.key, required this.user});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  late double screenHeight, screenWidth, cardwitdh;
  String maintitle = "Profile";
  bool isButtonActive = true;

  @override
  void initState() {
    super.initState();
    checkUserLogin();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(8),
            height: screenHeight * 0.25,
            width: screenWidth,
            child: Card(
              elevation: 8,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (!isButtonActive)
                  Container(
                    margin: const EdgeInsets.all(4),
                    width: screenWidth * 0.4,
                    child: Image.asset(
                      "assets/images/profile2.png",
                    ),
                  ),
                if (isButtonActive)
                  Container(
                    margin: const EdgeInsets.all(4),
                    width: screenWidth * 0.4,
                    child: Image.asset(
                      "assets/images/profile.png",
                    ),
                  ),
                Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        if (isButtonActive)
                          Text(
                            widget.user.name.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              color: Color.fromARGB(255, 22, 20, 124),
                            ),
                          ),
                        if (isButtonActive)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.email),
                              const SizedBox(width: 10),
                              Text(widget.user.email.toString()),
                            ],
                          ),
                        if (isButtonActive)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.phone),
                              const SizedBox(width: 10),
                              Text(widget.user.phone.toString()),
                            ],
                          ),
                        if (!isButtonActive)
                          const Text(
                            "Guest User",
                            style: TextStyle(
                              fontSize: 24,
                              color: Color.fromARGB(255, 22, 20, 124),
                            ),
                          ),
                        if (!isButtonActive)
                          const Text(
                            "Welcome to BarterIt",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 22, 20, 124),
                            ),
                          ),
                      ],
                    )),
              ]),
            ),
          ),
          Container(
            height: 200,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                if (isButtonActive)
                  ElevatedButton(
                    onPressed: _updateNameDialog,
                    child: const Text("EDIT NAME"),
                  ),
                if (isButtonActive)
                  ElevatedButton(
                    onPressed: _updatePhoneDialog,
                    child: const Text("EDIT PHONE NUMBER"),
                  ),
                if (isButtonActive)
                  ElevatedButton(
                    onPressed: _updateEmailDialog,
                    child: const Text("EDIT E-MAIL"),
                  ),
                if (isButtonActive)
                  ElevatedButton(
                    onPressed: _updatePasswordDialog,
                    child: const Text("EDIT PASSWORD"),
                  ),
                if (isButtonActive)
                  ElevatedButton(
                    onPressed: onLogoutDialog,
                    child: const Text("LOGOUT"),
                  ),
                if (!isButtonActive) const SizedBox(height: 180),
                if (!isButtonActive)
                  ElevatedButton(
                    onPressed: onLoginDialog,
                    child: const Text("LOGIN"),
                  ),
                if (!isButtonActive)
                  ElevatedButton(
                    onPressed: onRegisterDialog,
                    child: const Text("REGISTER"),
                  ),
              ],
            ),
          )),
        ]),
      ),
    );
  }

  void onLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text("Logout", style: TextStyle()),
          content: const Text("Confirm logout?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                logout();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text("Please Wait"),
          content: Text("Logging Out..."),
        );
      },
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email')) ?? '';
    String password = (prefs.getString('pass')) ?? '';
    late User user;
    if (email.length > 1 && password.length > 1) {
      http.post(Uri.parse("${MyConfig().server}/barteritV2/php/login_user.php"),
          body: {"email": email, "password": password}).then((response) async {
        if (response.statusCode == 200 && response.body != "failed") {
          prefs = await SharedPreferences.getInstance();
          await prefs.remove('email');
          await prefs.remove('pass');
        }
      });
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (content) => const LoginScreen()));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Logged Out")));
  }

  void _updateNameDialog() {
    TextEditingController _nameeditingController = TextEditingController();
    _nameeditingController.text = widget.user.name.toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Text(
            "Name",
            style: TextStyle(),
          ),
          content: TextField(
            controller: _nameeditingController,
            keyboardType: TextInputType.name,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Confirm",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                try {
                  http.post(
                      Uri.parse(
                          "${MyConfig().server}/barteritV2/php/update_profile.php"),
                      body: {
                        "newname": _nameeditingController.text,
                        "userid": widget.user.id
                      }).then((response) {
                    String jsonsDataString = response.body.toString();
                    var data = json.decode(jsonsDataString);
                    if (response.statusCode == 200 &&
                        data['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Edit Success")));
                      setState(() {
                        widget.user.name = _nameeditingController.text;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Edit Failed")));
                    }
                  });
                } on TimeoutException catch (_) {
                  print("Time out");
                }
              },
            ),
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updatePhoneDialog() {
    TextEditingController _phoneeditingController = TextEditingController();
    _phoneeditingController.text = widget.user.phone.toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Phone Number",
            style: TextStyle(),
          ),
          content: TextField(
              controller: _phoneeditingController,
              keyboardType: TextInputType.phone),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Confirm",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                try {
                  http.post(
                      Uri.parse(
                          "${MyConfig().server}/barteritV2/php/update_profile.php"),
                      body: {
                        "newphone": _phoneeditingController.text,
                        "userid": widget.user.id
                      }).then((response) {
                    String jsonsDataString = response.body.toString();
                    var data = json.decode(jsonsDataString);
                    if (response.statusCode == 200 &&
                        data['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Edit Success")));
                      setState(() {
                        widget.user.phone = _phoneeditingController.text;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Edit Failed")));
                    }
                  });
                } on TimeoutException catch (_) {
                  print("Time out");
                }
              },
            ),
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateEmailDialog() {
    TextEditingController _emaileditingController = TextEditingController();
    _emaileditingController.text = widget.user.email.toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Email",
            style: TextStyle(),
          ),
          content: TextField(
              controller: _emaileditingController,
              keyboardType: TextInputType.phone),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Confirm",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                try {
                  http.post(
                      Uri.parse(
                          "${MyConfig().server}/barteritV2/php/update_profile.php"),
                      body: {
                        "newemail": _emaileditingController.text,
                        "userid": widget.user.id
                      }).then((response) {
                    String jsonsDataString = response.body.toString();
                    var data = json.decode(jsonsDataString);
                    if (response.statusCode == 200 &&
                        data['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Edit Success")));
                      setState(() {
                        widget.user.phone = _emaileditingController.text;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Edit Failed")));
                    }
                  });
                } on TimeoutException catch (_) {
                  print("Time out");
                }
              },
            ),
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void checkUserLogin() {
    if (widget.user.id == "na") {
      isButtonActive = false;
    } else {
      isButtonActive = true;
    }
  }

  void onLoginDialog() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.push(
        context, MaterialPageRoute(builder: (content) => const LoginScreen()));
  }

  void onRegisterDialog() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.push(context,
        MaterialPageRoute(builder: (content) => const RegistrationScreen()));
  }

  void _updatePasswordDialog() {
    TextEditingController _pass1editingController = TextEditingController();
    TextEditingController _pass2editingController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Text(
            "Update Password",
            style: TextStyle(),
          ),
          content: SizedBox(
            height: screenHeight / 5,
            child: Column(
              children: [
                TextField(
                    controller: _pass1editingController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'New password',
                        labelStyle: TextStyle(),
                        icon: Icon(
                          Icons.password,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ))),
                TextField(
                    controller: _pass2editingController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Renter password',
                        labelStyle: TextStyle(),
                        icon: Icon(
                          Icons.password,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ))),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Confirm",
                style: TextStyle(),
              ),
              onPressed: () {
                if (_pass1editingController.text !=
                    _pass2editingController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Passwords are not the same")));
                }
                if (_pass1editingController.text.isEmpty ||
                    _pass2editingController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a password")));
                  Navigator.of(context).pop();
                }
                http.post(
                    Uri.parse(
                        "${MyConfig().server}/barteritV2/php/update_profile.php"),
                    body: {
                      "password": _pass1editingController.text,
                      "userid": widget.user.id
                    }).then((response) {
                  var data = jsonDecode(response.body);
                  //  print(data);
                  if (response.statusCode == 200 &&
                      data['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Edit success")));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Edit failed")));
                  }
                });
              },
            ),
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
