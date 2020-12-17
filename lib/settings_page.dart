import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placard_frontend/app_bloc/app_bloc.dart';
import 'package:placard_frontend/app_bloc/app_event.dart';
import 'package:placard_frontend/user_settings_page.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Edit Profile'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => UserSettingsPage(),
              ));
            },
          ),
          Divider(),
          // SwitchListTile(
          //   title: const Text('Dark Mode'),
          //   // TODO: do dark mode
          //   value: false,
          //   onChanged: (bool value) {
          //     print('switch flipped: $value');
          //   },
          //   secondary: const Icon(Icons.wb_sunny),
          // ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
            onTap: () {
              context.bloc<AppBloc>().add(AppLogoutRequested());
            },
          ),
        ],
      ),
    );
  }
}
