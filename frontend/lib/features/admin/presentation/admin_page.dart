import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/utils/text_file_picker.dart';
import '../../../core/widgets/app_card.dart';
import '../../cs2_grenades/data/cs2_grenades_api.dart';
import '../../cs2_grenades/data/cs2_grenades_providers.dart';
import '../../cs2_grenades/domain/cs2_models.dart';
import '../../cs2_grenades/domain/recorder_import.dart';

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
  final _recorderJson = TextEditingController();

  String _map = 'mirage';
  String _side = 'T';
  String _type = 'smoke';
  String _difficulty = 'easy';
  bool _submitting = false;
  RecorderGrenadeImport? _lastImport;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _from.dispose();
    _to.dispose();
    _imageUrl.dispose();
    _videoUrl.dispose();
    _tags.dispose();
    _recorderJson.dispose();
    super.dispose();
  }

  Future<void> _pickRecorderJson() async {
    final content = await pickTextFile(accept: '.json,application/json');
    if (content == null || !mounted) {
      return;
    }

    _recorderJson.text = content;
    _applyRecorderImport(content);
  }

  void _applyRecorderImport([String? rawJson]) {
    final source = rawJson ?? _recorderJson.text;

    try {
      final imported = RecorderGrenadeImport.fromRawText(source);
      setState(() {
        _lastImport = imported;
        _map = imported.safeMapCode;
        _type = imported.safeGrenadeType;
        _title.text = imported.suggestedTitle;
        _description.text = imported.suggestedDescription;
        _from.text = imported.suggestedFromPosition;
        _to.text = imported.suggestedToPosition;
        if (_imageUrl.text.trim().isEmpty) {
          _imageUrl.text = imported.suggestedImageUrl;
        }
        if (_tags.text.trim().isEmpty ||
            _tags.text.trim() == 'default, execute') {
          _tags.text = imported.suggestedTagsCsv;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recorder JSON импортирован в форму')),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось разобрать grenade.json: ${error.message}'),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось импортировать grenade.json')),
      );
    }
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
        _imageUrl.clear();
        _videoUrl.clear();
        _tags.text = 'default, execute';
        _recorderJson.clear();
        setState(() => _lastImport = null);
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
          'Здесь можно либо заполнить гранату вручную, либо импортировать grenade.json из CS2 recorder.',
          style: TextStyle(color: GameMentorColors.muted),
        ),
        const SizedBox(height: 22),
        _RecorderImportCard(
          controller: _recorderJson,
          lastImport: _lastImport,
          onImportPressed: _applyRecorderImport,
          onPickFilePressed: _pickRecorderJson,
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
                      required: false,
                    ),
                    const SizedBox(height: 14),
                    _ResponsiveRow(
                      compact: compact,
                      children: [
                        _TextInput(
                          controller: _imageUrl,
                          label: 'URL картинки',
                          required: false,
                          hintText: '/assets/gamementor/cs2/maps/mirage.jpg',
                        ),
                        _TextInput(
                          controller: _videoUrl,
                          label: 'URL видео',
                          required: false,
                        ),
                        _TextInput(
                          controller: _tags,
                          label: 'Теги',
                          required: false,
                          hintText: 'recorder, mirage, smoke',
                        ),
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

class _RecorderImportCard extends StatelessWidget {
  const _RecorderImportCard({
    required this.controller,
    required this.lastImport,
    required this.onImportPressed,
    required this.onPickFilePressed,
  });

  final TextEditingController controller;
  final RecorderGrenadeImport? lastImport;
  final VoidCallback onImportPressed;
  final VoidCallback onPickFilePressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        colors: [
          GameMentorColors.blue.withValues(alpha: 0.18),
          GameMentorColors.green.withValues(alpha: 0.08),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Импорт из recorder',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            '1. Запиши grenade.json через cs2-grenade-recorder. 2. Вставь JSON ниже или открой файл. 3. Проверь side и difficulty, затем сохрани гранату.',
            style: TextStyle(color: GameMentorColors.muted, height: 1.45),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            minLines: 7,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Содержимое grenade.json',
              alignLabelWithHint: true,
              hintText:
                  '{\n  "map": "de_mirage",\n  "grenade_type": "smoke",\n  "throw_position": {}\n}',
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onPickFilePressed,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Открыть grenade.json'),
              ),
              ElevatedButton.icon(
                onPressed: onImportPressed,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Импортировать в форму'),
              ),
              if (lastImport != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: GameMentorColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GameMentorColors.border),
                  ),
                  child: Text(
                    '${lastImport!.safeMapCode.toUpperCase()} | ${lastImport!.safeGrenadeType.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          if (lastImport != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GameMentorColors.surfaceAlt.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: GameMentorColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Что подтянулось из recorder',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Throw: ${lastImport!.throwPosition.toShortString()}',
                    style: const TextStyle(color: GameMentorColors.muted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'View: pitch ${lastImport!.viewAngle.pitchLabel}, yaw ${lastImport!.viewAngle.yawLabel}',
                    style: const TextStyle(color: GameMentorColors.muted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Landing: ${lastImport!.landingPosition.toShortString()}',
                    style: const TextStyle(color: GameMentorColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
    this.required = true,
    this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool required;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hintText),
      validator: (value) {
        if (!required) {
          return null;
        }
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
      key: ValueKey<String>('${label}_$value'),
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
