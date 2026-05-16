import 'package:flutter/material.dart';

class CrawlerPanel extends StatelessWidget {
  const CrawlerPanel({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: const Row(
              children: [
                Text(
                  'Crawler',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CrawlerSourceCard(
                    name: '10times',
                    url: '10times.com/tradeshows',
                    status: 'configured',
                    spiderClass: 'TentimesSpider',
                  ),
                  const SizedBox(height: 12),
                  _CrawlerSourceCard(
                    name: 'EventsEye',
                    url: 'eventseye.com/fairs',
                    status: 'configured',
                    spiderClass: 'EventsEyeSpider',
                  ),
                  const SizedBox(height: 12),
                  _CrawlerSourceCard(
                    name: 'TradeFairDates',
                    url: 'tradefairdates.com',
                    status: 'configured',
                    spiderClass: 'TradeFairDatesSpider',
                  ),
                  const SizedBox(height: 12),
                  _CrawlerSourceCard(
                    name: 'TSNN',
                    url: 'tsnn.com/trade-shows',
                    status: 'configured',
                    spiderClass: 'TsnnSpider',
                  ),
                  const SizedBox(height: 12),
                  _CrawlerSourceCard(
                    name: 'UFI',
                    url: 'ufi.org/membership',
                    status: 'configured',
                    spiderClass: 'UfiSpider',
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
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
                            Icon(Icons.info_outline, color: const Color(0xFF6A9FFF), size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'How to run',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _CodeLine(r'cd crawlers'),
                        _CodeLine(r'pip install -r requirements.txt'),
                        _CodeLine(r'scrapy crawl 10times'),
                        _CodeLine(r'python run_all.py'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrawlerSourceCard extends StatelessWidget {
  final String name;
  final String url;
  final String status;
  final String spiderClass;

  const _CrawlerSourceCard({
    required this.name,
    required this.url,
    required this.status,
    required this.spiderClass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2C58BC).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.travel_explore, color: Color(0xFF2C58BC), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text(url, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Ready', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(spiderClass, style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  final String code;
  const _CodeLine(this.code);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '\$',
              style: TextStyle(color: const Color(0xFF10B981), fontSize: 13, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            code,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
