import 'package:chat_app1/const.dart';
import 'package:chat_app1/service/alert_service.dart';
import 'package:chat_app1/service/auth_service.dart';
import 'package:chat_app1/service/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  bool _obscureText = true;
  String? email, password;
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late AlertService _alertService;
  late NavigationService _navigationService;
  late void Function(String?) onSave;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50),
        child: Form(
          key: _loginFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.person_pin_outlined,
                size: 120,
                color: Colors.blue,
              ),
              Column(
                children: [
                  TextFormField(
                    onSaved: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    validator: (value) {
                      if (value != null &&
                          EMAIL_VALIDATION_REGEX.hasMatch(value)) {
                        return null;
                      } else {
                        return "Enter a valid email";
                      }
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Email"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    onSaved: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                    validator: (value) {
                      if (value != null &&
                          PASSWORD_VALIDATION_REGEX.hasMatch(value)) {
                        return null;
                      } else {
                        return "Enter a valid password";
                      }
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            )),
                        border: const OutlineInputBorder(),
                        labelText: "Password"),
                    obscureText: _obscureText,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue,
                    ),
                    child: TextButton(
                        onPressed: () async {
                          if (_loginFormKey.currentState?.validate() ?? false) {
                            _loginFormKey.currentState?.save();
                            bool result =
                                await _authService.login(email!, password!);
                            print(result);
                            if (result) {
                              _alertService.showToast(
                                  text: "login success!", icon: Icons.check, color: Colors.green);
                              _navigationService.pushReplacementNamed("/home");
                            } else {
                              _alertService.showToast(
                                  text: "failed to login,please try again!", color: Colors.red);
                            }
                          }
                        },
                        child: const Text(
                          "login",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?  ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigationService.pushNamed("/register");
                    },
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
