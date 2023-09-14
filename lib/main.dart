import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:functions_sample/push_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final messaging = FirebaseMessaging.instance;
  // 通知の許可をリクエスト
  await messaging.requestPermission(
    alert: true, // 通知が表示されるかどうか
    announcement: false, // アナウンスメント通知が有効かどうか
    badge: true, // バッジ（未読件数）が更新されるかどうか
    carPlay: false, // CarPlayで通知が表示されるかどうか
    criticalAlert: false, // 重要な通知（サイレントではない）が有効かどうか
    provisional: false, // 仮の通知（ユーザーによる設定を尊重）が有効かどうか
    sound: true, // 通知にサウンドが含まれるかどうか
  );

// フォアグラウンドで通知が表示されるオプションの設定
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // フォアグラウンドで通知が表示されるかどうか
    badge: false, // バッジ（未読件数）が表示されるかどうか
    sound: true, // 通知にサウンドが含まれるかどうか
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Function Sample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1;
  final functions = FirebaseFunctions.instance;

  Future<void> callFunction() async {
    try {
      final HttpsCallable callable = functions
          .httpsCallable('doubleNumber'); // Firebase Cloud Functions の関数名を指定
      final HttpsCallableResult result =
          await callable.call({'number': _counter}); // 関数を呼び出し、引数を渡す

      final data = result.data;
      setState(() {
        _counter = data['result'];
      }); // 関数からの結果を取得

      print('結果: ${data['result']}'); // 結果を表示
    } catch (e) {
      print('エラー: $e'); // エラーハンドリング
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 200),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const PushPage();
                  }));
                },
                child: const Text('プッシュページへ'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: callFunction,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
