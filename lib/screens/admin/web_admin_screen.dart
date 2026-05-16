import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_provider.dart';
import 'panels/exhibitions_panel.dart';
import 'panels/users_panel.dart';
import 'panels/crawler_panel.dart';

class WebAdminScreen extends StatefulWidget {
  const WebAdminScreen({super.key});

  @override
  State<WebAdminScreen> createState() => _WebAdminScreenState();
}

class _WebAdminScreenState extends State<WebAdminScreen> {
  int _selectedIndex = 0;

  final _panels = const [
    _DashboardPanel(),
    ExhibitionsPanel(),
    UsersPanel(),
    CrawlerPanel(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: _panels[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _Sidebar({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF010E27),
            Color(0xFF0B1C39),
            Color(0xFF03215A),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Row(
            children: [
              const SizedBox(width: 20),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_month_rounded, size: 22, color: Color(0xFF8EC8FF)),
              ),
              const SizedBox(width: 12),
              const Text(
                'FairConnect',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 72),
            child: Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.4),
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _NavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            index: 0,
            selectedIndex: selectedIndex,
            onTap: onItemSelected,
          ),
          _NavItem(
            icon: Icons.business,
            label: 'Exhibitions',
            index: 1,
            selectedIndex: selectedIndex,
            onTap: onItemSelected,
          ),
          _NavItem(
            icon: Icons.people,
            label: 'Users',
            index: 2,
            selectedIndex: selectedIndex,
            onTap: onItemSelected,
          ),
          _NavItem(
            icon: Icons.travel_explore,
            label: 'Crawler',
            index: 3,
            selectedIndex: selectedIndex,
            onTap: onItemSelected,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'FairConnect v1.0',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: isSelected ? const Color(0xFF6A9FFF) : Colors.white.withValues(alpha: 0.5), size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () => onTap(index),
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final exhibitions = provider.exhibitions;
    final total = exhibitions.length;
    final featured = exhibitions.where((e) => e.isFeatured).length;
    final premium = exhibitions.where((e) => e.isPremium).length;
    final upcoming = exhibitions.where((e) => e.isUpcoming || e.isOngoing).length;

    return Container(
      color: const Color(0xFF0A0E1A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1A2332), width: 1)),
            ),
            child: Row(
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _StatCard('Total Exhibitions', total.toString(), Icons.business, const Color(0xFF2C58BC)),
                  _StatCard('Featured', featured.toString(), Icons.star, const Color(0xFFD4A837)),
                  _StatCard('Premium', premium.toString(), Icons.workspace_premium, const Color(0xFF8B5CF6)),
                  _StatCard('Upcoming', upcoming.toString(), Icons.event, const Color(0xFF10B981)),
                  _StatCard('Users', '-', Icons.people, const Color(0xFFF59E0B)),
                  _StatCard('Organizer Claims', '-', Icons.assignment_turned_in, const Color(0xFF3B82F6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
