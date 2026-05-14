import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/exhibition.dart';
import '../../models/organizer_claim.dart';
import '../../services/app_provider.dart';
import '../../services/firestore_service.dart';

class OrganizerPortalScreen extends StatefulWidget {
  const OrganizerPortalScreen({super.key});

  @override
  State<OrganizerPortalScreen> createState() => _OrganizerPortalScreenState();
}

class _OrganizerPortalScreenState extends State<OrganizerPortalScreen> {
  final FirestoreService _firestore = FirestoreService();
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Organizer Portal')),
        body: const Center(child: Text('Please sign in to access the portal')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Portal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF1A237E)),
                      const SizedBox(width: 8),
                      Text('Claim an Exhibition',
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Are you an exhibition organizer? Claim your event to update details, add media, and manage your listing.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showClaimForm(context, provider),
                      icon: const Icon(Icons.assignment_turned_in),
                      label: const Text('Claim Your Exhibition'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Browse Exhibitions to Claim',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildExhibitionList(context, provider),
        ],
      ),
    );
  }

  Widget _buildExhibitionList(BuildContext context, AppProvider provider) {
    return StreamBuilder(
      stream: _firestore.getExhibitions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final exhibitions = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: exhibitions.length,
          itemBuilder: (context, index) {
            final e = exhibitions[index];
            return ListTile(
              leading: const Icon(Icons.business),
              title: Text(e.name),
              subtitle: Text('${e.city}, ${e.country}'),
              trailing: TextButton(
                onPressed: () => _showClaimForm(context, provider, exhibition: e),
                child: const Text('Claim'),
              ),
            );
          },
        );
      },
    );
  }

  void _showClaimForm(BuildContext context, AppProvider provider,
      {Exhibition? exhibition}) {
    final companyCtrl = TextEditingController();
    final emailCtrl =
        TextEditingController(text: provider.currentUser?.email ?? '');
    final phoneCtrl = TextEditingController();
    final websiteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Claim: ${exhibition?.name ?? "Exhibition"}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: companyCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Company Name *')),
              TextField(
                  controller: emailCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Contact Email *')),
              TextField(
                  controller: phoneCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Phone Number')),
              TextField(
                  controller: websiteCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Company Website')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (companyCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;

              final claim = OrganizerClaim(
                id: _uuid.v4(),
                exhibitionId: exhibition?.id ?? '',
                userId: provider.currentUser!.id,
                companyName: companyCtrl.text,
                contactEmail: emailCtrl.text,
                phone: phoneCtrl.text.isNotEmpty ? phoneCtrl.text : null,
                website: websiteCtrl.text.isNotEmpty ? websiteCtrl.text : null,
              );

              await _firestore.addOrganizerClaim(claim);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Claim submitted! Admin will review it shortly.')),
                );
              }
            },
            child: const Text('Submit Claim'),
          ),
        ],
      ),
    );
  }
}
