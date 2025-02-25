import 'package:flutter/material.dart';

class MyBioBox extends StatelessWidget {
  final String text;

  const MyBioBox({super.key, required this.text});

  //build ui
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,

        //curve corners
        borderRadius: BorderRadius.circular(8),
      ),

      //padding inside
      padding: EdgeInsets.all(25),

      //text
      child: Text(
        text.isNotEmpty ? text : "Empty bio..",
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
      ),
    );
  }
}
