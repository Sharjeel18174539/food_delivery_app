import 'package:flutter/material.dart';
class ErrorDialogue extends StatelessWidget {
  String message;
  ErrorDialogue({super.key,
    required this.message
});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Text(message!),
      actions: [
        ElevatedButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Center(child: Text("Ok")),
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
          ),
        )
      ],
    );
  }
}
