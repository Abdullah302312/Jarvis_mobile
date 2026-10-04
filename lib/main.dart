import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

const String groqApiKey = "PASTE_YOUR_GROQ_KEY_HERE";

void main()=>runApp(MaterialApp(home:JarvisHome(),debugShowCheckedModeBanner:false));
class JarvisHome extends StatefulWidget{ _JarvisHomeState createState()=>_JarvisHomeState();}
class _JarvisHomeState extends State<JarvisHome>{
  late stt.SpeechToText _speech; FlutterTts tts=FlutterTts();
  String text="Mic dabao aur bolo"; bool listening=false;
  final String groqKey=" PASTE_YOUR_GROQ_KEY_HERE";

  @override initState(){super.initState();_speech=stt.SpeechToText();}

  Future<String> askGroq(String p) async{
    final r=await http.post(Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
      headers:{"Content-Type":"application/json","Authorization":"Bearer $groqKey"},
      body:jsonEncode({"model":"llama-3.3-70b-versatile","messages":[{"role":"user","content":p}]}));
    return jsonDecode(r.body)['choices'][0]['message']['content'];
  }
  void listen() async{
    bool a=await _speech.initialize();
    if(a){setState(()=>listening=true);
      _speech.listen(onResult:(v)async{setState(()=>text=v.recognizedWords);
        if(v.finalResult){String rep=await askGroq(text);setState(()=>text=rep);await tts.speak(rep);setState(()=>listening=false);}});
    }
  }
  @override Widget build(BuildContext c){return Scaffold(backgroundColor:Colors.black,
    body:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      AvatarGlow(animate:listening,glowColor:Colors.cyan,child:FloatingActionButton(backgroundColor:Colors.cyan,onPressed:listen,child:Icon(Icons.mic,size:36))),
      SizedBox(height:30),Padding(padding:EdgeInsets.all(20),child:Text(text,style:TextStyle(color:Colors.cyanAccent,fontSize:18),textAlign:TextAlign.center))
    ])));}
}