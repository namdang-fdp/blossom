import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import 'guest_profile_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => unawaited(db.close()));
  return db;
});

final guestProfileRepositoryProvider = Provider<GuestProfileRepository>(
  (ref) => GuestProfileRepository(ref.watch(appDatabaseProvider)),
);

final guestProfileProvider = FutureProvider<ProfileIdentity>(
  (ref) => ref.watch(guestProfileRepositoryProvider).ensureGuestProfile(),
  retry: (_, _) => null,
);

class ProfileBootstrap extends StatelessWidget {
  const ProfileBootstrap({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onRetry == null)
                  const CircularProgressIndicator()
                else
                  Icon(
                    Icons.error_outline,
                    size: 32,
                    color: theme.colorScheme.error,
                  ),
                const SizedBox(height: 24),
                Text(
                  onRetry == null
                      ? 'Đang mở hồ sơ của bạn…'
                      : 'Chưa mở được hồ sơ',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Không thể mở hoặc lưu hồ sơ trên máy. Hãy thử lại. '
                    'Ứng dụng sẽ không tự xóa dữ liệu của bạn.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: onRetry,
                    child: const Text('Thử lại'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
