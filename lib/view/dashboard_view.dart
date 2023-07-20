import 'package:flutter/material.dart';
import 'package:ipssisqy2023/controller/all_utilisateur.dart';
import 'package:ipssisqy2023/controller/mes_favoris.dart';
import 'package:ipssisqy2023/view/my_drawer.dart';
import 'package:ipssisqy2023/view/my_map_view.dart';
import 'package:ipssisqy2023/view/resgister_view.dart';

class MyDashBoardView extends StatefulWidget {
  const MyDashBoardView({super.key});

  @override
  State<MyDashBoardView> createState() => _MyDashBoardViewState();
}

class _MyDashBoardViewState extends State<MyDashBoardView> {
  //variable
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(
        width: MediaQuery.of(context).size.width *0.75,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: const MyDrawer(),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: bodyPage(),
          ),
          const Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 16.0),
                // FloatingActionButton.extended(
                //   onPressed: (){},
                //   heroTag: 'message',
                //   elevation: 0,
                //   backgroundColor: Colors.deepPurpleAccent,
                //   label: const Text("Message"),
                //   icon: const Icon(Icons.message_rounded),
                // ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: [Colors.lightBlueAccent, Colors.redAccent, Colors.green][currentIndex],
        currentIndex: currentIndex,
        onTap: (index){
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon:  Icon(Icons.person),
            label: "Utilisateurs",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Mes amis"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: "Carte"
          ),
        ],
      ),
    );
  }


  Widget bodyPage(){
    switch(currentIndex){
      case 0 : return const AllUsers();
      case 1 : return const MyFavorites();
      case 2 : return const MyMapView();
      default: return const Text("Probleme d'affichage");
    }
  }
}
