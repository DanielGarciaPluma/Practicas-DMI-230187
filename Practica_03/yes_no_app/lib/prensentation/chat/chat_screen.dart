import 'package:flutter/material.dart';
import 'package:yes_no_app/prensentation/widgets/chat/my_message_bubble.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/f/fb/Minecraft-creeper-face.jpg?utm_source=es.wikipedia.org&utm_campaign=index&utm_content=original'),
                
          ),
        ),
        title: const Text('Minecraft Creeper'),
        centerTitle: false,
      ),
      body: _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
      
      child: Column(
          children: [

            Expanded(child: ListView.builder(
              itemCount: 100,
              itemBuilder:  (context, index) {
                return const MyMessageBubble();
              }))
          ],
        ),
      )
    );
  }
} 