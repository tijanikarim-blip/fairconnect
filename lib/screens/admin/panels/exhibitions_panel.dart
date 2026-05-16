import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/app_provider.dart';

class ExhibitionsPanel extends StatelessWidget {
  const ExhibitionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final exhibitions = provider.exhibitions;

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
                  'Exhibitions',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  '${exhibitions.length} total',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: exhibitions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business_outlined, size: 64, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        Text('No exhibitions', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exhibitions.length,
                    itemBuilder: (context, index) {
                      final e = exhibitions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF1F2937)),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (e.isPremium ? const Color(0xFF8B5CF6) : const Color(0xFF2C58BC)).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              e.isPremium ? Icons.workspace_premium : Icons.business,
                              color: e.isPremium ? const Color(0xFF8B5CF6) : const Color(0xFF2C58BC),
                              size: 20,
                            ),
                          ),
                          title: Text(e.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            '${e.country} · ${e.city} · ${e.industries.join(", ")}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (e.isFeatured)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4A837).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Featured', style: TextStyle(color: Color(0xFFD4A837), fontSize: 11)),
                                ),
                              if (e.isPremium) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Premium', style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 11)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
