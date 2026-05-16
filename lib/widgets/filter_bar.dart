import 'package:flutter/material.dart';
import '../core/constants/constants.dart';

class FilterBar extends StatelessWidget {
  final String? selectedIndustry;
  final String? selectedCountry;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<String?> onIndustryChanged;
  final ValueChanged<String?> onCountryChanged;
  final VoidCallback onClear;

  const FilterBar({
    super.key,
    this.selectedIndustry,
    this.selectedCountry,
    this.fromDate,
    this.toDate,
    required this.onIndustryChanged,
    required this.onCountryChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Industry',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedIndustry,
                      isDense: true,
                      onChanged: onIndustryChanged,
                      items: AppConstants.industries
                          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                          .toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCountry,
                      isDense: true,
                      onChanged: onCountryChanged,
                      items: AppConstants.countries
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (selectedIndustry != null || selectedCountry != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }
}
