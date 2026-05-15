import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/exhibition.dart';
import '../../services/firestore_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirestoreService _firestore = FirestoreService();
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'import',
            onPressed: () => _importCsv(context),
            child: const Icon(Icons.file_upload),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => _showExhibitionForm(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore.getExhibitions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final exhibitions = snapshot.data!;

          if (exhibitions.isEmpty) {
            return const Center(
              child: Text('No exhibitions yet. Tap + to add one.'),
            );
          }

          return ListView.builder(
            itemCount: exhibitions.length,
            itemBuilder: (context, index) {
              final exhibition = exhibitions[index];
              return ListTile(
                leading: Icon(
                  exhibition.isPremium ? Icons.workspace_premium : Icons.business,
                  color: exhibition.isPremium ? Colors.amber : null,
                ),
                title: Text(exhibition.name),
                subtitle: Text(
                    '${exhibition.country} • ${exhibition.industries.join(', ')} | ${exhibition.exhibitorsCount ?? "?"} exhibitors'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showExhibitionForm(context, exhibition: exhibition),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _confirmDelete(context, exhibition),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _importCsv(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final lines = await file.readAsLines();
      if (lines.length < 2) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CSV must have a header row and at least one data row')),
          );
        }
        return;
      }

      final headers = lines[0].split(',').map((h) => h.trim().toLowerCase()).toList();
      int count = 0;

      for (int i = 1; i < lines.length; i++) {
        final row = _parseCsvRow(lines[i]);
        if (row.length != headers.length) continue;

        final data = <String, String>{};
        for (int j = 0; j < headers.length; j++) {
          data[headers[j]] = row[j].trim();
        }

        final exhibition = Exhibition(
          id: _uuid.v4(),
          name: data['name'] ?? '',
          nameAr: data['name_ar'] ?? data['namear'] ?? '',
          nameFr: data['name_fr'] ?? data['namefr'] ?? '',
          description: data['description'] ?? '',
          descriptionAr: data['description_ar'] ?? data['descriptionar'] ?? '',
          descriptionFr: data['description_fr'] ?? data['descriptionfr'] ?? '',
          industries: _parseList(data['industries'] ?? data['industry'] ?? ''),
          country: data['country'] ?? '',
          city: data['city'] ?? '',
          startDate: _parseDate(data['start_date'] ?? data['startdate'] ?? DateTime.now().toIso8601String()),
          endDate: _parseDate(data['end_date'] ?? data['enddate'] ?? DateTime.now().toIso8601String()),
          venue: data['venue'] ?? '',
          images: _parseList(data['images'] ?? data['image_url'] ?? data['imageurl'] ?? ''),
          youtubeVideoId: data['youtube_video_id'] ?? data['youtubevideoid'] ?? data['youtubevideoId'],
          registrationUrl: data['registration_url'] ?? data['registrationurl'] ?? '',
          organizer: data['organizer'] ?? '',
          website: data['official_website'] ?? data['website'] ?? data['officialwebsite'],
          exhibitorsCount: int.tryParse(data['exhibitors_count'] ?? data['exhibitorscount'] ?? ''),
          visitorsCount: int.tryParse(data['visitors_count'] ?? data['visitorscount'] ?? ''),
          tags: _parseList(data['tags'] ?? ''),
          languages: _parseList(data['languages'] ?? ''),
          isPremium: data['is_premium']?.toLowerCase() == 'true' || data['ispremium']?.toLowerCase() == 'true',
          isFeatured: data['is_featured']?.toLowerCase() == 'true' || data['isfeatured']?.toLowerCase() == 'true',
        );

        await _firestore.addExhibition(exhibition);
        count++;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported $count exhibitions successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import error: $e')),
        );
      }
    }
  }

  List<String> _parseList(String value) {
    if (value.isEmpty) return [];
    return value.split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  DateTime _parseDate(String value) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  List<String> _parseCsvRow(String line) {
    final result = <String>[];
    bool inQuotes = false;
    final current = StringBuffer();
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }

  void _showExhibitionForm(BuildContext context, {Exhibition? exhibition}) {
    final nameCtrl = TextEditingController(text: exhibition?.name ?? '');
    final nameArCtrl = TextEditingController(text: exhibition?.nameAr ?? '');
    final nameFrCtrl = TextEditingController(text: exhibition?.nameFr ?? '');
    final slugCtrl = TextEditingController(text: exhibition?.slug ?? '');
    final descCtrl = TextEditingController(text: exhibition?.description ?? '');
    final descArCtrl = TextEditingController(text: exhibition?.descriptionAr ?? '');
    final descFrCtrl = TextEditingController(text: exhibition?.descriptionFr ?? '');
    final industriesCtrl = TextEditingController(text: exhibition?.industries.join('; ') ?? '');
    final countryCtrl = TextEditingController(text: exhibition?.country ?? '');
    final cityCtrl = TextEditingController(text: exhibition?.city ?? '');
    final venueCtrl = TextEditingController(text: exhibition?.venue ?? '');
    final imagesCtrl = TextEditingController(text: exhibition?.images.join('; ') ?? '');
    final organizerCtrl = TextEditingController(text: exhibition?.organizer ?? '');
    final regUrlCtrl = TextEditingController(text: exhibition?.registrationUrl ?? '');
    final websiteCtrl = TextEditingController(text: exhibition?.website ?? '');
    final youtubeCtrl = TextEditingController(text: exhibition?.youtubeVideoId ?? '');
    final exhibitorsCtrl = TextEditingController(
        text: exhibition?.exhibitorsCount?.toString() ?? '');
    final visitorsCtrl = TextEditingController(
        text: exhibition?.visitorsCount?.toString() ?? '');
    final tagsCtrl = TextEditingController(text: exhibition?.tags.join('; ') ?? '');
    final languagesCtrl = TextEditingController(text: exhibition?.languages.join('; ') ?? '');

    DateTime startDate = exhibition?.startDate ?? DateTime.now();
    DateTime endDate = exhibition?.endDate ?? DateTime.now().add(const Duration(days: 3));
    bool isPremium = exhibition?.isPremium ?? false;
    bool isFeatured = exhibition?.isFeatured ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(exhibition != null ? 'Edit Exhibition' : 'Add Exhibition'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (EN)')),
                TextField(controller: nameArCtrl, decoration: const InputDecoration(labelText: 'Name (AR)')),
                TextField(controller: nameFrCtrl, decoration: const InputDecoration(labelText: 'Name (FR)')),
                TextField(controller: slugCtrl, decoration: const InputDecoration(labelText: 'Slug (auto)')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description (EN)'), maxLines: 2),
                TextField(controller: descArCtrl, decoration: const InputDecoration(labelText: 'Description (AR)'), maxLines: 2),
                TextField(controller: descFrCtrl, decoration: const InputDecoration(labelText: 'Description (FR)'), maxLines: 2),
                TextField(controller: industriesCtrl, decoration: const InputDecoration(labelText: 'Industries (separate with ;)')),
                TextField(controller: countryCtrl, decoration: const InputDecoration(labelText: 'Country')),
                TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City')),
                TextField(controller: venueCtrl, decoration: const InputDecoration(labelText: 'Venue')),
                TextField(controller: organizerCtrl, decoration: const InputDecoration(labelText: 'Organizer')),
                TextField(controller: regUrlCtrl, decoration: const InputDecoration(labelText: 'Registration URL')),
                TextField(controller: websiteCtrl, decoration: const InputDecoration(labelText: 'Website URL')),
                TextField(controller: youtubeCtrl, decoration: const InputDecoration(labelText: 'YouTube Video ID')),
                TextField(controller: imagesCtrl, decoration: const InputDecoration(labelText: 'Image URLs (separate with ;)')),
                TextField(controller: exhibitorsCtrl, decoration: const InputDecoration(labelText: 'Exhibitors Count'), keyboardType: TextInputType.number),
                TextField(controller: visitorsCtrl, decoration: const InputDecoration(labelText: 'Visitors Count'), keyboardType: TextInputType.number),
                TextField(controller: tagsCtrl, decoration: const InputDecoration(labelText: 'Tags (separate with ;)')),
                TextField(controller: languagesCtrl, decoration: const InputDecoration(labelText: 'Languages (separate with ;)')),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Start Date'),
                  trailing: Text('${startDate.day}/${startDate.month}/${startDate.year}'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context, initialDate: startDate,
                      firstDate: DateTime(2020), lastDate: DateTime(2035),
                    );
                    if (picked != null) setDialogState(() => startDate = picked);
                  },
                ),
                ListTile(
                  title: const Text('End Date'),
                  trailing: Text('${endDate.day}/${endDate.month}/${endDate.year}'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context, initialDate: endDate,
                      firstDate: DateTime(2020), lastDate: DateTime(2035),
                    );
                    if (picked != null) setDialogState(() => endDate = picked);
                  },
                ),
                CheckboxListTile(title: const Text('Premium'), value: isPremium,
                    onChanged: (v) => setDialogState(() => isPremium = v ?? false)),
                CheckboxListTile(title: const Text('Featured'), value: isFeatured,
                    onChanged: (v) => setDialogState(() => isFeatured = v ?? false)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final data = Exhibition(
                  id: exhibition?.id ?? _uuid.v4(),
                  name: nameCtrl.text,
                  nameAr: nameArCtrl.text,
                  nameFr: nameFrCtrl.text,
                  slug: slugCtrl.text.isNotEmpty ? slugCtrl.text : null,
                  description: descCtrl.text,
                  descriptionAr: descArCtrl.text,
                  descriptionFr: descFrCtrl.text,
                  industries: _parseList(industriesCtrl.text),
                  country: countryCtrl.text,
                  city: cityCtrl.text,
                  startDate: startDate,
                  endDate: endDate,
                  venue: venueCtrl.text,
                  images: _parseList(imagesCtrl.text),
                  youtubeVideoId: youtubeCtrl.text.isNotEmpty ? youtubeCtrl.text : null,
                  registrationUrl: regUrlCtrl.text,
                  organizer: organizerCtrl.text,
                  website: websiteCtrl.text.isNotEmpty ? websiteCtrl.text : null,
                  exhibitorsCount: int.tryParse(exhibitorsCtrl.text),
                  visitorsCount: int.tryParse(visitorsCtrl.text),
                  tags: _parseList(tagsCtrl.text),
                  languages: _parseList(languagesCtrl.text),
                  isPremium: isPremium,
                  isFeatured: isFeatured,
                );
                if (exhibition != null) {
                  await _firestore.updateExhibition(data);
                } else {
                  await _firestore.addExhibition(data);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Exhibition exhibition) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exhibition'),
        content: Text('Are you sure you want to delete "${exhibition.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
            onPressed: () async {
              await _firestore.deleteExhibition(exhibition.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
