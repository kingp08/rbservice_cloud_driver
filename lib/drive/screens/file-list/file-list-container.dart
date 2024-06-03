import 'package:bedrive/drive/navigation/app-bar/file-list-bar/file-list-bar.dart';
import 'package:bedrive/drive/screens/file-list/error-indicators/error-indicator.dart';
import 'package:bedrive/drive/screens/file-list/error-indicators/no-results-indicator.dart';
import 'package:bedrive/drive/screens/file-list/file-grid.dart';
import 'package:bedrive/drive/screens/file-list/file-list-mode.dart';
import 'package:bedrive/drive/screens/file-list/file-list.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/preference-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileListContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DriveState>(context, listen: false);
    return RefreshIndicator(
      onRefresh: () => Future.sync(state.reloadEntries),
      child: CustomScrollView(
        primary: false,
        controller: state.scrollController,
        slivers: <Widget>[
          FileListBar(),
          _Body(state: state),
          SliverToBoxAdapter(
            child: _Footer(state: state),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    Key? key,
  }) : super(key: key);
  final DriveState state;

  @override
  Widget build(BuildContext context) {
    final FileListMode mode =
    context.select((PreferenceState s) => s.fileListMode);
    final pagination = context.select((DriveState s) => s.pagination);
    final isInitialLoad = pagination.currentPage == null;
    final loadingFromBackend =
    context.select((DriveState s) => s.isLoadingFromBackend);
    final backendError = context.select((DriveState s) => s.lastBackendError);
    final entries = context.select((DriveState s) => s.entries);

    if (isInitialLoad && loadingFromBackend) {
      return SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(),
          ));
    } else if (isInitialLoad && backendError != null) {
      return SliverPadding(
        padding: EdgeInsets.all(10),
        sliver: SliverFillRemaining(
          child: Container(
              padding: EdgeInsets.all(20),
              child: ErrorIndicator(
                  compact: state.pagination.currentPage != null,
                  error: state.lastBackendError!,
                  onTryAgain: state.reloadEntries)),
        ),
      );
    } else if (pagination.total == 0 && entries.isEmpty) {
      return SliverPadding(
        padding: EdgeInsets.all(10),
        sliver: SliverFillRemaining(
            child: Center(
              child: NoResultsIndicator(),
            )),
      );
    } else {
      return SliverPadding(
          padding: mode == FileListMode.grid
              ? const EdgeInsets.all(10)
              : EdgeInsets.all(0),
          sliver: mode == FileListMode.grid
              ? FileGrid(entries)
              : FileList(entries));
    }
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.state,
    Key? key,
  }) : super(key: key);
  final DriveState state;

  @override
  Widget build(BuildContext context) {
    final isLoadingNewPage = context.select((DriveState s) =>
    s.isLoadingFromBackend && s.pagination.currentPage != null);
    final lastBackendError =
    context.select((DriveState s) => s.lastBackendError);
    if (isLoadingNewPage) {
      return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (lastBackendError != null && !lastBackendError.noInternet!) {
      return Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          height: 85,
          child: ErrorIndicator(
            compact: true,
            error: lastBackendError,
            onTryAgain: () =>
                state.loadEntries(state.pagination.currentPage! + 1),
          ));
    } else {
      return Container();
    }
  }
}
