import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/api.dart';
import 'core/models.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets.dart';

final storageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());
final apiProvider = Provider<Api>((ref) {
  final api = Api(ref.read(storageProvider));
  api.init();
  return api;
});
final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final response = await ref.read(apiProvider).dio.get('/orders', queryParameters: {'date': DateTime.now().toIso8601String().substring(0, 10)});
  final body = Map<String, dynamic>.from(response.data as Map);
  final data = Map<String, dynamic>.from(body['data'] as Map);
  return List<dynamic>.from(data['data'] as List).map((item) => Order.fromJson(Map<String, dynamic>.from(item as Map))).toList();
});

void main() => runApp(const ProviderScope(child: SabalanApp()));

class SabalanApp extends StatelessWidget {
  const SabalanApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('fa'),
        supportedLocales: const [Locale('fa')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: AppTheme.light,
        home: const Gate(),
      );
}

class Gate extends ConsumerWidget {
  const Gate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder<String?>(
        future: ref.read(storageProvider).read(key: 'token'),
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Scaffold(body: LoadingView());
          return snapshot.data == null ? const LoginPage() : const HomeShell();
        },
      );
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _showPassword = false;
  @override
  void dispose() { _login.dispose(); _password.dispose(); super.dispose(); }
  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      final response = await ref.read(apiProvider).dio.post('/login', data: {'login': _login.text.trim(), 'password': _password.text, 'device_name': 'Visitor Android'});
      final data = Map<String, dynamic>.from(Map<String, dynamic>.from(response.data as Map)['data'] as Map);
      await ref.read(storageProvider).write(key: 'token', value: data['token'] as String);
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeShell()));
    } on DioException catch (error) {
      final message = error.response?.data is Map ? error.response?.data['message']?.toString() : null;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? 'خطا در ارتباط با سرور')));
    } finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [const SabalanLogo(size: 120), const SizedBox(height: 14), const Text('سامانه تحویل سفارش', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const Text('سبلان پرند', style: TextStyle(color: AppColors.secondaryText)), const SizedBox(height: 28), TextField(controller: _login, decoration: const InputDecoration(labelText: 'نام کاربری یا شماره موبایل', prefixIcon: Icon(Icons.person_outline))), const SizedBox(height: 12), TextField(controller: _password, obscureText: !_showPassword, decoration: InputDecoration(labelText: 'رمز عبور', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _showPassword = !_showPassword), icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined)))), const SizedBox(height: 22), FilledButton(onPressed: _busy ? null : _submit, child: _busy ? const CircularProgressIndicator(color: Colors.white) : const Text('ورود به سامانه'))]))))))));
}

class HomeShell extends ConsumerStatefulWidget { const HomeShell({super.key}); @override ConsumerState<HomeShell> createState() => _HomeShellState(); }
class _HomeShellState extends ConsumerState<HomeShell> { int index = 0; @override Widget build(BuildContext context) { final pages = [const DashboardPage(), const OrdersPage(), const ProfilePage()]; return Scaffold(body: pages[index], bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (value) => setState(() => index = value), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'خانه'), NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'سفارش‌ها'), NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'پروفایل')])); } }

class DashboardPage extends ConsumerWidget { const DashboardPage({super.key}); @override Widget build(BuildContext context, WidgetRef ref) => AppScaffold(title: 'تحویل سبلان پرند', body: ref.watch(ordersProvider).when(loading: () => const LoadingView(), error: (_, __) => RetryView(onRetry: () => ref.invalidate(ordersProvider)), data: (orders) { final delivered = orders.where((o) => o.status == 'delivered').length; return ListView(padding: const EdgeInsets.all(20), children: [const Text('نمای کلی امروز', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 8), const Text('وضعیت سفارش‌های تخصیص‌داده‌شده به شما', style: TextStyle(color: AppColors.secondaryText)), const SizedBox(height: 20), Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Summary('سفارش امروز', orders.length, AppColors.primary), Summary('تحویل‌شده', delivered, AppColors.success)])))]; })));
}

class Summary extends StatelessWidget { const Summary(this.label, this.value, this.color, {super.key}); final String label; final int value; final Color color; @override Widget build(BuildContext context) => Column(children: [Text('$value', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)), Text(label, style: const TextStyle(color: AppColors.secondaryText))]); }
class RetryView extends StatelessWidget { const RetryView({required this.onRetry, super.key}); final VoidCallback onRetry; @override Widget build(BuildContext context) => Center(child: OutlinedButton(onPressed: onRetry, child: const Text('تلاش مجدد'))); }

class OrdersPage extends ConsumerWidget { const OrdersPage({super.key}); @override Widget build(BuildContext context, WidgetRef ref) => AppScaffold(title: 'سفارش‌های امروز', body: ref.watch(ordersProvider).when(loading: () => const LoadingView(), error: (_, __) => RetryView(onRetry: () => ref.invalidate(ordersProvider)), data: (orders) => orders.isEmpty ? const EmptyState() : ListView.separated(padding: const EdgeInsets.all(16), itemCount: orders.length, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (_, index) => OrderCard(order: orders[index])))); }
class OrderCard extends StatelessWidget { const OrderCard({required this.order, super.key}); final Order order; @override Widget build(BuildContext context) => Card(child: ListTile(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailPage(order: order))), title: Text('سفارش ${order.number}', style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text((order.customer['name'] ?? '').toString()), trailing: StatusBadge(status: order.status))); }

class OrderDetailPage extends ConsumerWidget { const OrderDetailPage({required this.order, super.key}); final Order order; Future<void> _start(BuildContext context, WidgetRef ref) async { try { await ref.read(apiProvider).dio.post('/orders/${order.id}/start-delivery'); if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => VerifyCodePage(order: order))); } on DioException { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('امکان شروع تحویل وجود ندارد.'))); } } @override Widget build(BuildContext context, WidgetRef ref) => AppScaffold(title: 'جزئیات سفارش', body: ListView(padding: const EdgeInsets.all(20), children: [Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('اطلاعات مشتری', style: TextStyle(fontWeight: FontWeight.w800)), const Divider(), Text((order.customer['name'] ?? '').toString()), Text((order.customer['address'] ?? '').toString())]))), const SizedBox(height: 12), Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('اطلاعات سفارش', style: TextStyle(fontWeight: FontWeight.w800)), const Divider(), Text('شماره سفارش: ${order.number}'), Text('وزن کل: ${order.weight} کیلوگرم'), Text('مبلغ: ${order.amount} تومان'), const SizedBox(height: 10), StatusBadge(status: order.status)]))), const SizedBox(height: 24), FilledButton(onPressed: () => _start(context, ref), child: const Text('شروع تحویل'))])); }

class VerifyCodePage extends ConsumerStatefulWidget { const VerifyCodePage({required this.order, super.key}); final Order order; @override ConsumerState<VerifyCodePage> createState() => _VerifyCodePageState(); }
class _VerifyCodePageState extends ConsumerState<VerifyCodePage> { final code = TextEditingController(); bool busy = false; @override void dispose() { code.dispose(); super.dispose(); } Future<void> verify() async { if (code.text.length != 6) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کد تحویل باید ۶ رقم باشد.'))); return; } setState(() => busy = true); try { await ref.read(apiProvider).dio.post('/orders/${widget.order.id}/verify-delivery-code', data: {'code': code.text}); if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PaymentPage(order: widget.order))); } on DioException { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کد صحیح نیست.'))); } finally { if (mounted) setState(() => busy = false); } } @override Widget build(BuildContext context) => AppScaffold(title: 'تأیید تحویل سفارش', body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Spacer(), const Text('کد تحویل دریافت‌شده از مشتری را وارد کنید.', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 22), TextField(controller: code, maxLength: 6, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, letterSpacing: 10), decoration: const InputDecoration(counterText: '', hintText: '••••••')), const SizedBox(height: 20), FilledButton(onPressed: busy ? null : verify, child: const Text('بررسی کد تحویل')), const Spacer()]))); }

class PaymentPage extends ConsumerStatefulWidget { const PaymentPage({required this.order, super.key}); final Order order; @override ConsumerState<PaymentPage> createState() => _PaymentPageState(); }
class _PaymentPageState extends ConsumerState<PaymentPage> { String method = 'card'; bool busy = false; final amount = TextEditingController(); final reference = TextEditingController(); @override void dispose() { amount.dispose(); reference.dispose(); super.dispose(); } Future<void> submit() async { setState(() => busy = true); try { final value = int.tryParse(amount.text.replaceAll(',', '')) ?? (widget.order.amount as int); await ref.read(apiProvider).dio.post('/orders/${widget.order.id}/payment', data: {'method': method, 'amount': value, 'reference_number': reference.text}); await ref.read(apiProvider).dio.post('/orders/${widget.order.id}/complete-delivery', data: {'idempotency_key': '${widget.order.id}-${DateTime.now().millisecondsSinceEpoch}'}); if (mounted) Navigator.popUntil(context, (route) => route.isFirst); } on DioException { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ثبت تحویل ناموفق بود.'))); } finally { if (mounted) setState(() => busy = false); } } @override Widget build(BuildContext context) => AppScaffold(title: 'ثبت پرداخت', body: ListView(padding: const EdgeInsets.all(20), children: [const Text('روش تسویه را انتخاب کنید', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 12), DropdownButtonFormField(value: method, items: const [DropdownMenuItem(value: 'card', child: Text('کارتخوان')), DropdownMenuItem(value: 'cash', child: Text('نقدی')), DropdownMenuItem(value: 'cheque', child: Text('چک')), DropdownMenuItem(value: 'credit', child: Text('اعتباری')), DropdownMenuItem(value: 'bank_transfer', child: Text('واریز بانکی')), DropdownMenuItem(value: 'prepaid', child: Text('قبلاً پرداخت شده'))], onChanged: (value) => setState(() => method = value!)), const SizedBox(height: 12), TextField(controller: amount, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'مبلغ (پیشنهادی: ${widget.order.amount})')), const SizedBox(height: 12), TextField(controller: reference, decoration: const InputDecoration(labelText: 'شماره پیگیری (در صورت وجود)')), const SizedBox(height: 22), FilledButton(onPressed: busy ? null : submit, child: const Text('ثبت پرداخت و تکمیل تحویل'))])); }

class ProfilePage extends ConsumerWidget { const ProfilePage({super.key}); @override Widget build(BuildContext context, WidgetRef ref) => AppScaffold(title: 'پروفایل', body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const SabalanLogo(size: 92), const Spacer(), OutlinedButton.icon(onPressed: () async { await ref.read(storageProvider).delete(key: 'token'); if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false); }, icon: const Icon(Icons.logout), label: const Text('خروج از حساب'))]))); }
