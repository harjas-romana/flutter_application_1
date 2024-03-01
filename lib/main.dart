import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Chat {
  final String name;
  late final String message;
  late final String time;
  late final bool sentByMe;

  Chat({
    required this.name,
    required this.message,
    required this.time,
    required this.sentByMe,
  });
}

class ChatsProvider extends ChangeNotifier {
  List<Chat> _chats = [];

  List<Chat> get chats => _chats;

  Future<void> loadChats() async {
    await Future.delayed(Duration(seconds: 1));
    _chats = [
      Chat(
          name: "John Doe",
          message: "Hello!",
          time: "10:00 AM",
          sentByMe: false),
      Chat(
          name: "Jane Smith",
          message: "Hi there!",
          time: "11:30 AM",
          sentByMe: false),
      Chat(name: "Alice", message: "Hey!", time: "12:00 PM", sentByMe: false),
      Chat(name: "Bob", message: "Hi!", time: "12:30 PM", sentByMe: false),
      Chat(
          name: "Charlie", message: "Hello!", time: "1:00 PM", sentByMe: false),
    ];
    notifyListeners();
  }

  void sendMessage(String name, String message) {
    final currentTime = DateTime.now().toString();
    final chatIndex = _chats.indexWhere((chat) => chat.name == name);
    if (chatIndex != -1) {
      _chats[chatIndex].message = message;
      _chats[chatIndex].time = currentTime;
      _chats[chatIndex].sentByMe = true;
    } else {
      _chats.add(Chat(
          name: name, message: message, time: currentTime, sentByMe: true));
    }
    notifyListeners();
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatsProvider(),
      child: MaterialApp(
        title: 'WhatsApp UI',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.grey[200],
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: ChatsScreen(),
      ),
    );
  }
}

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: Provider.of<ChatsProvider>(context, listen: false).loadChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading chats'),
            );
          } else {
            return Consumer<ChatsProvider>(
              builder: (context, chatsProvider, _) => ListView.builder(
                itemCount: chatsProvider.chats.length,
                itemBuilder: (context, index) {
                  final chat = chatsProvider.chats[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      child: Text(
                        chat.name.substring(0, 1),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(
                      chat.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(chat.message),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          chat.time,
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 5),
                        Icon(Icons.check_circle_outline,
                            color: chat.sentByMe ? Colors.blue : Colors.grey),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(chat: chat),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class ChatDetailScreen extends StatelessWidget {
  final Chat chat;

  const ChatDetailScreen({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatsProvider = Provider.of<ChatsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              child: Text(
                chat.name.substring(0, 1),
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(width: 10),
            Text(chat.name),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Align(
                      alignment: chat.sentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: chat.sentByMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          chat.message,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (message) {
                      chatsProvider.sendMessage(chat.name, message);
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
