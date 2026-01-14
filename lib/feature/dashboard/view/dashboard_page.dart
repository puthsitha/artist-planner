import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static MaterialPage<void> page({Key? key}) =>
      MaterialPage<void>(child: DashboardPage(key: key));

  @override
  Widget build(BuildContext context) {
    return const DashboardView();
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Dashboard Page')));
  }
}
