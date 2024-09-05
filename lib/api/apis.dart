//import 'dart:ui';
// ignore_for_file: unused_local_variable
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:messaju/models/chat_user.dart';
import 'package:messaju/models/message.dart';

class APIs{
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;
//forfirebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for storing self information
  static late ChatUser me;

  static User get user => auth.currentUser!;

  // user exists or not check
  static Future<bool> userExists() async{
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

   // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async{
    final data = await firestore.collection('users').where('email',isEqualTo: email).get();

    log('data:${data.docs}');

    if(data.docs.isNotEmpty && data.docs.first.id != user.uid){
      //user exists
      log('user exists:${data.docs.first.data()}');
      firestore.collection('users').doc(user.uid).collection('my_users').doc(data.docs.first.id).set({});
      return true;

    }else{
      //user doesn't exist
      return false;
    }
  }

  //for push notification

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //for getting message token
  static Future<void> getFirebaseMessagingToken() async{
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if(t != null){
        me.pushToken = t;
        log('Push Token: $t');
      }

    });

    //handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.data}');

  if (message.notification != null) {
    log('Message also contained a notification: ${message.notification}');
  }
});
  }

  //for getting current user
    static Future<void> getSelfInfo() async{

       await firestore.collection('users').doc(user.uid).get().then((user) async {
        if(user.exists){
          me = ChatUser.fromJson(user.data()!);
          await getFirebaseMessagingToken(); 
          APIs.updateActiveStatus(true);  //for setting user is active
        }else{
          await createUser().then((value) => getSelfInfo());

        }

       });
  }

  //for push notifications
  static Future<void> sendPushNotification(ChatUser chatUser,String msg)async{
    try{
    final body ={
    "to":chatUser.pushToken,
     "notification": {
        "title":chatUser.name,
        "body":msg,
        "android_channel_id": "chats",
    },
    "data": {
    "some_data" : "User ID: ${me.id}",
  },

    };
    
    var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'), 
    headers: {
      HttpHeaders.contentTypeHeader:"application/json",
      HttpHeaders.authorizationHeader:"key=AAAAGhVmJbM:APA91bGgGhTve5EkUURcNnpwJIdMdEbmtevoLMigIdcSC6dj_eGIohW82egZxvw_OtvXiLyOxAK9ECXn3-SYU3jgjcC_HXOeKXknIcDuu63ZLz8WyaSXrlcOpwKX-shMaDsD6-joFTv9"

    },
    body: jsonEncode(body) );
    log('Response status: ${res.statusCode}');
    log('Response body: ${res.body}');
    }
    catch(e){
      log('\nsendPushNotificationE:$e');
    }

  }

  // for existing user
  static Future<void> createUser() async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();


    final chatUser = ChatUser(
      id:user.uid, 
      name:user.displayName.toString(),
      email:user.email.toString(),
      about:"Hey,I'm Using Messaju",
      image:user.photoURL.toString() ,
      createdAt: time,
      isOnline: false,
      lastActive:time,
      pushToken: ''

      );
    return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }
// for geeting all users from firebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds) {

    log("\nUserIds: $userIds");
    return firestore
    .collection('users')
    .where('id',whereIn: userIds)
    //.where('id',isNotEqualTo: user.uid)
    .snapshots();
  }

  // for getting id's of users from firebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
    .collection('users')
    .doc(user.uid)
    .collection('my_users')
    .snapshots();
  }

  //for adding user to myuser when first message is send
  static Future<void> sendFirstMessage(ChatUser chatUser,String msg,Type type) async{
    await firestore.collection('users').doc(chatUser.id).collection('my_users').doc(user.uid).set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  //update all users from firebase
  static Future<void> updateUserInfo() async{
    await firestore.collection('users').doc(user.uid).update({
      'name':me.name,
      'about':me.about,
    });
  }

  //update profile picture
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log('Extension:$ext');
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref.putFile(file,SettableMetadata(contentType: 'image/$ext')).then((p0) {
      log('Data transferred: ${p0.bytesTransferred / 1000} kb');
      
    });
  me.image=await ref.getDownloadURL();

  await firestore.collection('users').doc(user.uid).update({
      'image':me.image
    });

  }

//gettng conversation id

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser){
    return firestore.collection('users').where('id',isEqualTo: chatUser.id).snapshots();
  } 

  //update online or offline
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users')
    .doc(user.uid).update({'is_online':isOnline,
    'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
    'push_token':me.pushToken,
    });

  }

  //for sending messages

  static Future<void> sendMessage(ChatUser chatUser, String msg,Type type) async{
    //message sending time
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send

    //final Message message = Message(toId: chatUser.id, msg: msg, read: '', type: Type.text, sent: time, fromId: user.uid);
        final Message message = Message(
        toId: chatUser.id,
        msg: msg ,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);
    final ref=firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');

      await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUser,type == Type.text ? msg : 'image'));
  }


  //update read status

  static Future<void> updateMessageReadStatus(Message message) async{
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/').doc(message.sent).update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }


  //get last message

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user){
    return firestore
       .collection('chats/${getConversationID(user.id)}/messages/')
       .orderBy('sent', descending: true)
       .limit(1)
        .snapshots();
  }


// for send images
static Future<void> sendChatImage(ChatUser chatUser,File file)async {
     final ext = file.path.split('.').last;
    final ref = storage.ref().child('images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref.putFile(file,SettableMetadata(contentType: 'image/$ext')).then((p0) {
      log('Data transferred: ${p0.bytesTransferred / 1000} kb');
      
    });

  //update image in firebase
  final imageUrl=await ref.getDownloadURL();

  await APIs.sendMessage(chatUser, imageUrl, Type.image);


}

//for deleting message
static Future<void> deleteMessage(Message message) async{

      await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

      if(message.type == Type.image){
        await storage.refFromURL(message.msg).delete();
      }

}

//for updating message
static Future<void> updateMessage(Message message,String updatedMsg) async{

      await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});

}

}