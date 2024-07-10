import 'dart:io';

import 'package:chat_app1/const.dart';
import 'package:chat_app1/models/user_profile.dart';
import 'package:chat_app1/service/alert_service.dart';
import 'package:chat_app1/service/auth_service.dart';
import 'package:chat_app1/service/database_service.dart';
import 'package:chat_app1/service/media_service.dart';
import 'package:chat_app1/service/navigation_service.dart';
import 'package:chat_app1/service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  String? email, password, name;
  final GetIt _getIt = GetIt.instance;
  late MediaService _mediaService;
  late DatabaseService _databaseService;
  late StorageService _storageService;
  late AuthService _authService;
  late AlertService _alertService;
  late NavigationService _navigationService;
  File? selectedImage;
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
    _authService = _getIt.get<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50),
        child: Form(
          key: _registerFormKey,
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.blue,
                        )),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(width: 2, color: Colors.white)),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.blue,
                            )),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 10,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.blue,
                            )),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border:
                                  Border.all(width: 2, color: Colors.white)),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 212, 210, 210),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.blue,
                                )),
                            child: IconButton(
                                onPressed: () async {
                                  File? file =
                                      await _mediaService.getImageFromGallery();
                                  if (file != null) {
                                    setState(() {
                                      selectedImage = file;
                                    });
                                  }
                                },
                                icon: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.blue,
                                )),
                          ),
                        ),
                      )),
                ],
              ),

              // ),
              Column(
                children: [
                  TextFormField(
                    onSaved: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                    validator: (value) {
                      if (value != null &&
                          NAME_VALIDATION_REGEX.hasMatch(value)) {
                        return null;
                      } else {
                        return "Enter a valid name";
                      }
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: "Name"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
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
                        border: OutlineInputBorder(), hintText: "Email"),
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
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: "Password"),
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
                          try {
                            if (_registerFormKey.currentState?.validate() ??
                                false) {
                              _registerFormKey.currentState?.save();
                              bool result =
                                  await _authService.signup(email!, password!);
                              if (result) {
                                String? pfpURl =
                                    await _storageService.uploadUserPfp(
                                        file: selectedImage!,
                                        uid: _authService.user!.uid);
                                if (pfpURl != null) {
                                  await _databaseService.createUserProfile(
                                      userProfile: UserProfile(
                                          uid: _authService.user!.uid,
                                          name: name,
                                          pfpURL: pfpURl));
                                  // }
                                  _alertService.showToast(
                                      text: "register successfully!",
                                      icon: Icons.check,
                                      color: Colors.green);
                                  _navigationService
                                      .pushReplacementNamed("/home");
                                }
                              }
                            }
                          } catch (e) {
                            print(e);
                            // _alertService.showToast(
                            //     text: "Fail to register, Please try again!",
                            //     icon: Icons.error,
                            //     color: Colors.red);
                          }
                        },
                        child: const Text(
                          "Register",
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
                    "Already have an account?  ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigationService.pushReplacementNamed("/login");
                    },
                    child: Text(
                      "login here",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          )),
        ),
      ),
    );
  }
}
