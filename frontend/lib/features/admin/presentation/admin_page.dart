import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../cs2_grenades/data/cs2_grenades_api.dart';
import '../../cs2_grenades/data/cs2_grenades_providers.dart';
import '../../cs2_grenades/domain/cs2_models.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _imageUrl = TextEditingController();
  final _videoUrl = TextEditingController();
  final _tags = TextEditingController(text: 'default, execute');

  String _map = 'mirage';
  String _side = 'T';
  String _type = 'smoke';
  String _difficulty = 'easy';
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _from.dispose();
    _to.dispose();
    _imageUrl.dispose();
    _videoUrl.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final request = CreateCS2GrenadeRequest(
        map: _map,
        side: _side,
        type: _type,
        title: _title.text.trim(),
        description: _description.text.trim(),
        fromPosition: _from.text.trim(),
        toPosition: _to.text.trim(),
        difficulty: _difficulty,
        imageUrl: _imageUrl.text.trim(),
        videoUrl: _videoUrl.text.trim(),
        tags: _tags.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
      );
      await ref.read(cs2GrenadesApiProvider).createGrenade(request);
      ref.invalidate(cs2GrenadesProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Граната добавлена')));
        _title.clear();
        _description.clear();
        _from.clear();
        _to.clear();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Админ-панель',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Добавление CS2 раскидок через тот же API-контракт, который использует приложение.',
          style: TextStyle(color: GameMentorColors.muted),
        ),
        const SizedBox(height: 22),
        AppCard(
          child: Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 780;
                return Column(
                  children: [
                    _ResponsiveRow(
                      compact: compact,
                      children: [
                        _SelectField(
                          label: 'Карта',
                          value: _map,
                          values: const {
                            'mirage': 'Mirage',
                            'inferno': 'Inferno',
                            'dust2': 'Dust2',
                            'nuke': 'Nuke',
                            'ancient': 'Ancient',
                            'anubis': 'Anubis',
                            'vertigo': 'Vertigo',
                          },
                          onChanged: (value) => setState(() => _map = value),
                        ),
                        _SelectField(
                          label: 'Сторона',
                          value: _side,
                          values: const {'T': 'T', 'CT': 'CT'},
                          onChanged: (value) => setState(() => _side = value),
                        ),
                        _SelectField(
                          label: 'Тип',
                          value: _type,
                          values: const {
                            'smoke': 'Смок',
                            'flash': 'Флеш',
                            'molotov': 'Molotov',
                            'he': 'HE',
                          },
                          onChanged: (value) => setState(() => _type = value),
                        ),
                        _SelectField(
                          label: 'Сложность',
                          value: _difficulty,
                          values: const {
                            'easy': 'Легко',
                            'medium': 'Средне',
                            'hard': 'Сложно',
                          },
                          onChanged: (value) =>
                              setState(() => _difficulty = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ResponsiveRow(
                      compact: compact,
                      children: [
                        _TextInput(controller: _title, label: 'Название'),
                        _TextInput(controller: _from, label: 'Откуда'),
                        _TextInput(controller: _to, label: 'Куда'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _TextInput(
                      controller: _description,
                      label: 'Описание',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 14),
                    _ResponsiveRow(
                      compact: compact,
                      children: [
                        _TextInput(
                          controller: _imageUrl,
                          label: 'URL картинки',
                        ),
                        _TextInput(controller: _videoUrl, label: 'URL видео'),
                        _TextInput(controller: _tags, label: 'Теги'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _submitting ? null : _submit,
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add_rounded),
                        label: const Text('Добавить гранату'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ResponsiveRow extends StatelessWidget {
  const _ResponsiveRow({required this.compact, required this.children});

  final bool compact;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        children: [
          for (final child in children)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: child),
        ],
      );
    }
    return Row(
      children: [
        for (final child in children) ...[
          Expanded(child: child),
          if (child != children.last) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Поле обязательно';
        }
        return null;
      },
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final entry in values.entries)
          DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
