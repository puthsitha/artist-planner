import 'package:flutter/material.dart';

class NotFoundScreen extends StatefulWidget {
  const NotFoundScreen({super.key});

  static MaterialPage<void> page({Key? key}) =>
      MaterialPage<void>(child: NotFoundScreen(key: key));

  @override
  State<NotFoundScreen> createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<NotFoundScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: const Center(child: Text('Hmmm... 404 - Page Not Found')),
    );
  }
}
