import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/exhibition.dart';
import '../../services/app_provider.dart';
import '../../services/firestore_service.dart';

class ExhibitionDetailScreen extends StatefulWidget {
  final String exhibitionId;

  const ExhibitionDetailScreen({super.key, required this.exhibitionId});

  @override
  State<ExhibitionDetailScreen> createState() => _ExhibitionDetailScreenState();
}

class _ExhibitionDetailScreenState extends State<ExhibitionDetailScreen> {
  final FirestoreService _firestore = FirestoreService();
  Exhibition? _exhibition;
  YoutubePlayerController? _youtubeController;
  bool _hasReminder = false;
  final int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _firestore.getExhibition(widget.exhibitionId).listen((exhibition) {
      if (!mounted) return;
      setState(() { _exhibition = exhibition; });
      if (exhibition?.youtubeVideoId != null && _youtubeController == null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: exhibition!.youtubeVideoId!,
          flags: const YoutubePlayerFlags(autoPlay: false),
        );
      }
    });

    final provider = context.read<AppProvider>();
    if (provider.currentUser != null) {
      _firestore
          .hasReminder(provider.currentUser!.id, widget.exhibitionId)
          .listen((has) {
        if (mounted) setState(() => _hasReminder = has);
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    if (_exhibition == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final e = _exhibition!;
    final isFav = provider.isFavorite(e.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: e.images.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          e.images[_currentImageIndex],
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(theme),
                        ),
                        if (e.images.length > 1)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Row(
                              children: List.generate(e.images.length, (i) {
                                return Container(
                                  width: 8, height: 8,
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i == _currentImageIndex
                                        ? Colors.white
                                        : Colors.white38,
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    )
                  : _placeholder(theme),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(e.name,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (e.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                          child: const Text('PREMIUM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: e.industries.map((ind) =>
                      Chip(
                        avatar: const Icon(Icons.category, size: 16),
                        label: Text(ind, style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                      )
                    ).toList(),
                  ),
                  const SizedBox(height: 12),
                  _infoRow(Icons.calendar_today, '${_formatDate(e.startDate)} - ${_formatDate(e.endDate)}'),
                  _infoRow(Icons.timer, e.durationText),
                  _infoRow(Icons.location_on, e.venue),
                  _infoRow(Icons.map, '${e.city}, ${e.country}'),
                  _infoRow(Icons.business, e.organizer),
                  if (e.exhibitorsCount != null)
                    _infoRow(Icons.people, '$_exhibitorsCount exhibitors'),
                  if (e.visitorsCount != null)
                    _infoRow(Icons.visibility, '$_visitorsCount visitors'),
                  if (e.languages.isNotEmpty)
                    _infoRow(Icons.language, e.languages.join(', ')),
                  const SizedBox(height: 16),
                  Text(e.description, style: theme.textTheme.bodyLarge),
                  if (e.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 4, runSpacing: 4,
                      children: e.tags.map((t) =>
                        Chip(
                          label: Text(t, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: theme.colorScheme.secondaryContainer,
                        )
                      ).toList(),
                    ),
                  ],
                  if (e.youtubeVideoId != null && _youtubeController != null) ...[
                    const SizedBox(height: 24),
                    Text('Watch Video', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: YoutubePlayer(controller: _youtubeController!, showVideoProgressIndicator: true),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchUrl(e.registrationUrl),
                          icon: const Icon(Icons.login),
                          label: const Text('Register Now'),
                        ),
                      ),
                      if (e.website != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _launchUrl(e.website!),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Website'),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (e.lastVerifiedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Last verified: ${_formatDate(e.lastVerifiedAt!)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (provider.currentUser != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionChip(
                          icon: isFav ? Icons.favorite : Icons.favorite_border,
                          label: isFav ? 'Favorited' : 'Favorite',
                          color: isFav ? Colors.red : null,
                          onTap: () => provider.toggleFavorite(e.id),
                        ),
                        _actionChip(
                          icon: _hasReminder ? Icons.notifications_active : Icons.notifications_outlined,
                          label: _hasReminder ? 'Reminder Set' : 'Remind Me',
                          color: _hasReminder ? Colors.orange : null,
                          onTap: () => _toggleReminder(provider, e),
                        ),
                      ],
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(ThemeData theme) => Container(
    color: theme.colorScheme.primaryContainer,
    child: const Center(child: Icon(Icons.business, size: 80)),
  );

  Widget _infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  String get _exhibitorsCount {
    final c = _exhibition!.exhibitorsCount;
    return c != null ? '$c' : 'N/A';
  }

  String get _visitorsCount {
    final c = _exhibition!.visitorsCount;
    return c != null ? '$c' : 'N/A';
  }

  Widget _actionChip({
    required IconData icon, required String label, Color? color, required VoidCallback onTap,
  }) {
    return ActionChip(avatar: Icon(icon, color: color), label: Text(label), onPressed: onTap);
  }

  void _toggleReminder(AppProvider provider, Exhibition e) {
    if (_hasReminder) {
      _firestore.removeReminder(provider.currentUser!.id, e.id);
    } else {
      final remindAt = e.startDate.subtract(const Duration(days: 1));
      _firestore.setReminder(provider.currentUser!.id, e.id, remindAt);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder set for 1 day before')),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
