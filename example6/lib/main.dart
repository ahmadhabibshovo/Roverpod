import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

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
      home: const MyHomePage(title: 'Film List'),
    );
  }
}

class Film extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isFavorite;

  const Film({
    required this.id,
    required this.title,
    required this.description,
    this.isFavorite = false,
  });

  Film copy({bool? isFavorite}) {
    return Film(
      id: id,
      title: title,
      description: description,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() {
    return 'Film(id: $id, title: $title, description: $description, isFavorite: $isFavorite)';
  }

  @override
  List<Object?> get props => [id, title, description, isFavorite];
}

final allFilms = [
  Film(
    id: '1',
    title: 'The Shawshank Redemption',
    description:
        'Two imprisoned  men bond over a number of years, finding solace and eventual redemption through acts of common decency.',
  ),
  Film(
    id: '2',
    title: 'The Godfather',
    description:
        'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.',
  ),
  Film(
    id: '3',
    title: 'The Dark Knight',
    description:
        'When the menace known as the Joker emerges from his mysterious past, he wreaks havoc and chaos on the people of Gotham.',
  ),
  Film(
    id: '4',
    title: 'Pulp Fiction',
    description:
        'The lives of two mob hitmen, a boxer, a gangster\'s wife, and a pair of diner bandits intertwine in four tales of violence and redemption.',
  ),
  Film(
    id: '5',
    title: 'The Lord of the Rings: The Return of the King',
    description:
        'Gandalf and Aragorn lead the World of Men against the army of Mordor to draw their gaze from Frodo and Sam as they approach Mount Doom.',
  ),
];

class FilmNotifier extends StateNotifier<List<Film>> {
  FilmNotifier() : super(allFilms);

  void toggleFavorite(int index) {
    state[index] = state[index].copy(isFavorite: !state[index].isFavorite);
  }
}

final filmProvider = StateNotifierProvider<FilmNotifier, List<Film>>((ref) {
  return FilmNotifier();
});

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,

      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
        ),
        body: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'All Films'),
                Tab(text: 'Favorite Films'),
              ],
            ),
            Expanded(
              child: TabBarView(children: [FilmList(onToggleFavorite: ref.read(filmProvider.notifier).toggleFavorite  ), FavoriteFilmList()]),
            ),
          ],
        ),
      ),
    );
  }
}

class FilmList extends StatelessWidget {
  List<Film> get films => allFilms;
  final onToggleFavorite;
  const FilmList({super.key, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context, ) {
    return ListView.builder(
      itemCount: films.length,
      itemBuilder: (context, index) {
        final film = films[index];
        return ListTile(
          title: Text(film.title),
          subtitle: Text(film.description),
          trailing: IconButton(
            icon: Icon(
              film.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: film.isFavorite ? Colors.red : null,
            ),
            onPressed: () =>
                ref.read(filmProvider.notifier).toggleFavorite(index),
          ),
        );
      },
    );
  }
}

class FavoriteFilmList extends ConsumerWidget {
  const FavoriteFilmList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(filmProvider);
    final favoriteFilms = films.where((film) => film.isFavorite).toList();
    return ListView.builder(
      itemCount: favoriteFilms.length,
      itemBuilder: (context, index) {
        final film = favoriteFilms[index];
        return ListTile(
          title: Text(film.title),
          subtitle: Text(film.description),
          trailing: IconButton(
            icon: Icon(
              film.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: film.isFavorite ? Colors.red : null,
            ),
            onPressed: () => ref
                .read(filmProvider.notifier)
                .toggleFavorite(films.indexOf(film)),
          ),
        );
      },
    );
  }
}
