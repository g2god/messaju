import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messaju/main.dart';
import 'package:messaju/models/chat_user.dart';
import 'package:messaju/screens/auth/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user ;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Color.fromARGB(255, 235, 235, 235).withOpacity(.9),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
    content: SizedBox(width: mq.width*.6,height: mq.height*.45,
    child:Stack(
      children: [
                  Positioned(
                  top:mq.height*.075,
                  left: mq.width*.125,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height *.25),
                    child: CachedNetworkImage(
                      width: mq.height * .25,
                      height: mq.height *.25,
                      
                      fit: BoxFit.cover,
                      imageUrl: user.image,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => 
                          const CircleAvatar(child: Icon(CupertinoIcons.person)),
                       ),
                                 ),
                 ),
        Positioned(
          left: mq.width*.04,
          top:mq.height*.02,
          width: mq.width*.60,
          child: Text(user.name.toUpperCase(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black87),)),

          Positioned(
          left: mq.width*.09,
          bottom:mq.height*.02,
          width: mq.width*.55,
          child: Text('Click Info Button To View Profile',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color: Colors.black87),)),
 
        //info
        Positioned(
                  right: 8,top: 6,
                  child:MaterialButton(onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context,MaterialPageRoute(builder: (_) => ViewProfileScreen(user: user)));
                  },
                  child:  Icon(Icons.info_outline,size: 30,color: Colors.blueAccent,),
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(0),
                  minWidth: 0,)),
      ],
      
    ),),);
  }
}