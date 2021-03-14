import 'package:clean_architecture_tdd/features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'package:flutter/material.dart';
import 'package:clean_architecture_tdd/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // It's our responsibility to invoke the init() method and the best place for
  // this ​service locator ​initialization is inside the main() function.

  await di.init();

  // It's important to await the Future even though it only contains void. We
  // definitely don't want the UI to be built up before ​any of the dependencies
  // had a chance to be registered.​​

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numver Trivia',
      theme: ThemeData(
        primaryColor: Colors.green.shade800,
        accentColor: Colors.green.shade600,
      ),
      home: NumberTriviaPage(),
    );
  }
}
