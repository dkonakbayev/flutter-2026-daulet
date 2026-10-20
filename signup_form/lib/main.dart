import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
    ),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthController = TextEditingController();

  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;
    if (!mounted) return;

    setState(() {
      _birth = picked;
      _birthController.text = _formatDate(picked);
    });
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _done = true;
      });
    }
  }

  void _startOver() {
    setState(() {
      _name.clear();
      _email.clear();
      _password.clear();
      _confirm.clear();
      _birthController.clear();

      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _birthController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done
        ? Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SummaryCard(
                      name: _name.text.trim(),
                      email: _email.text.trim(),
                      group: _group ?? '',
                      birthDate: _birthController.text,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _startOver,
                      child: const Text('Start over'),
                    ),
                  ],
                ),
              ),
            ),
          )
        : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _name,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            _emailFocus.requestFocus();
                          },
                          onTapOutside: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if ((v ?? '').trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _email,
                          focusNode: _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          onTapOutside: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'name@kbtu.kz',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final email = (v ?? '').trim();
                            final at = email.indexOf('@');

                            if (at <= 0 ||
                                !email.substring(at + 1).contains('.')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          onTapOutside: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            helperText: '${_password.text.length} of 8',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if ((v ?? '').length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _confirm,
                          obscureText: true,
                          autocorrect: false,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _signUp(),
                          onTapOutside: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          decoration: const InputDecoration(
                            labelText: 'Confirm password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if ((v ?? '') != _password.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          initialValue: _group,
                          decoration: const InputDecoration(
                            labelText: 'Group',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (final group in groups)
                              DropdownMenuItem<String>(
                                value: group,
                                child: Text(group),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _group = value;
                            });
                          },
                          validator: (g) {
                            if (g == null) {
                              return 'Choose a group';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _birthController,
                          readOnly: true,
                          onTap: _pickBirthDate,
                          onTapOutside: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          decoration: const InputDecoration(
                            labelText: 'Date of birth',
                            suffixIcon: Icon(Icons.calendar_month),
                            border: OutlineInputBorder(),
                          ),
                          validator: (_) {
                            if (_birth == null) {
                              return 'Choose your date of birth';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('I agree to the rules'),
                          value: _agreed,
                          onChanged: (value) {
                            setState(() {
                              _agreed = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        FilledButton(
                          onPressed: _agreed ? _signUp : null,
                          child: const Text('Sign up'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
  );
}
