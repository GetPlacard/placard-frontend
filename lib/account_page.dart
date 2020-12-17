import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placard_frontend/add_placard_page.dart';
import 'package:placard_frontend/api_manager.dart';
import 'package:placard_frontend/structs/user_error_type.dart';
import 'package:placard_frontend/user_bloc/user_bloc.dart';
import 'package:placard_frontend/structs/placed_placard.dart';
import 'package:placard_frontend/settings_page.dart';
import 'package:placard_frontend/structs/user.dart';
import 'package:placard_frontend/user_bloc/user_event.dart';
import 'package:placard_frontend/user_bloc/user_state.dart';

class AccountPage extends StatefulWidget {
  AccountPage(
    this.userBloc, {
    Key key,
  }) : super(key: key);

  final UserBloc userBloc;

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: this.widget.userBloc,
      builder: (BuildContext context, UserState userState) {
        final placardCards = userState.user.placards.map(
            (placard) => AccountPlacardCard(placard, this.widget.userBloc));
        return Scaffold(
          body: BlocListener(
            cubit: this.widget.userBloc,
            listener: (BuildContext context, UserState userState) {
              if (userState is UserStateError &&
                  userState.errorType != null &&
                  userState.errorType is! UserErrorType) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('An error occurred'),
                  ),
                );
              }
            },
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.amber[600],
                          child: Text(
                            userState.user.username.length > 0
                                ? userState.user.username[0].toUpperCase()
                                : '',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 36,
                            ),
                          ),
                          radius: 36,
                        ),
                        Spacer(flex: 1),
                        Expanded(
                          child: Text(
                            userState.user.username,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                            ),
                          ),
                          flex: 10,
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    ...placardCards,
                  ],
                  padding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          appBar: AppBar(
            actions: userState.user.isSelf
                ? [
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return SettingsPage();
                            },
                          ),
                        );
                      },
                    ),
                  ]
                : null,
          ),
          floatingActionButton: userState.user.isSelf
              ? FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return AddPlacardPage();
                        },
                      ),
                    );
                  },
                )
              : null,
        );
      },
    );
  }
}

class AccountPlacardCard extends StatelessWidget {
  AccountPlacardCard(this.placard, this.userBloc);

  final PlacedPlacard placard;
  final UserBloc userBloc;

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
                child: Image.memory(placard.type.imageBytes),
                fit: BoxFit.fill,
              ),
              aspectRatio: 1.5,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: Text(
                      placard.type.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.arrow_drop_up,
                    ),
                    color: placard.likeState == 1 ? Colors.amber : null,
                    onPressed: () {
                      userBloc.add(PlacardLikeStateChanged(
                        placard.id,
                        placard.likeState == 1 ? 0 : 1,
                      ));
                    }),
                Text(
                  placard.score.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_drop_down),
                  color: placard.likeState == -1 ? Colors.amber : null,
                  onPressed: () {
                    userBloc.add(PlacardLikeStateChanged(
                      placard.id,
                      placard.likeState == -1 ? 0 : -1,
                    ));
                  },
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
