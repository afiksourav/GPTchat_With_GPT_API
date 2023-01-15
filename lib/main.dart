// ignore: unused_import
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpt_chat/const.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;

import 'model.dart';
import 'controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late bool isLoading = false;
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: botBackgroundColor,
          toolbarHeight: 100,
          title: Padding(
            padding: EdgeInsets.all(0.8),
            child: Text(
              "OpenAI's ChatGpt Flutter Example \n@Afik Sourav",
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            //chat body
            Expanded(child: _buildList()),
            Visibility(
              visible: isLoading,
              child: const Padding(
                padding: EdgeInsets.all(0.8),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  //input field
                  _buildInput(),
                  //submit
                  _buildSubmit(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          color: Colors.white,
        ),
        controller: _textController,
        decoration: const InputDecoration(
            fillColor: botBackgroundColor,
            filled: true,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none),
      ),
    );
  }

  _buildSubmit() {
    return Visibility(
        visible: !isLoading,
        child: Container(
          color: botBackgroundColor,
          child: IconButton(
            icon: const Icon(
              Icons.send_rounded,
              color: Color.fromRGBO(142, 142, 160, 1),
            ),
            onPressed: () {
              //display user input
              setState(() {
                _messages.add(ChatMessage(
                    text: _textController.text,
                    chatMessageType: ChatMessageType.user));
                isLoading = true;
              });
              var input = _textController.text;
              _textController.clear();

              //call chatbot api

              ResponseController().generateResponse(input).then((value) {
                setState(() {
                  isLoading = false;
                  // display respose
                  _messages.add(ChatMessage(
                    text: value,
                    chatMessageType: ChatMessageType.bot,
                  ));
                });
                _textController.clear();
              });
            },
          ),
        ));
  }

  _buildList() {
    return ListView.builder(
        itemCount: _messages.length,
        itemBuilder: ((context, index) {
          var message = _messages[index];
          // print("Message${_messages[index].text}");
          return ChatMessageWidget(
            text: message.text,
            chatMessageType: message.chatMessageType,
          );
        }));
  }
}

class ChatMessageWidget extends StatelessWidget {
  final String text;
  final ChatMessageType chatMessageType;
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      color: chatMessageType == ChatMessageType.bot
          ? botBackgroundColor
          : backgroundColor,
      child: Row(
        children: [
          chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: const Color.fromRGBO(16, 163, 127, 1),
                    child: Image.asset(
                      "assets/chat-gpt-logo.jpg",
                      scale: 1.5,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: const CircleAvatar(child: Icon(Icons.person)),
                ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white),
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
