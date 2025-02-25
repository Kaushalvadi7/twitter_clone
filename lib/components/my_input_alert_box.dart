import 'package:flutter/material.dart';

class MyInputAlertBox extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final void Function()? onPressed;
  final String onPressedText;

  const MyInputAlertBox({
    super.key,
    required this.textController,
    required this.hintText,
    required this.onPressed,
    required this.onPressedText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //Curve corners
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),

      //color
      backgroundColor: Theme.of(context).colorScheme.surface,

      //Textfielf(user types here)
      content: TextField(
        controller: textController,

        //let's limit the max characters
        maxLength: 140,
        maxLines: 3,

        decoration: InputDecoration(
          //border when textfield is unselected
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
            ),
            borderRadius: BorderRadius.circular(12),
          ),

          //border when textfeild is selected
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(12),
          ),

          //hint text
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),

          //Color inside of textfeild
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,

          //Counter style
          counterStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),

      //Buttons
      actions: [
        //cancel button
        TextButton(
          onPressed: () {
            Navigator.pop(context);

            //clear controller
            textController.clear();
          },
          child: const Text("Cancel"),
        ),

        //yes button
        TextButton(
          onPressed: () {
            //close box
            Navigator.pop(context);

            //execute function
            onPressed!();

            //clear controller
            textController.clear();
          },
          child: Text(onPressedText),
        ),
      ],
    );
  }
}
