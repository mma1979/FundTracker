import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fund_tracker/models/category.dart';
import 'package:fund_tracker/models/user.dart';
import 'package:fund_tracker/pages/preferences/categories.dart';
import 'package:fund_tracker/pages/preferences/preferences.dart';
import 'package:fund_tracker/services/auth.dart';
import 'package:fund_tracker/services/localDB.dart';
import 'package:provider/provider.dart';

import 'library.dart';

class MainDrawer extends StatefulWidget {
  final FirebaseUser user;

  MainDrawer(this.user);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final AuthService _auth = AuthService();
  User userInfo;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    LocalDBService().findUser(widget.user.uid).first.then((user) => setState(() => userInfo = user));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          setState(() => isConnected = true);
        }
      } on SocketException catch (_) {
        setState(() => isConnected = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userInfo != null ? userInfo.fullname : ''),
            accountEmail: Text(userInfo != null ? userInfo.email : ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userInfo != null ? userInfo.fullname[0] : '',
                style: TextStyle(
                    fontSize: 40.0, color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          ListTile(
            title: Text('Home'),
            leading: Icon(Icons.home),
            onTap: () => goHome(context),
          ),
          ListTile(
            title: Text('Categories'),
            leading: Icon(Icons.category),
            onTap: () => openPage(
              context,
              StreamProvider<List<Category>>.value(
                value: LocalDBService().getCategories(widget.user.uid),
                child: Categories(),
              ),
            ),
          ),
          ListTile(
            title: Text('Preferences'),
            leading: Icon(Icons.tune),
            onTap: () => openPage(context, Preferences()),
          ),
          ListTile(
            title: Text('Sign Out'),
            leading: Icon(Icons.person),
            onTap: () async {
              Navigator.pop(context);
              await _auth.signOut();
            },
          ),
          isConnected
              ? ListTile(
                  title: Text('Sync'),
                  leading: Icon(Icons.sync),
                  onTap: () async {},
                )
              : ListTile(
                  title: Text('Sync Unavailable'),
                  leading: Icon(Icons.sync_problem),
                  onTap: () async {},
                ),
        ],
      ),
    );
  }
}