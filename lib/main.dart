import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText;
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("messaging");
    
    // Get FCM Token
    messaging.getToken().then((value) {
      print('============================================');
      print('FCM TOKEN: $value');
      print('============================================');
      setState(() {
        fcmToken = value;
      });
    });

    // Request permissions
    messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message received");
      print(event.notification!.body);
      print(event.data.values);

      
      String notificationType = event.data['type'] ?? 'regular';
      bool isImportant = notificationType == 'important';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            
            backgroundColor: isImportant ? Colors.red[50] : Colors.blue[50],
            
            
            title: Row(
              children: [
                Icon(
                  isImportant ? Icons.warning_amber_rounded : Icons.notifications,
                  color: isImportant ? Colors.red : Colors.blue,
                  size: 30,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isImportant ? "⚠️ IMPORTANT ALERT" : "📬 Notification",
                    style: TextStyle(
                      color: isImportant ? Colors.red[900] : Colors.blue[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.notification!.body!,
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 12),
                // Type badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isImportant ? Colors.red[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isImportant ? Colors.red : Colors.blue,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Type: ${notificationType.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isImportant ? Colors.red[900] : Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
            
            // DIFFERENT BUTTON COLORS
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: isImportant ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    });
    
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_active,
                size: 70,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                "Messaging Tutorial",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              // Display FCM Token
              if (fcmToken != null) ...[
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Your FCM Token:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 10),
                      SelectableText(
                        fcmToken!,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Tap token above to copy",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else
                Text("Loading token..."),
            ],
          ),
        ),
      ),
    );
  }
}