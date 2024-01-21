import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget{
  const NewMessage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _NewMessageSate();
      
  }
}

class _NewMessageSate extends State<NewMessage>{

  var _messageController = TextEditingController();

  void dispose(){
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async{
    final enteredMessage = _messageController.text;
    if(enteredMessage.trim().isEmpty){
      return;
    }
    FocusScope.of(context).unfocus();
    _messageController.clear();
     // send to firebase
     final user = FirebaseAuth.instance.currentUser!;
     final userData = await FirebaseFirestore.instance
     .collection('users')
     .doc(user.uid)
     .get();

     FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username']!,
      'userImage': userData.data()!['image_url']!,
     });

     
     
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(child: 
            TextField(
              controller: _messageController,
              textCapitalization:  TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(
                labelText: 'Send a message....',
              ),
            ),
          ), 
          IconButton(
            onPressed: _submitMessage, 
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    
    );
    
  }
}