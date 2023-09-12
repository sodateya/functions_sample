
const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require('firebase-functions');



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