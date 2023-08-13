import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {

  final TextEditingController? controller;
  final IconData? data;
  final String? hintText;
  bool? isobsecre = true;
  bool? enabled = true;
   CustomTextField({super.key,
     this.controller,
     this.data,
     this.hintText,
     this.enabled,
     this.isobsecre
   });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(10),
      child: TextFormField(
        enabled: enabled,
        controller: controller,
        obscureText: isobsecre!,
        cursorColor: Theme.of(context).primaryColor,
        decoration:  InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(
           data,
            color: Colors.black,
          )
        ),
      ),
    );
  }
}
