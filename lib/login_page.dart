import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse('https://script.google.com/macros/s/AKfycbylnID988biK38oNEy_dxgagWXe7ZF6vp1DbtvAzGyCFbJ-Gr-r2l7eYQDNrRUQ_XE/exec'));
    final data = json.decode(response.body);

    for (var user in data) {
      if (user['Email'] == _emailController.text && user['Password'] == _passwordController.text) {
        if (user['Status'] == 'No') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification Pending')));
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('user', json.encode(user));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()));
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email or Password Doesn\'t matched')));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
