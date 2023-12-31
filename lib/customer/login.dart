import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:first_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => Login());
  }

  @override
  State<StatefulWidget> createState() {
    return _Login();
  }
}

class _Login extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    final data = await supabase
        .from('users')
        .select()
        .eq('email', emailController.text)
        .limit(1);
    if (data.isEmpty) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Email salah',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
      );
    } else {
      var a = data[0];
      if (a['pass'] != passController.text) {
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: 'Password salah',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
        );
      } else {
        final datacust = await supabase
            .from('user_customer')
            .select()
            .eq('user_id', a['id'])
            .single();
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userid', a['id']);
        await prefs.setString('usernama', datacust['nama']);
        await prefs.setString('email', a['email']);
        Navigator.pushNamed(context, '/customer_home');
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''), // You can add title here
        leadingWidth: 50,
        leading: Container(
          margin: const EdgeInsets.only(left: 10.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back),
            style: ButtonStyle(
              shape: MaterialStateProperty.all(CircleBorder()),
              padding: MaterialStateProperty.all(EdgeInsets.all(2)),
              backgroundColor: MaterialStateProperty.all(
                  Color(0xFF2B9EA4)), // <-- Button color
              overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.pressed))
                  return Color.fromARGB(255, 34, 125, 129); // <-- Splash color
              }),
            ),
          ),
        ),
        backgroundColor:
            Colors.blue.withOpacity(0), //You can make this transparent
        elevation: 0.0, //No shadow
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 10.0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              const Text(
                "Login",
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B9EA4)),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: 325,
                height: 320,
                decoration: const BoxDecoration(
                  color: Color(0xFF2B9EA4),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Yuk Masukkan alamat emailmu",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: 260,
                      height: 60,
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          /*suffix: Icon(
                            FontAwesomeIcons.envelope,
                            color: Colors.red,
                          ),*/
                          hintText: 'Masukkan Email',
                          hintStyle: TextStyle(color: Colors.white),
                          labelText: "Email Address",
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Container(
                      width: 260,
                      height: 60,
                      child: TextField(
                        controller: passController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: const InputDecoration(
                          /*suffix: Icon(
                            FontAwesomeIcons.eyeSlash,
                            color: Colors.red,
                          ),*/
                          hintText: 'Masukkan Password',
                          hintStyle: TextStyle(color: Colors.white),
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10.0),
                      alignment: Alignment.center,
                      width: 250,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.white,
                      ),
                      child: TextButton(
                        onPressed: _isLoading ? null : _signIn,
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: Color(0xFF2B9EA4),
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 17,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
