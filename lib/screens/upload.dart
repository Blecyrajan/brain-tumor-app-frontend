import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'login.dart';
import 'history.dart';
import 'chat.dart';



class UploadScreen extends StatefulWidget {
  final String userEmail;

  const UploadScreen({super.key, required this.userEmail});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String result = "";
  bool loading = false;
  String imageUrl = "";

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => loading = true);

      final res =
          await ApiService.predict(image.path, widget.userEmail);

      // 🔍 TEMPORARY DEBUG PRINT (ADD HERE)
      print("PREDICT RESPONSE FROM BACKEND: $res");

      setState(() {
        result =
            "${res['class']} (${res['confidence']}%)";
        imageUrl = res['image_url'];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Brain Tumor Detection"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(userEmail: widget.userEmail),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Upload MRI"),
            ),

            const SizedBox(height: 20),

            // 🔹 SHOW MRI IMAGE
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 250,
                fit: BoxFit.cover,
              ),

            const SizedBox(height: 20),

            // 🔹 SHOW LOADER OR RESULT
            loading
                ? const CircularProgressIndicator()
                : Text(
                    result,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text("Ask AI about this result"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      userEmail: widget.userEmail,
                      prediction: result,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
