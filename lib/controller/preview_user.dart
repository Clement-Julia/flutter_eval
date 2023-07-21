import 'package:flutter/material.dart';
import 'package:ipssisqy2023/controller/firestore_helper.dart';
import 'package:ipssisqy2023/globale.dart';
import 'package:ipssisqy2023/model/my_user.dart';
import 'package:ipssisqy2023/view/conversation_view.dart';

class PreviewUser extends StatefulWidget {
  final MyUser utilisateur;
  const PreviewUser({required this.utilisateur});

  @override
  _PreviewUserState createState() => _PreviewUserState();
}

class _PreviewUserState extends State<PreviewUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 80),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xff0043ba), Color(0xff006df1)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 35.00),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  widget.utilisateur.avatar ?? 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png',
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 8.0, left: 8.0),
              child: Column(
                children: [
                  Text(
                    widget.utilisateur.fullName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Text(
                      widget.utilisateur.mail,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () {
                          setState(() {
                            if(me.favoris!.contains(widget.utilisateur.id)){
                              me.favoris!.remove(widget.utilisateur.id);
                            }
                            else
                            {
                              me.favoris!.add(widget.utilisateur.id);
                            }
                            Map<String,dynamic> map = {
                              "FAVORIS":me.favoris
                            };
                            FirestoreHelper().updateUser(me.id, map);
                          });
                        },
                        heroTag: 'follow',
                        elevation: 0,
                        backgroundColor: (me.favoris != null && me.favoris?.contains(widget.utilisateur.id) == true) ? Colors.redAccent : Colors.lightBlueAccent,
                        label: (me.favoris != null && me.favoris?.contains(widget.utilisateur.id) == true) ? const Text("Unfollow") : const Text("Follow"),
                        icon: (me.favoris != null && me.favoris?.contains(widget.utilisateur.id) == true) ? const Icon(Icons.person_remove_alt_1) : const Icon(Icons.person_add_alt_1),
                      ),
                      const SizedBox(width: 16.0),
                      FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ConversationPage(uuid: widget.utilisateur.id)
                            ),
                          );
                        },
                        heroTag: 'message',
                        elevation: 0,
                        backgroundColor: Colors.deepPurpleAccent,
                        label: const Text("Message"),
                        icon: const Icon(Icons.message_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 80,
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "${widget.utilisateur.pseudo}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Pseudo",
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const VerticalDivider(),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: FutureBuilder<int>(
                                  future: FirestoreHelper().getCountFollowers(widget.utilisateur.id),
                                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (snapshot.hasError) {
                                      return const Text('0');
                                    } else {
                                      int followers = snapshot.data ?? 0;
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "$followers",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Followers",
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ),
                              const VerticalDivider(),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        widget.utilisateur.favoris != null ? "${widget.utilisateur.favoris!.length}" : "0",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Following",
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const VerticalDivider(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Couleur du bouton
          ),
          child: const Text('Retour'),
        ),
      ),
    );
  }
}
