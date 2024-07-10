import 'dart:io';

import 'package:chat_app1/const.dart';
import 'package:chat_app1/models/chat.dart';
import 'package:chat_app1/models/message.dart';
import 'package:chat_app1/models/user_profile.dart';
import 'package:chat_app1/service/auth_service.dart';
import 'package:chat_app1/service/database_service.dart';
import 'package:chat_app1/service/media_service.dart';
import 'package:chat_app1/service/storage_service.dart';
import 'package:chat_app1/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';

class ChatPage extends StatefulWidget {
  UserProfile chatUser;
  ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late MediaService _mediaService;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  ChatUser? currentUser, otherUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _storageService = _getIt.get<StorageService>();
    _mediaService = _getIt.get<MediaService>();
    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
      
    );
    otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
      profileImage: widget.chatUser.pfpURL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.chatUser.pfpURL!),
                radius: 15,
              ),
              SizedBox(
                width: 5,
              ),
              Text(widget.chatUser.name!)
            ],
          ),
        ),
        body: StreamBuilder(
          stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
          builder: (context, snapshot) {
            Chat? chat = snapshot.data?.data();
            List<ChatMessage> message = [];
            if (chat != null && chat.messages != null) {
              message = _generateChatMessageList(chat.messages!);
            }
            return DashChat(
              messageOptions: MessageOptions(
                showOtherUsersAvatar: true,
                showTime: true,
              ),
              inputOptions: InputOptions(alwaysShowSend: true, trailing: [
                IconButton(
                    onPressed: () async {
                      File? file = await _mediaService.getImageFromGallery();
                      if (file != null) {
                        String chatID = generateChatID(
                            uid1: currentUser!.id, uid2: otherUser!.id);
                        String? downloadURL = await _storageService
                            .uploadImageToChat(file: file, chatID: chatID);
                        if (downloadURL != null) {
                          ChatMessage chatMessage = ChatMessage(
                              user: currentUser!,
                              createdAt: DateTime.now(),
                              medias: [
                                ChatMedia(
                                    url: downloadURL,
                                    fileName: "",
                                    type: MediaType.image)
                              ]);
                          _sendMessage(chatMessage);
                        }
                      }
                    },
                    icon: Icon(
                      Icons.image,
                      color: Color.fromARGB(255, 76, 5, 88),
                    ))
              ]),
              currentUser: currentUser!,
              onSend: _sendMessage,
              messages: message,
            );
          },
        ));
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await _databaseService.sendChatMessage(
            currentUser!.id, otherUser!.id, message);
      }
    } else {
      Message message = Message(
          senderID: currentUser!.id,
          content: chatMessage.text,
          messageType: MessageType.Text,
          sentAt: Timestamp.fromDate(chatMessage.createdAt));
      await _databaseService.sendChatMessage(
          currentUser!.id, otherUser!.id, message);
    }
  }

  List<ChatMessage> _generateChatMessageList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map(
      (e) {
        if (e.messageType == MessageType.Image) {
          return ChatMessage(
            user: e.senderID == currentUser!.id ? currentUser! : otherUser!,
            createdAt: e.sentAt!.toDate(),
            medias: [
              ChatMedia(url: e.content!, fileName: "", type: MediaType.image)
            ],
          );
        } else {
          return ChatMessage(
            user: e.senderID == currentUser!.id ? currentUser! : otherUser!,
            text: e.content!,
            createdAt: e.sentAt!.toDate(),
          );
        }
      },
    ).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }
}
