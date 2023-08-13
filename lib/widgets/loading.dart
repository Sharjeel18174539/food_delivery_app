import 'package:flutter/material.dart';
import 'package:food_delivery_app/widgets/progress.dart';
class LoadingDialogue extends StatelessWidget {
  String message;
  LoadingDialogue({super.key,
    required this.message
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circularProgress(),
          const SizedBox(height: 10,),
          Text("${message!},Please wait...")
        ],
      ),

    );
  }
}
