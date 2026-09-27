import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/providers/auth_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploadingPhoto = false;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isUploadingPhoto = true);

      bool success;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        success = await ref
            .read(authControllerProvider.notifier)
            .uploadProfilePictureBytes(bytes);
      } else {
        success = await ref
            .read(authControllerProvider.notifier)
            .uploadProfilePictureFile(File(picked.path));
      }

      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        _showSnack(
          success
              ? 'Profile picture updated successfully!'
              : 'Failed to upload profile picture. Please try again.',
          isError: !success,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        _showSnack('Error picking image: $e', isError: true);
      }
    }
  }

  void _showPhotoOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: PennyPalColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PennyPalColors.muted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PennyPalColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: PennyPalColors.elevated,
                    child: AppIcon(
                      AppIcons.image,
                      size: 20,
                      color: PennyPalColors.white,
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      color: PennyPalColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: PennyPalColors.elevated,
                    child: AppIcon(
                      AppIcons.edit,
                      size: 20,
                      color: PennyPalColors.white,
                    ),
                  ),
                  title: const Text(
                    'Take a Photo (Camera)',
                    style: TextStyle(
                      color: PennyPalColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (ref.read(currentUserProvider)?.photoUrl != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: PennyPalColors.dangerSurface,
                      child: AppIcon(
                        AppIcons.delete,
                        size: 20,
                        color: PennyPalColors.danger,
                      ),
                    ),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(
                        color: PennyPalColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      setState(() => _isUploadingPhoto = true);
                      await ref
                          .read(authControllerProvider.notifier)
                          .updateProfile(photoUrl: '');
                      if (mounted) {
                        setState(() => _isUploadingPhoto = false);
                        _showSnack('Profile picture removed.');
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileSheet() {
    HapticFeedback.lightImpact();
    final user = ref.read(currentUserProvider);
    final firstCtrl = TextEditingController(text: user?.firstName ?? '');
    final lastCtrl = TextEditingController(text: user?.lastName ?? '');
    final phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    final instCtrl = TextEditingController(text: user?.institution ?? '');
    final bioCtrl = TextEditingController(text: user?.bio ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PennyPalColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: PennyPalColors.muted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: PennyPalColors.white,
                          ),
                        ),
                        IconButton(
                          icon: const AppIcon(
                            AppIcons.close,
                            size: 18,
                            color: PennyPalColors.muted,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _FormField(
                            label: 'First Name',
                            controller: firstCtrl,
                            hint: 'First name',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FormField(
                            label: 'Last Name',
                            controller: lastCtrl,
                            hint: 'Last name',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _FormField(
                      label: 'Phone Number',
                      controller: phoneCtrl,
                      hint: '+234 800 000 0000',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _FormField(
                      label: 'University / Institution',
                      controller: instCtrl,
                      hint: 'e.g. UNILAG, FUTA, UI, Covenant Univ',
                    ),
                    const SizedBox(height: 14),
                    _FormField(
                      label: 'Bio / Note',
                      controller: bioCtrl,
                      hint: 'e.g. 300L Computer Science student saving for rent',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PennyPalColors.white,
                          foregroundColor: PennyPalColors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                setSheetState(() => isSaving = true);
                                final success = await ref
                                    .read(authControllerProvider.notifier)
                                    .updateProfile(
                                      firstName: firstCtrl.text.trim(),
                                      lastName: lastCtrl.text.trim(),
                                      phoneNumber: phoneCtrl.text.trim(),
                                      institution: instCtrl.text.trim(),
                                      bio: bioCtrl.text.trim(),
                                    );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  _showSnack(
                                    success
                                        ? 'Profile updated successfully!'
                                        : 'Failed to update profile.',
                                    isError: !success,
                                  );
                                }
                              },
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: PennyPalColors.black,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: PennyPalColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: PennyPalColors.border),
          ),
          title: const Row(
            children: [
              AppIcon(
                AppIcons.warning,
                color: PennyPalColors.gray,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Deactivate Profile',
                style: TextStyle(
                  color: PennyPalColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          content: const Text(
            'Deactivating your account will temporarily disable your profile and log you out. Your financial transactions and savings data will remain securely saved in Firebase, and you can reactivate anytime by logging back in.',
            style: TextStyle(
              color: PennyPalColors.lightGray,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: PennyPalColors.gray),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PennyPalColors.elevated,
                foregroundColor: PennyPalColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: PennyPalColors.border),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                final success = await ref
                    .read(authControllerProvider.notifier)
                    .deactivateAccount();
                if (mounted && !success) {
                  _showSnack('Failed to deactivate profile.', isError: true);
                }
              },
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: PennyPalColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: PennyPalColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red header banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: const BoxDecoration(
                    color: PennyPalColors.dangerSurface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: PennyPalColors.danger.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: PennyPalColors.danger.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const AppIcon(
                          AppIcons.delete,
                          color: PennyPalColors.danger,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Delete Account?',
                        style: TextStyle(
                          color: PennyPalColors.danger,
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Body
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 7-day recovery notice
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: PennyPalColors.elevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: PennyPalColors.mutedBorder),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppIcon(
                              AppIcons.info,
                              size: 18,
                              color: PennyPalColors.white,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '7-Day Recovery Window',
                                    style: TextStyle(
                                      color: PennyPalColors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Your account will be scheduled for deletion. You can recover it by logging back in within 7 days. After that, all data is permanently removed.',
                                    style: TextStyle(
                                      color: PennyPalColors.lightGray,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'What gets deleted after 7 days:',
                        style: TextStyle(
                          color: PennyPalColors.gray,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const _DeleteBullet('Profile & account information'),
                      const _DeleteBullet('All budgets and spending plans'),
                      const _DeleteBullet('Savings goals and progress'),
                      const _DeleteBullet('Transaction history'),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PennyPalColors.danger,
                            foregroundColor: PennyPalColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            final success = await ref
                                .read(authControllerProvider.notifier)
                                .deleteAccount();
                            if (mounted && !success) {
                              _showSnack(
                                'Could not schedule account deletion. Please log out and try again.',
                                isError: true,
                              );
                            }
                          },
                          child: const Text(
                            'Schedule Deletion',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Keep My Account',
                            style: TextStyle(
                              color: PennyPalColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            isError ? PennyPalColors.dangerSurface : PennyPalColors.elevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isError ? PennyPalColors.danger : PennyPalColors.border,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isError ? PennyPalColors.danger : PennyPalColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final name = user?.fullName ?? 'Student';
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : 'S';

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile & Account',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: PennyPalColors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const AppIcon(
              AppIcons.edit,
              color: PennyPalColors.white,
              size: 20,
            ),
            onPressed: _showEditProfileSheet,
          ),
        ],
        iconTheme: const IconThemeData(color: PennyPalColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 50),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Profile Picture with Camera Edit Badge
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PennyPalColors.elevated,
                        border: Border.all(
                          color: PennyPalColors.border,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                            ? Image.network(
                                user.photoUrl!,
                                fit: BoxFit.cover,
                                width: 96,
                                height: 96,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: PennyPalColors.white,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: PennyPalColors.white,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: PennyPalColors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (_isUploadingPhoto)
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: PennyPalColors.white,
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: PennyPalColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: PennyPalColors.black,
                            width: 2,
                          ),
                        ),
                        child: const AppIcon(
                          AppIcons.image,
                          size: 14,
                          color: PennyPalColors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // User Name & Email
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: PennyPalColors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 13.5, color: PennyPalColors.gray),
            ),
            if (user?.institution != null && user!.institution!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: PennyPalColors.elevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PennyPalColors.mutedBorder),
                ),
                child: Text(
                  user.institution!,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: PennyPalColors.lightGray,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),

            // Quick Edit Button
            SizedBox(
              width: 140,
              height: 38,
              child: OutlinedButton.icon(
                onPressed: _showEditProfileSheet,
                style: OutlinedButton.styleFrom(
                  backgroundColor: PennyPalColors.surface,
                  side: const BorderSide(color: PennyPalColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                icon: const AppIcon(
                  AppIcons.edit,
                  size: 14,
                  color: PennyPalColors.white,
                ),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: PennyPalColors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Personal Information Section
            _InfoSection(
              title: 'Personal Information',
              items: [
                _InfoRow(label: 'Full Name', value: name),
                _InfoRow(label: 'Email Address', value: user?.email ?? '—'),
              ],
            ),
            const SizedBox(height: 20),

            // Account Status Section
            _InfoSection(
              title: 'Account Details',
              items: [
                _InfoRow(
                  label: 'Account Status',
                  value: user?.isDeactivated == true ? 'Deactivated' : 'Active ✓',
                  valueColor: user?.isDeactivated == true
                      ? PennyPalColors.danger
                      : PennyPalColors.success,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Account Actions
            _InfoSection(
              title: 'Account Settings',
              items: [
                _ActionRow(
                  icon: AppIcons.lockCheck,
                  label: 'Deactivate Account',
                  subtitle: 'Temporarily hide profile and sign out',
                  onTap: _showDeactivateDialog,
                ),
                _ActionRow(
                  icon: AppIcons.delete,
                  label: 'Delete Account',
                  subtitle: 'Schedule account deletion — recoverable within 7 days',
                  isDanger: true,
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Log Out Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(authControllerProvider.notifier).logout();
                },
                icon: const AppIcon(
                  AppIcons.logout,
                  color: PennyPalColors.white,
                  size: 18,
                ),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: PennyPalColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: PennyPalColors.card,
                  side: const BorderSide(color: PennyPalColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: PennyPalColors.lightGray,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: PennyPalColors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: PennyPalColors.muted, fontSize: 13),
            filled: true,
            fillColor: PennyPalColors.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: PennyPalColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: PennyPalColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: PennyPalColors.white, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.items});
  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: PennyPalColors.muted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: PennyPalColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PennyPalColors.border),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: PennyPalColors.mutedBorder,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13.5, color: PennyPalColors.gray),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: valueColor ?? PennyPalColors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
  });

  final List<List<dynamic>> icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isDanger
                  ? PennyPalColors.dangerSurface
                  : PennyPalColors.elevated,
              child: AppIcon(
                icon,
                size: 16,
                color: isDanger ? PennyPalColors.danger : PennyPalColors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDanger
                          ? PennyPalColors.danger
                          : PennyPalColors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: PennyPalColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const AppIcon(
              AppIcons.chevronRight,
              size: 16,
              color: PennyPalColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteBullet extends StatelessWidget {
  const _DeleteBullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: CircleAvatar(
              radius: 3,
              backgroundColor: PennyPalColors.danger,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: PennyPalColors.lightGray,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
