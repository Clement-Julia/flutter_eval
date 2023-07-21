import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:ipssisqy2023/controller/firestore_helper.dart';
import 'package:ipssisqy2023/globale.dart';
import 'package:ipssisqy2023/model/my_user.dart';

class ConversationPage extends StatefulWidget {
  final String uuid;

  ConversationPage({required this.uuid});

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _editingController = TextEditingController();
  MyUser _user = MyUser.empty();
  List<dynamic> _conversationMessages = [];
  int _selectedMessageIndex = -1;
  final _messageMenuController = _MessageMenuController();

  @override
  void initState() {
    super.initState();
    _loadUserAndConversation();
  }

  Future<void> _loadUserAndConversation() async {
    final user = await FirestoreHelper().getUser(widget.uuid);
    final myConversation = me.conversation as List<dynamic>;
    List<dynamic> conversation = user.conversation as List<dynamic>;

    final myMessages = myConversation.where((message) => message['sentTo'] == user.id);
    final otherUserMessages = conversation.where((message) => message['sentTo'] == me.id);
    final mergedMessages = [...myMessages, ...otherUserMessages]
      ..sort((a, b) => b['date'].compareTo(a['date']));

    _updateConversationMessages(mergedMessages);
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(_user.avatar ?? defaultImage),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(_user.fullName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _conversationMessages.length,
              itemBuilder: (context, index) {
                final messageData = _conversationMessages[index] as Map<String, dynamic>;
                final message = messageData['message'];
                final sentBy = messageData['sentBy'];
                final isSentByMe = sentBy == me.id;

                final messageKey = GlobalKey();

                return GestureDetector(
                  key: messageKey,
                  onTap: () {
                    setState(() {
                      if (_selectedMessageIndex == index) {
                        _selectedMessageIndex = -1;
                      } else {
                        _selectedMessageIndex = index;
                      }
                    });
                  },
                  onLongPress: () {
                    final RenderBox box = messageKey.currentContext!.findRenderObject() as RenderBox;
                    final position = box.localToGlobal(Offset.zero);

                    setState(() {
                      _messageMenuController.selectedIndex = index;
                    });

                    final menuItems = _buildMessageContextMenuItems(messageData, index);
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        position.dx,
                        position.dy,
                        position.dx + box.size.width,
                        position.dy + box.size.height,
                      ),
                      items: menuItems,
                      elevation: 8,
                    ).then((value) {
                      _messageMenuController.closeMenu();
                    });
                  },
                  child: Column(
                    children: [
                      ListTile(
                        title: Align(
                          alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSentByMe ? Colors.blue : Colors.grey,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              message,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        // trailing: isSentByMe ? PopupMenuButton<MessageOption>(
                        //   itemBuilder: (context) => [
                        //     const PopupMenuItem(value: MessageOption.copy,child: Text('Copier')),
                        //     const PopupMenuItem(value: MessageOption.edit,child: Text('Modifier')),
                        //     const PopupMenuItem(value: MessageOption.delete,child: Text('Supprimer')),
                        //   ],
                        //   onSelected: (option) {
                        //     _onMessageOptionSelected(option, message, index);
                        //   },
                        // ) : null,
                      ),
                      if (_selectedMessageIndex == index)
                        Align(
                          alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8, right: 20, left: 20),
                            child: Text(
                              _formatDateTime(messageData['date']),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
                  ),
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
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Écrire un message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.extended(
                  onPressed: () {
                    _sendMessage();
                  },
                  label: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      FirestoreHelper().sendMessage(me.id, _user.id, message).then((value) {
        me = value as MyUser;
        _loadUserAndConversation();
      });
      _messageController.clear();
    }
  }

  void _updateConversationMessages(List<dynamic> conversation) {
    setState(() {
      _conversationMessages = conversation;
    });
  }

  void _onMessageOptionSelected(MessageOption option, String message, int index) {
    if (option == MessageOption.edit) {
      setState(() {
        _selectedMessageIndex = index;
      });
      _showEditMessageDialog(message);
    } else {
      switch (option) {
        case MessageOption.edit:
          break;
        case MessageOption.copy:
          Clipboard.setData(ClipboardData(text: message));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message copié dans le presse-papiers')),
          );
          break;
        case MessageOption.delete:
          break;
      }
    }
  }

  void _showEditMessageDialog(String currentMessage) {
    _editingController.text = currentMessage;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le message'),
          content: TextField(
            controller: _editingController,
            decoration: const InputDecoration(hintText: 'Entrez votre nouveau message'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _saveEditedMessage();
                Navigator.pop(context);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _saveEditedMessage() {
    final String editedMessage = _editingController.text.trim();
    if (editedMessage.isNotEmpty) {
      _conversationMessages[_selectedMessageIndex]['message'] = editedMessage;
      final myMessages = _conversationMessages.where((message) => message['sentBy'] == me.id);
      Map<String,dynamic> map = {
        "CONVERSATION": myMessages
      };

      FirestoreHelper().updateUser(me.id, map);
      _loadUserAndConversation();
    }
  }

  List<PopupMenuEntry<MessageOption>> _buildMessageContextMenuItems(Map<String, dynamic> messageData, int index) {
    final List<PopupMenuEntry<MessageOption>> menuItems = [];

    if (_messageMenuController.selectedIndex == index) {
      menuItems.add(
        const PopupMenuItem<MessageOption>(
          value: MessageOption.copy,
          child: Text('Copier'),
        ),
      );
      menuItems.add(
        const PopupMenuItem<MessageOption>(
          value: MessageOption.edit,
          child: Text('Modifier'),
        ),
      );
      menuItems.add(
        const PopupMenuItem<MessageOption>(
          value: MessageOption.delete,
          child: Text('Supprimer'),
        ),
      );
    }

    return menuItems;
  }

  String _formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }
}

class _MessageMenuController {
  int selectedIndex = -1;
  void closeMenu() {
    selectedIndex = -1;
  }
}