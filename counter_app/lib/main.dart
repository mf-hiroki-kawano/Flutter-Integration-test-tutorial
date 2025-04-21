import 'package:counter_app/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider = StateProvider<int>((_) => 0);
final isValid = StateProvider<bool>((_) => true);
void main() {
  runApp(
    // アプリをラップしてproviderを伝播させる
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Counter App',
      home: MyHomePage(title: 'Counter App Home Page'),
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
  // int counterProvider = 0;
  String enterText = "";
  RegExp exp = RegExp(r'^[0-9]{1,99}$');
  final _textEditingController = TextEditingController();
  // bool isValid = true;

  // void _incrementCounter() {
  //   setState(() {
  //     counterProvider++;
  //   });
  // }

  String? _validate(String? input) {
    if (input == null) {
      return null;
    }
    if (!exp.hasMatch(input)) {
      print('バリデーションエラ−発生');
      return '数字を入力してください';
    }
    return null;
  }

  void _onFormChanged(String? value) {
    // バリデーション実行結果の保存
    print('_onFormChanged開始');
    final validateResult = _validate(enterText);
    print(enterText);
    print(validateResult);
    final beNull = validateResult ?? true;
    print(beNull);
    if (beNull == true) {
      print('ステータスtrue');
      setState(() {
        isValid = true;
      });
    } else {
      print('ステータスfalse');
      setState(() {
        isValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ボタンを押すことで数値を増加できます',
            ),
            Text(
              '${ref.watch(counterProvider)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Form(
              
              child:TextFormField(
                controller: _textEditingController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged:(value) {
                  enterText = value;
                  _onFormChanged(value);
                },
                validator: _validate,
                decoration: InputDecoration(
                  labelText: 'number',
                  // hintText: 'Enter number',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              )
            ),
            ElevatedButton(
              onPressed: isValid?(){
                  setState(() {
                    // counterProvider = int.parse(enterText);
                    ref.watch(counterProvider.notifier).state.toInt();
                  });
              } : null ,
              child: const Text('入力表示'),
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NextPage(ref.watch(counterProvider))),
                );
              },
              child: Text('これで確定する'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('increment'),
        onPressed: () => ref.watch(counterProvider.notifier).state++,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
