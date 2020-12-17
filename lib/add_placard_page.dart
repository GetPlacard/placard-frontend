import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placard_frontend/api_manager.dart';
import 'package:placard_frontend/structs/placard_type.dart';
import 'package:placard_frontend/user_bloc/user_bloc.dart';
import 'package:placard_frontend/user_bloc/user_event.dart';

class AddPlacardPage extends StatefulWidget {
  @override
  _AddPlacardPageState createState() => _AddPlacardPageState();
}

class _AddPlacardPageState extends State<AddPlacardPage> {
  String searchTerm;
  List<PlacardType> searchResults = [];

  @override
  Widget build(BuildContext context) {
    final cards = [];
    if (searchResults.isNotEmpty) {
      cards.addAll(
          searchResults.map((result) => AddPlacardCard(result)).toList());
    } else if (searchTerm != null && searchTerm != '') {
      cards.add(ListTile(
        title: Center(child: Text('No Results Found')),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Placard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AddPlacardSearchBar(
            onChangedCallback: (String query) {
              searchTerm = query;
            },
            searchCallback: () async {
              final results = await context
                  .repository<APIManager>()
                  .getSearchResults(searchTerm);
              setState(() {
                searchResults = results;
              });
            },
          ),
          Divider(),
          Card(
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Create a new Placard'),
              onTap: () {},
            ),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          ...cards,
        ],
      ),
    );
  }
}

class AddPlacardSearchBar extends StatefulWidget {
  const AddPlacardSearchBar(
      {Key key, this.onChangedCallback, this.searchCallback})
      : super(key: key);

  final searchCallback;
  final onChangedCallback;

  @override
  _AddPlacardSearchBarState createState() => _AddPlacardSearchBarState();
}

class _AddPlacardSearchBarState extends State<AddPlacardSearchBar> {
  Timer debounceTimer = Timer(Duration(milliseconds: 500), () {});

  static const debounceTime = 500;

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Search for Placards',
        icon: Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: () => _controller.clear(),
          icon: Icon(Icons.clear),
        ),
      ),
      onChanged: (String searchTerm) {
        this.widget.onChangedCallback(searchTerm);
        debounceTimer.cancel();
        if (searchTerm != null && searchTerm != '') {
          debounceTimer = Timer(
            Duration(milliseconds: debounceTime),
            this.widget.searchCallback,
          );
        }
      },
    );
  }
}

class AddPlacardCard extends StatelessWidget {
  AddPlacardCard(this.placard);

  final PlacardType placard;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.amber.withAlpha(30),
        onTap: () {},
        child: Column(
          children: [
            AspectRatio(
              child: FittedBox(
                child: Image.memory(placard.imageBytes),
                fit: BoxFit.fill,
              ),
              aspectRatio: 1.5,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: Text(
                      placard.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    child: Text('Add'),
                    onPressed: () {
                      context.bloc<UserBloc>().add(PlacardAdded(placard.id));
                      Navigator.of(context).pop();
                    },
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ],
            ),
          ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
    );
  }
}
