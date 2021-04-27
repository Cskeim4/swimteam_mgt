import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'swimmer.dart';

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
  final TextEditingController _newItemTextField = TextEditingController();
  CollectionReference itemCollectionDB = FirebaseFirestore.instance.collection('ITEMS');
  //List<String> itemList = [];

  Widget nameTextFieldWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.7,
      child: TextField(
        controller: _newItemTextField,
        style: TextStyle(fontSize: 22, color: Colors.black),
        decoration: InputDecoration(
          hintText: "Enter a Swimmer: ",
          hintStyle: TextStyle(fontSize: 22, color: Colors.black),
        ),
      ),
    );
  }

  Widget addButtonWidget() {
    return SizedBox(
      child: ElevatedButton(
          onPressed: () async {
            //setState(() {
            //itemList.add(_newItemTextField.text);
            //_newItemTextField.clear();
            await itemCollectionDB.add({'item_name': _newItemTextField.text}).then((value) => _newItemTextField.clear());
            //});
          },
          child: IconButton(
            icon: const Icon(Icons.add)
          )),
    );
  }

  Widget itemInputWidget() {
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

  Widget itemTileWidget(snapshot, position) {
    return ListTile(
      leading: Icon(Icons.access_time),
        //onTap: (){

    //},
      title: Text(snapshot.data.docs[position]['item_name']),
      onTap: () {
        setState(() {
          print("You tapped at position =  $position");
          String itemId = snapshot.data.docs[position].id;
          itemCollectionDB.doc(itemId).delete();
        });
      },
    );
  }

  Widget itemListWidget() {
    //Collection of users, each user has a collection of items, so each user has an individual list
    itemCollectionDB = FirebaseFirestore.instance.collection('USERS').doc(userID).collection('ITEMS');
    return Expanded(
        child:
        StreamBuilder(stream: itemCollectionDB.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int position) {
                    return Card(
                        child: itemTileWidget(snapshot,position)
                    );
                  }
              );
            })
    );
  }

  //Pop-up box for Times button
  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Popup example'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Times: "),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: Text('Close'),
        ),
      ],
    );
  }



  Widget logoutButton() {
    return ElevatedButton(
        onPressed: ()
        async {
          //setState(() async {
          await FirebaseAuth.instance.signOut();
          print ("Button Logout");
          // });
        },
        child: Text(
          'Logout',
          style: TextStyle(fontSize: 20),
        )
    );
  }

  Widget mainScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Swim Team Name"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            itemInputWidget(),
            SizedBox(height: 40,),
            itemListWidget(),
            logoutButton(),
          ],
        ),
      ),
    );
  }

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
                  // do authenication
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
          userID = FirebaseAuth.instance.currentUser.uid;
          return mainScreen();
        }
        else {
          return loginScreen();
        }
      },
    );
  }

}