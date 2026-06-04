import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/utils/text_file_picker.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_network_image.dart';
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
  final _tags = TextEditingController(text: 'recorder, execute');
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
            _tags.text.trim() == 'recorder, execute') {
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
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Граната добавлена')));
      _title.clear();
      _description.clear();
      _from.clear();
      _to.clear();
      _imageUrl.clear();
      _videoUrl.clear();
      _tags.text = 'recorder, execute';
      _recorderJson.clear();
      setState(() => _lastImport = null);
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
    final previewImage = _imageUrl.text.trim().isEmpty
        ? '/assets/gamementor/cs2/maps/$_map.jpg'
        : _imageUrl.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdminHeader(submitting: _submitting),
        const SizedBox(height: 16),
        const _OpsBoard(),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1080;
            final importColumn = Column(
              children: [
                _RecorderImportCard(
                  controller: _recorderJson,
                  lastImport: _lastImport,
                  onImportPressed: _applyRecorderImport,
                  onPickFilePressed: _pickRecorderJson,
                ),
                const SizedBox(height: 16),
                _PreviewCard(
                  map: _map,
                  side: _side,
                  type: _type,
                  difficulty: _difficulty,
                  title: _title.text,
                  from: _from.text,
                  to: _to.text,
                  imageUrl: previewImage,
                  tags: _tags.text,
                ),
              ],
            );
            final form = _GrenadeFormCard(
              formKey: _formKey,
              map: _map,
              side: _side,
              type: _type,
              difficulty: _difficulty,
              title: _title,
              description: _description,
              from: _from,
              to: _to,
              imageUrl: _imageUrl,
              videoUrl: _videoUrl,
              tags: _tags,
              submitting: _submitting,
              onMapChanged: (value) => setState(() => _map = value),
              onSideChanged: (value) => setState(() => _side = value),
              onTypeChanged: (value) => setState(() => _type = value),
              onDifficultyChanged: (value) =>
                  setState(() => _difficulty = value),
              onTextChanged: () => setState(() {}),
              onSubmit: _submit,
            );

            if (!wide) {
              return Column(
                children: [importColumn, const SizedBox(height: 16), form],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: importColumn),
                const SizedBox(width: 16),
                Expanded(flex: 6, child: form),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.submitting});

  final bool submitting;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        colors: [
          GameMentorColors.green.withValues(alpha: 0.18),
          GameMentorColors.surface.withValues(alpha: 0.92),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: GameMentorColors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: GameMentorColors.black,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Админ-центр GameMentor',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Создание CS2 гранат, импорт recorder JSON и подготовка контента к модерации.',
                  style: TextStyle(color: GameMentorColors.muted),
                ),
              ],
            ),
          ),
          _StatusBadge(
            icon: submitting ? Icons.sync_rounded : Icons.check_rounded,
            label: submitting ? 'Сохранение' : 'Готово',
            color: submitting ? GameMentorColors.amber : GameMentorColors.green,
          ),
        ],
      ),
    );
  }
}

class _OpsBoard extends StatelessWidget {
  const _OpsBoard();

  @override
  Widget build(BuildContext context) {
    final items = const [
      _OpsItem('Импорт recorder', 'JSON → форма', Icons.file_upload_rounded),
      _OpsItem('Статус контента', 'черновик → ревью', Icons.rule_rounded),
      _OpsItem('Создание через API', 'POST /cs2/grenades', Icons.api_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 860 ? 3 : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 1 ? 4.6 : 2.5,
          children: [
            for (final item in items)
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: GameMentorColors.green.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, color: GameMentorColors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: GameMentorColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Импорт из CS2 recorder',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Открой grenade.json или вставь содержимое вручную. Форма подтянет карту, тип, позиции и теги.',
            style: TextStyle(color: GameMentorColors.muted, height: 1.45),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            minLines: 7,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText:
                  '{\n  "map": "de_mirage",\n  "grenade_type": "smoke",\n  "throw_position": {}\n}',
              alignLabelWithHint: true,
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onPickFilePressed,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Открыть JSON'),
              ),
              ElevatedButton.icon(
                onPressed: onImportPressed,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Заполнить форму'),
              ),
            ],
          ),
          if (lastImport != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GameMentorColors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GameMentorColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImportLine(
                    label: 'Throw',
                    value: lastImport!.throwPosition.toShortString(),
                  ),
                  _ImportLine(
                    label: 'View',
                    value:
                        'pitch ${lastImport!.viewAngle.pitchLabel}, yaw ${lastImport!.viewAngle.yawLabel}',
                  ),
                  _ImportLine(
                    label: 'Landing',
                    value: lastImport!.landingPosition.toShortString(),
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

class _GrenadeFormCard extends StatelessWidget {
  const _GrenadeFormCard({
    required this.formKey,
    required this.map,
    required this.side,
    required this.type,
    required this.difficulty,
    required this.title,
    required this.description,
    required this.from,
    required this.to,
    required this.imageUrl,
    required this.videoUrl,
    required this.tags,
    required this.submitting,
    required this.onMapChanged,
    required this.onSideChanged,
    required this.onTypeChanged,
    required this.onDifficultyChanged,
    required this.onTextChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final String map;
  final String side;
  final String type;
  final String difficulty;
  final TextEditingController title;
  final TextEditingController description;
  final TextEditingController from;
  final TextEditingController to;
  final TextEditingController imageUrl;
  final TextEditingController videoUrl;
  final TextEditingController tags;
  final bool submitting;
  final ValueChanged<String> onMapChanged;
  final ValueChanged<String> onSideChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onDifficultyChanged;
  final VoidCallback onTextChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Form(
        key: formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Новая CS2 граната',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                _ResponsiveRow(
                  compact: compact,
                  children: [
                    _SelectField(
                      label: 'Карта',
                      value: map,
                      values: const {
                        'mirage': 'Mirage',
                        'inferno': 'Inferno',
                        'dust2': 'Dust2',
                        'nuke': 'Nuke',
                        'ancient': 'Ancient',
                        'anubis': 'Anubis',
                        'vertigo': 'Vertigo',
                      },
                      onChanged: onMapChanged,
                    ),
                    _SelectField(
                      label: 'Сторона',
                      value: side,
                      values: const {'T': 'T', 'CT': 'CT'},
                      onChanged: onSideChanged,
                    ),
                    _SelectField(
                      label: 'Тип',
                      value: type,
                      values: const {
                        'smoke': 'Смок',
                        'flash': 'Флеш',
                        'molotov': 'Молотов',
                        'he': 'HE',
                      },
                      onChanged: onTypeChanged,
                    ),
                    _SelectField(
                      label: 'Сложность',
                      value: difficulty,
                      values: const {
                        'easy': 'Легко',
                        'medium': 'Средне',
                        'hard': 'Сложно',
                      },
                      onChanged: onDifficultyChanged,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ResponsiveRow(
                  compact: compact,
                  children: [
                    _TextInput(
                      controller: title,
                      label: 'Название',
                      onChanged: onTextChanged,
                    ),
                    _TextInput(
                      controller: from,
                      label: 'Откуда бросать',
                      onChanged: onTextChanged,
                    ),
                    _TextInput(
                      controller: to,
                      label: 'Куда прилетает',
                      onChanged: onTextChanged,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TextInput(
                  controller: description,
                  label: 'Описание',
                  maxLines: 4,
                  required: false,
                  onChanged: onTextChanged,
                ),
                const SizedBox(height: 12),
                _ResponsiveRow(
                  compact: compact,
                  children: [
                    _TextInput(
                      controller: imageUrl,
                      label: 'URL картинки',
                      required: false,
                      hintText: '/assets/gamementor/cs2/maps/mirage.jpg',
                      onChanged: onTextChanged,
                    ),
                    _TextInput(
                      controller: videoUrl,
                      label: 'URL видео',
                      required: false,
                      onChanged: onTextChanged,
                    ),
                    _TextInput(
                      controller: tags,
                      label: 'Теги',
                      required: false,
                      hintText: 'recorder, mirage, smoke',
                      onChanged: onTextChanged,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: submitting ? null : onSubmit,
                    icon: submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.map,
    required this.side,
    required this.type,
    required this.difficulty,
    required this.title,
    required this.from,
    required this.to,
    required this.imageUrl,
    required this.tags,
  });

  final String map;
  final String side;
  final String type;
  final String difficulty;
  final String title;
  final String from;
  final String to;
  final String imageUrl;
  final String tags;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        GameMentorColors.black.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Text(
                    title.trim().isEmpty ? 'Preview гранаты' : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusBadge(
                      icon: Icons.map_rounded,
                      label: map.toUpperCase(),
                      color: GameMentorColors.green,
                    ),
                    _StatusBadge(
                      icon: Icons.flag_rounded,
                      label: side,
                      color: GameMentorColors.blue,
                    ),
                    _StatusBadge(
                      icon: Icons.grain_rounded,
                      label: type,
                      color: GameMentorColors.amber,
                    ),
                    _StatusBadge(
                      icon: Icons.speed_rounded,
                      label: difficulty,
                      color: GameMentorColors.muted,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${from.trim().isEmpty ? 'позиция броска' : from} → ${to.trim().isEmpty ? 'точка прилёта' : to}',
                  style: const TextStyle(color: GameMentorColors.muted),
                ),
                const SizedBox(height: 10),
                Text(
                  tags.trim().isEmpty ? 'Теги не заданы' : tags,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
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
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool required;
  final String? hintText;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hintText),
      onChanged: (_) => onChanged?.call(),
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

class _ImportLine extends StatelessWidget {
  const _ImportLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: GameMentorColors.muted),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _OpsItem {
  const _OpsItem(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}
