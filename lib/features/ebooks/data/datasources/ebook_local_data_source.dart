import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ebook_model.dart';

abstract class EbookLocalDataSource {
  Future<void> saveReadingProgress(String ebookId, int pageNumber);
  Future<int> getReadingProgress(String ebookId);
  Future<void> saveCustomEbook(EbookModel ebook);
  Future<List<EbookModel>> getCustomEbooks();
  Future<void> deleteCustomEbook(String ebookId);
  Future<void> markEbookAsDeleted(String ebookId);
  Future<List<String>> getDeletedEbookIds();
  Future<void> addRecentlyRead(String ebookId);
  Future<List<String>> getRecentlyReadIds();
}

class EbookLocalDataSourceImpl implements EbookLocalDataSource {
  final SharedPreferences sharedPreferences;

  EbookLocalDataSourceImpl({required this.sharedPreferences});

  static const String _readingProgressKeyPrefix = 'reading_progress_';
  static const String _customEbooksKey = 'custom_uploaded_ebooks';
  static const String _deletedEbooksKey = 'deleted_ebook_ids';
  static const String _recentlyReadKey = 'recently_read_ebook_ids';

  @override
  Future<void> saveReadingProgress(String ebookId, int pageNumber) async {
    await sharedPreferences.setInt('$_readingProgressKeyPrefix$ebookId', pageNumber);
    await addRecentlyRead(ebookId);
  }

  @override
  Future<int> getReadingProgress(String ebookId) async {
    return sharedPreferences.getInt('$_readingProgressKeyPrefix$ebookId') ?? 1;
  }

  @override
  Future<void> saveCustomEbook(EbookModel ebook) async {
    final customBooks = await getCustomEbooks();
    customBooks.removeWhere((e) => e.id == ebook.id);
    customBooks.insert(0, ebook);

    final stringList = customBooks.map((e) => jsonEncode(e.toJson())).toList();
    await sharedPreferences.setStringList(_customEbooksKey, stringList);

    // If re-saving a book, ensure it's not marked as deleted
    final deletedIds = await getDeletedEbookIds();
    if (deletedIds.contains(ebook.id)) {
      deletedIds.remove(ebook.id);
      await sharedPreferences.setStringList(_deletedEbooksKey, deletedIds);
    }
  }

  @override
  Future<List<EbookModel>> getCustomEbooks() async {
    final stringList = sharedPreferences.getStringList(_customEbooksKey) ?? [];
    return stringList.map((str) {
      try {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return EbookModel.fromJson(map);
      } catch (_) {
        return null;
      }
    }).whereType<EbookModel>().toList();
  }

  @override
  Future<void> deleteCustomEbook(String ebookId) async {
    final customBooks = await getCustomEbooks();
    customBooks.removeWhere((e) => e.id == ebookId);

    final stringList = customBooks.map((e) => jsonEncode(e.toJson())).toList();
    await sharedPreferences.setStringList(_customEbooksKey, stringList);
  }

  @override
  Future<void> markEbookAsDeleted(String ebookId) async {
    final deletedIds = await getDeletedEbookIds();
    if (!deletedIds.contains(ebookId)) {
      deletedIds.add(ebookId);
      await sharedPreferences.setStringList(_deletedEbooksKey, deletedIds);
    }
    await deleteCustomEbook(ebookId);
  }

  @override
  Future<List<String>> getDeletedEbookIds() async {
    return sharedPreferences.getStringList(_deletedEbooksKey) ?? [];
  }

  @override
  Future<void> addRecentlyRead(String ebookId) async {
    final ids = await getRecentlyReadIds();
    ids.remove(ebookId);
    ids.insert(0, ebookId);
    if (ids.length > 10) {
      ids.removeLast();
    }
    await sharedPreferences.setStringList(_recentlyReadKey, ids);
  }

  @override
  Future<List<String>> getRecentlyReadIds() async {
    return sharedPreferences.getStringList(_recentlyReadKey) ?? [];
  }
}
