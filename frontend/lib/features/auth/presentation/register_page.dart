import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_network_image.dart';
import '../data/user_session_provider.dart';
import '../domain/user_models.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  var _loginMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    _identityController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      if (_loginMode) {
        await ref
            .read(userSessionProvider.notifier)
            .login(
              LoginUserRequest(
                identity: _identityController.text.trim(),
                password: _passwordController.text.trim(),
              ),
            );
      } else {
        await ref
            .read(userSessionProvider.notifier)
            .register(
              RegisterUserRequest(
                email: _emailController.text.trim(),
                username: _usernameController.text.trim(),
                displayName: _displayNameController.text.trim(),
                password: _passwordController.text.trim(),
              ),
            );
      }
      if (mounted) {
        context.go('/profile');
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
    final session = ref.watch(userSessionProvider);
    final saving = session.isLoading;

    return AppCard(
      padding: EdgeInsets.zero,
      radius: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;
            final intro = _AuthIntro(loginMode: _loginMode);
            final form = _AuthForm(
              formKey: _formKey,
              loginMode: _loginMode,
              saving: saving,
              emailController: _emailController,
              usernameController: _usernameController,
              displayNameController: _displayNameController,
              identityController: _identityController,
              passwordController: _passwordController,
              confirmController: _confirmController,
              onSubmit: _submit,
              onModeChanged: (value) {
                setState(() {
                  _loginMode = value;
                  _formKey.currentState?.reset();
                });
              },
            );

            if (compact) {
              return Column(
                children: [
                  intro,
                  Padding(padding: const EdgeInsets.all(18), child: form),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: intro),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: form,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AuthIntro extends StatelessWidget {
  const _AuthIntro({required this.loginMode});

  final bool loginMode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: AppNetworkImage(
            imageUrl: '/assets/gamementor/home/hero.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.centerLeft,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.black.withValues(alpha: 0.9),
                  AppColors.black.withValues(alpha: 0.64),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppBadge(
                    icon: Icons.workspace_premium_rounded,
                    label: 'Member workspace',
                  ),
                  AppBadge(
                    icon: Icons.lock_rounded,
                    label: 'Secure profile',
                    color: AppColors.cyan,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                loginMode ? 'Вход в GameMentor' : 'Создай профиль игрока',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.06,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Сохраняй Dota account ID, избранные CS2 раскидки, прогресс тренировок и персональные настройки.',
                style: TextStyle(color: AppColors.textSoft, height: 1.5),
              ),
              const SizedBox(height: 24),
              const _AuthFeatureList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthFeatureList extends StatelessWidget {
  const _AuthFeatureList();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Dota профиль', Icons.query_stats_rounded),
      ('CS2 избранное', Icons.star_rounded),
      ('Тренировки', Icons.bolt_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(item.$2, color: AppColors.neon, size: 19),
                const SizedBox(width: 9),
                Text(
                  item.$1,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.formKey,
    required this.loginMode,
    required this.saving,
    required this.emailController,
    required this.usernameController,
    required this.displayNameController,
    required this.identityController,
    required this.passwordController,
    required this.confirmController,
    required this.onSubmit,
    required this.onModeChanged,
  });

  final GlobalKey<FormState> formKey;
  final bool loginMode;
  final bool saving;
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController displayNameController;
  final TextEditingController identityController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final VoidCallback onSubmit;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.black.withValues(alpha: 0.38),
      hoverLift: false,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.person_add_rounded),
                  label: Text('Регистрация'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.login_rounded),
                  label: Text('Вход'),
                ),
              ],
              selected: {loginMode},
              onSelectionChanged: (value) => onModeChanged(value.first),
            ),
            const SizedBox(height: 18),
            if (loginMode) ...[
              TextFormField(
                controller: identityController,
                decoration: const InputDecoration(
                  labelText: 'Email или username',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: _required,
              ),
            ] else ...[
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Введите email';
                  if (!text.contains('@')) return 'Email выглядит неверно';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length < 3) return 'Минимум 3 символа';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Имя в профиле',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                prefixIcon: Icon(Icons.lock_rounded),
              ),
              validator: (value) {
                final text = value ?? '';
                if (text.length < 6) return 'Минимум 6 символов';
                return null;
              },
            ),
            if (!loginMode) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Повтор пароля',
                  prefixIcon: Icon(Icons.verified_user_rounded),
                ),
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'Пароли не совпадают';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: saving ? null : onSubmit,
              icon: saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(loginMode ? Icons.login_rounded : Icons.person_add),
              label: Text(loginMode ? 'Войти' : 'Создать профиль'),
            ),
          ],
        ),
      ),
    );
  }
}

String? _required(String? value) {
  if ((value ?? '').trim().isEmpty) {
    return 'Заполните поле';
  }
  return null;
}
