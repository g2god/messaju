
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messaju/api/apis.dart';
import 'package:messaju/helper/my_date_util.dart';
import 'package:messaju/main.dart';
import 'package:messaju/models/chat_user.dart';
import 'package:messaju/models/message.dart';
import 'package:messaju/screens/auth/view_profile_screen.dart';
import 'package:messaju/widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});


  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
//for storing all messages
  List<Message>_list=[];

//handling message texyt changes
  final _textController =TextEditingController();

//for showing or hiding emoji and check uploading image
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
        onWillPop: (){
          if(_showEmoji) {
            setState(() {
              _showEmoji =!_showEmoji;
            });
          return Future.value(false);
          }else{
            return Future.value(true);
          }
        },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            //body
            body: Column(
              children: [
                 Expanded(
                   child: StreamBuilder(
                          stream:APIs.getAllMessages(widget.user),
                          builder: (context, snapshot) {
                           switch (snapshot.connectionState) {
                             //if data loading
                             case ConnectionState.waiting:
                             case ConnectionState.none:
                             return SizedBox();
                             
                             // if all data is available show it
                             case ConnectionState.active:
                             case ConnectionState.done:
                           
                             final data = snapshot.data?.docs;
            
                             //log('Data:${jsonEncode(data![0].data())}');
                            
                              _list= data?.map((e) => Message.fromJson(e.data())).toList() ??[];  //changed something here
            
                            // _list.clear();
                            // _list.add(Message(toId: 'xyz', msg: 'nyanpasu', read:'', type: Type.text, sent: '12:00 AM', fromId:APIs.user.uid));
                            
                            // _list.add(Message(toId:APIs.user.uid, msg: 'nyanpasu pasu', read:'', type: Type.text, sent: '12:05 AM', fromId:'xyz'));
                           
                            if(_list.isNotEmpty){
                             return ListView.builder(
                              reverse: true,
                             itemCount:_list.length,
                             padding: EdgeInsets.only(top: mq.height*.02),
                             physics: BouncingScrollPhysics(),
                             itemBuilder: (context,index) {
                             return MessageCard(message: _list[index],); 
                             },
                            );
                           }else{
                             return const Center(child: Text('Say Vanakkam 🙏',style: TextStyle(fontSize: 20),));
                           }
                           
                           }
                           },
                           
                          ),
                 ),
            if(_isUploading)
              const Align(alignment: Alignment.centerRight,
                
                child:

               Padding(
                padding: EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                child: CircularProgressIndicator())),
                
                _chatInput(),
            
            if(_showEmoji)             
              SizedBox(
            
              height: mq.height*.35,
              child:   EmojiPicker(
              
              
              
          textEditingController: _textController, 
              
          config: Config(
            bgColor:  const Color.fromARGB(255, 234, 248, 255),
              
              columns: 7,
              
              emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),    
          ),
              
              ),
            )
                ],
              
              ),
          ),
        ),
      ),
    );
  }

  Widget _appBar(){
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child:StreamBuilder(stream:APIs.getUserInfo(widget.user), builder: (context, snapshot) {
          final data = snapshot.data?.docs;
            final list= data?.map((e) => ChatUser.fromJson(e.data())).toList() ??[]; 


        return  Row(
        children: [
          //backbutton
          IconButton(onPressed:() => Navigator.pop(context),
           icon: const Icon(Icons.arrow_back,color: Colors.black54,)),
    
          //user profile picture
          ClipRRect(
              borderRadius: BorderRadius.circular(mq.width *.3),
              child: CachedNetworkImage(
                width: mq.height * .05,
                height: mq.height * .05,
                imageUrl:list.isNotEmpty? list[0].image: widget.user.image,
                errorWidget: (context, url, error) => 
                    const CircleAvatar(child: Icon(CupertinoIcons.person)),
                 ),
            ),
    
            //for space
            SizedBox(width:10),
    
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
    
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //username
                Text( list.isNotEmpty?list[0].name  : widget.user.name,
                style: const TextStyle(fontSize: 16,color: Colors.black87,fontWeight: FontWeight.w500),),
    
              //for space
            SizedBox(height:2),
    
    
              Text(list.isNotEmpty ?
              list[0].isOnline ?'online':
              MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
               :MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
              style: const TextStyle(fontSize: 13,color: Colors.black54,),),
              
              ],)
        ],
      );
 
      },)   );
  }

  //chat input

  Widget _chatInput(){
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: mq.height *.01,horizontal: mq.width *.025),
      child: Row(
        children: [
          //input field buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(children: [
                //emoji button
                    IconButton(onPressed:() {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji=!_showEmoji);
                    },
                     icon: const Icon(Icons.emoji_emotions,color: Colors.blue,size: 25,)),
            
                    Expanded(
                      
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        onTap: () {
                         if (_showEmoji) setState(() => _showEmoji=!_showEmoji);

                        },
                        maxLines: null,
                        decoration:InputDecoration(hintText: 'Type Something...',hintStyle: TextStyle(color: Colors.blueAccent),border: InputBorder.none) ,)),
            
                      //image button
                    IconButton(onPressed:() async {
                    final ImagePicker picker = new ImagePicker();
                //pick multiple image
                final List<XFile> images =
                  await picker.pickMultiImage(imageQuality: 70);

                for (var i in images) {
                  setState(() => _isUploading= true);
                   await APIs.sendChatImage(widget.user,File(i.path));
                  setState(() => _isUploading= false);
                  
                }
                // if (images.isNotEmpty){
                //   log('Image Path:${images.path}');
                 
                 
                // }
                },
                     icon: const Icon(Icons.image,color: Colors.blue,size: 26,)),
                      //camera button
                    IconButton(onPressed:() async {
                      final ImagePicker picker = new ImagePicker();
                //pick an image
                final XFile?image =
                  await picker.pickImage(source:ImageSource.camera,imageQuality: 70);
                if (image != null){
                  log('Image Path:${image.path}');
                 setState(() => _isUploading= true);
                  await APIs.sendChatImage(widget.user,File(image.path));
                  setState(() => _isUploading= false);
                
                }
                    },
                     icon: const Icon(Icons.camera_alt_rounded,color: Colors.blue,size: 26,)),

                SizedBox(width:mq.width*.02 ,)
              ],),
            ),
          ),
    
          //send button
          MaterialButton(onPressed: (){
            if(_textController.text.isNotEmpty){
              if(_list.isEmpty){
                //on first message(add user to collection of chat user)
                APIs.sendFirstMessage(widget.user, _textController.text,Type.text);
              }
              else {
                //simply send messages
                APIs.sendMessage(widget.user, _textController.text,Type.text);
              }
              _textController.text='';
            }
          },
          minWidth: 0,
          padding: EdgeInsets.only(top: 10,bottom: 10,right: 5,left: 10),
          shape: CircleBorder(),
          color: Colors.green,
          child: Icon(Icons.send,color: Colors.white,size: 28,),
          )
        ],
      ),
    );
  }
}