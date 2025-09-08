import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile_model.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class ArtisanProfileScreen extends StatefulWidget {
  const ArtisanProfileScreen({super.key});

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      
      await profileProvider.loadProfile(authProvider.userId!);
      
      if (profileProvider.profile != null) {
        final profile = profileProvider.profile!;
        _businessNameController.text = profile.businessName ?? '';
        _descriptionController.text = profile.description ?? '';
        _addressController.text = profile.address ?? '';
        _phoneController.text = profile.phone ?? '';
        _emailController.text = profile.email ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement du profil: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final profile = ProfileModel(
        id: authProvider.userId!,
        businessName: _businessNameController.text,
        description: _descriptionController.text,
        photos: profileProvider.profile?.photos ?? [],
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
      );
      
      await profileProvider.setProfile(profile);
      
      // Mettre à jour également les informations utilisateur
      if (userProvider.user != null) {
        final updatedUser = userProvider.user!.copyWith(
          name: _businessNameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
        );
        await userProvider.setUser(updatedUser);
      }
      
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil enregistré avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement: $e')),
        );
      }
    }
  }

  Future<void> _addPhoto() async {
    // Dans une vraie application, cela ouvrirait un sélecteur de fichiers
    // Pour cette démonstration, nous simulons l'ajout d'une URL de photo
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    
    // Simuler l'ajout d'une photo (dans une vraie application, cela viendrait d'un fichier)
    final String photoUrl = 'https://via.placeholder.com/300x300.png?text=Photo+${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      await profileProvider.addPhotoToProfile(authProvider.userId!, photoUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo ajoutée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de la photo: $e')),
        );
      }
    }
  }

  Future<void> _removePhoto(String photoUrl) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    
    try {
      await profileProvider.removePhotoFromProfile(authProvider.userId!, photoUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo supprimée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression de la photo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil de l\'artisan'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
          ),
        ],
      ),
      body: profileProvider.isLoading && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'entreprise',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nom de votre entreprise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description des services',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description de vos services';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditing,
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
                    const SizedBox(height: 24),
                    if (_isEditing)
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _saveProfile,
                              child: const Text('Enregistrer'),
                            ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Photos de réalisations',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (_isEditing)
                          IconButton(
                            onPressed: _addPhoto,
                            icon: const Icon(Icons.add_a_photo),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Afficher les photos de réalisations
                    _buildPhotosGrid(profileProvider.profile?.photos ?? []),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPhotosGrid(List<String> photos) {
    if (photos.isEmpty) {
      return const Center(
        child: Text('Aucune photo de réalisation ajoutée'),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: photos.asMap().entries.map((entry) {
        final int index = entry.key;
        final String photoUrl = entry.value;
        
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 50);
                },
              ),
            ),
            if (_isEditing)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                    onPressed: () => _removePhoto(photoUrl),
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}