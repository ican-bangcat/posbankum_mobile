import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class HomeParalegalScreen extends StatelessWidget {
  const HomeParalegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Paralegal"), backgroundColor: Colors.green),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.gavel, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text("Halo, Paralegal!", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                Get.offAll(() => const LoginScreen());
              },
              child: const Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}