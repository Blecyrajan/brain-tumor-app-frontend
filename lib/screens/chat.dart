import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


class ChatScreen extends StatefulWidget {
  final String userEmail;
  final String prediction;

  const ChatScreen({
    super.key,
    required this.userEmail,
    required this.prediction,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();

    // Initial system message
    messages.add({
      "role": "assistant",
      "content":
          "You can ask me questions about the predicted condition: ${widget.prediction}. "
          "I will provide educational explanations only."
    });
  }

  Future<void> sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "content": question});
      loading = true;
    });

    _controller.clear();

    final answer = await ApiService.chatWithContext(
      widget.userEmail,
      question,
      widget.prediction,
    );

    setState(() {
      messages.add({"role": "assistant", "content": answer});
      loading = false;
    });
  }

  Widget buildMessage(Map<String, String> message) {
    final isUser = message["role"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser ? Colors.indigo.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: MarkdownBody(
          data: message["content"] ?? "",
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(fontSize: 15),
            strong: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ask AI"),
      ),
      body: Column(
        children: [
          // Prediction context banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.indigo.shade50,
            child: Text(
              "Predicted condition: ${widget.prediction}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),

          if (loading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          // Input box
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask about this condition...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: loading ? null : sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
