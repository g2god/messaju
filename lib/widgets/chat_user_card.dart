import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messaju/api/apis.dart';
import 'package:messaju/helper/my_date_util.dart';
import 'package:messaju/main.dart';
import 'package:messaju/models/chat_user.dart';
import 'package:messaju/models/message.dart';
import 'package:messaju/screens/chat_screen.dart';
import 'package:messaju/widgets/dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {
final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  //last message info(if null --> no message )
  Message? _message;



  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width *.04,vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Color.fromARGB(244, 164, 234, 255).withOpacity(0.7),
      elevation: 2,
      child: InkWell(
        onTap: (){
          //for navigating to chat screen
          Navigator.push(context, MaterialPageRoute(builder:(_) => ChatScreen(user: widget.user,)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
             final data = snapshot.data?.docs;
            final list= data?.map((e) => Message.fromJson(e.data())).toList() ??[]; 


             if(list.isNotEmpty){
              _message= list[0] ;
             }


            return ListTile(
          //leading: const CircleAvatar(child: Icon(CupertinoIcons.person),),
          //profile image
          leading: InkWell(
            onTap: () {
              showDialog(context: context, builder: (_) => ProfileDialog(user: widget.user,));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(mq.width *.03),
              child: CachedNetworkImage(
                width: mq.height * .055,
                height: mq.height * .055,
                imageUrl: widget.user.image,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => 
                    const CircleAvatar(child: Icon(CupertinoIcons.person)),
                 ),
            ),
          ),
          //username
          title: Text(widget.user.name),
          //last message
          subtitle: Text(_message != null ?
          _message!.type == Type.image? 'image':
           _message!.msg : widget.user.about,maxLines: 1,),
          //last message time
          trailing: _message == null? null
          : _message!.read.isEmpty && _message!.fromId != APIs.user.uid ? Container(width: 15,height: 15,
          decoration: BoxDecoration(color: Colors.green,
          borderRadius: BorderRadius.circular(10)),):
          Text(
            MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),
            style: TextStyle(color:Colors.black54),),

        );
          
        },)
      ),
    );
  }
}