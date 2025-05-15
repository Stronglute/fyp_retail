import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store_model.dart';
import '../providers/store_provider.dart';

class AddStoreScreen extends ConsumerStatefulWidget {
  const AddStoreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends ConsumerState<AddStoreScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _nameController = TextEditingController();
  final _ratingController = TextEditingController();
  final _reviewsController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _enableFacebook = false;
  final _fbPageIdController = TextEditingController();
  final _fbAccessTokenController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _nameController.dispose();
    _ratingController.dispose();
    _reviewsController.dispose();
    _usernameController.dispose();
    _fbPageIdController.dispose();
    _fbAccessTokenController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final category = _categoryController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final name = _nameController.text.trim();
    final rating = double.parse(_ratingController.text.trim());
    final reviews = int.parse(_reviewsController.text.trim());
    final username = _usernameController.text.trim();

    final newStore = Store(
      id: '',
      category: category,
      imageUrl: imageUrl,
      name: name,
      rating: rating,
      reviews: reviews,
      username: username,
      fbPageId: _enableFacebook ? _fbPageIdController.text.trim() : '',
      fbAccessToken:
          _enableFacebook ? _fbAccessTokenController.text.trim() : '',
    );

    try {
      await ref.read(storeServiceProvider).addStore(newStore);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Store created successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating store: $e'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add New Store'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.green[800],
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildInputCard(
                  children: [
                    // Store Name
                    _buildStyledTextField(
                      controller: _nameController,
                      label: 'Store Name',
                      icon: Icons.store,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Enter the store name'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Category
                    _buildStyledTextField(
                      controller: _categoryController,
                      label: 'Categories (comma separated)',
                      icon: Icons.category,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Enter at least one category'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Image URL
                    _buildStyledTextField(
                      controller: _imageUrlController,
                      label: 'Image URL',
                      icon: Icons.image,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Enter an image URL'
                                  : null,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildInputCard(
                  children: [
                    // Rating
                    _buildStyledTextField(
                      controller: _ratingController,
                      label: 'Rating (0.0 - 5.0)',
                      icon: Icons.star,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter a rating';
                        final val = double.tryParse(v);
                        if (val == null || val < 0 || val > 5) {
                          return 'Rating must be between 0 and 5';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Reviews Count
                    _buildStyledTextField(
                      controller: _reviewsController,
                      label: 'Reviews Count',
                      icon: Icons.reviews,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Enter the number of reviews';
                        final val = int.tryParse(v);
                        if (val == null || val < 0)
                          return 'Enter a valid positive number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Username
                    _buildStyledTextField(
                      controller: _usernameController,
                      label: 'Username',
                      icon: Icons.person,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Enter the username'
                                  : null,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Facebook Integration Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(
                            'Enable Facebook Shop',
                            style: TextStyle(color: Colors.green[800]),
                          ),
                          secondary: Icon(
                            Icons.facebook,
                            color: Colors.blue[800],
                          ),
                          value: _enableFacebook,
                          onChanged: (v) => setState(() => _enableFacebook = v),
                          activeColor: Colors.green[400],
                        ),

                        if (_enableFacebook) ...[
                          const SizedBox(height: 10),
                          _buildStyledTextField(
                            controller: _fbPageIdController,
                            label: 'Facebook Page ID',
                            icon: Icons.pages,
                            validator: (v) {
                              if (_enableFacebook && (v == null || v.isEmpty)) {
                                return 'Enter your Page ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildStyledTextField(
                            controller: _fbAccessTokenController,
                            label: 'Facebook Access Token',
                            icon: Icons.security,
                            validator: (v) {
                              if (_enableFacebook && (v == null || v.isEmpty)) {
                                return 'Enter your Access Token';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: Colors.green[200],
                  ),
                  child: const Text(
                    'Create Store',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green[400]!, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.green[600]),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
