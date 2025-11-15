import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/history/history_cubit.dart';
import '../widgets/history_tile.dart';
import '../widgets/section_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _segmentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().loadEssay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.w700,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Essay'),
                  icon: Icon(Icons.edit),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Interview'),
                  icon: Icon(Icons.record_voice_over),
                ),
              ],
              selected: {_segmentIndex},
              onSelectionChanged: (Set<int> selected) {
                setState(() {
                  _segmentIndex = selected.first;
                  if (_segmentIndex == 0) {
                    context.read<HistoryCubit>().loadEssay();
                  } else {
                    context.read<HistoryCubit>().loadInterview();
                  }
                });
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = _segmentIndex == 0
                    ? state.essay
                    : state.interview;

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No history yet',
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final e = items[i];
                    if (_segmentIndex == 0) {
                      // Essay history
                      return HistoryTile(
                        title: 'Essay',
                        subtitle: (e['text'] as String? ?? '').trim(),
                        trailing: (e['timestamp'] as String? ?? '')
                            .split('T')
                            .first,
                        onTap: () {
                          _showEssayDetail(context, e);
                        },
                      );
                    } else {
                      // Interview history
                      return HistoryTile(
                        title: '${e['niche']} • ${e['mode']}',
                        subtitle: (e['feedback'] as String? ?? '').trim(),
                        trailing: (e['timestamp'] as String? ?? '')
                            .split('T')
                            .first,
                        onTap: () {
                          _showInterviewDetail(context, e);
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEssayDetail(BuildContext context, Map<String, dynamic> e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scroll) => SingleChildScrollView(
          controller: scroll,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionCard(
                header: const Text(
                  'Essay',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(
                  (e['text'] as String? ?? ''),
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
              SectionCard(
                header: const Text(
                  'Feedback',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(
                  (e['feedback'] as String? ?? ''),
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInterviewDetail(BuildContext context, Map<String, dynamic> e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scroll) => SingleChildScrollView(
          controller: scroll,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionCard(
                header: Text(
                  '${e['niche']} • ${e['mode']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(
                  (e['feedback'] as String? ?? ''),
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
