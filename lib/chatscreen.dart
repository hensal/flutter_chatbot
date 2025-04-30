import 'package:flutter/material.dart';
import 'chat_service.dart'; // Import the ChatService class

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  final ChatService chatService = ChatService(); // Create instance of ChatService

  // Method to scroll to the bottom of the chat
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Method to handle sending a message and getting a response
  Future<void> _sendMessage(String message) async {
    setState(() {
      messages.add({"user": message});
      isLoading = true;
    });

    // Get response from the server using ChatService
    String response = await chatService.sendMessage(message);

    setState(() {
      messages.add({"bot": response});
      isLoading = false;
    });

    // Scroll to the bottom after a new message is added
    _scrollToBottom();
  }

  // Method to clear the chat
  void _clearChat() {
    setState(() {
      messages.clear(); // Clear the chat messages
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
        actions: [
          // Row with "Clear Chat" text and IconButton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, 
              children: [
                const Flexible(
                  child: Text(
                    'Clear Chat',
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis, 
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: _clearChat, // Clear chat when pressed
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController, // Scrollable view for the messages
              child: Column(
                children: [
                  // Display user messages
                  ...messages.map((message) {
                    final isUser = message.containsKey("user");
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isUser ? message["user"]! : message["bot"]!,
                          style: TextStyle(
                              color: isUser ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Wrap TextField with Expanded to prevent overflow
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (text) {
                      if (text.isNotEmpty) {
                        _sendMessage(text); // Send message using ChatService
                        _controller.clear(); // Clear input field after sending message
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text); // Send message using ChatService
                      _controller.clear();  // Clear input field after sending message
                    }
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
