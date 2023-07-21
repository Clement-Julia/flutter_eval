import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ipssisqy2023/controller/firestore_helper.dart';
import 'package:ipssisqy2023/globale.dart';
import 'package:ipssisqy2023/model/my_user.dart';
import 'package:ipssisqy2023/view/conversation_view.dart';

class ListConversationPage extends StatefulWidget {
  @override
  _ListConversationPageState createState() => _ListConversationPageState();
}

class _ListConversationPageState extends State<ListConversationPage> {
  List<String> _uniqueRecipients = [];

  @override
  void initState() {
    super.initState();
    _loadUserAndConversation();
  }

  Future<void> _loadUserAndConversation() async {
    final user = await FirestoreHelper().getUser(me.id);
    _updateUniqueRecipients(user);
  }

  void _updateUniqueRecipients(MyUser user) {
    setState(() {
      _uniqueRecipients = user.getUniqueRecipients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: ListView.builder(
        itemCount: _uniqueRecipients.length,
        itemBuilder: (context, index) {
          final recipientId = _uniqueRecipients[index];
          final lastMessage = me.getLastMessageWithRecipient(recipientId);

          return FutureBuilder<MyUser>(
            future: FirestoreHelper().getUser(_uniqueRecipients[index]),
            builder: (BuildContext context, AsyncSnapshot<MyUser> snapshot) {
              MyUser user = snapshot.data ?? MyUser.empty();

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                color: Colors.lightBlueAccent,
                child: ListTile(
                  leading: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(user.avatar ?? defaultImage),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  title: Text(user.fullName),
                  subtitle: FutureBuilder<String?>(
                    future: lastMessage,
                    builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Text(
                          snapshot.data ?? "",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationPage(uuid: recipientId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

