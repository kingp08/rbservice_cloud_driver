import 'package:bedrive/drive/screens/file-list/recent-screen.dart';
import 'package:bedrive/drive/screens/file-list/root-screen.dart';
import 'package:bedrive/drive/screens/file-list/shared-screen.dart';
import 'package:bedrive/drive/screens/file-list/starred-screen.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int? _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final name = ModalRoute.of(context)!.settings.name;
    if (name != null && _BottomNavIndex[name] != null) {
      _selectedIndex = _BottomNavIndex[name];
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.folder_open_outlined),
          label: trans('Files'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.access_time_outlined),
          label: trans('Recent'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people_outline),
          label: trans('Shared'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.star_outline),
          label: trans('Starred'),
        ),
      ],
      currentIndex: _selectedIndex!,
      selectedItemColor: Theme.of(context).primaryColor,
      onTap: (int index) {
        setState(() {
          _selectedIndex = index;
        });
        final routeName = _BottomNavIndex.keys.firstWhere((k) => _BottomNavIndex[k] == index);
        if (_BottomNavIndex.keys.contains(ModalRoute.of(context)!.settings.name)) {
          Navigator.of(context).pushReplacementNamed(routeName);
        } else {
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }
}

const _BottomNavIndex = {
  RootScreen.ROUTE: 0,
  RecentScreen.ROUTE: 1,
  SharedScreen.ROUTE: 2,
  StarredScreen.ROUTE: 3,
};