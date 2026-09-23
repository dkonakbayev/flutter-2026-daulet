import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main(){
  final books = rawBooks.map((json) => Book.fromJson(json)).toList();
  final library = Library(books);

  library.open();

  print('Opened at: ${library.openedAt}');
  print('Country of Clean Code: ${library.countryOf('Clean Code')}');
  print('Country of Design Patterns: ${library.countryOf('Design Patterns')}');
  print('Country of Unknown Book: ${library.countryOf('Unknown Book')}');


  print('\n=== LEVEL 4 ===');
  print('All titles: ${library.allTitles}');
  print('Books after 2010: ${library.booksAfter2010}');
  print('Average pages: ${library.averagePages}');
  print('Author counts: ${library.authorBookCounts}');
  print('Authors: ${library.authorNames}');
  print('Genres: ${library.genres}');
  print('Display list: ${library.displayList}');


  print('\n=== LEVEL 5 ===');

  final stats = statsOf(books);

  print('Book count: ${stats.count}');
  print('Average pages: ${stats.avgPages}');

  print(describe(const Empty()));
  print(describe(Ready(books)));
  print(describe(const Broken('Something went wrong')));
}
