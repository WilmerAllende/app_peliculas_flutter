import 'package:flutter/material.dart';
import 'package:peliculas/providers/movies_provider.dart';
import 'package:peliculas/search/search_delegate.dart';
import 'package:peliculas/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
   
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peliculas de cine'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => showSearch(context: context, delegate: MovieSearchDelegate()), 
            icon: const Icon(Icons.search_outlined),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
        children: [
          //TODO: Cards widgets peliculas
          CardSwiper( movies: moviesProvider.onDisplayMovies ),

          //TODO: Listad horizontal de peliculas
          MovieSlider(
            movies: moviesProvider.onPopularMovies,
            title: 'Populares!!!',
            onNextPage: (){
              return moviesProvider.getPopularMovies();
            },
          ),
        ],
      ),
      )
    );
  }
}