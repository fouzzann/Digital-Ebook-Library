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
      title: 'Clean Code: A Handbook of Agile Software Craftsmanship',
      author: 'Robert C. Martin',
      description: 'Even bad code can function. But if code isn\'t clean, it can bring a development organization to its knees. Every year, countless hours and significant resources are lost because of poorly written code.',
      category: 'Science & Tech',
      coverUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&w=600&q=80',
      downloadUrl: 'https://example.com/books/clean-code.pdf',
      fileSize: '4.2 MB',
      format: 'PDF',
      publishedYear: 2008,
      rating: 4.8,
    ),
    const EbookModel(
      id: '2',
      title: 'Designing Data-Intensive Applications',
      author: 'Martin Kleppmann',
      description: 'Data keeps changing. Technology keeps changing. Key principles remain the same. Get a comprehensive guide to data architecture, consensus algorithms, and distributed systems.',
      category: 'Science & Tech',
      coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80',
      downloadUrl: 'https://example.com/books/ddia.epub',
      fileSize: '8.5 MB',
      format: 'EPUB',
      publishedYear: 2017,
      rating: 4.9,
    ),
    const EbookModel(
      id: '3',
      title: 'Dune',
      author: 'Frank Herbert',
      description: 'Set on the desert planet Arrakis, Dune is the story of the boy Paul Atreides, heir to a noble family tasked with ruling an inhospitable world where the only thing of value is the spice melange.',
      category: 'Fiction',
      coverUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&w=600&q=80',
      downloadUrl: 'https://example.com/books/dune.epub',
      fileSize: '3.1 MB',
      format: 'EPUB',
      publishedYear: 1965,
      rating: 4.7,
    ),
    const EbookModel(
      id: '4',
      title: 'The Lean Startup',
      author: 'Eric Ries',
      description: 'Most startups fail. But many of those failures are preventable. The Lean Startup is a new approach being adopted across the globe, changing the way companies are built and new products are launched.',
      category: 'Business',
      coverUrl: 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?auto=format&fit=crop&w=600&q=80',
      downloadUrl: 'https://example.com/books/lean-startup.pdf',
      fileSize: '2.8 MB',
      format: 'PDF',
      publishedYear: 2011,
      rating: 4.6,
    ),
    const EbookModel(
      id: '5',
      title: 'Sapiens: A Brief History of Humankind',
      author: 'Yuval Noah Harari',
      description: '100,000 years ago, at least six human species inhabited the earth. Today there is just one. Us. Homo sapiens. How did our species succeed in the battle for dominance?',
      category: 'History',
      coverUrl: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?auto=format&fit=crop&w=600&q=80',
      downloadUrl: 'https://example.com/books/sapiens.pdf',
      fileSize: '5.6 MB',
      format: 'PDF',
      publishedYear: 2014,
      rating: 4.8,
    ),
    const EbookModel(
      id: '6',
      title: 'Meditations',
      author: 'Marcus Aurelius',
      description: 'A series of personal writings by Marcus Aurelius, Roman Emperor from AD 161 to 180, recording his private notes to himself and ideas on Stoic philosophy.',
      category: 'Philosophy',
      coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=600&q=80',
      downloadUrl: 'https://example.com/books/meditations.pdf',
      fileSize: '1.9 MB',
      format: 'MOBI',
      publishedYear: 180,
      rating: 4.9,
    ),
  ];

  EbookRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<List<EbookModel>> fetchEbooks() async {
    // Simulate real network delay
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_mockEbooks);
  }

  @override
  Future<List<EbookModel>> searchEbooks(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
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
    await Future.delayed(const Duration(milliseconds: 300));
    final book = _mockEbooks.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('E-Book with id $id not found'),
    );
    return book;
  }

  @override
  Future<EbookModel> uploadEbook(EbookModel ebook) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newBook = EbookModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: ebook.title,
      author: ebook.author,
      description: ebook.description,
      category: ebook.category,
      coverUrl: ebook.coverUrl.isNotEmpty 
          ? ebook.coverUrl 
          : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80',
      downloadUrl: ebook.downloadUrl.isNotEmpty ? ebook.downloadUrl : 'https://example.com/uploaded.pdf',
      fileSize: ebook.fileSize.isNotEmpty ? ebook.fileSize : '3.5 MB',
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

    return Stream.periodic(const Duration(milliseconds: 150), (count) {
      final progress = (count + 1) * 0.2;
      return progress > 1.0 ? 1.0 : progress;
    }).take(6);
  }

  @override
  Future<void> deleteEbook(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _mockEbooks.removeWhere((e) => e.id == id);
  }
}
