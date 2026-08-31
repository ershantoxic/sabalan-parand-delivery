import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/api.dart';
import 'core/models.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets.dart';

final storageProvider = Provider<FlutterSecureStorage>((Ref ref) => const FlutterSecureStorage());
final apiProvider = Provider<Api>((Ref ref) {
  final Api api = Api(ref.read(storageProvider));
  api.init();
  return api;
});
final ordersProvider = FutureProvider<List<Order>>((Ref ref) async {
  final Response<dynamic> response = await ref.read(apiProvider).dio.get('/orders', queryParameters: <String, String>{'date': DateTime.now().toIso8601String().substring(0, 10)});
  final Map<String, dynamic> body = Map<String, dynamic>.from(response.data as Map);
  final Map<String, dynamic> data = Map<String, dynamic>.from(body['data'] as Map);
  return List<dynamic>.from(data['data'] as List).map((dynamic item) => Order.fromJson(Map<String, dynamic>.from(item as Map))).toList();
});

void main() => runApp(const ProviderScope(child: App()));

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('fa'),
        supportedLocales: const <Locale>[Locale('fa')],
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
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Scaffold(body: LoadingView(label: 'در حال آماده‌سازی سامانه...'));
          return snapshot.data == null ? const Login() : const Shell();
        },
      );
}

class Login extends ConsumerStatefulWidget {
  const Login({super.key});
  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final TextEditingController _login = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;
  @override
  void dispose() { _login.dispose(); _password.dispose(); super.dispose(); }
  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final Response<dynamic> response = await ref.read(apiProvider).dio.post('/login', data: <String, String>{'login': _login.text.trim(), 'password': _password.text, 'device_name': 'Visitor Android'});
      final Map<String, dynamic> data = Map<String, dynamic>.from(Map<String, dynamic>.from(response.data as Map)['data'] as Map);
      await ref.read(storageProvider).write(key: 'token', value: data['token'] as String);
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const Shell()));
    } on DioException catch (error) {
      final String message = error.response?.data is Map ? (error.response?.data['message']?.toString() ?? 'اطلاعات ورود صحیح نیست.') : 'خطا در ارتباط با سرور';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally { if (mounted) setState(() => _loading = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440), child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: <Widget>[
        const SabalanLogo(size: 126), const SizedBox(height: 16), const Text('سامانه تحویل سفارش', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('سبلان پرند', style: TextStyle(color: AppColors.secondaryText)), const SizedBox(height: 28),
        TextField(controller: _login, keyboardType: TextInputType.phone, textDirection: TextDirection.rtl, decoration: const InputDecoration(labelText: 'نام کاربری یا شماره موبایل', prefixIcon: Icon(Icons.person_outline))), const SizedBox(height: 14),
        TextField(controller: _password, obscureText: !_showPassword, decoration: InputDecoration(labelText: 'رمز عبور', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _showPassword = !_showPassword), icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined))), onSubmitted: (_) => _loading ? null : _submit()), const SizedBox(height: 24),
        FilledButton(onPressed: _loading ? null : _submit, child: _loading ? const SizedBox(height: 23, width: 23, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Text('ورود به سامانه')),
      ]))),
    ))),
  );
}

class Shell extends ConsumerStatefulWidget { const Shell({super.key}); @override ConsumerState<Shell> createState() => _ShellState(); }
class _ShellState extends ConsumerState<Shell> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[Home(onViewOrders: () => setState(() => _tab = 1)), const Orders(), const Profile()];
    return Scaffold(body: pages[_tab], bottomNavigationBar: NavigationBar(selectedIndex: _tab, onDestinationSelected: (int index) => setState(() => _tab = index), destinations: const <NavigationDestination>[NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'خانه'), NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'سفارش‌ها'), NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'پروفایل')]));
  }
}

class Home extends ConsumerWidget {
  const Home({required this.onViewOrders, super.key}); final VoidCallback onViewOrders;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Order>> orders = ref.watch(ordersProvider);
    return AppScaffold(title: 'تحویل سبلان پرند', body: orders.when(
      loading: () => const LoadingView(), error: (_, __) => _Retry(onRetry: () => ref.invalidate(ordersProvider)),
      data: (List<Order> list) { final int done = list.where((Order order) => order.status == 'delivered').length; final int outgoing = list.where((Order order) => order.status == 'out_for_delivery').length; return ListView(padding: const EdgeInsets.all(20), children: <Widget>[
        const Text('نمای کلی امروز', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 5), const Text('وضعیت سفارش‌های تخصیص‌داده‌شده به شما', style: TextStyle(color: AppColors.secondaryText)), const SizedBox(height: 20),
        Wrap(spacing: 12, runSpacing: 12, children: <Widget>[Stat('سفارش‌های امروز', list.length, Icons.inventory_2_outlined, AppColors.primary), Stat('در حال ارسال', outgoing, Icons.local_shipping_outlined, AppColors.warning), Stat('تحویل‌شده', done, Icons.check_circle_outline, AppColors.success)]), const SizedBox(height: 26), FilledButton.icon(onPressed: onViewOrders, icon: const Icon(Icons.list_alt), label: const Text('مشاهده سفارش‌های امروز')),
      ]); },
    ));
  }
}

class Stat extends StatelessWidget { const Stat(this.title, this.value, this.icon, this.color, {super.key}); final String title; final int value; final IconData icon; final Color color; @override Widget build(BuildContext context) => SizedBox(width: 160, child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Icon(icon, color: color), const SizedBox(height: 16), Text('$value', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)), Text(title, style: const TextStyle(color: AppColors.secondaryText))])))); }
class _Retry extends StatelessWidget { const _Retry({required this.onRetry}); final VoidCallback onRetry; @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[const Text('خطا در ارتباط با سرور'), const SizedBox(height: 12), OutlinedButton(onPressed: onRetry, child: const Text('تلاش مجدد'))])); }

class Orders extends ConsumerWidget {
  const Orders({super.key});
  Future<void> _refresh(WidgetRef ref) async { ref.invalidate(ordersProvider); await ref.read(ordersProvider.future); }
  @override
  Widget build(BuildContext context, WidgetRef ref) { final AsyncValue<List<Order>> orders = ref.watch(ordersProvider); return AppScaffold(title: 'سفارش‌های امروز', body: RefreshIndicator(onRefresh: () => _refresh(ref), child: orders.when(loading: () => const LoadingView(), error: (_, __) => ListView(children: <Widget>[const SizedBox(height: 220), _Retry(onRetry: () => ref.invalidate(ordersProvider))]), data: (List<Order> list) => list.isEmpty ? ListView(children: const <Widget>[SizedBox(height: 210), EmptyState()]) : ListView.separated(padding: const EdgeInsets.all(16), itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (_, int i) => OrderCard(list[i])))); }
}

class OrderCard extends StatelessWidget {
  const OrderCard(this.order, {super.key}); final Order order;
  @override
  Widget build(BuildContext context) { final String customer = (order.customer['company_name'] ?? order.customer['name'] ?? '').toString(); return Card(child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => OrderDetail(order))), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Row(children: <Widget>[Expanded(child: Text('سفارش ${order.number}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))), StatusBadge(status: order.status)]), const SizedBox(height: 12), Text(customer, style: const TextStyle(fontWeight: FontWeight.w600)), if ((order.customer['address'] ?? '').toString().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 5), child: Text(order.customer['address'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.secondaryText))), const Divider(height: 24), Row(children: <Widget>[const Icon(Icons.scale_outlined, size: 18, color: AppColors.secondaryText), const SizedBox(width: 5), Text('${order.weight} کیلوگرم'), const Spacer(), Text('${order.amount} تومان', style: const TextStyle(fontWeight: FontWeight.w700))])])))); }
}

class OrderDetail extends ConsumerWidget {
  const OrderDetail(this.order, {super.key}); final Order order;
  Future<void> _call() => launchUrl(Uri(scheme: 'tel', path: order.customer['mobile']?.toString() ?? ''));
  Future<void> _start(BuildContext context, WidgetRef ref) async { try { await ref.read(apiProvider).dio.post('/orders/${order.id}/start-delivery'); if (context.mounted) Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => Verify(order))); } on DioException { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('امکان شروع تحویل وجود ندارد.'))); } }
  @override
  Widget build(BuildContext context, WidgetRef ref) => AppScaffold(title: 'جزئیات سفارش', body: ListView(padding: const EdgeInsets.all(20), children: <Widget>[_Section('اطلاعات مشتری', <Widget>[Text((order.customer['name'] ?? '').toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), if ((order.customer['company_name'] ?? '').toString().isNotEmpty) Text(order.customer['company_name'].toString()), const SizedBox(height: 7), Text((order.customer['address'] ?? '').toString(), style: const TextStyle(color: AppColors.secondaryText))]), const SizedBox(height: 14), _Section('اطلاعات سفارش', <Widget>[Text('شماره سفارش: ${order.number}'), Text('وزن کل: ${order.weight} کیلوگرم'), Text('مبلغ: ${order.amount} تومان'), const SizedBox(height: 9), Align(alignment: Alignment.centerRight, child: StatusBadge(status: order.status))]), const SizedBox(height: 24), OutlinedButton.icon(onPressed: _call, icon: const Icon(Icons.call_outlined), label: const Text('تماس با مشتری')), const SizedBox(height: 12), FilledButton.icon(onPressed: () => _start(context, ref), icon: const Icon(Icons.local_shipping_outlined), label: const Text('شروع تحویل'))]));
}
class _Section extends StatelessWidget { const _Section(this.title, this.children); final String title; final List<Widget> children; @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const Divider(height: 22), ...children])); }

class Verify extends ConsumerStatefulWidget { const Verify(this.order, {super.key}); final Order order; @override ConsumerState<Verify> createState() => _VerifyState(); }
class _VerifyState extends ConsumerState<Verify> { final TextEditingController _code = TextEditingController(); bool _busy = false; @override void dispose() { _code.dispose(); super.dispose(); } Future<void> _verify() async { if (_code.text.length != 6) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کد تحویل باید ۶ رقم باشد.'))); return; } setState(() => _busy = true); try { await ref.read(apiProvider).dio.post('/orders/${widget.order.id}/verify-delivery-code', data: <String, String>{'code': _code.text}); if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => PaymentPage(widget.order))); } on DioException catch (error) { final String message = error.response?.data is Map ? (error.response?.data['message']?.toString() ?? 'کد صحیح نیست.') : 'برای تأیید کد اتصال اینترنت لازم است.'; if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); } finally { if (mounted) setState(() => _busy = false); } } @override Widget build(BuildContext context) => AppScaffold(title: 'تأیید تحویل سفارش', body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[const Spacer(), const Icon(Icons.verified_user_outlined, size: 58, color: AppColors.primary), const SizedBox(height: 16), const Text('کد تحویل دریافت‌شده از مشتری را وارد کنید.', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 24), TextField(controller: _code, autofocus: true, maxLength: 6, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(letterSpacing: 10, fontWeight: FontWeight.w800, fontSize: 25), decoration: const InputDecoration(counterText: '', hintText: '••••••')), const SizedBox(height: 20), FilledButton(onPressed: _busy ? null : _verify, child: _busy ? const CircularProgressIndicator(color: Colors.white) : const Text('بررسی کد تحویل')), const Spacer()])); }

class PaymentPage extends ConsumerStatefulWidget { const PaymentPage(this.order, {super.key}); final Order order; @override ConsumerState<PaymentPage> createState() => _PaymentState(); }
class _PaymentState extends ConsumerState<PaymentPage> { String _method = 'card'; final TextEditingController _amount = TextEditingController(); final TextEditingController _reference = TextEditingController(); bool _busy = false; @override void dispose() { _amount.dispose(); _reference.dispose(); super.dispose(); } Future<void> _submit() async { setState(() => _busy = true); try { final int amount = int.tryParse(_amount.text.replaceAll(',', '')) ?? (widget.order.amount as int); await ref.read(apiProvider).dio.post('/orders/${widget.order.id}/payment', data: <String, Object>{'method': _method, 'amount': amount, 'reference_number': _reference.text}); await ref.read(apiProvider).dio.post('/orders/${widget.order.id}/complete-delivery', data: <String, String>{'idempotency_key': '${widget.order.id}-${DateTime.now().millisecondsSinceEpoch}'}); if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => Receipt(widget.order, _method))); } on DioException { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ثبت تحویل ناموفق بود. دوباره تلاش کنید.'))); } finally { if (mounted) setState(() => _busy = false); } } @override Widget build(BuildContext context) { const List<({String key, String label, IconData icon})> methods = <({String key, String label, IconData icon})>[ (key: 'card', label: 'کارتخوان', icon: Icons.credit_card), (key: 'cash', label: 'نقدی', icon: Icons.payments_outlined), (key: 'cheque', label: 'چک', icon: Icons.receipt_long_outlined), (key: 'credit', label: 'اعتباری', icon: Icons.account_balance_wallet_outlined), (key: 'bank_transfer', label: 'واریز بانکی', icon: Icons.account_balance_outlined), (key: 'prepaid', label: 'قبلاً پرداخت شده', icon: Icons.check_circle_outline) ]; return AppScaffold(title: 'ثبت پرداخت', body: ListView(padding: const EdgeInsets.all(20), children: <Widget>[const Text('روش تسویه را انتخاب کنید', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 14), Wrap(spacing: 10, runSpacing: 10, children: methods.map((m) => SizedBox(width: 165, child: ChoiceChip(label: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Icon(m.icon, size: 18), const SizedBox(width: 6), Flexible(child: Text(m.label))]), selected: _method == m.key, onSelected: (_) => setState(() => _method = m.key), selectedColor: AppColors.lightRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)), padding: const EdgeInsets.symmetric(vertical: 10))).toList()), const SizedBox(height: 22), TextField(controller: _amount, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'مبلغ (پیشنهادی: ${widget.order.amount})')), const SizedBox(height: 12), TextField(controller: _reference, decoration: const InputDecoration(labelText: 'شماره پیگیری (در صورت وجود)')), const SizedBox(height: 24), FilledButton(onPressed: _busy ? null : _submit, child: _busy ? const CircularProgressIndicator(color: Colors.white) : const Text('ثبت پرداخت و تکمیل تحویل'))])); } }

class Receipt extends StatelessWidget { const Receipt(this.order, this.method, {super.key}); final Order order; final String method; @override Widget build(BuildContext context) => AppScaffold(title: 'رسید تحویل', body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[const Icon(Icons.check_circle, color: AppColors.success, size: 76), const SizedBox(height: 16), const Text('تحویل با موفقیت ثبت شد.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 12), Text('سفارش: ${order.number}'), Text('مشتری: ${order.customer['name']}'), Text('روش پرداخت: $method'), const SizedBox(height: 24), FilledButton(onPressed: () => Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst), child: const Text('بازگشت به خانه'))]))); }
class Profile extends ConsumerWidget { const Profile({super.key}); @override Widget build(BuildContext context, WidgetRef ref) => AppScaffold(title: 'پروفایل', body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[const SabalanLogo(size: 92), const SizedBox(height: 20), const Center(child: Text('سبلان پرند', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))), const Spacer(), OutlinedButton.icon(onPressed: () async { await ref.read(storageProvider).delete(key: 'token'); if (context.mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => const Login()), (Route<dynamic> route) => false); }, icon: const Icon(Icons.logout), label: const Text('خروج از حساب'))]))); }
