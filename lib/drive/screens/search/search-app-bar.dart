import 'package:bedrive/drive/state/drive-state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

AppBar searchAppBar(BuildContext context,
    {TextEditingController? controller, FocusNode? focusNode}) {
  return AppBar(
    backgroundColor: Theme.of(context).canvasColor,
    iconTheme: Theme.of(context).iconTheme,
    toolbarTextStyle: Theme.of(context).textTheme.bodyText2,
    title: _TextField(controller: controller, focusNode: focusNode),
    actions: [
      _CloseButton(controller: controller),
    ],
  );
}

class _TextField extends StatelessWidget {
  const _TextField({
    Key? key,
    this.controller,
    this.focusNode,
  }) : super(key: key);

  final TextEditingController? controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final folderName =
    context.select((DriveState s) => s.activePage!.folder?.name);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      style: Theme.of(context).textTheme.headline6,
      textInputAction: TextInputAction.search,
      onSubmitted: (String value) {
        context.read<DriveState>().setSearchFilter('query', value);
      },
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: folderName == null ? 'Search' : 'Search in $folderName',
        hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({
    Key? key,
    this.controller,
  }) : super(key: key);

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final queryIsEmpty = context.select(
            (DriveState s) => s.activePage!.staticQueryParams!['query'] == null);
    return queryIsEmpty
        ? Container()
        : IconButton(
      icon: Icon(Icons.close),
      onPressed: () {
        context.read<DriveState>().setSearchFilter('query', null);
        controller!.text = '';
      },
    );
  }
}
