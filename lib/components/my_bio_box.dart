import 'package:flutter/material.dart';

class MyBioBox extends StatelessWidget {
  final String text;

  const MyBioBox({super.key, required this.text});

  //build ui
  @override
  Widget build(BuildContext context) {
    return Container(
      //padding outside
      margin: const EdgeInsets.symmetric(horizontal: 25),

      //padding inside
      padding: EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,

        //curve corners
        borderRadius: BorderRadius.circular(8),
      ),

      //text
      child: Text(
        text.isNotEmpty ? text : "Empty bio..",
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
      ),
    );
  }
}
