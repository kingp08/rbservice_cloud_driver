import 'dart:ui';
import 'package:background_fetch/background_fetch.dart';
import 'package:bedrive/auth/auth-state.dart';
import 'package:bedrive/auth/screens/login-screen.dart';
import 'package:bedrive/config/app-config.dart';
import 'package:bedrive/config/themes/theme-config.dart';
import 'package:bedrive/drive/http/file-entries-api.dart';
import 'package:bedrive/drive/screens/destination-picker/destination-picker-state.dart';
import 'package:bedrive/drive/screens/file-list/root-screen.dart';
import 'package:bedrive/drive/screens/file-preview/file-preview-state.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/entry-cache.dart';
import 'package:bedrive/drive/state/offlined-entries/offlined-entries.dart';
import 'package:bedrive/drive/state/preference-state.dart';
import 'package:bedrive/drive/state/root-navigator-key.dart';
import 'package:bedrive/drive/state/space-usage/space-usage-state.dart';
import 'package:bedrive/localizations/backend-localizations-delegate.dart';
import 'package:bedrive/notifications/notifications.dart';
import 'package:bedrive/routes.dart';
import 'package:bedrive/transfers/downloads/download-manager.dart';
import 'package:bedrive/transfers/transfer-queue/transfer-queue.dart';
import 'package:bedrive/transfers/uploads/upload-manager.dart';
import 'package:bedrive/utils/local-storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'firebase_options.dart';

void appRunner(AppConfig appConfig) async {
  final preferences = PreferenceState();
  final localStorage = await LocalStorage().init();
  final httpClient = appConfig.httpClient;
  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final notifications = Notifications(httpClient);
  final authState =
  await AuthState(httpClient!, localStorage, notifications).init();
  await preferences.init();
  initBackgroundFetch();

  runApp(MultiProvider(
    providers: [
      Provider.value(value: httpClient),
      Provider.value(value: appConfig),
      Provider.value(value: localStorage),
      Provider.value(value: notifications),
      ChangeNotifierProvider.value(value: authState),
      ChangeNotifierProvider.value(value: preferences),
      ChangeNotifierProvider(create: (_) => SpaceUsageState(httpClient)),
      Provider(create: (context) => FileEntriesApi(httpClient, localStorage)),
      Provider(
          create: (context) => DownloadManager(
            context.read<FileEntriesApi>(),
            notifications,
          )),
      Provider(
          create: (context) => UploadManager(
            context.read<FileEntriesApi>(),
            notifications,
          )),
      ChangeNotifierProvider(
          create: (context) => TransferQueue(
            context.read<Notifications>(),
            context.read<DownloadManager>(),
            context.read<UploadManager>(),
            localStorage,
          )),
      Provider(
          create: (context) =>
              EntryCache(localStorage, authState.currentUser!)),
      ChangeNotifierProvider(
          create: (context) => OfflinedEntries(
            context.read<FileEntriesApi>(),
            context.read<TransferQueue>(),
          )),
      ChangeNotifierProvider(
          create: (context) => FilePreviewState(context.read<OfflinedEntries>(),
              localStorage, context.read<FileEntriesApi>())),
      Provider(create: (_) => DestinationPickerState()),
      ChangeNotifierProvider(
          create: (context) => DriveState(
            api: context.read<FileEntriesApi>(),
            entryCache: context.read<EntryCache>(),
            offlinedEntriesDB: context.read<OfflinedEntries>(),
            transferQueue: context.read<TransferQueue>(),
          ))
    ],
    child: MyApp(appConfig: appConfig, authState: authState),
  ));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appConfig = await AppConfig().init();

  if (appConfig.localConfig.sentryDsn != null) {
    await SentryFlutter.init(
          (options) {
        options.dsn = appConfig.localConfig.sentryDsn;
      },
      // Init your App.
      appRunner: () => appRunner(appConfig),
    );
  } else {
    appRunner(appConfig);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.appConfig,
    required this.authState,
  }) : super(key: key);

  final AppConfig appConfig;
  final AuthState authState;

  @override
  Widget build(context) {
    final selectedTheme = context.select((PreferenceState s) => s.themeMode);
    return MaterialApp(
      navigatorObservers: [
        SentryNavigatorObserver(),
      ],
      debugShowCheckedModeBanner: false,
      initialRoute:
      authState.currentUser != null ? RootScreen.ROUTE : LoginScreen.ROUTE,
      navigatorKey: rootNavigatorKey,
      onGenerateRoute: (RouteSettings settings) => buildRoute(settings),
      theme: buildTheme(context, appConfig.lightThemeConfig!),
      darkTheme: buildTheme(context, appConfig.darkThemeConfig!),
      themeMode: selectedTheme,
      localizationsDelegates: [
        BackendLocalizationsDelegate(appConfig),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales:
      appConfig.locales.values.map((l) => l.toFlutterLocale()),
    );
  }
}

initBackgroundFetch() async {
  await BackgroundFetch.configure(
      BackgroundFetchConfig(
        requiresDeviceIdle: true,
        minimumFetchInterval: 1440,
      ), (String taskId) async {
    final sendPort =
    IsolateNameServer.lookupPortByName(OfflinedEntries.syncTaskName);
    try {
      sendPort?.send(OfflinedEntries.syncTaskName);
    } catch (_) {}
    BackgroundFetch.finish(taskId);
  }, (String taskId) async {
    BackgroundFetch.finish(taskId);
  });
}
