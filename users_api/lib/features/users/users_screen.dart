import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';
import 'users_views.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final city = context.watch<SettingsModel>().city;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: _body(m, city),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const NewUserScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _body(UsersModel m, String? city) {
    if (m.loading && m.items.isEmpty) return const LoadingView();
    final shown = city == null
        ? m.items
        : m.items.where((u) => u.address.city == city).toList();
    return switch (m.error) {
      null => Column(
        children: [
          if (m.fromCache) StaleBanner(onRetry: m.load),
          Expanded(child: UserList(shown, onRefresh: m.load)),
        ],
      ),
      NoConnectionException() => Offline(onRetry: m.load),
      NotFoundException() || UnauthorizedException() => const RequestError(),
      ServerException(:final status) => ServerError(status, onRetry: m.load),
      BadResponseException() => const GenericError(),
    };
  }
}

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key, required this.onRefresh});

  final List<User> users;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final u = users[index];
        return ListTile(
          title: Text(u.name),
          subtitle: Text('${u.email}\n${u.address.city}'),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => UserDetailScreen(user: u))),
        );
      },
    ),
  );
}
