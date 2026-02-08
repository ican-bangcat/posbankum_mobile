import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart'; 

class HomeMasyarakatScreen extends StatelessWidget {
  const HomeMasyarakatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Masyarakat"), backgroundColor: Colors.blue),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text("Halo, Warga!", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                Get.offAll(() => const LoginScreen()); // Logout balik ke Login
              },
              child: const Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}