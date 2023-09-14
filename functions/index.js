
const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();



// onCall 関数を定義します。
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

///ここまでは〜セットアップ&基本動作編〜



exports.pushTalk = functions.region('asia-northeast1').https.onCall(async (data, _response) => {
  const title = data.title;  // dataに格納されている引数を受け取る
  const body = data.body;
  const token = data.token;

  const message = {
    notification: {
      title: title,
      body: body
    },
    data: {
      title: title,
      body: body
    },
    android: {
      notification: {
        sound: 'default',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
    },
    apns: {
      payload: {
        aps: {
          badge: 1,
          sound: 'default'
        },
      },
    },
    token: token
  };
  pushToDevice(token, message);
});



function pushToDevice(token, payload) {

  admin.messaging().send(payload)
    .then(_pushResponse => {
      return {
        text: token
      };
    })
    .catch(error => {
      throw new functions.https.HttpsError('unknown', error.message, error);
    });
}


///ここまでは〜Push通知編〜
