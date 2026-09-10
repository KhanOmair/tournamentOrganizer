import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tourney_app/widgets/court_widgets.dart';
import 'signup_page.dart';

Future<void> sendResetEmailQuick(String email) =>
    FirebaseAuth.instance.sendPasswordResetEmail(
      email: email.trim(),
      actionCodeSettings: ActionCodeSettings(
        url: 'https://khanomair.github.io/tournamentOrganizer/',
        handleCodeInApp: false,
      ),
    );

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSendingReset = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // AuthGate owns navigation when the signed-in user changes.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Unable to sign in. Please try again.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to sign in. Please check your connection.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your email address to reset your password.'),
        ),
      );
      return;
    }
    setState(() => _isSendingReset = true);
    try {
      await sendResetEmailQuick(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your email for a password reset link.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Could not send reset email.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not send reset email. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingReset = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CourtAuthLayout(
      title: 'Welcome back.',
      subtitle: 'Sign in to follow your community’s tournaments.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: (value) =>
                    value == null || !value.trim().contains('@')
                    ? 'Enter a valid email address'
                    : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => loginUser(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _showPassword ? 'Hide password' : 'Show password',
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your password'
                    : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isSendingReset ? null : _sendPasswordResetEmail,
                  child: Text(
                    _isSendingReset
                        ? 'Sending reset link…'
                        : 'Forgot password?',
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _isLoading ? null : loginUser,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward, size: 18),
                label: Text(_isLoading ? 'Signing in…' : 'Sign in'),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      ),
                child: const Text('New here? Create an account'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
