import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'views/login_view.dart';
import 'views/google_restaurant_info_view.dart';
import 'views/phone_restaurant_info_view.dart';
import 'views/dashboard_view.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final user = FirebaseAuth.instance.currentUser;
  final providers = user?.providerData.map((e) => e.providerId).toList() ?? [];

  Widget initialView;
  if (user == null) {
    initialView = LoginView();
  } else if (providers.contains('google.com')) {
    initialView = const GoogleRestaurantInfoView();
  } else {
    initialView = const PhoneRestaurantInfoView();
  }

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialView,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<FirebaseApp> _initFirebase() async {
    try {
      print('Firebase apps count: ${Firebase.apps.length}');
      if (Firebase.apps.isEmpty) {
        print('Initializing Firebase...');
        return await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
            appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
            messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
            projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
            authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '',
            storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
          ),
        );
      }
      print('Firebase already initialized');
      return Firebase.app();
    } catch (e) {
      print('❌ خطأ أثناء تهيئة Firebase: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GetMaterialApp(
            title: 'إدارة المطعم',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Cairo',
              textTheme: const TextTheme(
                bodyLarge: TextStyle(fontFamily: 'Cairo'),
                bodyMedium: TextStyle(fontFamily: 'Cairo'),
                titleLarge: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            locale: const Locale('ar', 'SA'),
            textDirection: TextDirection.rtl,
            home: LoginView(),
            debugShowCheckedModeBanner: false,
            getPages: [
              GetPage(name: '/login', page: () => LoginView()),
              GetPage(
                  name: '/restaurant-info',
                  page: () => const GoogleRestaurantInfoView()),
              GetPage(name: '/dashboard', page: () => const DashboardView()),
            ],
          );
        }
        return const MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('restaurants')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                if (userData['isProfileComplete'] == true) {
                  return const DashboardView();
                }
              }
              return const GoogleRestaurantInfoView();
            },
          );
        }

        return LoginView();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
