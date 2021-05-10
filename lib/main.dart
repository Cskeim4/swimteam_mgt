import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

//Import the team member class
import 'teammember.dart';

// @author, Clara Skeim
//CIS 3334 FINAL PROJECT
//SWIM TEAM MGT VERSION 1


// Sample code from https://github.com/pythonhubpy/YouTube/blob/Firebae-CRUD-Part-1/lib/main.dart#L19
// video https://www.youtube.com/watch?v=SmmCMDSj8ZU&list=PLtr8DfMFkiJu0lr1OKTDaoj44g-GGnFsn&index=10&t=291s


//Set up the state and initialization for the application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Root widget for the app
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

//Where Our Code Will Go
//Note: Widgets broken into separate methods to allow for better organization
class _FirebaseDemoState extends State<FirebaseDemo> {

  //Initialize the DB collections and text fields
  final TextEditingController _newSwimmerTextField = TextEditingController();
  final TextEditingController _newTimeTextField = TextEditingController();
  CollectionReference swimmersCollectionDB;
  CollectionReference timesCollectionDB;
  //List<String> itemList = [];

  //Variable to hold the firestore id assigned for each swimmer
  String swimmer_id;


  // == CODE FOR THE SWIMMER PAGE ==

  //Text field widget for entering a swimmer
  Widget nameTextFieldWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.7,
      child: TextField(
        controller: _newSwimmerTextField, //sets the controller for editing the text field
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
        nameTextFieldWidget(), //call to separated widget method
        SizedBox(width: 10,),
        addButtonWidget(),
      ],
    );
  }

  //Time button widget, when clicked on displays a dialog box with a list of the swimmer's times
  Widget timeIconButton(snapshot, position){
    return IconButton (
      icon : const Icon(Icons.access_time),
      onPressed: (){
        //Gets the swimmer id of the swimmer pressed in order to view the times of the specified swimmer
        swimmer_id = snapshot.data.docs[position].id;
        viewTimes();
      },
    );
  }


//Tile widget that holds the information gathered about each swimmer
  Widget swimmerTileWidget(snapshot, position) {
    return ListTile(
      leading:
      Image(image: AssetImage(snapshot.data.docs[position]['swim_image'])),

      //Time icon, when clicked on shows a list of the swimmer's times in a dialog pop-up box
      trailing: timeIconButton(snapshot, position), //call to the separated icon button method

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

// == END OF SWIMMER PAGE WIDGETS/CODE ==


// == CODE FOR THE TIMES PAGE ==

  //Text field widget for the swimmer times to be entered in to
  Widget timeTextField(){
    return TextField(
      controller: _newTimeTextField,
      style: Theme.of(context).textTheme.headline4,
      decoration: InputDecoration(
        hintText: "Enter a Time:",
        hintStyle: TextStyle(fontSize: 22, color: Colors.black),
      ),
    );
  }

  //Add time button widget, adds the entered time to the list of times for the chosen swimmer
  Widget addTimeButton(){
    return ElevatedButton( //When clicked adds the time to the swimmer's times list
      child: Text('Add Time'),
      onPressed: () async {
        await timesCollectionDB.add({'time_input': _newTimeTextField.text, 'swimmer_id': swimmer_id}).then((value) => _newTimeTextField.clear());
        //await timesCollectionDB.add({'time_input': _newTimeTextField.text}).then((value) => _newSwimmerTextField.clear());
      },
    );
  }

  //Close button, when pressed closes the dialog box that shows a list of the swimmer's times
  Widget closeDialogButton(){
    return ElevatedButton( //When clicked closes the dialog pop-up view
      child: Text('Close'),
      onPressed: (){
        Navigator.pop(context);
      },
    );
  }

  //Pop-up dialog box widget for the Time button, appears when the time icon is clicked
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

                    timeTextField(), //calls to a separated widget method

                    addTimeButton(),

                    //Call to the times list widget
                    timesListWidget(),

                    closeDialogButton()

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
        setState(() { //tells firebase that data has been updated
          print("You tapped at position =  $position");
          String itemId = snapshot.data.docs[position].id;
          timesCollectionDB.doc(itemId).delete(); //based on the position tapped, delete the listed time
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
                    //if the swimmer id of the position selected in the list matches the id on the given list of times
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

// == END OF THE TIMES PAGE WIDGETS/CODE ==


// == LOGIN/LOGOUT PAGE AND MAIN SCREEN CODE ==

  //Code for the logout button that appears on the main screen and the login screen
  Widget logoutButton() {
    return ElevatedButton(
        onPressed: ()
        async {
          setState(() async {
          await FirebaseAuth.instance.signOut(); //when the button is pressed, sign out of the firebase instance
          print ("Button Logout");
          });
        },
        child: Text(
          'Logout',
          style: TextStyle(fontSize: 20),
        )
    );
  }

  //Google login button widget, checks the user credentials in order to log in the user
  Widget loginWithGoogleButton(){
    return ElevatedButton(
        onPressed: ()
        async {
          // Wait for the go ahead from google authentication
          userCredential = await signInWithGoogle();
          userID = userCredential.user.uid;
          print ("Button onPressed DONE");
        },
        child: Text(
          'Log in with Google',
          style: TextStyle(fontSize: 20),
        )
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
            loginWithGoogleButton(),
            //Calls the logout button widget method
            logoutButton(),
          ],
        ),
      ),
    );
  }

  //Widget for the container on the main screen of the application
  Widget mainscreenContainer(){
    return Container(
      //The main screen calls the swimmer input widget to create the main screen layout
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          swimmerInputWidget(), //calls to separated widgets that make up the main screen
          SizedBox(height: 40,),
          swimmerListWidget(),
          logoutButton(),
        ],
      ),
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
      body: mainscreenContainer() //calls to the mainscreen container widget method above
    );
  }

  // == END OF LOGIN/LOGOUT AND MAIN SCREEN PAGE WIDGETS/CODE ==


  // == GOOGLE AUTHENTICATION CODE ==

  //Checks user credentials in order to sign them in
  UserCredential userCredential;
  String userID;

  Future<UserCredential> signInWithGoogle() async {
    // Start the authentication process
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    // Get the sign in specifics from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    // Create a new user credential object
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Return the credential once the user has been signed in
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // == END OF GOOGLE AUTH CODE ==


  // == MAIN BUILD METHOD CODE ==

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) { //check if the user is logged in already
          print("User already logged in");
          //Add the id of the user who is signed in to the firebase console
          //Modifies the screen to fit the user who is currently logged in
          userID = FirebaseAuth.instance.currentUser.uid;
          swimmersCollectionDB = FirebaseFirestore.instance.collection('USERS').doc(userID).collection('SWIMMERS');
          timesCollectionDB = FirebaseFirestore.instance.collection('USERS').doc(userID).collection('TIMES');
          return mainScreen();
        }
        else {
          return loginScreen(); //if the user is not logged in, return to the login screen
        }
      },
    );
  }

  // == END OF MAIN BUILD METHOD CODE/WIDGETS ==

}