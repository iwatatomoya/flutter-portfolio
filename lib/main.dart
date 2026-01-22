import 'package:flutter/material.dart';
import 'package:self_analysis_app/screens/history_screen.dart';
import 'package:self_analysis_app/screens/profile_screen.dart';
import 'package:self_analysis_app/screens/skill_screen.dart';


void main(){
  runApp(
    MaterialApp(
      title: "Self Analysis",
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Portfolio", 
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold)
          ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 画面A（プロフィール画面）
            SizedBox(
              width: 300,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProfileScreen();
                  }));
                },
                icon: Icon(Icons.person),
                label: Text("プロフィール (Profile)", style: TextStyle(fontSize: 21)),
              ),
            ),
            
            SizedBox(height: 20),

            // 画面B（スキル・性格）
            SizedBox(
              width: 300,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SkillScreen();
                  }));
                },
                icon: Icon(Icons.bar_chart),
                label: Text("スキル・性格 (Skills)", style: TextStyle(fontSize: 21)),
              ),
            ),

            SizedBox(height: 20),

            // 画面C（経歴・実績）
            SizedBox(
              width: 300,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return HistoryScreen();
                  }));
                },
                icon: Icon(Icons.history_edu),
                label: Text("経歴・実績 (History)", style: TextStyle(fontSize: 21)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}