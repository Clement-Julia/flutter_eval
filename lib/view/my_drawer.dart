import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ipssisqy2023/controller/firestore_helper.dart';
import 'package:ipssisqy2023/globale.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  //variable
  bool isSript = false;
  TextEditingController pseudo = TextEditingController();
  String? nameImage;
  Uint8List? bytesImages;

  //fonction
  popImage(){
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context){
         return CupertinoAlertDialog(
           title: const Text("Souhaitez-vous enregistrer cette image ?"),
           content: Image.memory(bytesImages!),
           actions: [
             TextButton(onPressed: (){
               Navigator.pop(context);
             },
                 child: const Text("Annulation")
             ),
             TextButton(
                 onPressed: (){
                   //effectuer l'enregsitrement
                   //stokcer notre image
                   FirestoreHelper().stockageData("images", me.id, nameImage!, bytesImages!).then((value){
                     setState(() {
                       me.avatar = value;
                     });
                   });
                   Map<String,dynamic> map = {
                     "AVATAR": me.avatar
                   };
                   //mettre à jour les informations de l'utilisateur
                   FirestoreHelper().updateUser(me.id, map);



                   Navigator.pop(context);

                 }, child: const Text("Enregistrement")
             ),
           ],
         );
        }
    );
  }

  accesPhoto() async{
    FilePickerResult? resultat = await FilePicker.platform.pickFiles(
      type: FileType.image,
        withData: true
    );
    if(resultat != null){
      nameImage = resultat.files.first.name;
      bytesImages = resultat.files.first.bytes;
      popImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Center(
            child: Column(
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: (){
                        accesPhoto();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 10.00),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(me.avatar ?? defaultImage),
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(
                    thickness: 0,
                    color: Colors.black,
                  ),
                ),
                ListTile(
                  leading: const  Icon(Icons.mail,color: Colors.black,),
                  title: Text(me.mail,style: const TextStyle(fontSize: 20),),
                ),
                ListTile(
                  leading: const  Icon(Icons.person,color: Colors.black,),
                  title: Text(me.fullName,style: const TextStyle(fontSize: 20),textAlign: TextAlign.left,),
                ),
                ListTile(
                  leading: const  Icon(Icons.account_circle,color: Colors.black,),
                  title: (isSript)?TextField(
                    controller: pseudo,
                    decoration: InputDecoration(
                      hintText: me.pseudo ?? ""
                    ),
                  ):Text(me.pseudo ?? "",style: const TextStyle(fontSize: 20),textAlign: TextAlign.left,),
                  trailing: IconButton(
                    icon: Icon((isSript)?Icons.fiber_manual_record:Icons.update),
                    onPressed: (){
                      if(isSript){
                        if(pseudo != null && pseudo.text != "" && pseudo.text != me.pseudo){
                          Map<String,dynamic> map = {
                            "PSEUDO": pseudo.text
                          };
                          setState(() {
                            me.pseudo = pseudo.text;
                          });
                          FirestoreHelper().updateUser(me.id, map);
                        }
                      }
                      setState(() {
                        isSript = !isSript;
                      });
                    },
                  ),
                ),
              ],
            )
        )
    );
  }
}

