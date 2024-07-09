import 'package:chat_app1/models/user_profile.dart';
import 'package:chat_app1/service/alert_service.dart';
import 'package:chat_app1/service/auth_service.dart';
import 'package:chat_app1/service/database_service.dart';
import 'package:chat_app1/service/navigation_service.dart';
import 'package:chat_app1/widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;

  late NavigationService _navigationService;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late AlertService _alertService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();

    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.menu,
            color: Colors.blue,
          ),
        ),
        title: Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () async {
                    bool result = await _authService.logout();
                    if (result) {
                      _alertService.showToast(
                          text: "logout successfully!",
                          icon: Icons.check,
                          color: Colors.green);
                      _navigationService.pushReplacementNamed("/login");
                    }
                  },
                  icon: Icon(Icons.logout, color: Colors.blue))
            ],
          )
        ],
      ),
      body: StreamBuilder(
        stream: _databaseService.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Unable to load data"),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final users = snapshot.data!.docs;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                UserProfile user = users[index].data();
                return ChatTile(userProfile: user, onTap: () {});
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
