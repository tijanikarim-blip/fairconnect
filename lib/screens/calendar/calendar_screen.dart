import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/exhibition.dart';
import '../../services/app_provider.dart';
import '../../widgets/exhibition_card.dart';
import '../detail/exhibition_detail_screen.dart';
import '../../core/theme/colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final exhibitions = provider.exhibitions;

    final selectedExhibitions = _selectedDay != null
        ? exhibitions.where((e) {
            final start = e.startDate;
            final end = e.endDate;
            return !_selectedDay!.isBefore(start) && !_selectedDay!.isAfter(end);
          }).toList()
        : <Exhibition>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 730)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) {
                return exhibitions.where((e) {
                  return !day.isBefore(e.startDate) && !day.isAfter(e.endDate);
                }).toList();
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Color(0xFF00BCD4),
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                markerSize: 6,
                markerMargin: const EdgeInsets.symmetric(horizontal: 1),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  border: Border.fromBorderSide(BorderSide(color: AppColors.primary)),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                formatButtonTextStyle: TextStyle(color: AppColors.primary),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _selectedDay == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'Select a day to view exhibitions',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : selectedExhibitions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No exhibitions on this day',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: selectedExhibitions.length,
                        itemBuilder: (context, index) {
                          final exhibition = selectedExhibitions[index];
                          return ExhibitionCard(
                            exhibition: exhibition,
                            isFavorite: provider.isFavorite(exhibition.id),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExhibitionDetailScreen(
                                  exhibitionId: exhibition.id,
                                ),
                              ),
                            ),
                            onFavoriteToggle: () => provider.toggleFavorite(exhibition.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}