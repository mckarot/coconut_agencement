import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;
  UserRole _selectedRole = UserRole.client; // Default role

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      UserModel? user;

      if (_isLogin) {
        final userCredential = await authProvider.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (userCredential.user != null) {
          user = await userProvider.getUserById(userCredential.user!.uid);
          if (user != null) {
            await userProvider.setUser(user);
          } else {
            throw Exception("Impossible de trouver les données de l'utilisateur.");
          }
        } else {
          throw Exception("La connexion a échoué.");
        }

      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          setState(() {
            _errorMessage = 'Les mots de passe ne correspondent pas';
            _isLoading = false;
          });
          return;
        }

        // Register the user
        final userCredential = await authProvider.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Check if user is not null
        if (userCredential.user != null) {
          // Create user profile
          user = UserModel(
            id: userCredential.user!.uid,
            email: _emailController.text.trim(),
            role: _selectedRole,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
          );

          await userProvider.setUser(user);
        } else {
          throw Exception('Failed to create user account');
        }
      }

      if (mounted && user != null) {
        if (user.role == UserRole.artisan) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/client-home');
        }
      }

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Connexion' : 'Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                if (!_isLogin) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom complet';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  // Role selection
                  const Text(
                    'Sélectionnez votre rôle :',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Client'),
                          leading: Radio<UserRole>(
                            value: UserRole.client,
                            groupValue: _selectedRole,
                            onChanged: (UserRole? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('Artisan'),
                          leading: Radio<UserRole>(
                            value: UserRole.artisan,
                            groupValue: _selectedRole,
                            onChanged: (UserRole? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(_isLogin ? 'Se connecter' : 'S\'inscrire'),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _errorMessage = null;
                    });
                  },
                  child: Text(_isLogin
                      ? 'Pas de compte ? Inscrivez-vous'
                      : 'Déjà un compte ? Connectez-vous'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}