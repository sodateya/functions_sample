# functions_sample

# 目次
[1.はじめに](#はじめに)
[2-1. 例１: Functionsにデータを処理してもらう](#例１-functionsにデータを処理してもらう)
[2-2. 例2: Push通知を送る](#例2--push通知を送る)
[2-3. 例3 : Firebaseを監視して動作する](#例3--firebaseを監視して動作する)
[3.FunctionsをFlutterで使えるようにする](#functionsをflutterで使えるようにする)
[4Functionsを動かす](#functionsを動かす)
[5.Functionsを書くindex.jsを編集](#functionsを書くindexjsを編集)
[6.FlutterでFunctionsを読んで動かす](#flutterでfunctionsを呼んで動かす)
[7.まとめ](#まとめ)


# はじめに
CloudFunctionsとは、簡単に表現するとサーバー内に関数を保存して、必要なタイミングで呼び出せるサービスです。
何を言っているか自分でも分からなくなりそうなので、使用例を図と共に紹介します！

## 例１: Functionsにデータを処理してもらう
![スライド1.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3075676/fbd9e64d-13cc-e528-a680-5eb026ef7186.png)

これはアプリからFunctionsに数字を送って送った数字を２倍にして返してもらう。という関数をFunctionsに保存して使用する例です。

ここで注意してほしい事がFunctionsがデータを返すときはjson型で返してきます。

この図は見ての通りですので次の使用例にいきましょう！

## 例2 : Push通知を送る
![スライド2.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3075676/cb5c4c23-9067-5e63-1368-69d43e2bdf0d.png)


Flutter × Push通知といえばFunctions！！
といってもいいほど使用されるケースが多い例だと思います。

これも図を見ての通りですが、Push通知を送るためには複雑なサービスの壁をのり超えていかないと届けることはできません。ですがFunctionsとFirebase Cloud Messaging（FCM）というものを使用することで簡単に実装することができます。

これに関しましては次回以降詳しく説明していこうと思います。では次の例へ！！

## 例3 : Firebaseを監視して動作する
![スライド3.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3075676/28eed290-0660-3ebd-c8d6-bd5b97384b5f.png)


少し図が複雑になってしまいました。すいません。
この使用例はFirebaseのドキュメントが削除されるタイミングを監視して、削除されたドキュメントをログに残しておく関数(ここではcheckDb();)をFunctionsに保存しておくというものになります。

ばた子がどんな投稿を削除したか、アプリの管理者側からすると確認しておきたいものですよね？
もし荒らしを書いては消してを繰り返していたらコストがすごいことになります。そんなユーザを特定するためにも、Functionsは役に立ってくれます！

これに関しましても次回以降詳しく説明していこうと思います。

まだまだ使い方はたくさんありますが、使用例はここまでとなります。

# FunctionsをFlutterで使えるようにする
前置きが長くなりましたがさっそく、FunctionsとFlutterを結びつけていきましょう！

* 使用パッケージ
firebase_core  

https://pub.dev/packages/firebase_core

cloud_functions

https://pub.dev/packages/cloud_functions

* Firebaseプロジェクトを作成
Firebaseのプロジェクトを作成し、Flutterで動くようにセットアップします。
今回はセットアップ方法は割愛させていただいます。

:::note warn
Firebaseのプランを従量制に変更しないとFunctionsを使用できませんのでここで変更しておいてください！！
:::


https://zenn.dev/kazutxt/books/flutter_practice_introduction/viewer/29_chapter4_overview

こちらがとてもわかりやすいので参考までに!

* Functionsのセットアップ

1. firebase-toolsをプロジェクトファイルにインストール
``` ターミナル.
npm install -g firebase-tools
```

２. Functionsと必要なツールをプロジェクトファイルに追加
``` ターミナル.
firebase init functions
```

これを実行すると質問いくつかをされます。

>? What language would you like to use to write Cloud Functions? 

これは何の言語でFunctionsの関数を書きますか？と聞いています。
JavaScript、TypeScript、Pythonから選べます。

今回はJavaScriptを選びました。
Dartでかけたらいいんですけどね、、、

>Do you want to use ESLint to catch probable bugs and enforce style? (y/N)

これはESLintを使用するか聞いています。
使うとたまにおかしくなるので僕は使用しません。

これが完了すると、プロジェクトファイルにいくつか新しいファイルが生成されます。
中でも重要なものを以下で説明します。

| path |説明| 
|-----------|------------|
| functions/index.js|ここに関数を書いていきます|
| functions/package.json|Flutterでいうpubspec.yamlのようなもの| 
| firebase.json|作った関数をFunctionsにデプロイするために使います| 
| .firebaserc|Firebaseのプロジェクトを指定するために使用（多分）| 

※デプロイ：サーバにアップロードして使用できるようにする的な意味

ここまででセットアップは完了ですお疲れ様でした！

# Functionsを動かす
今回は使用例１で紹介したものをFlutterのカウントアップアプリで使用していいきたいと思います！


* サンプル
![20230912_163831.GIF](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3075676/25fa2b33-75c9-c52f-bbba-a1270351d3ed.gif)

## Functionsを書く　~index.jsを編集~

* index.jsを編集
Javascriptで書いていきます。
下記コードのexports.の後の部分が関数名となります。
ですので今回の関数名はdoubleNumberとなります。
```index.js

const functions = require('firebase-functions');

exports.doubleNumber = functions.https.onCall((data, context) => {
    // クライアントから送信された数値を取得します。
    const number = data.number;

    // 数値を2倍にして返します。
    const result = number * 2;

    // 結果を返します。
    return {
        result: result
    };
});

```

* Functionsにデプロイ
--only functionsをつけることでfunctionsのみデプロイすることができます。
ここでのfunctionsはfirebase.jsonで名前を指定されています。
firebase.jsonファイルを見てみると何となくわかると思います,,,
```ターミナル.
firebase deploy --only functions
```
成功するとFirebaseコンソールのFunctionsにdoubleNumberがあると思います
![スクリーンショット 2023-09-12 11.21.46.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3075676/54455576-f707-231a-fce4-bdb7d9dcde9f.png)

## FlutterでFunctionsを呼んで動かす
一部割愛していますが全体のコードは以下になります。

```main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

//////////
//////////
//////////

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1;

//Functionsを初期化
  final functions = FirebaseFunctions.instance;

  Future<void> callFunction() async {
    try {
      final HttpsCallable callable = functions
          .httpsCallable('doubleNumber'); 
      // Firebase Cloud Functions の関数名を指定
      final HttpsCallableResult result =
          await callable.call({'number': _counter}); 
      // 関数を呼び出し、引数を渡す

      final data = result.data;
      setState(() {
        _counter = data['result'];
      }); // 関数からの結果を取得

      print('結果: ${data['result']}'); // 結果を表示
    } catch (e) {
      print('エラー: $e'); // エラーハンドリング
    }
  }
//////////
//////////
//////////
    floatingActionButton: FloatingActionButton(
        onPressed: callFunction,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
```
***
* 重要そうな部分を細かく説明

以下のコードはFunctions呼び出し処理とFunctionsのjsコードです。

main.dartの、callable.call({'number': _counter})部分はindex.jsの
onCall((data, context)のdataに入り、data.numberというふうに処理できるようになります。
このjsのコードは最終的にdata.numberを２をかけてアプリに返しています。

***



```main.dart
final HttpsCallable callable = functions
          .httpsCallable('doubleNumber'); 

      final HttpsCallableResult result =
          await callable.call({'number': _counter}); 
```
```index.js
// onCall 関数を定義します。
exports.doubleNumber = functions.https.onCall((data, context) => {
    const number = data.number;
    const result = number * 2;
    return {
        result: result
    };
});
```
***
以下のコードは受け取った値をFlutterを扱えるようにしている部分です。
result.dateはMap型のように扱えます。
受け取って値を_counterに代入して、最終的には画面に反映しています。
```main.dart
 final data = result.data;
      setState(() {
        _counter = data['result'];
      }); // 関数からの結果を取得
```

# まとめ
今回はFunctionsのセットアップと簡単な使い方を紹介しました。
後半は少し説明が難しく、分かりずらかったかもしれませんが実際に動かしてみるとわかってくると思います。
Functionsは、push通知、DB監視、そして決済などにも使用されます。
これらも紹介していきたいと思っておりますので、お待ちください！！

コードは以下のGitにありますので参考にしてみてください！！

https://github.com/sodateya/functions_sample
