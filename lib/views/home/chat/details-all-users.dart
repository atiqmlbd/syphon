// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:syphon/store/rooms/room/model.dart';
import 'package:syphon/views/widgets/appbars/appbar-search.dart';
import 'package:syphon/views/widgets/containers/card-section.dart';
import 'package:syphon/views/widgets/modals/modal-user-details.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

// Project imports:
import 'package:syphon/global/colours.dart';
import 'package:syphon/global/dimensions.dart';
import 'package:syphon/global/strings.dart';
import 'package:syphon/store/index.dart';
import 'package:syphon/store/search/actions.dart';
import 'package:syphon/store/user/model.dart';
import 'package:syphon/store/user/selectors.dart';
import 'package:syphon/views/widgets/avatars/avatar-circle.dart';

class ChatUsersDetailArguments {
  final String roomId;

  ChatUsersDetailArguments({this.roomId});
}

class ChatUsersDetailView extends StatefulWidget {
  const ChatUsersDetailView({Key key}) : super(key: key);

  @override
  ChatUsersDetailState createState() => ChatUsersDetailState();
}

class ChatUsersDetailState extends State<ChatUsersDetailView> {
  final searchInputFocusNode = FocusNode();

  ChatUsersDetailState({Key key});

  bool loading = false;

  // componentDidMount(){}
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    onMounted();
  }

  @protected
  void onMounted() {
    final store = StoreProvider.of<AppState>(context);

    final searchResults = store.state.searchStore.searchResults;

    // Clear search if previous results are not from User searching
    if (searchResults.isNotEmpty && !(searchResults[0] is User)) {
      store.dispatch(clearSearchResults());
    }
  }

  @override
  void dispose() {
    searchInputFocusNode.dispose();
    super.dispose();
  }

  @protected
  onShowUserDetails({
    BuildContext context,
    String roomId,
    String userId,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalUserDetails(
        roomId: roomId,
        userId: userId,
      ),
    );
  }

  @protected
  Widget buildUserList(BuildContext context, _Props props) => ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: props.usersFiltered.length,
        itemBuilder: (BuildContext context, int index) {
          final user = (props.usersFiltered[index] as User);

          return GestureDetector(
            onTap: () => this.onShowUserDetails(
              context: context,
              userId: user.userId,
              roomId: props.room.id,
            ),
            child: CardSection(
              padding: EdgeInsets.zero,
              elevation: 0,
              child: Container(
                child: ListTile(
                  leading: AvatarCircle(
                    uri: user.avatarUri,
                    alt: user.displayName ?? user.userId,
                    size: Dimensions.avatarSizeMin,
                    background: Colours.hashedColor(
                      user.displayName ?? user.userId,
                    ),
                  ),
                  title: Text(
                    formatUsername(user),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  subtitle: Text(
                    user.userId,
                    style: Theme.of(context).textTheme.caption.merge(
                          TextStyle(
                            color: props.loading
                                ? Color(Colours.greyDisabled)
                                : null,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final ChatUsersDetailArguments arguments =
        ModalRoute.of(context).settings.arguments;

    return StoreConnector<AppState, _Props>(
      distinct: true,
      converter: (Store<AppState> store) =>
          _Props.mapStateToProps(store, arguments.roomId),
      builder: (context, props) => Scaffold(
        appBar: AppBarSearch(
          title: Strings.titleRoomUsers,
          label: Strings.labelSearchForUsers,
          tooltip: 'Search users',
          brightness: Brightness.dark,
          focusNode: searchInputFocusNode,
          onChange: (text) {
            props.onSearch(text);
          },
          onSearch: (text) {
            props.onSearch(text);
          },
        ),
        body: Stack(
          children: [
            buildUserList(context, props),
            Positioned(
              child: Visibility(
                visible: this.loading,
                child: Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RefreshProgressIndicator(
                        strokeWidth: Dimensions.defaultStrokeWidth,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        value: null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Props extends Equatable {
  final Room room;
  final bool loading;
  final String searchText;
  final List<dynamic> usersFiltered;

  final Function onSearch;

  _Props({
    @required this.room,
    @required this.loading,
    @required this.searchText,
    @required this.usersFiltered,
    @required this.onSearch,
  });

  @override
  List<Object> get props => [
        searchText,
        usersFiltered,
        loading,
      ];

  static _Props mapStateToProps(Store<AppState> store, String roomId) => _Props(
        loading: store.state.roomStore.loading,
        searchText: store.state.searchStore.searchText,
        room: store.state.roomStore.rooms[roomId] ?? Room(),
        usersFiltered: searchUsersLocal(
          List.from(
            (store.state.roomStore.rooms[roomId] ?? Room()).users.values,
          ),
          searchText: store.state.searchStore.searchText,
        ),
        onSearch: (text) {
          store.dispatch(setSearchText(text: text));
        },
      );
}
