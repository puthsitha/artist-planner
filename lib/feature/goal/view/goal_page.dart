import 'package:flutter/material.dart';

class GoalPage extends StatelessWidget {
  const GoalPage({super.key});

  static MaterialPage<void> page({Key? key}) =>
      MaterialPage<void>(child: GoalPage(key: key));

  @override
  Widget build(BuildContext context) {
    return const GoalView();
  }
}

class GoalView extends StatelessWidget {
  const GoalView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Goal Page')));
  }
}
