import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'teammember.dart';
import 'popup_screen.dart';


// Sample code from https://github.com/pythonhubpy/YouTube/blob/Firebae-CRUD-Part-1/lib/main.dart#L19
// video https://www.youtube.com/watch?v=SmmCMDSj8ZU&list=PLtr8DfMFkiJu0lr1OKTDaoj44g-GGnFsn&index=10&t=291s

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swim Team MGT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirebaseDemo(),
    );
  }
}

class FirebaseDemo extends StatefulWidget {
  @override
  _FirebaseDemoState createState() => _FirebaseDemoState();
}

class _FirebaseDemoState extends State<FirebaseDemo> {
  //Initialize the DB collections and text fields
  final TextEditingController _newSwimmerTextField = TextEditingController();
  final TextEditingController _newTimeTextField = TextEditingController();

  CollectionReference swimmersCollectionDB;
  CollectionReference timesCollectionDB;
  //List<String> itemList = [];
  String swimmer_id;


 //== SWIMMER PAGE WIDGETS ==


  //Text field widget for entering a swimmer
  Widget nameTextFieldWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.7,
      child: TextField(
        controller: _newSwimmerTextField,
        style: TextStyle(fontSize: 22, color: Colors.black),
        decoration: InputDecoration(
          hintText: "Enter a Swimmer: ",
          hintStyle: TextStyle(fontSize: 22, color: Colors.black),
        ),
      ),
    );
  }

  //Button to add the swimmer to the list
  Widget addButtonWidget() {
    return SizedBox(
      child: ElevatedButton(
          onPressed: () async {
            //setState(() {
            //itemList.add(_newItemTextField.text);
            //_newItemTextField.clear();
            //Add the swimmer to the swimmer collection
            await swimmersCollectionDB.add({'item_name': _newSwimmerTextField.text, 'swim_image': getImage(1)}).then((value) => _newSwimmerTextField.clear());
            //});
          },
          child: IconButton( //icon of a plus sign, when clicked on adds the swimmer to the list
            icon: const Icon(Icons.add)
          )),
    );
  }

  //The input widget for the swimmers, calls the text field and add button widgets for each swimmer created
  Widget swimmerInputWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        nameTextFieldWidget(),
        SizedBox(width: 10,),
        addButtonWidget(),
      ],
    );
  }

  //Tile widget that holds the information gathered about each swimmer
  Widget swimmerTileWidget(snapshot, position) {
    return ListTile(
      leading:
        Image(image: AssetImage(snapshot.data.docs[position]['swim_image'])),
      //Time icon, when clicked on shows a list of the swimmer's times in a dialog pop-up box
      trailing: IconButton (
          icon : const Icon(Icons.access_time),
          onPressed: (){
            swimmer_id = snapshot.data.docs[position].id;
            viewTimes();
          },
      )
      ,
      //A snapshot is taken of the data at that position in the list
      title: Text(snapshot.data.docs[position]['item_name']),
      onLongPress: () {
        setState(() {
          print("You tapped at position =  $position");
          String itemId = snapshot.data.docs[position].id;
          //if a position in the list has a long press on it, it will be deleted from the list
          swimmersCollectionDB.doc(itemId).delete();
        });
      },
    );
  }

  //List widget for the swimmers to be added to
  Widget swimmerListWidget() {
    //Collection of users, each user has a collection of items, so each user has an individual list
    //swimmersCollectionDB = FirebaseFirestore.instance.collection('USERS').doc(userID).collection('ITEMS');
    return Expanded(
        child:
            //calls the tile widget to create a tile for each swimmer added to the list
        StreamBuilder(stream: swimmersCollectionDB.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //print(snapshot.data.docs.length);
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int position) {
                    return Card(
                        child: swimmerTileWidget(snapshot,position)
                    );
                  }
              );
            })
    );
  }

  //== END OF SWIMMER PAGE WIDGETS ==




  //== TIMES PAGE WIDGETS ==

  //Pop-up dialog box from Times button
  //@override
  Widget viewTimes(){
    int _sizeSelected = 1;
    showDialog( //Creates a popup window
        context: context,
        builder: (context) {
          return Dialog(
              child: SizedBox(
                height: 500,
                child:  Column(
                  children: <Widget>[
                    //A new time can be added to the individual list created for each swimmer in the collection
                    Text( //Place for the user to enter more times for the swimmer
                      'Times',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    TextField(
                      controller: _newTimeTextField,
                      style: Theme.of(context).textTheme.headline4,
                      decoration: InputDecoration(
                        hintText: "Enter a Time:",
                        hintStyle: TextStyle(fontSize: 22, color: Colors.black),
                      ),
                    ),
                  ElevatedButton( //When clicked adds the time to the swimmer's times list
                      child: Text('Add Time'),
                      onPressed: () async {
                        await timesCollectionDB.add({'time_input': _newTimeTextField.text, 'swimmer_id': swimmer_id}).then((value) => _newTimeTextField.clear());
                        //await timesCollectionDB.add({'time_input': _newTimeTextField.text}).then((value) => _newSwimmerTextField.clear());
                        setState(() { //Tells the program there is data that needs updating

                        });
                      },
                  ),
                    //Call to the times list widget
                    timesListWidget()

                    ],
                ),
              )
          );
        }
    );
  }

  //Widget that creates the tile format for each time entered for swimmer
  Widget timesTileWidget(snapshot, position) {
    return ListTile(
      title: Text(snapshot.data.docs[position]['time_input']),
      //If there is a long press on a time in the list, it will be deleted
      onLongPress: () {
        setState(() {
          print("You tapped at position =  $position");
          String itemId = snapshot.data.docs[position].id;
          timesCollectionDB.doc(itemId).delete();
        });
      },
    );
  }

  //Widget that creates a list for the times of each swimmer
  Widget timesListWidget() {
    //Collection of times, each swimmer has a collection of times, so each swimmer has an individual list
    //timesCollectionDB = FirebaseFirestore.instance.collection('TIMES').doc(userID).collection('TIMES');
    return Expanded(
        child:
        StreamBuilder(stream: timesCollectionDB.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int position) {
                    if(snapshot.data.docs[position]['swimmer_id'] == swimmer_id){
                    //Calls the tile widget to create a tile so the time can be formatted and added to the list
                    return timesTileWidget(snapshot, position);
                    }
                    else{
                      return SizedBox.shrink();
                    }

                  }
              );
            })
    );
  }


  //== END OF TIMES PAGE WIDGETS ==





// == AUTHENTICATION, LOGIN/LOGOUT, and MAIN SCREEN CODE ==


  //Code for the logout button that appears on the main screen and the login screen
  Widget logoutButton() {
    return ElevatedButton(
        onPressed: ()
        async {
          setState(() async {
          await FirebaseAuth.instance.signOut();
          print ("Button Logout");
          });
        },
        child: Text(
          'Logout',
          style: TextStyle(fontSize: 20),
        )
    );
  }

  //Widget for the main screen
  Widget mainScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: Image(image: AssetImage('graphics/dartmouthlogo.png')),
        title: Text(
            "Dartmouth Swim & Dive",
                style: TextStyle(
                  fontSize: 30.0,
            fontWeight: FontWeight.bold,
        ),
        ),
      ),
      body: Container(
        //The main screen calls the swimmer input widget to create the main screen layout
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            swimmerInputWidget(),
            SizedBox(height: 40,),
            swimmerListWidget(),
            logoutButton(),
          ],
        ),
      ),
    );
  }

  //Widget that lays out the login screen for authentication
  Widget loginScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Swim Team MGT"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Not Logged in"),
            ElevatedButton(
                onPressed: ()
                async {
                  //setState(() async {
                  // do authenication, wait for validation
                  userCredential = await signInWithGoogle();
                  userID = userCredential.user.uid;
                  print ("Button onPressed DONE");
                  // });
                },
                child: Text(
                  'Log in with Google',
                  style: TextStyle(fontSize: 20),
                )
            ),
            //Calls the logout button widget
            logoutButton(),
          ],
        ),
      ),
    );
  }

  // ======== Added for Authentication  ========
  //Checks user credentials in order to sign them in as a user

  UserCredential userCredential;
  String userID;

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // === Main Build Method ===
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          print("User already logged in");
          //User id is added to the user authentication space on the firebase console
          //Creates the screen based on who the current user is
          userID = FirebaseAuth.instance.currentUser.uid;
          swimmersCollectionDB = FirebaseFirestore.instance.collection('USERS').doc(userID).collection('SWIMMERS');
          timesCollectionDB = FirebaseFirestore.instance.collection('USERS').doc(userID).collection('TIMES');
          return mainScreen();
        }
        else {
          return loginScreen();
        }
      },
    );
  }

}