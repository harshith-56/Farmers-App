import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/session_service.dart';
import '../services/api_service.dart';
import '../localization/translator.dart';
import '../providers/language_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String phone = "";
  String selectedLanguage = "en";

  bool isLoading = true;
  bool isSaving = false;
  bool isChangingPassword = false;

  String? errorMessage;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionService.getUser();

    setState(() {
      nameController.text = user["name"] ?? "";
      phoneController.text = user["phone"] ?? "";
      phone = user["phone"] ?? "";
      selectedLanguage = user["language"] ?? "en";
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t(context, "profile")),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _profileCard(),
            const SizedBox(height: 24),
            _securityCard(),
          ],
        ),
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.greenAccent,
            child: Icon(Icons.person, size: 36, color: Colors.green),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: t(context, "name"),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: phoneController,
            enabled: false,
            decoration: InputDecoration(
              labelText: t(context, "phone"),
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: selectedLanguage,
            decoration: InputDecoration(
              labelText: t(context, "language"),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.language),
            ),
            items: [
              DropdownMenuItem(value: "en", child: Text(t(context, "english"))),
              DropdownMenuItem(value: "te", child: Text(t(context, "telugu"))),
              DropdownMenuItem(value: "hi", child: Text(t(context, "hindi"))),
            ],
            onChanged: (value) {
              setState(() {
                selectedLanguage = value!;
              });
            },
          ),
          const SizedBox(height: 20),

          if (errorMessage != null)
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isSaving ? null : _saveProfile,
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(t(context, "save_changes")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _securityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(context, "security"),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openChangePasswordDialog,
              icon: const Icon(Icons.lock_outline),
              label: Text(t(context, "change_password")),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      setState(() {
        errorMessage = t(context, "name_empty");
      });
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    final result = await ApiService.updateProfile(
      phone: phone,
      name: nameController.text.trim(),
      language: selectedLanguage,
    );

    setState(() {
      isSaving = false;
    });

    if (result["success"] == true) {
      await SessionService.updateName(result["name"]);
      await context.read<LanguageProvider>().changeLanguage(result["language"]);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(context, "profile_updated"))),
      );
    } else {
      setState(() {
        errorMessage = result["message"];
      });
    }
  }

  void _openChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(t(context, "change_password")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: t(context, "current_password")),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: t(context, "new_password")),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: t(context, "confirm_password")),
                  ),
                  const SizedBox(height: 12),
                  if (passwordError != null)
                    Text(passwordError!, style: const TextStyle(color: Colors.red)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t(context, "cancel")),
                ),
                ElevatedButton(
                  onPressed: isChangingPassword ? null : () async {
                    setDialogState(() {
                      isChangingPassword = true;
                      passwordError = null;
                    });

                    try {
                      if (newPasswordController.text.trim() != confirmPasswordController.text.trim()) {
                        throw t(context, "passwords_not_match");
                      }

                      final result = await ApiService.changePassword(
                        phone: phone,
                        currentPassword: currentPasswordController.text.trim(),
                        newPassword: newPasswordController.text.trim(),
                      );

                      if (result["success"] == true) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t(context, "password_updated"))),
                        );
                      } else {
                        throw result["message"];
                      }
                    } catch (e) {
                      setDialogState(() {
                        passwordError = e.toString();
                      });
                    } finally {
                      setDialogState(() {
                        isChangingPassword = false;
                      });
                    }
                  },
                  child: isChangingPassword
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : Text(t(context, "update")),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
