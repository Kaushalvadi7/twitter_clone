import 'package:flutter/material.dart';
import 'package:twitter_clone/components/my_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MyDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "H O M E",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
