import 'package:flutter/material.dart';

import 'theme/app_colors.dart';

class SabalanLogo extends StatelessWidget {
  const SabalanLogo({super.key, this.size = 112});
  final double size;
  @override
  Widget build(BuildContext context) => Image.asset('assets/branding/sabalan_parand_logo.png', width: size, height: size, fit: BoxFit.contain, semanticLabel: 'سبلان پرند');
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.title, required this.body, this.actions, this.bottomNavigationBar});
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title), actions: actions), body: SafeArea(child: body), bottomNavigationBar: bottomNavigationBar);
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label = 'در حال دریافت اطلاعات...'});
  final String label;
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[const CircularProgressIndicator(), const SizedBox(height: 16), Text(label, style: const TextStyle(color: AppColors.secondaryText))]));
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.message = 'سفارشی برای نمایش وجود ندارد.'});
  final String message;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[const Icon(Icons.inventory_2_outlined, color: AppColors.secondaryText, size: 52), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.secondaryText))])));
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final ({String label, Color color}) values = switch (status) {
      'delivered' => (label: 'تحویل شده', color: AppColors.success),
      'out_for_delivery' => (label: 'در حال ارسال', color: AppColors.warning),
      'code_verified' => (label: 'کد تأیید شد', color: AppColors.success),
      'delivery_failed' => (label: 'عدم تحویل', color: AppColors.error),
      'assigned' => (label: 'تخصیص داده شده', color: AppColors.primary),
      _ => (label: 'در انتظار تحویل', color: AppColors.secondaryText),
    };
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: values.color.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)), child: Text(values.label, style: TextStyle(color: values.color, fontWeight: FontWeight.w700, fontSize: 12)));
  }
}
