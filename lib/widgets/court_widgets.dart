import 'package:flutter/material.dart';
import 'package:tourney_app/utils/theme_data.dart';

class CourtBrand extends StatelessWidget {
  final bool compact;
  const CourtBrand({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.emoji_events_outlined,
          color: AppColors.background,
          size: 23,
        ),
      ),
      if (!compact) ...[
        const SizedBox(width: 12),
        Flexible(child: Text('TOURNAMENT\nORGANIZER', style: courtHeading(19))),
      ],
    ],
  );
}

class CourtPage extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  const CourtPage({
    super.key,
    required this.child,
    this.maxWidth = 1120,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class CourtSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const CourtSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!, style: const TextStyle(color: AppColors.muted)),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    ),
  );
}

class CourtStatus extends StatelessWidget {
  final String status;
  const CourtStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'ongoing' => AppColors.success,
      'completed' => AppColors.muted,
      'upcoming' => AppColors.warning,
      _ => AppColors.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            normalized == 'completed'
                ? Icons.check_circle_outline
                : Icons.circle,
            size: normalized == 'completed' ? 13 : 6,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: .6,
            ),
          ),
        ],
      ),
    );
  }
}

class CourtEmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;
  const CourtEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.emoji_events_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: AppColors.muted),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}

class CourtAuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const CourtAuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth < 600 ? 20 : 40,
          vertical: 32,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - 64).clamp(0, double.infinity),
          ),
          child: Center(
            child: SizedBox(
              width: 440,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CourtBrand(),
                  const SizedBox(height: 48),
                  Text(
                    title.toUpperCase(),
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 28),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
