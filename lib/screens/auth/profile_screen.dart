
//import 'dart:developer';

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messaju/api/apis.dart';
import 'package:messaju/helper/dialogs.dart';
import 'package:messaju/main.dart';
import 'package:messaju/models/chat_user.dart';
import 'package:messaju/screens/auth/login_screen.dart';

// profile settings
class ProfileScreen extends StatefulWidget {
  final ChatUser user;


  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();

}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //appbar
        appBar: AppBar(
          
          title: const Text('Profile'),
          ),
    
       //floating button bottom
       floatingActionButton: Padding(
       padding: const EdgeInsets.only(bottom: 20,right: 15),
       child: FloatingActionButton.extended(
        backgroundColor:Colors.red,
        onPressed: () async {
        
          //sign out function
          // show progress bar
        Dialogs.showProgressBar(context);

        await  APIs.updateActiveStatus(false);
          await APIs.auth.signOut().then((value) async {
            await GoogleSignIn().signOut().then((value) {
              //hide progress bar
              Navigator.pop(context);
            //move to home screen
              Navigator.pop(context);

              APIs.auth = FirebaseAuth.instance;
              //replace home with login
              Navigator.pushReplacement(context,MaterialPageRoute(
                  builder: (_) => LoginScreen()));
            },);
    
          });
          
      
        },
          icon:const Icon(Icons.exit_to_app), label:Text('Logout'),
          //child: const Icon(Icons.add_comment_rounded),
        ),
       ),
       body: 
       Form(
        key: _formKey,
         child: Padding(
             //space between
         padding: EdgeInsets.symmetric(horizontal: mq.width *.05),
         child: SingleChildScrollView(
           child: Column(children: [
            SizedBox(
              height: mq.height *.04,
              width: mq.width,
            ),
             //profile image
              Stack(
                children: [

                  _image!=null ?  
                  //local image
                        ClipRRect(
                        borderRadius: BorderRadius.circular(mq.width *.2),
                        child: Image.file(
                          File(_image!),
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit: BoxFit.cover,
                           ),
                      ):

                      // image from server
                  ClipRRect(
                        borderRadius: BorderRadius.circular(mq.width *.2),
                        child: CachedNetworkImage(
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.image,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => 
                              const CircleAvatar(child: Icon(CupertinoIcons.person)),
                           ),
                      ),
                  
                  //edit image
             
                  Positioned(
                  
                    bottom: 0,right: 0,
                    child: MaterialButton(onPressed: (){
                      _showBottomSheet();
                    },
                    elevation: 1,
                    shape: const CircleBorder(),
                     color: Colors.white,
                     child:const Icon(Icons.edit,color: Colors.blue,),),
                  ),
                ],
              ),
                  SizedBox(
              height: mq.height *.04,
              width: mq.width,
            ),
             
            Text(widget.user.email,
            style: TextStyle(color: Colors.black54,fontSize: 16),),
             
             SizedBox(
              height: mq.height *.05,
              width: mq.width,
            ),
             
            TextFormField(
              initialValue: widget.user.name,
              onSaved: (val)=> APIs.me.name = val ?? "",
              validator: (val)=> val != null && val.isNotEmpty ? null : 'Required Field',
              decoration: InputDecoration(
                border:const OutlineInputBorder(),
                prefixIcon: Icon(Icons.person,color: Colors.blue,),
                hintText: 'eg: gojo Sataru',label: Text('Name')),
            ),
             
            SizedBox(
              height: mq.height *.05,
              width: mq.width,
            ),
             
            TextFormField(
              initialValue: widget.user.about,
              decoration: InputDecoration(
                  border:const OutlineInputBorder(),
                prefixIcon: Icon(Icons.info_outline,color: Colors.lightBlue,),
                //border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'eg: gojo Sataru',label: Text('Info')),
            ),
             
            SizedBox(
              height: mq.height *.05,
              width: mq.width,
            ),
             
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(shape:const StadiumBorder(),minimumSize: Size(mq.width*0.5,mq. height*.06)),
              
              onPressed: (){
                if(_formKey.currentState!.validate()){
                  _formKey.currentState!.save();
                  APIs.updateUserInfo().then((value) {
                    Dialogs.showSnackbar(context
                  ,'Profile Updated Succesfully');
                  });
                  
                }
              },icon: Icon(Icons.edit),
              label:const Text('UPDATE',style: TextStyle(fontSize: 16),)),
                  
           ],),
         ),
         ),
       )
       ),
    );
    
  }

  //bottom sheeet for image selection

  void _showBottomSheet(){
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))),
      builder: (_){
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: mq.height *.03,bottom: mq.height *.08),
          children: [
            const Text('Pick Your Profile Picture',textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
            //for some space
            SizedBox(
              height: mq.height *.02,
            ),

            //Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //from galery
              ElevatedButton(onPressed: () async {
                final ImagePicker picker = new ImagePicker();
                //pick an image
                final XFile?image =
                  await picker.pickImage(source:ImageSource.gallery,imageQuality: 80);
                if (image != null){
                  log('Image Path:${image.path} -- MimeType:${image.mimeType}');
                  setState(() {
                    _image=image.path;

                  });

                  APIs.updateProfilePicture(File(_image!));
                
                //for hiding bottom sheet
                Navigator.pop(context);
                }
                
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: Colors.white,
                fixedSize: Size(mq.width *.3, mq.height *.15)
              ),
               child: Image.asset(
                'images/add_image.png'
              )),

              //from camera

               ElevatedButton(onPressed: () async {
                final ImagePicker picker = new ImagePicker();
                //pick an image
                final XFile?image =
                  await picker.pickImage(source:ImageSource.camera,imageQuality: 80);
                if (image != null){
                  log('Image Path:${image.path}');
                  setState(() {
                    _image=image.path;
                  });

                  APIs.updateProfilePicture(File(_image!));
                
                //for hiding bottom sheet
                Navigator.pop(context);
                }
               },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: Colors.white,
                fixedSize: Size(mq.width *.3, mq.height *.15)
              ),
               child: Image.asset(
                'images/camera.png'
              ))
            ],)
          ],
        );

      } 
    );
  }


}