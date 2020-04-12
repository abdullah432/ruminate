import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notesapp/Screens/setNotification.dart';
import 'package:notesapp/Screens/welcome_screen.dart';
import 'package:notesapp/utils/firestore.dart';
import 'package:notesapp/utils/receivednotification.dart';
import 'package:rxdart/subjects.dart';
import 'Screens/notes_screen.dart';
import 'Screens/note_edit_screen.dart';
import 'utils/auth_provider.dart';
import 'utils/authentication.dart';
import 'package:flutter/services.dart';

// Future<void> main() async {
//   // needed if you intend to initialize in the `main` function
//   WidgetsFlutterBinding.ensureInitialized();

//   notificationAppLaunchDetails =
//       await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

//   var initializationSettingsAndroid = AndroidInitializationSettings('ruminate_appicon');
//   // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
//   // of the `IOSFlutterLocalNotificationsPlugin` class
//   var initializationSettingsIOS = IOSInitializationSettings(
//       requestAlertPermission: false,
//       requestBadgePermission: false,
//       requestSoundPermission: false,
//       onDidReceiveLocalNotification:
//           (int id, String title, String body, String payload) async {
//         didReceiveLocalNotificationSubject.add(ReceivedNotification(
//             id: id, title: title, body: body, payload: payload));
//       });
//   var initializationSettings = InitializationSettings(
//       initializationSettingsAndroid, initializationSettingsIOS);
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onSelectNotification: (String payload) async {
//     if (payload != null) {
//       debugPrint('notification payload: ' + payload);
//     }
//     selectNotificationSubject.add(payload);
//   });

//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
//       .then((_) {
//     runApp(new MyApp());
//   });
// }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
      runApp(new MyApp());
    });
   }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
        auth: Auth(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: RootPage(),
        ));
  }
}

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final BaseAuth auth = AuthProvider.of(context).auth;
    return StreamBuilder<String>(
      stream: auth.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool isLoggedIn = snapshot.hasData;

          String data = snapshot.data;
          debugPrint('data: ' + data.toString());
          //load notify timing data
          CustomFirestore _customF = new CustomFirestore();
          _customF.loadNotifyData();
          
          return isLoggedIn ? NotesScreen(snapshot.data) : WelcomeScreen();
          // return SetNotification();
        }
        //should return splash screen here
        return _buildWaitingScreen(context);
      },
    );
  }

  Widget _buildWaitingScreen(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()));
  }
}
