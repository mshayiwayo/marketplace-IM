import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart'; // For kIsWeb

class ChatScreen extends StatefulWidget {
  final String username;
  final String targetUser;

  @override
  const ChatScreen({Key? key, required this.username, required this.targetUser})
      : super(key: key);
  //Widget build(BuildContext context) {
  //Retrieve arguments passed from the previous screen
  //final Map<String, dynamic>? args =
  //  ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

  //if (args != null && args.isNotEmpty) {
  //final String username = args['username'] ?? 'Unknown User';
  //final String targetUser = args['targetUser'] ?? 'Unknown Target';

  //return Scaffold(
  //appBar: AppBar(title: Text('Chat with $targetUser')),
  //body: Center(
  //child: Text('Chat screen between $username and $targetUser'),
  //),
  //);
  //} else {
  //return Scaffold(
  //appBar: AppBar(title: const Text('Error')),
  //body: const Center(
  //child: Text('No user data passed.'),
  //),
  //);
  //}
  //}

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late IO.Socket _socket;
  late String roomId;

  @override
  void initState() {
    super.initState();
    roomId = _generateRoomId(widget.username, widget.targetUser);
    connectToServer();
  }

  void connectToServer() {
    String serverUrl;

    // Determine the appropriate server URL for Android or Web (Chrome)
    if (kIsWeb) {
      serverUrl = 'http://localhost:3000'; // For Flutter Web (Chrome)
    } else {
      serverUrl = 'http://10.0.2.2:3000'; // For Android emulator
    }

    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect':
          false, // You can change this to true if you want to auto-connect
    });

    _socket.connect();

    _socket.on('connect', (_) {
      print('Connected to WebSocket on');
      _socket.emit('join room', {'roomId': roomId});
    });

    _socket.on('chat message', (data) {
      setState(() {
        _messages.add({
          'message': data['message'],
          'sender': data['sender'],
        });
      });
    });

    // In your Flutter client, listen for 'previous messages'
    _socket.on('previous messages', (data) {
      setState(() {
        for (var message in data) {
          _messages.add({
            'message': message['message'],
            'sender': message['sender'],
          });
        }
      });
    });

    _socket.on('disconnect', (_) {
      print('Disconnected from WebSocket');
    });
  }

  String _generateRoomId(String user1, String user2) {
    List<String> users = [user1, user2];
    users.sort();
    return users.join('_');
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      _socket.emit('private message', {
        'roomId': roomId,
        'message': message,
        'sender': widget.username,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Chat with ${widget.targetUser}'),
        leading: const Icon(Icons.arrow_back_ios),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isMe = _messages[index]['sender'] == widget.username;
// Modify this based on your logic to determine the message sender
                return ChatBubble(
                  message: _messages[index]['message'],
                  isMe: isMe,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Enter your message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, this.isMe = true});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15.0),
            topRight: const Radius.circular(15.0),
            bottomLeft:
                isMe ? const Radius.circular(15.0) : const Radius.circular(0.0),
            bottomRight:
                isMe ? const Radius.circular(0.0) : const Radius.circular(15.0),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}
