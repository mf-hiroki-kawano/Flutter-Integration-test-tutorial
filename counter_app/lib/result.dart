import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NextPage extends StatelessWidget {
  NextPage(this.result);
  num result;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            message(result),
            Text(
              '$result',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
  Widget message(num result) {
    if (result == 0) {
      return const Text('0以外の数値で確定してください');
    } else {
      return  Text('Congratulations!!!');
    }
  }
}