import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/main_screens/home_screen.dart';
import 'package:food_delivery_app/widgets/custom_text_field.dart';
import 'package:food_delivery_app/widgets/error.dart';
import 'package:food_delivery_app/widgets/loading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController =TextEditingController();
  TextEditingController emailController =TextEditingController();
  TextEditingController passwordController =TextEditingController();
  TextEditingController passwordConfirmController =TextEditingController();
  TextEditingController phoneController =TextEditingController();
  TextEditingController locationController =TextEditingController();
  XFile? imageXFile;

  final ImagePicker _picker =ImagePicker();

  Position? position;
  List<Placemark>? placeMarks;
   String sellerImageUrl="";
   String completeAddress="";

  Future<void> _getImage() async{
    imageXFile= await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }


  getCurrentLocation() async {
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    position=newPosition;

    placeMarks = await placemarkFromCoordinates(
        position!.latitude,
        position!.longitude,
    );
    Placemark pMark= placeMarks![0];
    completeAddress = '${pMark.subThoroughfare} ${pMark.thoroughfare},${pMark.subLocality}${pMark.locality},${pMark.subAdministrativeArea} ${pMark.administrativeArea},${pMark.postalCode},${pMark.country}';

    locationController.text = completeAddress;
  }

  Future<void> formvalidation()async{
    if(imageXFile == null){
      showDialog(
          context: context,
          builder: (c){
            return ErrorDialogue(
                message: "Please select an image",
            );
          }
      );
    }
    else{
      if(passwordController.text == passwordConfirmController){
        showDialog(
            context: context,
            builder: (c){
              return LoadingDialogue(
                  message: "Registering Account",
              );
            }
        );
      }
      else{
        showDialog(
            context: context,
            builder: (c){
              return ErrorDialogue(
                message: "Please select an image",
              );
            }
        );
        String filename = DateTime.now().millisecondsSinceEpoch.toString();
        fStorage.Reference reference =fStorage.FirebaseStorage.instance.ref().child("sellers").child(filename);
        fStorage.UploadTask uploadTask =reference.putFile(File(imageXFile!.path));
        fStorage.TaskSnapshot taskSnapshot= await uploadTask.whenComplete(() {});
        await taskSnapshot.ref.getDownloadURL().then((url) {
           sellerImageUrl=url;

           authenticateSellerAndSignup();
        });
      }
    }
  }

  Future saveDataToFirestore(User currentUser)async{
    FirebaseFirestore.instance.collection("sellers").doc(currentUser.uid).set({
      "sellerUID": currentUser.uid,
      "sellerEmail": currentUser.email,
      "sellerName": nameController.text.trim(),
      "sellerAvatarUrl": sellerImageUrl,
      "phone": phoneController,
      "address": completeAddress,
      "status": "approved",
      "earning": 0.0,
      "lat": position!.latitude,
      "lng": position!.longitude,
    });
    
    SharedPreferences? sharedPreferences;
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences.setString("name", nameController.text.trim());
    await sharedPreferences.setString("photoUrl", sellerImageUrl);
  }

  Future<void> authenticateSellerAndSignup() async {
    User? currentUser;
    final FirebaseAuth firebaseAuth=FirebaseAuth.instance;
    await firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim()
    ).then((auth) {
      currentUser=auth.user;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c){
            return ErrorDialogue(
                message: error.message.toString(),
            );
          }
      );
    });

    if(currentUser!=null){
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        
        Route newRoute=MaterialPageRoute(builder: (c)=>HomeScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
       mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 10,),
            InkWell(
              onTap: (){
                _getImage();
              },
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width*0.20,
                backgroundColor: Colors.white,
                backgroundImage: imageXFile==null? null : FileImage(File(imageXFile!.path),),
                child: imageXFile == null
                ?
                Icon(
                  Icons.add_a_photo_rounded,
                  size: MediaQuery.of(context).size.width*0.2,
                  color: Colors.grey,
                ) : null,

              ),
            ),
          Form(
            key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    children: [
                      CustomTextField(
                        data: Icons.person,
                        controller: nameController,
                        hintText: "Name",
                        isobsecre: false,
                      ),
                      CustomTextField(
                        data: Icons.email,
                        controller: emailController,
                        hintText: "Enter email",
                        isobsecre: false,
                      ),
                      CustomTextField(
                        data: Icons.lock,
                        controller: passwordController,
                        hintText: "Enter The Password",
                        isobsecre: false,
                      ),
                      CustomTextField(
                        data: Icons.lock,
                        controller: passwordConfirmController,
                        hintText: "Confirm Password",
                        isobsecre: false,
                      ),
                      CustomTextField(
                        data: Icons.phone,
                        controller: phoneController,
                        hintText: "Phone Number",
                        isobsecre: false,

                      ),
                      CustomTextField(
                        data: Icons.my_location,
                        controller: locationController,
                        hintText: "Restaurant Location",
                        isobsecre: true,
                        enabled: true,
                      ),
                      Container(
                        height: 40,
                        width: 400,
                        alignment: Alignment.center,
                        child: ElevatedButton.icon(
                            onPressed: (){
                              getCurrentLocation();
                            },
                            icon: const Icon(
                              Icons.location_on,
                            ),
                            label: const Text(
                              "Get My Current Location"
                            ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 20,),
          ElevatedButton(
              onPressed: (){
                formvalidation();
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
            ),
              child:  const Text("Sign up",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ),
        ],
      ),
    );
  }
}

