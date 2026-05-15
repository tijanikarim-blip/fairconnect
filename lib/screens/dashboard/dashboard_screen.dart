import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_provider.dart';
import '../../widgets/exhibition_card.dart';
import '../detail/exhibition_detail_screen.dart';
import '../search/search_screen.dart';
import '../favorites/favorites_screen.dart';
import '../subscription/subscription_screen.dart';
import '../admin/admin_screen.dart';
import '../organizer/organizer_portal_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final _screens = const [
    _ExhibitionsTab(),
    SearchScreen(),
    FavoritesScreen(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FairConnect'),
        actions: [
          if (_currentIndex == 3)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminScreen()),
              ),
            ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ExhibitionsTab extends StatelessWidget {
  const _ExhibitionsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final exhibitions = provider.exhibitions;

    if (exhibitions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No exhibitions yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back soon for upcoming trade shows',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final upcoming =
        exhibitions.where((e) => e.isUpcoming || e.isOngoing).toList();
    final featured =
        exhibitions.where((e) => e.isFeatured && (e.isUpcoming || e.isOngoing)).toList();

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      children: [
        if (featured.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Featured Exhibitions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 12, right: 4),
              itemCount: featured.length,
              itemBuilder: (context, index) {
                final e = featured[index];
                return SizedBox(
                  width: 280,
                  child: ExhibitionCard(
                    exhibition: e,
                    isFavorite: provider.isFavorite(e.id),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExhibitionDetailScreen(exhibitionId: e.id),
                      ),
                    ),
                    onFavoriteToggle: () => provider.toggleFavorite(e.id),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Upcoming Exhibitions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        ...upcoming.map((exhibition) {
          final isFav = provider.isFavorite(exhibition.id);
          return ExhibitionCard(
            exhibition: exhibition,
            isFavorite: isFav,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ExhibitionDetailScreen(exhibitionId: exhibition.id),
              ),
            ),
            onFavoriteToggle: () => provider.toggleFavorite(exhibition.id),
          );
        }),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final loc = provider.localization;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        CircleAvatar(
          radius: 48,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.displayName ?? user?.email ?? 'Guest',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (user?.isPremiumValid == true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber),
            ),
            child: Text(
              '${loc.tr('premiumExpires')}: ${_formatDate(user!.premiumExpiry!)}',
              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600),
            ),
          ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.subscriptions),
          title: Text(loc.tr('subscribeTitle')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.assignment_turned_in),
          title: const Text('Organizer Portal'),
          subtitle: const Text('Claim & manage your exhibitions'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrganizerPortalScreen()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(loc.tr('language')),
          subtitle: Text(loc.tr(localeToLanguage(loc.locale.languageCode))),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguagePicker(context, provider),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text(loc.tr('signOut'),
              style: const TextStyle(color: Colors.red)),
          onTap: () => provider.signOut(),
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

  String localeToLanguage(String code) {
    switch (code) {
      case 'ar':
        return 'arabic';
      case 'fr':
        return 'french';
      default:
        return 'english';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
