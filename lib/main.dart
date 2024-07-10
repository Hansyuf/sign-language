import 'package:flutter/material.dart';
import 'package:signbridge/sign_language_model.dart'; // Assuming SignLanguageModel is correctly implemented

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignBridge',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image container
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpeg'), // Adjust asset path as necessary
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Centered white container with padding
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), // Rounded corners
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.grey, // Grey color for "Welcome to"
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'SignBridge',
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.black, // Black color for "SignBridge"
                      fontWeight: FontWeight.bold, // Bold text
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20), // Adjust vertical spacing as needed
                  // Insert your app logo here
                  Image.asset(
                    'assets/logo.png', // Adjust asset path as necessary
                    width: 250, // Adjust width as necessary
                    height: 250, // Adjust height as necessary
                  ),
                  const SizedBox(height: 40), // Adjust vertical spacing as needed
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SignLanguageModel(), // Navigate to your SignLanguageModel screen
                        ),
                      );
                    },
                    child: const Text('Open Camera'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(
                          255, 10, 10, 10), // Adjust button color as needed
                      minimumSize: const Size(200, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
