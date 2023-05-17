import 'package:authentication_repository/authentication_repository.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/authentication/bloc/authentication_bloc.dart';
import 'package:ez_badminton_admin_app/home/view/home_page.dart';
import 'package:ez_badminton_admin_app/login/view/login_page.dart';
import 'package:ez_badminton_admin_app/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase_provider/pocketbase_provider.dart';
import 'package:user_repository/user_repository.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final PocketBaseProvider _pocketBaseProvider;
  late final AuthenticationRepository _authenticationRepository;
  late final UserRepository _userRepository;
  late final CollectionRepository<Player> _playerRepository;
  late final CollectionRepository<Competition> _competitionRepository;
  late final CollectionRepository<PlayingLevel> _playingLevelRepository;
  late final CollectionRepository<Team> _teamRepository;
  late final CollectionRepository<Club> _clubRepository;

  @override
  void initState() {
    super.initState();
    _pocketBaseProvider = PocketBaseProvider();
    _authenticationRepository = AuthenticationRepository(
      pocketBaseProvider: _pocketBaseProvider,
    );
    _userRepository = UserRepository(
      pocketBaseProvider: _pocketBaseProvider,
    );
    _playerRepository = CollectionRepository(
      modelConstructor: Player.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _competitionRepository = CollectionRepository(
      modelConstructor: Competition.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _playingLevelRepository = CollectionRepository(
      modelConstructor: PlayingLevel.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _teamRepository = CollectionRepository(
      modelConstructor: Team.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _clubRepository = CollectionRepository(
      modelConstructor: Club.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
  }

  @override
  void dispose() {
    _authenticationRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authenticationRepository),
        RepositoryProvider.value(value: _playerRepository),
        RepositoryProvider.value(value: _competitionRepository),
        RepositoryProvider.value(value: _playingLevelRepository),
        RepositoryProvider.value(value: _teamRepository),
        RepositoryProvider.value(value: _clubRepository),
      ],
      child: BlocProvider(
        create: (_) => AuthenticationBloc(
            authenticationRepository: _authenticationRepository,
            userRepository: _userRepository),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ez Badminton Admin',
      navigatorKey: _navigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (_, state) {
            switch (state.status) {
              case AuthenticationStatus.authenticated:
                _navigator.pushAndRemoveUntil<void>(
                  HomePage.route(),
                  (route) => false,
                );
                break;
              case AuthenticationStatus.unauthenticated:
                _navigator.pushAndRemoveUntil<void>(
                  LoginPage.route(),
                  (route) => false,
                );
                break;
              case AuthenticationStatus.unknown:
                break;
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}
