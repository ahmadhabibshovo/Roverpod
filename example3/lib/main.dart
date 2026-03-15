import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

enum City { dhaka, paris, tokyo }

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(Duration(seconds: 2), () {
    return {City.dhaka: "🌦️", City.paris: "🌞", City.tokyo: "❄️"}[city]!;
  });
}

final cityProvider = StateProvider<City?>((ref) => null);

final weatherProvider = FutureProvider<WeatherEmoji>((ref) {
  final city = ref.watch(cityProvider);

  return city == null ? "Unkonwn City" : getWeather(city);
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.all(8),
              child: ref
                  .watch(weatherProvider)
                  .when(
                    data: (data) {
                      return Text(data);
                    },
                    error: (obj, tracre) {
                      Text("Something Wrong");
                      return null;
                    },
                    loading: () => Center(child: CircularProgressIndicator()),
                  ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: City.values.length,
                itemBuilder: (context, index) {
                  final selectedCity = ref.watch(cityProvider);
                  return ListTile(
                    onTap: () => ref.read(cityProvider.notifier).state =
                        City.values[index],
                    title: Text(City.values[index].toString()),
                    trailing: selectedCity == City.values[index]
                        ? Icon(Icons.check)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
