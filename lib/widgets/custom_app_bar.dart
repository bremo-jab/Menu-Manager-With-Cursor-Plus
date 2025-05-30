import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/login_view.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: [
        ...?actions,
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signOut();
              Get.offAll(() => const LoginView());
            } catch (e) {
              Get.snackbar(
                'خطأ',
                'حدث خطأ أثناء تسجيل الخروج',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
