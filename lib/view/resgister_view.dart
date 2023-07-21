import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ipssisqy2023/controller/animation_controller.dart';
import 'package:ipssisqy2023/controller/firestore_helper.dart';
import 'package:ipssisqy2023/globale.dart';
import 'package:ipssisqy2023/view/dashboard_view.dart';
import 'package:ipssisqy2023/view/my_background.dart';
import 'package:lottie/lottie.dart';

class MyRegisterView extends StatefulWidget {
  const MyRegisterView({super.key});

  @override
  State<MyRegisterView> createState() => _MyRegisterViewState();
}

class _MyRegisterViewState extends State<MyRegisterView> {
  //variable
  TextEditingController mail = TextEditingController(text: "clement@gmail.com");
  TextEditingController password = TextEditingController(text: "azerty123");
  TextEditingController nom = TextEditingController();
  TextEditingController prenom = TextEditingController();

  //fonction
  MyPopError(dynamic erreur){
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context){
          if(Platform.isIOS){
            return CupertinoAlertDialog(
              title: const Text("Erreur de connexion"),
              content: Text(erreur.toString()),
              actions: [
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: const Text("OK")
                )
              ],
            );
          }
          else
            {
              return AlertDialog(
                title: const Text("Erreur de connexion"),
                content: Text(erreur.toString()),
                actions: [
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: const Text("OK")
                  )
                ],
              );
            }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // title: const Text("Connexion"),
            // backgroundColor: Colors.purple,
            // centerTitle : true
            backgroundColor: Colors.transparent,
            elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body:  Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                  child : Padding(
                      padding : const EdgeInsets.all(10),
                      child : Center(
                          child :   Column(
                              mainAxisAlignment : MainAxisAlignment.center,
                              children : [
                                MyAnimationController(
                                  delay: 1,
                                  child: Container(
                                      height : 250,
                                      width : 350,
                                      child: Lottie.asset("assets/anim_login.json"),
                                  ),
                                ),

                                const SizedBox(height : 15),
                                MyAnimationController(
                                  delay: 2,
                                  child: TextField(
                                      controller: prenom,
                                      decoration : InputDecoration(
                                          hintText: "Entrer votre prénom",
                                          prefixIcon : const Icon(Icons.person),
                                          border : OutlineInputBorder(
                                            borderRadius : BorderRadius.circular(15),
                                          )
                                      )
                                  ),
                                ),

                                const SizedBox(height : 15),
                                //adresse mail
                                MyAnimationController(
                                  delay: 2,
                                  child: TextField(
                                      controller: nom,
                                      decoration : InputDecoration(
                                          hintText: "Entrer votre nom",
                                          prefixIcon : const Icon(Icons.badge),
                                          border : OutlineInputBorder(
                                            borderRadius : BorderRadius.circular(15),
                                          )
                                      )
                                  ),
                                ),

                                const SizedBox(height : 15),
                                MyAnimationController(
                                  delay: 2,
                                  child: TextField(
                                    controller: mail,
                                      decoration : InputDecoration(
                                          hintText: "Entrer votre adresse mail",
                                          prefixIcon : const Icon(Icons.mail),
                                          border : OutlineInputBorder(
                                            borderRadius : BorderRadius.circular(15),

                                          )

                                      )

                                  ),
                                ),

                                const SizedBox(height : 15),
                                MyAnimationController(
                                  delay: 3,
                                  child: TextField(
                                    controller : password,
                                    obscureText : true,
                                    decoration : InputDecoration(
                                        hintText: "Entrer votre mot de passe",
                                        prefixIcon : const Icon(Icons.lock),

                                        border : OutlineInputBorder(
                                          borderRadius : BorderRadius.circular(15),

                                        )

                                    ),

                                  ),
                                ),

                                const SizedBox(height : 15),
                                MyAnimationController(
                                  delay: 4,
                                  child: ElevatedButton(
                                      style : ElevatedButton.styleFrom(
                                          backgroundColor : Colors.blueAccent,
                                          shape : const StadiumBorder()
                                      ),
                                      onPressed : (){
                                        FirestoreHelper().connect(mail.text, password.text).then((value){
                                          setState(() {
                                            me = value;
                                          });
                                          Navigator.push(context,MaterialPageRoute(
                                              builder : (context){
                                                return const MyDashBoardView();
                                              }
                                          ));
                                        }).catchError((onError){
                                          print(onError);
                                          MyPopError(onError);
                                        });
                                      },

                                      child : const Text("Connexion")
                                  ),
                                ),
                                MyAnimationController(
                                    delay: 6,
                                    child: TextButton(
                                      onPressed: (){

                                        FirestoreHelper().register(mail.text, password.text,nom.text,prenom.text).then((value){
                                          setState(() {
                                            me = value;
                                          });
                                          Navigator.push(context,MaterialPageRoute(
                                              builder : (context){
                                                return const MyDashBoardView();
                                              }

                                          ));
                                        }).catchError((onError){
                                          print(onError);
                                        });
                                      },
                                      child: const Text("Inscription"),
                                    )
                                )
                              ]
                          )
                      )
                  )
              ),
            ),
          ],
        )
    );
  }
}
