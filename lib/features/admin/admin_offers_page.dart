import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/data/models.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:biconcept_in/features/admin/admin_shell.dart';
import 'package:flutter/material.dart';

class AdminOffersPage extends StatefulWidget {
  const AdminOffersPage({super.key});

  @override
  State<AdminOffersPage> createState() => _AdminOffersPageState();
}

class _AdminOffersPageState extends State<AdminOffersPage> {
  final _repo = OffersRepository();
  late Future<List<StudioOffer>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.listAll();
  }

  void _reload() {
    setState(() {
      _future = _repo.listAll();
    });
  }

  Future<void> _edit([StudioOffer? row]) async {
    final saved = await showDialog<StudioOffer>(
      context: context,
      builder: (context) => _OfferEditor(row: row),
    );
    if (saved == null) return;
    await _repo.upsert(saved);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageFrame(
      title: 'Offers',
      action: GoldButton(label: 'Add offer', onPressed: () => _edit()),
      child: FutureBuilder<List<StudioOffer>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: BcAdminColors.gold));
          }
          if (snapshot.hasError) {
            return AdminError('Could not load offers.', onRetry: _reload);
          }
          final rows = snapshot.data ?? const <StudioOffer>[];
          if (rows.isEmpty) {
            return const Text('No offers yet. Add a promotion for home or a specific practice.');
          }
          return Column(
            children: [
              for (final row in rows) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: BcAdminColors.charcoal,
                    border: Border.all(color: BcAdminColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.title, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 6),
                      Text(
                        [
                          if (row.practice.isNotEmpty) row.practice,
                          if (row.published) 'published' else 'draft',
                        ].join(' · '),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (row.summary.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(row.summary, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        children: [
                          GoldButton(label: 'Edit', onPressed: () => _edit(row)),
                          GoldButton(
                            label: 'Delete',
                            variant: GoldButtonVariant.outline,
                            onPressed: () async {
                              await _repo.delete(row.id);
                              _reload();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _OfferEditor extends StatefulWidget {
  const _OfferEditor({this.row});

  final StudioOffer? row;

  @override
  State<_OfferEditor> createState() => _OfferEditorState();
}

class _OfferEditorState extends State<_OfferEditor> {
  late final TextEditingController _title;
  late final TextEditingController _summary;
  late final TextEditingController _cta;
  late final TextEditingController _href;
  late final TextEditingController _practice;
  late bool _published;

  @override
  void initState() {
    super.initState();
    final row = widget.row;
    _title = TextEditingController(text: row?.title ?? '');
    _summary = TextEditingController(text: row?.summary ?? '');
    _cta = TextEditingController(text: row?.ctaLabel ?? 'Inquire');
    _href = TextEditingController(text: row?.href ?? '');
    _practice = TextEditingController(text: row?.practice ?? '');
    _published = row?.published ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _cta.dispose();
    _href.dispose();
    _practice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BcAdminColors.panel,
      title: Text(widget.row == null ? 'Add offer' : 'Edit offer'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _title, decoration: const InputDecoration(labelText: 'TITLE')),
              const SizedBox(height: 12),
              TextField(
                controller: _summary,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'SUMMARY'),
              ),
              const SizedBox(height: 12),
              TextField(controller: _cta, decoration: const InputDecoration(labelText: 'CTA LABEL')),
              const SizedBox(height: 12),
              TextField(
                controller: _href,
                decoration: const InputDecoration(labelText: 'HREF (optional, e.g. /inquire?practice=interiors)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _practice,
                decoration: const InputDecoration(
                  labelText: 'PRACTICE SLUG (blank = all, or architecture / interiors / real-estate)',
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Published'),
                value: _published,
                activeThumbColor: BcAdminColors.gold,
                onChanged: (value) => setState(() => _published = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              StudioOffer(
                id: widget.row?.id ?? '',
                title: _title.text.trim(),
                summary: _summary.text.trim(),
                ctaLabel: _cta.text.trim(),
                href: _href.text.trim(),
                practice: _practice.text.trim(),
                published: _published,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
