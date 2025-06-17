import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepLink Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _linkMessage = 'No deep link yet!';
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

Future<void> initDeepLinks() async {
  _appLinks = AppLinks();

  // Get initial link 
  try {
    final appLink = await _appLinks.getInitialAppLink();
    log('Initial deep link: $appLink');  
    if (appLink != null) {
      _handleDeepLink(appLink);
    }
  } catch (e) {
    log('Error getting initial link: $e');
  }

  // Listen for links 
  _linkSubscription = _appLinks.uriLinkStream.listen(
    (uri) {
      log('New deep link received: $uri');  
      _handleDeepLink(uri);
    },
    onError: (err) {
      log('Deep link stream error: $err');
    }
  );
}

  void _handleDeepLink(Uri uri) {
    setState(() {
      _linkMessage = 'Received deep link:\n${uri.toString()}';
      
      // Extract parameters
      final params = uri.queryParameters;
      if (params.isNotEmpty) {
        _linkMessage += '\n\nParameters:';
        params.forEach((key, value) {
          _linkMessage += '\n$key: $value';
        });
      }
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deep Link Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Test deep links using:'),
            const SizedBox(height: 10),
            Text(
              'https://yourdomain.com/?param1=value1',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 30),
            const Icon(Icons.link, size: 50),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                _linkMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
