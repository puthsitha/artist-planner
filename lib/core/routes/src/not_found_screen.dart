import 'package:artistplanner/l10n/l10n.dart';
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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.not_found_title)),
      body: Center(child: Text(l10n.not_found_message)),
    );
  }
}
