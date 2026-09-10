import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tourney_app/widgets/court_widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    for (final controller in [
      _emailController,
      _passwordController,
      _nameController,
      _firstNameController,
      _lastNameController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      final uid = credential.user!.uid;
      await FirebaseFirestore.instance.collection('players').doc(uid).set({
        'id': uid,
        'email': _emailController.text.trim(),
        'fname': _firstNameController.text.trim(),
        'lname': _lastNameController.text.trim(),
        'name': _nameController.text.trim(),
        'rating': 0,
        'isAdmin': false,
        'globalStats': {
          'matchesPlayed': 0,
          'wins': 0,
          'losses': 0,
          'tournamentsPlayed': 0,
        },
      });
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Unable to create your account.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save your profile. Please check your connection.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _nameField(
    TextEditingController controller,
    String label,
    String autofillHint,
  ) => TextFormField(
    controller: controller,
    textCapitalization: TextCapitalization.words,
    textInputAction: TextInputAction.next,
    autofillHints: [autofillHint],
    decoration: InputDecoration(labelText: label),
    validator: (value) => value == null || value.trim().isEmpty
        ? 'Enter your ${label.toLowerCase()}'
        : null,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('JOIN THE COMMUNITY')),
    body: CourtAuthLayout(
      title: 'You’re up next.',
      subtitle: 'Create your player profile to get started.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _nameField(
                _firstNameController,
                'First name',
                AutofillHints.givenName,
              ),
              const SizedBox(height: 16),
              _nameField(
                _lastNameController,
                'Last name',
                AutofillHints.familyName,
              ),
              const SizedBox(height: 16),
              _nameField(
                _nameController,
                'Player name',
                AutofillHints.nickname,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: (value) =>
                    value == null || !value.trim().contains('@')
                    ? 'Enter a valid email address'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: (_) => _signup(),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  helperText: 'At least 6 characters',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) => value == null || value.trim().length < 6
                    ? 'Use at least 6 characters'
                    : null,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _isLoading ? null : _signup,
                child: Text(
                  _isLoading ? 'Creating your account…' : 'Create account',
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Already a member? Sign in'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
