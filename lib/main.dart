import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_strings.dart';
import 'core/services/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_bloc.dart';
import 'features/ebooks/presentation/bloc/download_bloc.dart';
import 'features/ebooks/presentation/bloc/ebook_bloc.dart';
import 'features/ebooks/presentation/bloc/reader_bloc.dart';
import 'features/ebooks/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (_) => sl<ThemeBloc>()),
        BlocProvider<EbookBloc>(create: (_) => sl<EbookBloc>()),
        BlocProvider<ReaderBloc>(create: (_) => sl<ReaderBloc>()),
        BlocProvider<DownloadBloc>(create: (_) => sl<DownloadBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: AppStrings.appTitle,
            debugShowCheckedModeBanner: false,
            themeMode: themeState.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
