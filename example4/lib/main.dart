import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

const names = [
  'Alice',
  'Bob',
  'Charlie',
  'David',
  'Eve',
  'Frank',
  'Grace',
  'Heidi',
  'Ivan',
  'Judy',
  'Kevin',
  'Leo',
  'Mallory',
  'Nina',
  'Oscar',
  'Peggy',
  'Quentin',
  'Ruth',
  'Sam',
  'Trudy',
  'Uma',
  'Victor',
  'Walter',
  'Xavier',
  'Yvonne',
  'Zara',
];

final tickerProvider = StreamProvider(
  (ref) => Stream.periodic(const Duration(seconds: 1), (i) => i + 1),
);

final namesProvider = StreamProvider((ref) {
  return ref.watch(tickerProvider.future).asStream().map((data) {
    print("data : ${data}");
    return names.getRange(0, data);
  });
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'Weather'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ref
          .watch(namesProvider)
          .when(
            data: (data) {
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (ctx, index) {
                  return ListTile(title: Text(data.elementAt(index)));
                },
              );
            },
            error: (error, stackTrace) => Text('erroe'),
            loading: () => Center(child: CircularProgressIndicator()),
          ),
    );
  }
}
