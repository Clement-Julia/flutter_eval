import 'package:flutter/material.dart';
import 'package:ipssisqy2023/controller/firestore_helper.dart';
import 'package:ipssisqy2023/controller/preview_user.dart';
import 'package:ipssisqy2023/globale.dart';
import 'package:ipssisqy2023/model/my_user.dart';

class MyFavorites extends StatefulWidget {
  const MyFavorites({super.key});

  @override
  State<MyFavorites> createState() => _MyFavoritesState();
}

class _MyFavoritesState extends State<MyFavorites> {
  List<MyUser> maListeAmis = [];

  @override
  void initState() {
    // TODO: implement initState
    for(var uid in me.favoris!){
      FirestoreHelper().getUser(uid).then((value){
        setState(() {
          maListeAmis.add(value);
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: maListeAmis.length,
        itemBuilder: (context,index){
          MyUser otherUser = maListeAmis[index];
          if(me.id == otherUser.id){
            return Container();
          } else {
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.redAccent,
              child: ListTile(
                leading: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(otherUser.avatar ?? defaultImage),
                          fit: BoxFit.fill
                      )
                  ),
                ),
                title: Text(otherUser.fullName),
                subtitle: Text(otherUser.mail),
                trailing: IconButton(
                    icon: Icon(Icons.heart_broken ,color: (me.favoris!.contains(otherUser.id))?Colors.brown:Colors.grey,),
                    onPressed: (){
                      setState(() {
                          me.favoris!.remove(otherUser.id);
                          Map<String,dynamic> map = {
                            "FAVORIS": me.favoris
                          };
                          FirestoreHelper().updateUser(me.id, map);
                          maListeAmis.remove(otherUser);
                      });
                    }
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreviewUser(utilisateur: otherUser),
                    ),
                  );
                },
              ),
            );
          }

        }
    );
  }
}
