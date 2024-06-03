import 'package:bedrive/auth/screens/forgot-password-screen.dart';
import 'package:bedrive/auth/screens/login-screen.dart';
import 'package:bedrive/auth/screens/register-screen.dart';
import 'package:bedrive/drive/dialogs/loading-dialog.dart';
import 'package:bedrive/drive/screens/destination-picker/destination-picker.dart';
import 'package:bedrive/drive/screens/file-list/folder-screen.dart';
import 'package:bedrive/drive/screens/file-list/recent-screen.dart';
import 'package:bedrive/drive/screens/file-list/root-screen.dart';
import 'package:bedrive/drive/screens/file-list/shared-screen.dart';
import 'package:bedrive/drive/screens/file-list/starred-screen.dart';
import 'package:bedrive/drive/screens/file-preview/file-preview-screen.dart';
import 'package:bedrive/drive/screens/manage-users/manage-entry-users-state.dart';
import 'package:bedrive/drive/screens/manage-users/manage-users-screen.dart';
import 'package:bedrive/drive/screens/offline-entries-screen.dart';
import 'package:bedrive/drive/screens/search/search-screen.dart';
import 'package:bedrive/drive/screens/settings-screen/settings-screen.dart';
import 'package:bedrive/drive/screens/shareable-link/shareable-link-screen.dart';
import 'package:bedrive/drive/screens/shareable-link/shareable-link-state.dart';
import 'package:bedrive/drive/screens/trash-screen.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/transfers/transfers-screen/transfers-screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: missing_return
MaterialPageRoute? buildRoute(RouteSettings settings) {
  switch (settings.name) {

    // AUTH
    case LoginScreen.ROUTE:
      return MaterialPageRoute(builder: (_) => loadingWillPopScope(LoginScreen()), settings: settings);
    case RegisterScreen.ROUTE:
      return MaterialPageRoute(builder: (_) => loadingWillPopScope(RegisterScreen()), settings: settings);
    case ForgotPasswordScreen.ROUTE:
      return MaterialPageRoute(builder: (_) => loadingWillPopScope(ForgotPasswordScreen()), settings: settings);

    // DRIVE BOTTOM NAV + FOLDER
    case RootScreen.ROUTE:
      return NoTransitionMaterialRoute(builder: (_) => loadingWillPopScope(RootScreen()), settings: settings, maintainState: false);
    case RecentScreen.ROUTE:
      return NoTransitionMaterialRoute(builder: (_) => loadingWillPopScope(RecentScreen()), settings: settings, maintainState: false);
    case SharedScreen.ROUTE:
      return NoTransitionMaterialRoute(builder: (_) => loadingWillPopScope(SharedScreen()), settings: settings, maintainState: false);
    case StarredScreen.ROUTE:
      return NoTransitionMaterialRoute(builder: (_) => loadingWillPopScope(StarredScreen()), settings: settings, maintainState: false);
    case FolderScreen.ROUTE:
      FolderScreenArgs? args = settings.arguments as FolderScreenArgs?;
      // don't maintain drive.state so back button loads file entries properly
      return NoTransitionMaterialRoute(builder: (_) => loadingWillPopScope(FolderScreen(args!.folderPage)), settings: settings, maintainState: false);

    // SHARE
    case ManageUsersScreen.ROUTE:
      ManageUsersArgs? args = settings.arguments as ManageUsersArgs?;
      return MaterialPageRoute(builder: (_) => loadingWillPopScope(ChangeNotifierProvider(
        create: (bc) => ManageEntryUsersState(bc.read<DriveState>()),
        child: ManageUsersScreen(args!.fileEntry),
      )), settings: settings);
    case ShareableLinkScreen.ROUTE:
      ShareableLinkArgs? args = settings.arguments as ShareableLinkArgs?;
      return MaterialPageRoute(builder: (_) => loadingWillPopScope(ChangeNotifierProvider(
        create: (bc) => ShareableLinkState(bc.read<DriveState>(), args!.fileEntry),
        child: ShareableLinkScreen(),
      )), settings: settings);

    // DRIVE OTHER ROUTES
    case FilePreviewScreen.ROUTE:
      return MaterialPageRoute(builder: (_) => loadingWillPopScope(FilePreviewScreen()), settings: settings);
    case SettingsScreen.ROUTE:
      return MaterialPageRoute(builder: (_) => loadingWillPopScope(SettingsScreen()), settings: settings);
    case TransfersScreen.ROUTE:
      return MaterialPageRoute(builder: (_) => loadingWillPopScope(TransfersScreen()), settings: settings);
    case DestinationPicker.ROUTE:
      FolderScreenArgs? args = settings.arguments as FolderScreenArgs?;
      return MaterialPageRoute(builder: (_) => loadingWillPopScope(DestinationPicker(args!.folderPage)), settings: settings, maintainState: false);
    case SearchScreen.ROUTE:
      return MaterialPageRoute(builder: (_) => loadingWillPopScope(SearchScreen()), settings: settings);
    case TrashScreen.ROUTE:
      return MaterialPageRoute(builder: (_) => loadingWillPopScope(TrashScreen()), settings: settings);
    case OfflineEntriesScreen.ROUTE:
      return MaterialPageRoute(builder: (_) => loadingWillPopScope(OfflineEntriesScreen()), settings: settings);
  }
}

class NoTransitionMaterialRoute extends MaterialPageRoute {
  NoTransitionMaterialRoute({
    required builder,
    RouteSettings? settings,
    maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
      builder: builder,
      settings: settings,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog
  );

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}