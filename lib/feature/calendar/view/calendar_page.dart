import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  static MaterialPage<void> page({Key? key}) =>
      MaterialPage<void>(child: CalendarPage(key: key));

  @override
  Widget build(BuildContext context) {
    return const CalendarView();
  }
}

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Calendar Page')));
  }
}
