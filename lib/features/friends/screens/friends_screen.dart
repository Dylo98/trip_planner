import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/friends/widgets/friends_list_tab.dart';
import 'package:trip_planner/features/friends/widgets/friend_requests_tab.dart';
import 'package:trip_planner/features/friends/widgets/add_friend_dialog.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddFriendDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCountAsync = ref.watch(pendingRequestsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Znajomi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddFriendDialog,
            tooltip: 'Dodaj znajomego',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(
              icon: Icon(Icons.people),
              text: 'Znajomi',
            ),
            Tab(
              icon: Badge(
                label: pendingCountAsync.when(
                  data: (count) => count > 0 ? Text('$count') : null,
                  loading: () => null,
                  error: (_, __) => null,
                ),
                isLabelVisible: pendingCountAsync.value != null &&
                    pendingCountAsync.value! > 0,
                child: const Icon(Icons.mail),
              ),
              text: 'Zaproszenia',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FriendsListTab(),
          FriendRequestsTab(),
        ],
      ),
    );
  }
}
