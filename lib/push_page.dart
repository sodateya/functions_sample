import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushPage extends StatefulWidget {
  const PushPage({super.key});

  @override
  State<PushPage> createState() => _PushPageState();
}

class _PushPageState extends State<PushPage> {
  String tokenText = 'トークンはまだありません';

  final fcm = FirebaseMessaging.instance;
  Future getToken() async {
    final token = await fcm.getToken();
    setState(() {
      tokenText = token!;
    });
  }

  final functions = FirebaseFunctions.instanceFor(region: 'asia-northeast1');
  Future<void> push(String token) async {
    try {
      final HttpsCallable callable = functions.httpsCallable('pushTalk');
      final HttpsCallableResult result = await callable.call({
        'title': 'Push通知テスト',
        'body': '自分から届きました',
        'token': tokenText
      }); // 関数を呼び出し、引数を渡す
    } catch (e) {
      print('エラー: $e'); // エラーハンドリング
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Push Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tokenText),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                  onPressed: () async {
                    getToken();
                  },
                  child: const Text('トークン発行')),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                  onPressed: () async {
                    push(tokenText);
                    print(tokenText);
                  },
                  child: const Text('通知')),
            )
          ],
        ),
      ),
    );
  }
}
