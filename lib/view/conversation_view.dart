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
      print("AAAAAAAAAAAAA");
      print(_user.avatar);
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
                      if(isSentByMe) {
                        final RenderBox box = messageKey.currentContext!.findRenderObject() as RenderBox;
                        final position = box.localToGlobal(Offset.zero);

                        setState(() {
                          _messageMenuController.selectedIndex = index;
                        });

                        final menuItems = _buildMessageContextMenuItems(message, index);
                        showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            position.dx + box.size.width,
                            position.dy - (box.size.height * 3),
                            (position.dx + box.size.width) + 100,
                            position.dy + box.size.height,
                          ),
                          items: menuItems,
                          elevation: 8,
                        ).then((value) {
                          _messageMenuController.closeMenu();
                        });
                      }
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

  void _onMessageOptionSelected(MessageMenuAction option, String message, int index) {
    switch (option) {
      case MessageMenuAction.copy:
        Clipboard.setData(ClipboardData(text: message));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message copié dans le presse-papiers')),
        );
        break;
      case MessageMenuAction.edit:
        setState(() {
          _selectedMessageIndex = index;
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          _showEditMessageDialog(message);
        });
        break;
      case MessageMenuAction.delete:
        _deleteMessage(index);
        break;
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

  void _deleteMessage(int index) async {
    final deletedMessage = _conversationMessages.removeAt(index);
    final myMessages = _conversationMessages.where((message) => message['sentBy'] == me.id).toList();

    Map<String, dynamic> map = {
      "CONVERSATION": myMessages
    };

    try {
      await FirestoreHelper().updateUser(me.id, map);
      me.conversation = myMessages;
      _loadUserAndConversation();
    } catch (error) {
      _conversationMessages.insert(index, deletedMessage);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Une erreur est survenue'),
              content: const Text("Votre message n'a pas pu être supprimé"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          }
      );
    }
  }

  List<PopupMenuEntry<MessageMenuAction>> _buildMessageContextMenuItems(String message, int index) {
    final List<PopupMenuEntry<MessageMenuAction>> menuItems = [];

    if (_messageMenuController.selectedIndex == index) {
      menuItems.add(
        PopupMenuItem<MessageMenuAction>(
          value: MessageMenuAction.copy,
          child: const Text('Copier'),
          onTap: () {
            _onMessageOptionSelected(MessageMenuAction.copy, message, index);
          },
        ),
      );
      menuItems.add(
        PopupMenuItem<MessageMenuAction>(
          value: MessageMenuAction.edit,
          child: const Text('Modifier'),
          onTap: () {
            _onMessageOptionSelected(MessageMenuAction.edit, message, index);
          },
        ),
      );
      menuItems.add(
        PopupMenuItem<MessageMenuAction>(
          value: MessageMenuAction.delete,
          child: const Text('Supprimer'),
          onTap: () {
            _onMessageOptionSelected(MessageMenuAction.delete, message, index);
          },
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