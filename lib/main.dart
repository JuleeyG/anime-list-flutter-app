// ****** Reactive Flutter App ******
// Start Date: May 28, Hours: 20
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anime_lists/detailPage.dart';

// TODO: Animate the list

Future<void> main() async {
  // Initializes Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Makes it visible to the screen
  runApp(AnimeList(),);
}

class AnimeList extends StatefulWidget {
  @override
  State<AnimeList> createState() => _AnimeListState();
}

// Menu items to be selected
enum DrawerSelection {newA, watchedA}

class _AnimeListState extends State<AnimeList> {

  // Collections of completed and new anime in firebase
  CollectionReference animes = FirebaseFirestore.instance.collection('animes');
  CollectionReference nanimes = FirebaseFirestore.instance.collection('nanimes');
  
  // Length of both lists
  int length1 = 0;
  int length2 = 0;

  // Captures user text from bottom app bar
  final textController = TextEditingController();

  // Currently selected menu item
  DrawerSelection _drawerSelection = DrawerSelection.newA;

  // Lists filter options
  List<String> dropDown = <String>['NAME','RATING', 'STATUS','PREMIERED'];

  // Currently selected filter
  String _sortSelection = 'NAME';

  // Currently selected filter and anime list type used to change stream of firebase data
  String field = 'name';
  String animeListType = 'new';
  bool desc = false;

  // Filters the anime list by changing the stream of data
  void sortList(String item){

    // Sort by rating
    if(item.compareTo('rating') == 0) {
      _sortSelection = 'RATING';
      desc = true;
    }

    // Sort list alphabetically
    if(item.compareTo('name') == 0) {
      _sortSelection = 'NAME';
      desc = false;
    }

    // Sort by ongoing status first (a green button appears)
    if(item.compareTo('status') == 0){
      _sortSelection = 'STATUS';
      desc = true;
    }

    // Sort by the date it aired
    if(item.compareTo('premiered') == 0){
      _sortSelection = 'PREMIERED';
      desc = true;
    }

    // Update stream of data to sort the list
    field = item;
  }

  @override
  Widget build(BuildContext context) {

    // Grab snapshots of to-be watched and completed anime to display
    Stream<QuerySnapshot> nsnap = nanimes.orderBy(field, descending: desc).snapshots();
    Stream<QuerySnapshot> asnap = animes.orderBy(field, descending: desc).snapshots();

    // Toggle between to-be watched and watched list
    Stream<QuerySnapshot> toggleStreams(String field){

      // Display the new anime to the screen
      if(field.compareTo('new') == 0){
          animeListType = 'new';
          return nsnap;
        }
      // Display the watched anime to screen
      else {
          animeListType = 'watched';
          return asnap;
        }
    }

    // This is where all the widgets on the screen are
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Sora',
        textTheme:
          const TextTheme(
            subtitle1: TextStyle(color: Colors.white70),
            headline2: TextStyle(color: Colors.deepPurpleAccent),
            bodyText2: TextStyle(color: Colors.deepPurpleAccent),
          ),
      ),


      home: Builder(
        builder: (context) {

          return Container(
            // Sets scaffold's background image using decoration tag
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("images/scaffold-background.jpg"),
                colorFilter: ColorFilter.mode(
                    const Color(0xff121f27).withOpacity(0.7),
                    BlendMode.darken
                ),
              ),
            ),

            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Colors.transparent,

              // Create a title bar that displays a list filter and menu drawer
              appBar: AppBar(
                // Removes the shadow
                elevation: 0,

                backgroundColor: const Color(0xff121f27).withOpacity(0.9),

                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text('Anime'),

                    DropdownButton<String>(
                        underline: Container(),
                        icon: const Icon(Icons.sort,color: Colors.white),
                        value: _sortSelection,
                        dropdownColor: Colors.teal[300],
                        borderRadius: BorderRadius.circular(10),
                        style: const TextStyle(color: Colors.white),
                        items: dropDown.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      onChanged: (value){
                        setState(() {
                          sortList(value.toString().toLowerCase());
                        });
                      },
                    )
                  ],
                ),

                centerTitle: true,
              ),

              // Displays either anime list
              body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                // Horizontally scroll through the completed and new anime lists
                children: [

                  // TOdo: Have is so when you tab a subtitle, the list resets
                  Text("Watch Later ($length1)", style: const TextStyle(color: Colors.white)),
                  StreamBuilder(
                    stream:  nsnap,//toggleStreams(animeListType),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      return !snapshot.hasData
                      ? const Center(child: Text('Loading'),)
                      :
                      // Displays the list
                      SizedBox(
                        height: 210,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(12),
                            itemCount: snapshot.data?.docs.length.toInt() ?? 0,
                            separatorBuilder: (context, index) {
                              return const SizedBox(width: 12);
                            },
                            itemBuilder: (context, index) {
                              length1 = snapshot.data?.docs.length.toInt() ?? 0;
                              String name = snapshot.data?.docs[index]['name'];
                              String rating = snapshot.data?.docs[index]['rating'];
                              String status = snapshot.data?.docs[index]['status'];

                              return buildCard(name, rating, status);
                            },

                        ),
                      );
                    }),
                  Text("Completed ($length2)", style: const TextStyle(color: Colors.white), textAlign: TextAlign.start,),
                  StreamBuilder(
                      stream:  asnap,//toggleStreams(animeListType),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        return !snapshot.hasData
                            ? const Center(child: Text('Loading'),)
                            :
                        // Displays the list
                        SizedBox(
                          height: 210,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(12),
                            itemCount: snapshot.data?.docs.length.toInt() ?? 0,
                            separatorBuilder: (context, index) {
                              return const SizedBox(width: 12);
                            },
                            itemBuilder: (context, index) {
                              length2 = snapshot.data?.docs.length.toInt() ?? 0;
                              String name = snapshot.data?.docs[index]['name'];
                              String rating = snapshot.data?.docs[index]['rating'];
                              String status = snapshot.data?.docs[index]['status'];

                              return buildCard(name, rating, status);
                            },

                          ),
                        );
                      }),
                ],
              ),

              // User inputs anime to be added to the list
              bottomSheet: BottomAppBar(
                color: const Color(0xff121f27),
                child: TextField(
                  controller: textController,
                ),
              ),

              // Users taps button to add new anime
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.teal[300],
                child: const Icon(Icons.add),
                onPressed: (){ // New anime
                  if(_drawerSelection == DrawerSelection.newA) {
                    nanimes.add({
                      'name': textController.text,
                      'rating': '1',
                      'premiered':'',
                      'status':'',
                      'source':'',
                      'studios':'',
                      'episodes':'',
                      'genres':''
                    });
                  }else {// Watched anime
                    animes.add({
                      'name': textController.text,
                      'rating': '1',
                      'premiered':'',
                      'status':'',
                      'source':'',
                      'studios':'',
                      'episodes':'',
                      'genres':''
                    });
                  }
                  textController.clear();
                },
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
              // Scaffold body

              // Create a drawer to view either new or completed anime
              endDrawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,

                  children: [
                    const UserAccountsDrawerHeader(
                      accountName: Text('Juleeyah W'),

                      accountEmail: Text('Juleeyahwright@example.com'),

                      currentAccountPicture: CircleAvatar(
                        child: ClipOval(
                          child: Image(image: AssetImage('images/avatar-icon.jpg')),
                        ),
                      ),

                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.fill,

                            image: NetworkImage('https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')
                        ),
                      ),
                    ),

                    ListTile(
                      selected: _drawerSelection == DrawerSelection.newA,

                      leading: const Icon(Icons.favorite),

                      title: const Text('Watching'),

                      onTap:() => {
                        setState(() {
                          _drawerSelection = DrawerSelection.newA;
                          toggleStreams('new');
                        })
                      },
                    ),

                    ListTile(
                      selected: _drawerSelection == DrawerSelection.watchedA,

                      leading: const Icon(Icons.favorite),

                      title: const Text('Completed'),

                      onTap:() => {
                        setState(() {
                          _drawerSelection = DrawerSelection.watchedA;
                          toggleStreams('watched');
                        })
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  // TODO: Add images to each card
  // Populate an individual anime with its image, name, and rating
  Widget buildCard(String name, String rating, String status) {
    return InkWell(
      onTap: () {
        debugPrint("Card has been tapped");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const detailPage()) // TODO fix this
        );
        },
      onLongPress: (){debugPrint("Somehow delete the app");},
      child: SizedBox(
        width: 140,
        height: 140,

        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset("images/avatar-icon.jpg")
              ),
              Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),),
              Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(rating,  style: TextStyle(fontSize: 10, color: Colors.teal[300], fontWeight: FontWeight.bold,)),
                    const Icon(Icons.star, size: 15, color: Colors.white70,),
                  ]
              ),
            ],
        ),
        ),
      ),
    );
  }
}

// Create a second route to navigate to
class SecondRoute extends StatelessWidget {
  const SecondRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}