import '../../../../core/network/api_consumer.dart';
import '../models/ebook_model.dart';

abstract class EbookRemoteDataSource {
  Future<List<EbookModel>> fetchEbooks();
  Future<List<EbookModel>> searchEbooks(String query);
  Future<EbookModel> getEbookDetails(String id);
  Future<EbookModel> uploadEbook(EbookModel ebook);
  Future<Stream<double>> downloadEbook(String id);
  Future<void> deleteEbook(String id);
}

class EbookRemoteDataSourceImpl implements EbookRemoteDataSource {
  final ApiConsumer apiConsumer;

  // In-memory persistent mock storage for real interactive behavior
  final List<EbookModel> _mockEbooks = [
    const EbookModel(
      id: '1',
      title: 'Clean Architecture: A Craftsman\'s Guide to Software Structure',
      author: 'Robert C. Martin',
      description: 'By applying essential software design principles, you can develop software systems that are easier to maintain, adapt, test, and scale. Uncle Bob shows you how to structure applications for long-term production resilience.',
      category: 'Science & Tech',
      coverUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      fileSize: '6.4 MB',
      format: 'PDF',
      publishedYear: 2017,
      rating: 4.9,
    ),
    const EbookModel(
      id: '2',
      title: 'Designing Data-Intensive Applications',
      author: 'Martin Kleppmann',
      description: 'Data keeps changing. Technology keeps changing. Key principles remain the same. Get a comprehensive guide to data architecture, consensus algorithms, event streaming, and distributed database systems.',
      category: 'Science & Tech',
      coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://raw.githubusercontent.com/mozilla/pdf.js/master/web/compressed.tracemonkey-pldi-09.pdf',
      fileSize: '8.5 MB',
      format: 'PDF',
      publishedYear: 2017,
      rating: 4.9,
      isDownloaded: true,
    ),
    const EbookModel(
      id: '3',
      title: 'Dune: Messiah & The Desert Chronicles',
      author: 'Frank Herbert',
      description: 'Set on the desert planet Arrakis, Dune is the story of Paul Atreides, heir to a noble family tasked with ruling an inhospitable world where the only thing of value is the spice melange.',
      category: 'Fiction',
      coverUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      fileSize: '4.2 MB',
      format: 'PDF',
      publishedYear: 1965,
      rating: 4.8,
    ),
    const EbookModel(
      id: '4',
      title: 'The Lean Startup',
      author: 'Eric Ries',
      description: 'Most startups fail. But many of those failures are preventable. The Lean Startup provides a scientific approach to creating and managing successful startups in an age when companies need to innovate faster than ever.',
      category: 'Business',
      coverUrl: 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://raw.githubusercontent.com/mozilla/pdf.js/master/web/compressed.tracemonkey-pldi-09.pdf',
      fileSize: '3.8 MB',
      format: 'PDF',
      publishedYear: 2011,
      rating: 4.7,
    ),
    const EbookModel(
      id: '5',
      title: 'Sapiens: A Brief History of Humankind',
      author: 'Yuval Noah Harari',
      description: '100,000 years ago, at least six human species inhabited the earth. Today there is just one: Homo sapiens. How did our species succeed in the battle for dominance?',
      category: 'History',
      coverUrl: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      fileSize: '5.6 MB',
      format: 'PDF',
      publishedYear: 2014,
      rating: 4.9,
    ),
    const EbookModel(
      id: '6',
      title: 'Meditations of Stoic Mastery',
      author: 'Marcus Aurelius',
      description: 'A series of personal writings by Marcus Aurelius, Roman Emperor from AD 161 to 180, recording private notes to himself and enduring wisdom on Stoic philosophy.',
      category: 'Philosophy',
      coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://raw.githubusercontent.com/mozilla/pdf.js/master/web/compressed.tracemonkey-pldi-09.pdf',
      fileSize: '2.1 MB',
      format: 'PDF',
      publishedYear: 180,
      rating: 4.95,
    ),
  ];

  EbookRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<List<EbookModel>> fetchEbooks() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_mockEbooks);
  }

  @override
  Future<List<EbookModel>> searchEbooks(String query) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (query.trim().isEmpty) return List.from(_mockEbooks);

    final lowerQuery = query.toLowerCase();
    return _mockEbooks.where((ebook) {
      return ebook.title.toLowerCase().contains(lowerQuery) ||
          ebook.author.toLowerCase().contains(lowerQuery) ||
          ebook.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<EbookModel> getEbookDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final book = _mockEbooks.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('E-Book with id $id not found'),
    );
    return book;
  }

  @override
  Future<EbookModel> uploadEbook(EbookModel ebook) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newBook = EbookModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: ebook.title,
      author: ebook.author,
      description: ebook.description,
      category: ebook.category,
      coverUrl: ebook.coverUrl.isNotEmpty 
          ? ebook.coverUrl 
          : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80',
      downloadUrl: ebook.downloadUrl.isNotEmpty ? ebook.downloadUrl : 'https://example.com/uploaded.pdf',
      fileSize: ebook.fileSize.isNotEmpty ? ebook.fileSize : '4.0 MB',
      format: ebook.format,
      publishedYear: ebook.publishedYear > 0 ? ebook.publishedYear : DateTime.now().year,
      rating: 5.0,
    );
    _mockEbooks.insert(0, newBook);
    return newBook;
  }

  @override
  Future<Stream<double>> downloadEbook(String id) async {
    final index = _mockEbooks.indexWhere((e) => e.id == id);
    if (index != -1) {
      _mockEbooks[index] = EbookModel.fromEntity(
        _mockEbooks[index].copyWith(isDownloaded: true, downloadProgress: 1.0),
      );
    }

    return Stream.periodic(const Duration(milliseconds: 120), (count) {
      final progress = (count + 1) * 0.25;
      return progress > 1.0 ? 1.0 : progress;
    }).take(5);
  }

  @override
  Future<void> deleteEbook(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockEbooks.removeWhere((e) => e.id == id);
  }
}
