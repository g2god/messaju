
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messaju/api/apis.dart';
import 'package:messaju/helper/dialogs.dart';
import 'package:messaju/main.dart';
import 'package:messaju/models/chat_user.dart';
import 'package:messaju/screens/auth/profile_screen.dart';
import 'package:messaju/widgets/chat_user_card.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 List<ChatUser> _list=[];
 final List<ChatUser> _Searchlist=[];

 bool _isSearching=false;

 @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    
    SystemChannels.lifecycle.setMessageHandler((message) {

      if(APIs.auth.currentUser !=null) {

      if(message.toString().contains('resume')) APIs.updateActiveStatus(true);
      if(message.toString().contains('pause')) APIs.updateActiveStatus(false);}


      return Future.value(message);
          });
  }

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: (){
          if(_isSearching) {
            setState(() {
              _isSearching =!_isSearching;
            });
          return Future.value(false);
          }else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          //appbar
          appBar: AppBar(
            leading:const Icon(CupertinoIcons.home),
            title: _isSearching ? TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Name, Email,...',
              ),
              autofocus: true,
              style: TextStyle(fontSize: 16,letterSpacing: 1),
              //search text changes then updated search list
              onChanged: (val) {
                //search logic
                _Searchlist.clear();
                for (var i in _list){
                  if(i.name.toLowerCase().contains(val) || i.email.toLowerCase().contains(val)){
                    _Searchlist.add(i);
                  }
                  setState(() {
                    _Searchlist;
                  });
          
                }
          
              }
            ) :Text('Messeju'),
            actions: [
              //search icon
              IconButton(
                icon: Icon(_isSearching?CupertinoIcons.clear_circled_solid:Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching=!_isSearching;
                  });
                  },),
              //featuresicon
              IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(
                    builder: (_) => ProfileScreen(user:APIs.me)));
                },
              ),
            ],
          
        
         ),
          
         //floating button bottom
         floatingActionButton: Padding(
         padding: const EdgeInsets.only(bottom: 20,right: 15),
         child: FloatingActionButton(onPressed: () async {
              _addChatUserDialog();
  
          },
            child: const Icon(Icons.add_comment_rounded),
          ),
         ),
         //body
         body:StreamBuilder(
          stream: APIs.getMyUsersId(),
          //get id of only known users
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
            //if data loading
            case ConnectionState.waiting:
            case ConnectionState.none:
                // return Center(child: CircularProgressIndicator());
            
            // if all data is available show it
            case ConnectionState.active:
            case ConnectionState.done:
              return StreamBuilder(
                    stream:APIs.getAllUsers(
                      snapshot.data?.docs.map((e) => e.id)
                      .toList() ?? []
                    ),
         //get only those user, who's ids are provided
         builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            //if data loading
            case ConnectionState.waiting:
            case ConnectionState.none:
                //return Center(child: CircularProgressIndicator());
            
            // if all data is available show it
            case ConnectionState.active:
            case ConnectionState.done:
          
                final data = snapshot.data?.docs;
           
              _list= data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
            
          
          if(_list.isNotEmpty){
           
            return ListView.builder(
            itemCount:_isSearching?_Searchlist.length: _list.length,
            padding: EdgeInsets.only(top: mq.height*.02),
            physics: BouncingScrollPhysics(),
            itemBuilder: (context,index) {
              return ChatUserCard(user:_isSearching?_Searchlist[index] : _list[index]);
              // return Text('Name:${list[index]}'); ;
            },);
          }
          else{
              return Center(child:Text('No Connections Found!',style: TextStyle(fontSize: 20)),);
          }  
          }    
          }, 
         );
           }
         },),
         ),
      ),
    ); 
  }

  //dialog for add new user
  void _addChatUserDialog(){
    String email = " ";

    showDialog(context: context, builder: (_) => AlertDialog(
      contentPadding: EdgeInsets.only(left: 24,right: 24,top: 20,bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //title
      title: Row(children: const [Icon(Icons.person_add,color: Colors.blue,size: 28,),
      Text(" Add User")]),

      //content
      content: TextFormField(
      
      maxLines: null,
      onChanged: (value) => email= value,
      decoration: InputDecoration(
        hintText: "Email id",prefixIcon: Icon(Icons.email,color: Colors.blue,),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      ),

      //actions
      actions: [
        //cancel  button
        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },
        child: const Text("Cancel",style: TextStyle(color: Colors.blue,fontSize: 16),),),

       //add button
        MaterialButton(onPressed: () async {
          Navigator.pop(context);
          if(email.isNotEmpty){
          await APIs.addChatUser(email).then((value) {
            if(!value){
              Dialogs.showSnackbar(context, 'User Does not Exist');
            }
          });}

        },
        child: const Text("Add",style: TextStyle(color: Colors.blue,fontSize: 16),),),
      ],
    ));
  }
}