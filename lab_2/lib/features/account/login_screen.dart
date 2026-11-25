import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_error_message.dart';
import '../../core/api/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/busy_button.dart';
import 'auth_model.dart';
import 'fake_auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthModel>().login(_email.text, _password.text);
      if (!mounted) return;
      await Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = ApiErrorMessage.of(e);
      });
    }
  }

  void _unfocus(PointerDownEvent _) => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign in')),
    body: Form(
      key: _form,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onTapOutside: _unfocus,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onTapOutside: _unfocus,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Password',
              helperText: 'Demo password: ${FakeAuthRepository.demoPassword}',
            ),
            validator: (v) =>
                (v == null || v.length < 8) ? 'At least 8 characters' : null,
          ),
          const SizedBox(height: 24),
          if (_error case final e?)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                e,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          BusyButton(busy: _busy, label: 'Sign in', onPressed: _submit),
        ],
      ),
    ),
  );
}
