import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDateUtil{
  static String getFormattedTime({required BuildContext context,required String time}){
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  //for getting time for sent and read
  static String getMessageTime(
    {required BuildContext context , required String time}){
      final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
      final DateTime now = DateTime.now();
      final formatedTime = TimeOfDay.fromDateTime(sent).format(context);

    if(now.day == sent.day && now.month == sent.month && now.year == sent.year){
      return TimeOfDay.fromDateTime(sent).format(context);
    }

    return now.year == sent.year 
    ?'$formatedTime - ${sent.day} ${_getMonth(sent)}'
    :'$formatedTime - ${sent.day} ${_getMonth(sent)} ${sent.year}' ;
    }


  //get last message time
  static String getLastMessageTime(
    {required BuildContext context,required String time,bool showYear =false}
  ){
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if(now.day == sent.day && now.month == sent.month && now.year == sent.year){
      return TimeOfDay.fromDateTime(sent).format(context);
    }

    return showYear 
    ?'${sent.day} ${_getMonth(sent)} ${sent.year}' 
    : '${sent.day} ${_getMonth(sent)}';
  }

  //get formatted last active time
  static String getLastActiveTime({
    required BuildContext context,required String lastActive
  }){
    final int i = int.tryParse(lastActive) ?? -1;

    //if time is not available
    if(i == -1) return 'Last Seen Not Available' ;

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);

    if(time.day == now.day &&
    time.month== now.month &&
    time.year == time.year ){
      return 'Last Seen today at $formattedTime';
    }

    if((now.difference(time).inHours /24).round()==1){
      return 'Last Seen Yesterday at $formattedTime ';
    }
    String month = _getMonth(time);
    return 'Last Seen on ${time.day} $month on $formattedTime';
  }

  //get month name

  static String _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }
}