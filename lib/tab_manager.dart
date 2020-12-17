import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placard_frontend/loading_page.dart';
import 'package:placard_frontend/structs/user.dart';
import 'package:placard_frontend/api_manager.dart';
import 'package:placard_frontend/account_page.dart';
import 'package:placard_frontend/map_page.dart';
import 'package:placard_frontend/user_bloc/user_bloc.dart';

class TabManager extends StatefulWidget {
  @override
  _TabManagerState createState() => _TabManagerState();
}

class _TabManagerState extends State<TabManager> {
  int _selectedIndex = 0;
  bool _tabsReady = false;
  final _mapState = MapState();
  Function _mapReady = () {};
  final PageStorageBucket _bucket = PageStorageBucket();

  final List<Widget> _widgetOptions = <Widget>[];

  @override
  void initState() {
    _initTabs();
    super.initState();
  }

  Future<void> _initTabs() async {
    final User user = await context.repository<APIManager>().getSelfUser();

    _widgetOptions.add(MapPage(
        key: PageStorageKey('mapPage'),
        selfUserTappedCallback: _selfUserTappedCallback,
        selfUserId: user.id,
        mapState: _mapState,
        onMapReady: _onMapReadyCb));

    _widgetOptions.add(AccountPage(
      context.bloc<UserBloc>(),
      key: PageStorageKey('accountPage'),
    ));

    setState(() {
      _tabsReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_tabsReady) {
      return LoadingPage();
    } else {
      return Scaffold(
        body: PageStorage(
          child: _widgetOptions[_selectedIndex],
          bucket: _bucket,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              title: Text('Map'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Account'),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      );
    }
  }

  void _onMapReadyCb() {
    _mapReady();
    _mapReady = () {};
  }

  void _selfUserTappedCallback() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == 0 && index != 0) {
      if (_mapState.ready) {
        setState(() {
          _selectedIndex = index;
        });
      } else {
        _mapReady = () {
          setState(() {
            _selectedIndex = index;
          });
        };
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
}
