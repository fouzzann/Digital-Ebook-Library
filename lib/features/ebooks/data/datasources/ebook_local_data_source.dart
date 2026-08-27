import 'package:shared_preferences/shared_preferences.dart';

abstract class EbookLocalDataSource {
  Future<void> saveReadingProgress(String ebookId, int pageNumber);
  Future<int> getReadingProgress(String ebookId);
}

class EbookLocalDataSourceImpl implements EbookLocalDataSource {
  final SharedPreferences sharedPreferences;

  EbookLocalDataSourceImpl({required this.sharedPreferences});

  static const String _readingProgressKeyPrefix = 'reading_progress_';

  @override
  Future<void> saveReadingProgress(String ebookId, int pageNumber) async {
    await sharedPreferences.setInt('$_readingProgressKeyPrefix$ebookId', pageNumber);
  }

  @override
  Future<int> getReadingProgress(String ebookId) async {
    return sharedPreferences.getInt('$_readingProgressKeyPrefix$ebookId') ?? 1;
  }
}
