import 'package:chat_app1/const.dart';
import 'package:chat_app1/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatTile extends StatelessWidget {
  final GetIt getIt = GetIt.instance;
  late UserProfile userProfile;
  final Function onTap;
  ChatTile({super.key, required this.userProfile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap();
      },
      dense: false,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userProfile.pfpURL!),
        // backgroundImage: NetworkImage(PLACEHOLDER_PFP),
      ),
      title: Text(userProfile.name!),
    );
  }
}
