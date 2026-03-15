import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

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
      home: const MyHomePage(title: 'Person'),
    );
  }
}

class Person {
  final String name;
  final String age;
  String uuid;

  Person({required this.name, required this.age, String? uuid})
    : uuid = uuid ?? Uuid().v4();

  Person updated([String? name, String? age]) {
    return Person(name: name ?? this.name, age: age ?? this.age, uuid: uuid);
  }

  String get getInfo => '$name  is $age years old.';
}

class DataModel extends ChangeNotifier {
  final List<Person> _people = [];
  int get count => _people.length;
  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);

  void addPerson(String name, String age) {
    _people.add(Person(name: name, age: age));
    notifyListeners();
  }

  void updatePerson(Person person, int index, String name, String age) {
    _people[index] = person.updated(name, age);
    notifyListeners();
  }
}

final dataModelProvider = ChangeNotifierProvider((ref) => DataModel());

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
      body: ref.watch(dataModelProvider).people.isEmpty
          ? const Center(child: Text('No people added yet.'))
          : ListView.builder(
              itemCount: ref.watch(dataModelProvider).people.length,
              itemBuilder: (ctx, index) {
                final person = ref.watch(dataModelProvider).people[index];
                return ListTile(
                  title: Text(person.getInfo),
                  onTap: () {
                    // SHOW DIALOG TO UPDATE PERSON
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        String name = person.name;
                        String age = person.age;
                        return AlertDialog(
                          title: const Text('Update Person'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                ),
                                onChanged: (value) => name = value,
                                controller: TextEditingController(
                                  text: person.name,
                                ),
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Age',
                                ),
                                onChanged: (value) => age = value,
                                controller: TextEditingController(
                                  text: person.age,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(dataModelProvider)
                                    .updatePerson(person, index, name, age);
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('Update'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //show dialog to add a new person
          showDialog(
            context: context,
            builder: (ctx) {
              String name = '';
              String age = '';
              return AlertDialog(
                title: const Text('Add Person'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      onChanged: (value) => name = value,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Age'),
                      onChanged: (value) => age = value,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      ref.read(dataModelProvider).addPerson(name, age);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
