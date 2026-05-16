import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_provider.dart';
import '../../core/theme/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loc = provider.localization;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('settings')),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'General',
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(loc.tr('language')),
                subtitle: Text(localeToLanguage(provider.localization.locale.languageCode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguagePicker(context, provider),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(loc.tr('notifications')),
                subtitle: const Text('Manage reminder preferences'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showNotificationSettings(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Data',
            children: [
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Offline Data'),
                subtitle: const Text('Manage cached exhibitions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showOfflineDataDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sync Data'),
                subtitle: const Text('Last synced: Just now'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Syncing data...')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Account',
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                subtitle: const Text('Version 1.0.0'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Support',
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help Center'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Send Feedback'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Rate the App'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => provider.signOut(),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text(loc.tr('signOut'), style: const TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showLanguagePicker(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(provider.localization.tr('language')),
        children: [
          SimpleDialogOption(
            onPressed: () {
              provider.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
            child: Text(provider.localization.tr('english')),
          ),
          SimpleDialogOption(
            onPressed: () {
              provider.setLocale(const Locale('ar'));
              Navigator.pop(context);
            },
            child: Text(provider.localization.tr('arabic')),
          ),
          SimpleDialogOption(
            onPressed: () {
              provider.setLocale(const Locale('fr'));
              Navigator.pop(context);
            },
            child: Text(provider.localization.tr('french')),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive alerts for exhibitions'),
              value: true,
              onChanged: (v) {},
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Get weekly digest'),
              value: false,
              onChanged: (v) {},
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showOfflineDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cached exhibitions: 12'),
            const SizedBox(height: 8),
            const Text('Favorites saved offline: 5'),
            const SizedBox(height: 16),
            const Text('Storage used: 2.4 MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clearing offline data...')),
              );
            },
            child: const Text('Clear Cache'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.business_center, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text('FairConnect'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            SizedBox(height: 12),
            Text(
              'Discover global trade exhibitions and transform them into business opportunities.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String localeToLanguage(String code) {
    switch (code) {
      case 'ar':
        return 'Arabic';
      case 'fr':
        return 'French';
      default:
        return 'English';
    }
  }
}