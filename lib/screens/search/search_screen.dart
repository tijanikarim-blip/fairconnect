import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_provider.dart';
import '../../widgets/exhibition_card.dart';
import '../../widgets/filter_bar.dart';
import '../../models/exhibition.dart';
import '../detail/exhibition_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? _selectedIndustry;
  String? _selectedCountry;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final exhibitions = provider.exhibitions;

    List<Exhibition> filtered = exhibitions.where((e) {
      if (_selectedIndustry != null && e.industry != _selectedIndustry) {
        return false;
      }
      if (_selectedCountry != null && e.country != _selectedCountry) {
        return false;
      }
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        if (!e.name.toLowerCase().contains(query) &&
            !e.country.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search exhibitions...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        FilterBar(
          selectedIndustry: _selectedIndustry,
          selectedCountry: _selectedCountry,
          onIndustryChanged: (v) => setState(() => _selectedIndustry = v),
          onCountryChanged: (v) => setState(() => _selectedCountry = v),
          onClear: () => setState(() {
            _selectedIndustry = null;
            _selectedCountry = null;
          }),
        ),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(48),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    _searchController.text.isNotEmpty || _selectedIndustry != null
                        ? 'No exhibitions match your search'
                        : 'No exhibitions found',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          ...filtered.map((exhibition) {
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
