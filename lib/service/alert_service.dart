import 'package:chat_app1/service/navigation_service.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';

class AlertService {
  final GetIt _getit = GetIt.instance;
  late NavigationService _navigationService;
  AlertService() {
    _navigationService = _getit.get<NavigationService>();
  }
  void showToast({
    required String text,
    IconData icon = Icons.info,
    required Color color,
  }) {
    try {
      DelightToastBar(
        snackbarDuration: Duration(milliseconds: 2000),
        autoDismiss: true,
        position: DelightSnackbarPosition.top,
        builder: (context) {
          return Container(
            // decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
            child: ToastCard(
              shadowColor: Colors.blue,
              title: Text(
                text,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              leading: Icon(
                icon,
                color: color,
                size: 29,
              ),
            ),
          );
        },
      ).show(
        _navigationService.navigatorKey!.currentContext!,
      );
    } catch (e) {
      print(e);
    }
  }
}
