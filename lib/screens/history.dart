import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final String userEmail;

  const HistoryScreen({super.key, required this.userEmail});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<dynamic>> historyFuture;

  @override
  void initState() {
    super.initState();
    historyFuture = ApiService.getHistory(widget.userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prediction History")),
      body: FutureBuilder<List<dynamic>>(
        future: historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load history"));
          }

          final history = snapshot.data!;

          if (history.isEmpty) {
            return const Center(child: Text("No predictions yet"));
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Image.network(
                            item["image_url"],   // 👈 must match backend key
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                  title: Text(
                    item["prediction"].toString().toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Confidence: ${item["confidence"]}%\nTime: ${item["timestamp"]}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
