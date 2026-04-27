import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'login.dart';
import 'history.dart';
import 'chat.dart';

class UploadScreen extends StatefulWidget {
  final String userEmail;

  const UploadScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String result = "";
  bool loading = false;

  String imageUrl = "";
  String heatmapUrl = "";

  Map features = {};

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    setState(() {
      loading = true;
      result = "";
    });

    try {
      final res = await ApiService.predict(
        image.path,
        widget.userEmail,
      );

      if (!mounted) return;

      print("PREDICT RESPONSE FROM BACKEND: $res");

      setState(() {
        result =
            "${res['class']} (${res['confidence']}%)";

        imageUrl = res['image_url'] ?? "";
        heatmapUrl = res['heatmap_url'] ?? "";
        features = res['features'] ?? {};

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        result = "Prediction failed";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  Widget buildFeatureCard(
    String title,
    dynamic value,
    IconData icon,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              "$value%",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageSection(
    String title,
    String url,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            height: 230,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 230,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Text("Image not available"),
                ),
              );
            },
          ),
        ),
      ],
    );
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
                  builder: (_) => HistoryScreen(
                    userEmail: widget.userEmail,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: loading ? null : pickImage,
              icon: const Icon(Icons.upload),
              label: const Text("Upload MRI"),
            ),

            const SizedBox(height: 20),

            if (loading)
              const CircularProgressIndicator(),

            if (result.isNotEmpty && !loading)
              Text(
                result,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 20),

            // ORIGINAL MRI IMAGE
            if (imageUrl.isNotEmpty)
              buildImageSection(
                "Uploaded MRI Scan",
                imageUrl,
              ),

            const SizedBox(height: 20),

            // HEATMAP IMAGE
            if (heatmapUrl.isNotEmpty)
              buildImageSection(
                "AI Explanation Heatmap",
                heatmapUrl,
              ),

            const SizedBox(height: 20),

            // FEATURE SCORES
            if (features.isNotEmpty)
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tumor Analysis",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),

                  buildFeatureCard(
                    "Asymmetry",
                    features["asymmetry"] ?? 0,
                    Icons.flip,
                  ),

                  buildFeatureCard(
                    "Texture",
                    features["texture"] ?? 0,
                    Icons.texture,
                  ),

                  buildFeatureCard(
                    "Boundary",
                    features["boundary"] ?? 0,
                    Icons.crop_square,
                  ),

                  buildFeatureCard(
                    "Tumor Area",
                    features["tumor_area"] ?? 0,
                    Icons.blur_on,
                  ),
                ],
              ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text(
                "Ask AI about this result",
              ),
              onPressed: result.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            userEmail:
                                widget.userEmail,
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