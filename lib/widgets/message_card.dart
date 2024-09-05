import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:messaju/api/apis.dart';
import 'package:messaju/helper/dialogs.dart';
import 'package:messaju/helper/my_date_util.dart';
import 'package:messaju/main.dart';
import 'package:messaju/models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
   final Message message;
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {

 
  @override
  Widget build(BuildContext context) {

    bool isMe=APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child:isMe ? _greenMessage():_blueMessage() ,) ;
  }
// Another user Message
  Widget _blueMessage(){
    //update last read message if sender and receiver are different 

    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
      //log('message read updated');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type== Type.image ? mq.width*.03 :mq.width*.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width*.04, vertical: mq.height*.01),
            decoration: BoxDecoration(color: const Color.fromARGB(255, 221, 245, 255),
            border: Border.all(color: Colors.lightBlue),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30))),
            child:
            //show text
            widget.message.type == Type.text?
             Text(
              widget.message.msg,
            style: TextStyle(fontSize: 15,color: Colors.black87),):
            //show image
              ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => 
                    const Icon(Icons.image,size: 70,)),
                 ),
            ),
          ),
        Padding(
          padding:  EdgeInsets.only(right: mq.width*.04),
          child: Text(
            MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 13,color: Colors.black54),
          ),
        ),

      ],
    );
  }
//our message
  Widget _greenMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // time message
      children: [
        
        //
        Row(
          children: [

            SizedBox(width: mq.width*.04,),
            //double tick icon
            if(widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded,color: Colors.blue,size: 20,),

            //for some space
            const SizedBox(width: 2),

            //read time
            Text(
              MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13,color: Colors.black54),
            ),
          ],
        ),

        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width*.03 : mq.width*.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width*.04, vertical: mq.height*.01),
            decoration: BoxDecoration(color: Colors.greenAccent,
            border: Border.all(color: Colors.green),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(30))),
            child:
                        //show text
            widget.message.type == Type.text?
             Text(
              widget.message.msg,
            style: TextStyle(fontSize: 15,color: Colors.black87),):
            //show image
              ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                
                imageUrl: widget.message.msg,
                placeholder: (context, url) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => 
                    const Icon(Icons.image,size: 70,)),
                 ),
          ),
        ),

      ],
    );
  }

//bottom sheet for modifying message details
 void _showBottomSheet(bool isMe){
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))),
      builder: (_){
        return ListView(
          shrinkWrap: true,
          
          children: [
            Container(
              height:4,
              margin: EdgeInsets.symmetric(vertical: mq.height* .015,horizontal: mq.width*.4),
              decoration:BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(8)),),


          widget.message.type == Type.text ?
          // copy
          _OptionItem(icon: Icon(Icons.copy_all_rounded,color:Colors.blue,size: 24,), name:'Copy Text',
           onTap:() async {
            await Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value) {
              //for hidind bottom sheet
              Navigator.pop(context);

              Dialogs.showSnackbar(context, "Text Copied");
            });
           })
          :
          // save image
          _OptionItem(icon: Icon(Icons.download_rounded,color:Colors.blue,size: 24,), name:'Save Image', 
          onTap:() async {
            try{
            log('Image Url: ${widget.message.msg}');
                await GallerySaver.saveImage(widget.message.msg,albumName: 'Messeju').then((success) {
                  //for hidind bottom sheet
                  Navigator.pop(context);
                  if(success != null && success){
                    Dialogs.showSnackbar(context, "Image Saved Successfully");
                  }
                  });
            }
            catch(e){
              log('ErrorWhileSavingImage:$e');
            }

          }),


          //divider or seperator
          if(isMe)
          Divider(
            color:Colors.black54,
            endIndent: mq.width*.04,
            indent: mq.width*.04,
          ),
 
          //edit option
          if(widget.message.type == Type.text && isMe)
            _OptionItem(icon: Icon(Icons.edit,color:Colors.blue,size: 24,), name:'Edit Message',
             onTap:(){
               //for hidind bottom sheet
              Navigator.pop(context);
              _showMessageUpdateDialog();
             }),

          
          //delete
          if(isMe)
          _OptionItem(icon: Icon(Icons.delete_forever,color:Colors.red,), name:'Delete Message',
           onTap:() async {
            await APIs.deleteMessage(widget.message).then((value) {
              //for hidind bottom sheet
              Navigator.pop(context);
            });
           }),
          //divider or seperator
          Divider(
            color:Colors.black54,
            endIndent: mq.width*.04,
            indent: mq.width*.04,
          ),
          //sent at
          _OptionItem(icon: Icon(Icons.remove_red_eye,color:Colors.blue,size: 24,), 
          name:'Sent At:${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
           onTap:(){}),
          //read at
          _OptionItem(icon: Icon(Icons.remove_red_eye,color:Colors.green,size: 24,),
 
          name: widget.message.read.isEmpty ? "Read At : Not Seen Yet" :

          'Read At:${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
           onTap:(){})
          ],
        );

      } 
    );
  }
  //dialog for updating message content
  void _showMessageUpdateDialog(){
    String updatedMsg = widget.message.msg;

    showDialog(context: context, builder: (_) => AlertDialog(
      contentPadding: EdgeInsets.only(left: 24,right: 24,top: 20,bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //title
      title: Row(children: const [Icon(Icons.message,color: Colors.blue,size: 28,),
      Text(" Update Message")]),

      //content
      content: TextFormField(initialValue: updatedMsg,
      maxLines: null,
      onChanged: (value) => updatedMsg = value,
      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      ),

      //actions
      actions: [
        //cancel  button
        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },
        child: const Text("Cancel",style: TextStyle(color: Colors.blue,fontSize: 16),),),

       //update button
        MaterialButton(onPressed: (){
          Navigator.pop(context);
          APIs.updateMessage(widget.message, updatedMsg);
        },
        child: const Text("Update",style: TextStyle(color: Colors.blue,fontSize: 16),),),
      ],
    ));
  }

}
//custom options card
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem({required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: () => onTap(),
    child: Padding(
      padding: EdgeInsets.only(left: mq.width*.05,top: mq.height*.015,bottom: mq.height*.015),
      child: Row(
        children: [
          icon,Flexible(child: Text('     $name',style: TextStyle(fontSize: 15,color:Colors.black54,letterSpacing: 0.5),))
        ],
      ),
    ),);
  }
}