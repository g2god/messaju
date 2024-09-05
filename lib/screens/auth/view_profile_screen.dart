
//import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messaju/helper/my_date_util.dart';
import 'package:messaju/main.dart';
import 'package:messaju/models/chat_user.dart';

// view profile
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;


  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();

}

class _ViewProfileScreenState extends State<ViewProfileScreen> {


  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //appbar
        appBar: AppBar(
          
          title: Text(widget.user.name),
          ),

        floatingActionButton:  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Joined On:', style:TextStyle(color: Colors.black87,fontWeight:FontWeight.w500,fontSize: 20),),
              Text(MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt,showYear: true,),
              style: TextStyle(color: Colors.black54,fontSize: 20),),
            ],
          ),
        //body
       body: 
       Padding(
           //space between
       padding: EdgeInsets.symmetric(horizontal: mq.width *.05),
       child: SingleChildScrollView(
         child: Column(children: [
          SizedBox(
            height: mq.height *.04,
            width: mq.width,
          ),
           //profile image
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
                SizedBox(
            height: mq.height *.04,
            width: mq.width,
          ),
           //user email
          Text(widget.user.email,
          style: TextStyle(color: Colors.black87,fontSize: 20),),
           
           SizedBox(
            height: mq.height *.02,
            width: mq.width,
          ),

          //user about
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('About:', style:TextStyle(color: Colors.black87,fontWeight:FontWeight.w500,fontSize: 20),),
              Text(widget.user.about,
              style: TextStyle(color: Colors.black54,fontSize: 20),),
            ],
          ),
                
         ],),
       ),
       )
       ),
    );
    
  }
  
}