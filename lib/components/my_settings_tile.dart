import 'package:flutter/material.dart';

class MySettingsTile extends StatelessWidget {
  final String title;
  final Widget action;

  const MySettingsTile({super.key, required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    //container
    return Container(
      decoration: BoxDecoration(
        //color
        color: Theme.of(context).colorScheme.secondary,
        //curve corners
        borderRadius: BorderRadius.circular(12),
      ),

      //padding outside
      padding: const EdgeInsets.all(25),

      margin: const EdgeInsets.only(left: 25, right: 25, top: 10),

      //Row
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //title
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

          //action
          action,
        ],
      ),
    );
  }
}
