import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/api.dart';
import 'core/models.dart';

final storageProvider = Provider<FlutterSecureStorage>((Ref ref) => const FlutterSecureStorage());
final apiProvider = Provider<Api>((Ref ref) {
  final Api api = Api(ref.read(storageProvider));
  api.init();
  return api;
});
final ordersProvider = FutureProvider<List<Order>>((Ref ref) async {
  final Response<dynamic> response = await ref.read(apiProvider).dio.get(
    '/orders',
    queryParameters: <String, String>{
      'date': DateTime.now().toIso8601String().substring(0, 10),
    },
  );
  final Map<String, dynamic> body = Map<String, dynamic>.from(response.data as Map);
  final Map<String, dynamic> data = Map<String, dynamic>.from(body['data'] as Map);
  final List<dynamic> items = List<dynamic>.from(data['data'] as List<dynamic>);
  return items.map((dynamic item) => Order.fromJson(Map<String, dynamic>.from(item as Map))).toList();
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
        theme: ThemeData(colorSchemeSeed: Colors.teal),
        home: const Gate(),
      );
}

class Gate extends ConsumerWidget {
  const Gate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder<String?>(
        future: ref.read(storageProvider).read(key: 'token'),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          return snapshot.data == null ? const Login() : const Shell();
        },
      );
}

class Login extends ConsumerStatefulWidget { const Login({super.key}); @override ConsumerState<Login> createState() => _LoginState(); }
class _LoginState extends ConsumerState<Login> {
  final TextEditingController _login = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;
  @override void dispose() { _login.dispose(); _password.dispose(); super.dispose(); }
  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final Response<dynamic> response = await ref.read(apiProvider).dio.post('/login', data: <String, String>{'login': _login.text, 'password': _password.text, 'device_name': 'Visitor Android'});
      final Map<String, dynamic> body = Map<String, dynamic>.from(response.data as Map);
      final Map<String, dynamic> data = Map<String, dynamic>.from(body['data'] as Map);
      await ref.read(storageProvider).write(key: 'token', value: data['token'] as String);
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const Shell()));
    } on DioException {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ارتباط با سرور برقرار نشد یا اطلاعات ورود نادرست است.')));
    } finally { if (mounted) setState(() => _loading = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[const Text('سامانه تحویل سفارش', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), const SizedBox(height: 30), TextField(controller: _login, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'شماره موبایل یا نام کاربری')), TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'رمز عبور')), const SizedBox(height: 24), FilledButton(onPressed: _loading ? null : _submit, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)), child: _loading ? const CircularProgressIndicator() : const Text('ورود'))]))));
}

class Shell extends ConsumerStatefulWidget { const Shell({super.key}); @override ConsumerState<Shell> createState() => _ShellState(); }
class _ShellState extends ConsumerState<Shell> {
  int _tab = 0;
  @override Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[Home(onViewOrders: () => setState(() => _tab = 1)), const Orders(), const Report(), const Profile()];
    return Scaffold(body: pages[_tab], bottomNavigationBar: NavigationBar(selectedIndex: _tab, onDestinationSelected: (int index) => setState(() => _tab = index), destinations: const <NavigationDestination>[NavigationDestination(icon: Icon(Icons.home_outlined), label: 'خانه'), NavigationDestination(icon: Icon(Icons.list_alt), label: 'سفارش‌ها'), NavigationDestination(icon: Icon(Icons.bar_chart), label: 'گزارش من'), NavigationDestination(icon: Icon(Icons.person_outline), label: 'پروفایل')]));
  }
}

class Home extends ConsumerWidget {
  const Home({required this.onViewOrders, super.key}); final VoidCallback onViewOrders;
  @override Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Order>> orders = ref.watch(ordersProvider);
    return Scaffold(appBar: AppBar(title: const Text('خانه')), body: orders.when(data: (List<Order> list) { final int done = list.where((Order order) => order.status == 'delivered').length; return Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('امروز ${DateTime.now().toLocal().toString().substring(0, 10)}', style: const TextStyle(fontSize: 18)), const SizedBox(height: 20), Wrap(spacing: 12, runSpacing: 12, children: <Widget>[Stat('سفارش امروز', list.length), Stat('تحویل شده', done), Stat('باقی مانده', list.length - done)]), const SizedBox(height: 28), FilledButton(onPressed: onViewOrders, child: const Text('مشاهده سفارش‌های امروز'))])); }, error: (_, __) => const Center(child: Text('ارتباط با سرور برقرار نشد.')), loading: () => const Center(child: CircularProgressIndicator())));
  }
}
class Stat extends StatelessWidget { const Stat(this.title, this.value, {super.key}); final String title; final int value; @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: <Widget>[Text('$value', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)), Text(title)]))); }
class Orders extends ConsumerWidget { const Orders({super.key}); Future<void> _refresh(WidgetRef ref) async { await ref.refresh(ordersProvider.future); } @override Widget build(BuildContext context, WidgetRef ref) { final AsyncValue<List<Order>> orders = ref.watch(ordersProvider); return Scaffold(appBar: AppBar(title: const Text('سفارش‌های امروز')), body: RefreshIndicator(onRefresh: () => _refresh(ref), child: orders.when(data: (List<Order> list) => list.isEmpty ? const ListView(children: <Widget>[SizedBox(height: 250), Center(child: Text('سفارشی برای امروز ثبت نشده است.'))]) : ListView.builder(itemCount: list.length, itemBuilder: (BuildContext context, int index) => OrderCard(list[index])), error: (_, __) => ListView(children: const <Widget>[SizedBox(height: 250), Center(child: Text('ارتباط با سرور برقرار نشد. دوباره تلاش کنید.'))]), loading: () => const Center(child: CircularProgressIndicator())))); } }
class OrderCard extends StatelessWidget { const OrderCard(this.order, {super.key}); final Order order; @override Widget build(BuildContext context) { final String company = (order.customer['company_name'] ?? order.customer['name'] ?? '').toString(); return Card(child: ListTile(onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => OrderDetail(order))), title: Text('سفارش #${order.number}'), subtitle: Text('$company\nوزن: ${order.weight} kg'), trailing: Text('${order.amount} تومان\n${order.status}', textAlign: TextAlign.end))); } }

class OrderDetail extends ConsumerWidget { const OrderDetail(this.order, {super.key}); final Order order; Future<void> _call() => launchUrl(Uri(scheme: 'tel', path: order.customer['mobile']?.toString() ?? '')); Future<void> _start(BuildContext context, WidgetRef ref) async { try { await ref.read(apiProvider).dio.post('/orders/${order.id}/start-delivery'); if (context.mounted) Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => Verify(order))); } on DioException { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('امکان شروع تحویل وجود ندارد.'))); } } @override Widget build(BuildContext context, WidgetRef ref) => Scaffold(appBar: AppBar(title: Text('سفارش #${order.number}')), body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text((order.customer['name'] ?? '').toString(), style: const TextStyle(fontSize: 22)), Text((order.customer['address'] ?? '').toString()), const SizedBox(height: 20), Text('مبلغ: ${order.amount} تومان'), Text('وزن: ${order.weight} kg'), const Spacer(), Row(children: <Widget>[OutlinedButton.icon(onPressed: _call, icon: const Icon(Icons.call), label: const Text('تماس')), const SizedBox(width: 12), Expanded(child: FilledButton(onPressed: () => _start(context, ref), child: const Text('شروع تحویل')))])])));
}
class Verify extends ConsumerStatefulWidget { const Verify(this.order, {super.key}); final Order order; @override ConsumerState<Verify> createState() => _VerifyState(); }
class _VerifyState extends ConsumerState<Verify> { final TextEditingController _code = TextEditingController(); bool _busy = false; @override void dispose() { _code.dispose(); super.dispose(); } Future<void> _verify() async { setState(() => _busy = true); try { await ref.read(apiProvider).dio.post('/orders/${widget.order.id}/verify-delivery-code', data: <String, String>{'code': _code.text}); if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => PaymentPage(widget.order))); } on DioException catch (error) { final Object? responseData = error.response?.data; final String message = responseData is Map ? (responseData['message']?.toString() ?? 'کد صحیح نیست.') : 'برای تأیید کد اتصال اینترنت لازم است.'; if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); } finally { if (mounted) setState(() => _busy = false); } } @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('تأیید تحویل سفارش')), body: Padding(padding: const EdgeInsets.all(24), child: Column(children: <Widget>[Text('سفارش #${widget.order.number}'), Text((widget.order.customer['name'] ?? '').toString()), TextField(controller: _code, maxLength: 6, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'کد ۶ رقمی')), const SizedBox(height: 18), FilledButton(onPressed: _busy ? null : _verify, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)), child: const Text('بررسی کد'))]))); }
class PaymentPage extends ConsumerStatefulWidget { const PaymentPage(this.order, {super.key}); final Order order; @override ConsumerState<PaymentPage> createState() => _PaymentState(); }
class _PaymentState extends ConsumerState<PaymentPage> { String _method = 'card'; final TextEditingController _amount = TextEditingController(); final TextEditingController _reference = TextEditingController(); bool _busy = false; @override void dispose() { _amount.dispose(); _reference.dispose(); super.dispose(); } Future<void> _submit() async { setState(() => _busy = true); try { final int amount = int.tryParse(_amount.text.replaceAll(',', '')) ?? (widget.order.amount as int); await ref.read(apiProvider).dio.post('/orders/${widget.order.id}/payment', data: <String, Object>{'method': _method, 'amount': amount, 'reference_number': _reference.text}); await ref.read(apiProvider).dio.post('/orders/${widget.order.id}/complete-delivery', data: <String, String>{'idempotency_key': '${widget.order.id}-${DateTime.now().millisecondsSinceEpoch}'}); if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => Receipt(widget.order, _method))); } on DioException { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ثبت تحویل ناموفق بود. دوباره تلاش کنید.'))); } finally { if (mounted) setState(() => _busy = false); } } @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('روش تسویه')), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: <Widget>[DropdownButtonFormField<String>(value: _method, items: const <DropdownMenuItem<String>>[DropdownMenuItem(value: 'card', child: Text('کارت')), DropdownMenuItem(value: 'cash', child: Text('نقد')), DropdownMenuItem(value: 'cheque', child: Text('چک')), DropdownMenuItem(value: 'credit', child: Text('اعتباری')), DropdownMenuItem(value: 'bank_transfer', child: Text('واریز بانکی')), DropdownMenuItem(value: 'prepaid', child: Text('قبلاً پرداخت شده'))], onChanged: (String? value) { if (value != null) setState(() => _method = value); }), TextField(controller: _amount, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'مبلغ (پیشنهادی: ${widget.order.amount})')), TextField(controller: _reference, decoration: const InputDecoration(labelText: 'شماره پیگیری')), const Spacer(), FilledButton(onPressed: _busy ? null : _submit, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)), child: const Text('تأیید نهایی تحویل'))]))); }
class Receipt extends StatelessWidget { const Receipt(this.order, this.method, {super.key}); final Order order; final String method; @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('رسید تحویل')), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[const Icon(Icons.check_circle, color: Colors.green, size: 72), const Text('تحویل با موفقیت ثبت شد.', style: TextStyle(fontSize: 22)), Text('سفارش: ${order.number}'), Text('مشتری: ${order.customer['name']}'), Text('روش پرداخت: $method'), Text('زمان: ${DateTime.now()}')]))); }
class Report extends StatelessWidget { const Report({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('گزارش من')), body: const Center(child: Text('گزارش امروز، این هفته و این ماه از سرور نمایش داده می‌شود.'))); }
class Profile extends ConsumerWidget { const Profile({super.key}); @override Widget build(BuildContext context, WidgetRef ref) => Scaffold(appBar: AppBar(title: const Text('پروفایل')), body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[const Text('نسخه برنامه 1.0.0'), const Spacer(), FilledButton.tonal(onPressed: () async { final bool? confirmed = await showDialog<bool>(context: context, builder: (BuildContext dialogContext) => AlertDialog(title: const Text('خروج'), content: const Text('آیا از خروج مطمئن هستید؟'), actions: <Widget>[TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('خیر')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('بله'))])); if (confirmed == true) { await ref.read(storageProvider).delete(key: 'token'); if (context.mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => const Login()), (Route<dynamic> route) => false); } }, child: const Text('خروج از حساب'))]))); }
