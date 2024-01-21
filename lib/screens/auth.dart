import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';


final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget{
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen>{
  final _key = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail ='';
  var _enteredPass = '';
  File? _selectedImage;
  var _isUploading = false;
  var _enteredUsername ='';
 
  void _submit() async{
    final isValid = _key.currentState!.validate();
     FocusScope.of(context).unfocus();
      if(!isValid || !_isLogin && _selectedImage == null){
        // Show error message
        return;
      }
      _key.currentState!.save();

       try{
         setState(() {
           _isUploading = true;
         });
          if(_isLogin){
               final UserCredentials = await _firebase.signInWithEmailAndPassword(email: _enteredEmail, password: _enteredPass);
               
          }else{
              final userCredentials =  await _firebase.createUserWithEmailAndPassword(email: _enteredEmail, password: _enteredPass);
              final storageRef = FirebaseStorage.instance.ref().child('user_image').child('${userCredentials.user!.uid}.jpg');
              await storageRef.putFile(_selectedImage!);
              final imageUrl = await storageRef.getDownloadURL();
              await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredentials.user!.uid)
              .set({
                'username': _enteredUsername,
                'email': _enteredEmail,
                'image_url': imageUrl,
                }
              );
             }
      }on FirebaseAuthException catch(error){
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(error.message?? 'Authentication Failed')
                  )
                );
                setState(() {
                  _isUploading = false;
                });
        }
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30, 
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/image/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _key,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if(!_isLogin)UserImagePicker(onPickImage: (pickedImage) {
                            _selectedImage = pickedImage;
                          },),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Enter Your E-mail',

                            ),
                            validator: (value) {
                              if(value == null || value.trim().isEmpty || !value.contains('@')){
                                return 'Please Enter a valid email address';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            textCapitalization: TextCapitalization.none,
                            autocorrect: false,
                            onSaved: (newValue) {
                              _enteredEmail = newValue!;
                            },
                          ),
                          if(!_isLogin)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Username'
                            ),
                            enableSuggestions: false,
                            validator: (value){
                              if(value == null || value.isEmpty || value.trim().length<4){
                                return 'Please enter at least 4 characters';
                              }
                              return null;
                            },
                            onSaved:(value){
                              _enteredUsername = value!;
                            } ,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Enter Your Password',

                            ),
                            validator: (value) {
                              if(value == null || value.trim().length<6 ){
                                return 'Password should be of length 6';
                              }
                              return null;
                            },
                            obscureText: true,
                            onSaved: (newValue) {
                              _enteredPass = newValue!;
                              
                            },
                          ),
                          const SizedBox(height: 12,),
                          if(_isUploading)
                              const CircularProgressIndicator(),
                          if(!_isUploading)
                          ElevatedButton(
                            
                            onPressed: _submit, 
                            child: Text(_isLogin?'Login':'SignUp')
                          ),
                          if(!_isUploading)
                          TextButton(
                            onPressed: (){
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            }, 
                            child: Text(_isLogin?'Create New Account' : 'Already Have an Account')
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

      ),

    );
  }
}