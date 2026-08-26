import 'package:appwrite/appwrite.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/core/widgets/reveal.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthRepository();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _redirectIfSignedIn();
  }

  Future<void> _redirectIfSignedIn() async {
    final user = await _auth.currentUser();
    if (!mounted) return;
    if (user != null) context.go('/admin');
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _auth.login(username: _username.text, password: _password.text);
      if (!mounted) return;
      context.go('/admin');
    } on AppwriteException catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        final message = error.message?.trim();
        _error = (message != null && message.isNotEmpty)
            ? message
            : 'Sign-in failed. Check the studio username and password.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        final message = error.toString().trim();
        _error = message.isNotEmpty
            ? message
            : 'Sign-in failed. Check the studio username and password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BiConcept',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 28,
                      color: BcColors.ivory,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Kicker('Studio console'),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _username,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(labelText: 'USERNAME'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Username required.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(labelText: 'PASSWORD'),
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Password required.' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: BcColors.danger)),
                  ],
                  const SizedBox(height: 28),
                  GoldButton(
                    label: _busy ? 'Signing in…' : 'Enter console',
                    onPressed: _busy ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
