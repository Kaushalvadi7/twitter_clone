import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function() onTap;

  const MyButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        //padding inside
        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          //color of button
          color: Theme.of(context).colorScheme.secondary,

          //Curve corners
          borderRadius: BorderRadius.circular(10),
        ),

        //text
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
        ),
      ),
    );
  }
}
