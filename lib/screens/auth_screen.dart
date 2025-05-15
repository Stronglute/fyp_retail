import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/animation.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _selectedRole = 'customer';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  // Controllers for all fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _colorAnimation = ColorTween(
      begin: Colors.green[100],
      end: Colors.white,
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        await ref.read(authProvider.notifier).login(email, password);
      } else {
        await ref
            .read(authProvider.notifier)
            .signup(
              _nameController.text.trim(),
              email,
              password,
              _selectedRole,
              _addressController.text.trim(),
              _cityController.text.trim(),
              _countryController.text.trim(),
              _phoneController.text.trim(),
            );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 120,
            right: 20,
            left: 20,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Stack(
        children: [
          // Background elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.1),
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _isLogin ? 'Welcome Back!' : 'Join Us Today!',
                      key: ValueKey<bool>(_isLogin),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black26,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  centerTitle: true,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade800, Colors.green.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Icon(
                          _isLogin ? Icons.login : Icons.person_add,
                          key: ValueKey<bool>(_isLogin),
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                pinned: true,
                elevation: 0,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: _colorAnimation.value,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    if (!_isLogin) ...[
                                      _buildTextField(
                                        controller: _nameController,
                                        label: 'Full Name',
                                        icon: Icons.person_outline,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildRoleDropdown(),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        controller: _addressController,
                                        label: 'Address',
                                        icon: Icons.home_outlined,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        controller: _cityController,
                                        label: 'City',
                                        icon: Icons.location_city_outlined,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        controller: _countryController,
                                        label: 'Country',
                                        icon: Icons.public_outlined,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        controller: _phoneController,
                                        label: 'Phone Number',
                                        icon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    _buildTextField(
                                      controller: _emailController,
                                      label: 'Email',
                                      icon: Icons.email_outlined,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      icon: Icons.lock_outline,
                                      obscureText: true,
                                    ),
                                    const SizedBox(height: 24),
                                    _buildAuthButton(),
                                    const SizedBox(height: 16),
                                    _buildToggleAuthButton(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.green[800],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: Colors.green[700]),
        filled: true,
        fillColor: Colors.green[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      validator:
          validator ??
          (v) {
            if (v == null || v.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Role',
        labelStyle: TextStyle(
          color: Colors.green[800],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(Icons.people_outline, color: Colors.green[700]),
        filled: true,
        fillColor: Colors.green[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      ),
      dropdownColor: Colors.green[50],
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      items:
          ['retail', 'customer'].map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role[0].toUpperCase() + role.substring(1)),
            );
          }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedRole = val);
      },
    );
  }

  Widget _buildAuthButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _submit,
          child: Center(
            child: Text(
              _isLogin ? 'LOGIN' : 'SIGN UP',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleAuthButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: TextButton(
        key: ValueKey<bool>(_isLogin),
        onPressed: () {
          setState(() {
            _isLogin = !_isLogin;
            _animationController.reset();
            _animationController.forward();
          });
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.green[50],
        ),
        child: RichText(
          text: TextSpan(
            text:
                _isLogin
                    ? "Don't have an account? "
                    : 'Already have an account? ',
            style: TextStyle(color: Colors.green[800], fontSize: 15),
            children: [
              TextSpan(
                text: _isLogin ? 'SIGN UP' : 'LOGIN',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
