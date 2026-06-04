import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/section_header.dart';

class DotaDashboardPage extends StatefulWidget {
  const DotaDashboardPage({super.key});

  @override
  State<DotaDashboardPage> createState() => _DotaDashboardPageState();
}

class _DotaDashboardPageState extends State<DotaDashboardPage> {
  late final TextEditingController _accountController;

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController(
      text: AppConfig.defaultDotaAccountId,
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  void _openAnalysis() {
    final value = _accountController.text.trim();
    if (value.isEmpty) return;
    context.go('/dota/player/$value');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DotaLabHero(controller: _accountController, onAnalyze: _openAnalysis),
        const SizedBox(height: 16),
        const _ProductMetrics(),
        const SizedBox(height: 16),
        const _AiOfferCard(),
        const SizedBox(height: 16),
        const _HowAnalysisWorks(),
      ],
    );
  }
}

class _DotaLabHero extends StatelessWidget {
  const _DotaLabHero({required this.controller, required this.onAnalyze});

  final TextEditingController controller;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      hoverLift: false,
      borderColor: AppColors.dotaAccent.withValues(alpha: 0.45),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: AppNetworkImage(
                imageUrl: '/assets/gamementor/home/dota-card.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.black.withValues(alpha: 0.94),
                      AppColors.background.withValues(alpha: 0.82),
                      AppColors.black.withValues(alpha: 0.38),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(26),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 820;
                  final copy = _HeroCopy(
                    controller: controller,
                    onAnalyze: onAnalyze,
                  );
                  const preview = _HeroPreviewPanel();

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [copy, const SizedBox(height: 22), preview],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 6, child: copy),
                      const SizedBox(width: 28),
                      const Expanded(flex: 5, child: preview),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.controller, required this.onAnalyze});

  final TextEditingController controller;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppBadge(
              icon: Icons.query_stats_rounded,
              label: 'Dota Lab',
              color: AppColors.dotaAccent,
            ),
            AppBadge(
              icon: Icons.workspace_premium_rounded,
              label: 'первый AI-прогон за 0 ₽',
              color: AppColors.warningPro,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Разбор профиля, который сразу показывает, куда теряется рейтинг',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.02,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Введи Dota account ID: GameMentor соберёт OpenDota матчи, покажет форму, героев, сравнение с pro и подготовит план AI Coach.',
          style: AppTypography.bodyMuted,
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.tag_rounded),
                  labelText: 'Dota account ID',
                  hintText: '369102305',
                ),
                onSubmitted: (_) => onAnalyze(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: onAnalyze,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Анализировать'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroPreviewPanel extends StatelessWidget {
  const _HeroPreviewPanel();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('GameMentor Score', '0-100', Icons.speed_rounded),
      ('Hero Pool', 'лучшие/слабые', Icons.view_in_ar_rounded),
      ('Pro Compare', 'Yatoro/Nisha/Save', Icons.stacked_line_chart_rounded),
      ('AI Coach', 'план роста', Icons.psychology_alt_rounded),
    ];
    return AppCard(
      hoverLift: false,
      color: AppColors.black.withValues(alpha: 0.62),
      child: Column(
        children: [
          for (final item in items)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.78),
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(item.$3, color: AppColors.dotaAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text(item.$2, style: AppTypography.label),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductMetrics extends StatelessWidget {
  const _ProductMetrics();

  @override
  Widget build(BuildContext context) {
    const metrics = [
      ('8', 'ключевых графиков'),
      ('100', 'матчей в срезе'),
      ('7/30/90', 'периоды анализа'),
      ('0 ₽', 'первый AI-тест'),
    ];
    return GridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width >= 980 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        for (final item in metrics)
          AppCard(
            hoverLift: false,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.$1,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(item.$2, style: AppTypography.label),
              ],
            ),
          ),
      ],
    );
  }
}

class _AiOfferCard extends StatelessWidget {
  const _AiOfferCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hoverLift: false,
      borderColor: AppColors.warningPro.withValues(alpha: 0.45),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 820;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBadge(
                icon: Icons.auto_awesome_rounded,
                label: 'AI Coach',
                color: AppColors.warningPro,
              ),
              const SizedBox(height: 14),
              const Text(
                'Первый тестовый AI-разбор за 0 ₽',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Заглушка оплаты уже заложена: первый отчёт бесплатный, дальше можно включить тарифы за полный разбор матчей, hero pool и недельный план.',
                style: AppTypography.bodyMuted,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.go('/dota/ai-coach'),
                    icon: const Icon(Icons.bolt_rounded),
                    label: const Text('Получить 0 ₽ прогон'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showPaymentStub(context),
                    icon: const Icon(Icons.credit_card_rounded),
                    label: const Text('Оплата позже'),
                  ),
                ],
              ),
            ],
          );
          const plan = _AiPlanPreview();
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 18), plan],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: copy),
              const SizedBox(width: 22),
              const Expanded(flex: 5, child: plan),
            ],
          );
        },
      ),
    );
  }
}

class _AiPlanPreview extends StatelessWidget {
  const _AiPlanPreview();

  @override
  Widget build(BuildContext context) {
    const items = [
      '1. Найти главную причину потери винрейта',
      '2. Выделить 3 сильные и 5 слабых паттернов',
      '3. Дать hero pool на неделю',
      '4. Составить план: матчи, разборы, тренировки',
    ];
    return Column(
      children: [
        for (final item in items)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.32),
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.dotaAccent,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}

class _HowAnalysisWorks extends StatelessWidget {
  const _HowAnalysisWorks();

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('Профиль', 'OpenDota профиль и последние матчи.'),
      ('Метрики', 'Форма, герои, экономика, драки, объекты.'),
      ('План', 'AI Coach превращает цифры в действия.'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Как будет работать платный разбор',
          subtitle: 'Пока это MVP-заглушка, но структура уже готова под SaaS.',
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width >= 900 ? 3 : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            for (final step in steps)
              AppCard(
                hoverLift: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      step.$1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(step.$2, style: AppTypography.bodyMuted),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

void _showPaymentStub(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Оплата будет позже'),
      content: const Text(
        'Сейчас это заглушка. Следующий шаг - тарифы Free/Premium/Pro, лимит бесплатных AI-разборов и Stripe/ЮKassa интеграция.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Понятно'),
        ),
      ],
    ),
  );
}
