import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/models/search_movie_response.dart';

import '../helpers/debouncer.dart';
import '../models/models.dart';


class MoviesProvider  extends ChangeNotifier{
  String _apiKey = 'c34bd4585515560eb10a12622c1dd217';
  String _baseUrl = 'api.themoviedb.org';
  String _language = 'es-ES'; 

  List<Movie> onDisplayMovies = [];
  List<Movie> onPopularMovies = [];

  Map<int, List<Cast>> moviesCast = {};
  int _popularPage = 0;

  final debouncer = Debouncer(
    duration: Duration(milliseconds: 500),
  );

  final StreamController<List<Movie>> _suggestionStreamController = new StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream => this._suggestionStreamController.stream;

  MoviesProvider(){
    print('MoviesProvider inicializado');
    this.getOnDisplayMovies();
    this.getPopularMovies();
  }

  Future<String> _getJsonData(String endPoint, [int page = 1]) async{
    final url = Uri.https(_baseUrl, endPoint, {
      'api_key':_apiKey,
      'language':_language,
      'page': '$page'
      });
      final response = await http.get(url);
      return response.body;
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies()  async {
    _popularPage ++;
    final jsonData = await _getJsonData('3/movie/popular', _popularPage);

    final popularResponse = PopularResponse.fromJson(jsonData);
    onPopularMovies = [...onPopularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId)  async {
    if(moviesCast.containsKey(movieId)) return moviesCast[movieId]!;
    print('Pidiendo peticion cast');
    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);
    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovie(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key':_apiKey,
      'language':_language,
      'query': query
      });

      final response = await http.get(url);
      final searchResponse = SearchMovieResponse.fromJson(response.body); 
      return searchResponse.results;
  }

  void getSuggestionByQuery(String searchTerm){
    debouncer.value = '';
    debouncer.onValue = ( value ) async {
      final result = await this.searchMovie(value);
      this._suggestionStreamController.add(result);
    };

    final timer = Timer.periodic( Duration(milliseconds: 300), ( _ ) {
      debouncer.value = searchTerm;
    });

    Future.delayed(Duration(milliseconds: 301)).then(( _ ) => timer.cancel());
  }
}