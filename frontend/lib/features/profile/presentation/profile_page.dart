import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../auth/data/user_session_provider.dart';
import '../../auth/domain/user_models.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(userSessionProvider);
    final user = session.valueOrNull;

    if (user != null) {
      return _ProfileContent(user: user, saving: session.isLoading);
    }

    return session.when(
      data: (_) => const _GuestProfile(),
      loading: () => const LoadingState(rows: 5),
      error: (error, _) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(userSessionProvider),
      ),
    );
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        colors: [
          GameMentorColors.purple.withValues(alpha: 0.24),
          GameMentorColors.green.withValues(alpha: 0.1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.person_add_alt_1_rounded,
            color: GameMentorColors.green,
            size: 42,
          ),
          const SizedBox(height: 18),
          Text(
            'Профиль еще не создан',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const Text(
            'Создай аккаунт, чтобы сохранять Dota account ID, настройки профиля, будущие избранные гранаты и прогресс тренировок.',
            style: TextStyle(color: GameMentorColors.muted, height: 1.45),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.go('/register'),
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Создать профиль'),
          ),
        ],
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.user, required this.saving});

  final UserProfile user;
  final bool saving;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileHeader(user: user, saving: saving),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 960;
            final editor = _ProfileEditor(user: user, saving: saving);
            final side = Column(
              children: [
                _ProfileBlock(
                  title: 'Избранные гранаты',
                  icon: Icons.star_rounded,
                  items: const [
                    'Mirage window smoke',
                    'Inferno banana flash',
                    'Nuke hut molotov',
                  ],
                ),
                const SizedBox(height: 18),
                _ProfileBlock(
                  title: 'Последние поиски Dota',
                  icon: Icons.history_rounded,
                  items: [
                    if (user.dotaAccountId != null)
                      user.dotaAccountId.toString()
                    else
                      'Dota ID пока не сохранен',
                    '369102305',
                    '42424242',
                  ],
                ),
                const SizedBox(height: 18),
                const _ProfileBlock(
                  title: 'Прогресс тренировок',
                  icon: Icons.timeline_rounded,
                  items: [
                    'Mirage utility 68%',
                    'Inferno flashes 42%',
                    'Пул героев 31%',
                  ],
                ),
              ],
            );

            return compact
                ? Column(children: [editor, const SizedBox(height: 18), side])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: editor),
                      const SizedBox(width: 18),
                      Expanded(flex: 2, child: side),
                    ],
                  );
          },
        ),
      ],
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.user, required this.saving});

  final UserProfile user;
  final bool saving;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatar = user.avatarUrl.isEmpty
        ? '/assets/gamementor/dota/profile-fallback.jpg'
        : user.avatarUrl;

    return AppCard(
      gradient: LinearGradient(
        colors: [
          GameMentorColors.purple.withValues(alpha: 0.22),
          GameMentorColors.green.withValues(alpha: 0.1),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: GameMentorColors.surfaceAlt,
            backgroundImage: NetworkImage(avatar),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '@${user.username} · ${user.email}',
                  style: const TextStyle(color: GameMentorColors.muted),
                ),
                if (user.dotaAccountId != null) ...[
                  const SizedBox(height: 8),
                  ActionChip(
                    avatar: const Icon(Icons.query_stats_rounded, size: 18),
                    label: Text('Dota ID ${user.dotaAccountId}'),
                    onPressed: () =>
                        context.go('/dota?account_id=${user.dotaAccountId}'),
                  ),
                ],
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width > 620)
            TextButton.icon(
              onPressed: saving
                  ? null
                  : () => ref.read(userSessionProvider.notifier).logout(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Выйти'),
            ),
        ],
      ),
    );
  }
}

class _ProfileEditor extends ConsumerStatefulWidget {
  const _ProfileEditor({required this.user, required this.saving});

  final UserProfile user;
  final bool saving;

  @override
  ConsumerState<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends ConsumerState<_ProfileEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayName;
  late final TextEditingController _avatarUrl;
  late final TextEditingController _bio;
  late final TextEditingController _favoriteGame;
  late final TextEditingController _dotaAccountId;

  @override
  void initState() {
    super.initState();
    _displayName = TextEditingController(text: widget.user.displayName);
    _avatarUrl = TextEditingController(text: widget.user.avatarUrl);
    _bio = TextEditingController(text: widget.user.bio);
    _favoriteGame = TextEditingController(text: widget.user.favoriteGame);
    _dotaAccountId = TextEditingController(
      text: widget.user.dotaAccountId?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _ProfileEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.id != widget.user.id ||
        oldWidget.user.updatedAt != widget.user.updatedAt) {
      _displayName.text = widget.user.displayName;
      _avatarUrl.text = widget.user.avatarUrl;
      _bio.text = widget.user.bio;
      _favoriteGame.text = widget.user.favoriteGame;
      _dotaAccountId.text = widget.user.dotaAccountId?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _displayName.dispose();
    _avatarUrl.dispose();
    _bio.dispose();
    _favoriteGame.dispose();
    _dotaAccountId.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dotaText = _dotaAccountId.text.trim();
    final dotaAccountId = dotaText.isEmpty ? null : int.tryParse(dotaText);
    if (dotaText.isNotEmpty && (dotaAccountId == null || dotaAccountId <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный Dota account ID')),
      );
      return;
    }

    try {
      await ref
          .read(userSessionProvider.notifier)
          .updateProfile(
            UpdateUserProfileRequest(
              displayName: _displayName.text.trim(),
              avatarUrl: _avatarUrl.text.trim(),
              bio: _bio.text.trim(),
              favoriteGame: _favoriteGame.text.trim(),
              dotaAccountId: dotaAccountId,
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Профиль сохранен')));
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Настройки профиля',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _displayName,
              decoration: const InputDecoration(
                labelText: 'Имя в профиле',
                prefixIcon: Icon(Icons.badge_rounded),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Имя обязательно';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _avatarUrl,
              decoration: const InputDecoration(
                labelText: 'Avatar URL',
                prefixIcon: Icon(Icons.image_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _favoriteGame,
              decoration: const InputDecoration(
                labelText: 'Любимая дисциплина',
                prefixIcon: Icon(Icons.sports_esports_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dotaAccountId,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Dota account ID',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bio,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'О себе',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: widget.saving ? null : _save,
                  icon: widget.saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: const Text('Сохранить'),
                ),
                const SizedBox(width: 12),
                if (widget.user.dotaAccountId != null)
                  OutlinedButton.icon(
                    onPressed: () => context.go(
                      '/dota?account_id=${widget.user.dotaAccountId}',
                    ),
                    icon: const Icon(Icons.analytics_rounded),
                    label: const Text('Открыть Dota анализ'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: GameMentorColors.green),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.chevron_right_rounded, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: GameMentorColors.muted),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
