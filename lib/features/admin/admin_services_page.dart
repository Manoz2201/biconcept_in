import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/data/models.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:biconcept_in/features/admin/admin_shell.dart';
import 'package:flutter/material.dart';

class AdminServicesPage extends StatefulWidget {
  const AdminServicesPage({super.key});

  @override
  State<AdminServicesPage> createState() => _AdminServicesPageState();
}

class _AdminServicesPageState extends State<AdminServicesPage> {
  final _repo = CmsServicesRepository();
  late Future<List<ServiceRow>> _future;

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

  Future<void> _edit([ServiceRow? row]) async {
    final saved = await showDialog<ServiceRow>(
      context: context,
      builder: (context) => _ServiceEditor(row: row),
    );
    if (saved == null) return;
    await _repo.upsert(saved);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageFrame(
      title: 'Services',
      action: GoldButton(label: 'Add service', onPressed: () => _edit()),
      child: FutureBuilder<List<ServiceRow>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: BcAdminColors.gold));
          }
          if (snapshot.hasError) {
            return AdminError('Could not load services.', onRetry: _reload);
          }
          final rows = snapshot.data ?? const <ServiceRow>[];
          if (rows.isEmpty) {
            return const Text('No CMS services yet. Add architecture, interiors, and real-estate rows.');
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
                      Text(row.label, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 6),
                      Text(row.headline, style: Theme.of(context).textTheme.bodyMedium),
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

class _ServiceEditor extends StatefulWidget {
  const _ServiceEditor({this.row});

  final ServiceRow? row;

  @override
  State<_ServiceEditor> createState() => _ServiceEditorState();
}

class _ServiceEditorState extends State<_ServiceEditor> {
  late final TextEditingController _slug;
  late final TextEditingController _label;
  late final TextEditingController _kicker;
  late final TextEditingController _headline;
  late final TextEditingController _lede;
  late bool _published;

  @override
  void initState() {
    super.initState();
    final row = widget.row;
    _slug = TextEditingController(text: row?.slug ?? '');
    _label = TextEditingController(text: row?.label ?? '');
    _kicker = TextEditingController(text: row?.kicker ?? '');
    _headline = TextEditingController(text: row?.headline ?? '');
    _lede = TextEditingController(text: row?.lede ?? '');
    _published = row?.published ?? true;
  }

  @override
  void dispose() {
    _slug.dispose();
    _label.dispose();
    _kicker.dispose();
    _headline.dispose();
    _lede.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BcAdminColors.panel,
      title: Text(widget.row == null ? 'Add service' : 'Edit service'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _slug, decoration: const InputDecoration(labelText: 'SLUG')),
              const SizedBox(height: 12),
              TextField(controller: _label, decoration: const InputDecoration(labelText: 'LABEL')),
              const SizedBox(height: 12),
              TextField(controller: _kicker, decoration: const InputDecoration(labelText: 'KICKER')),
              const SizedBox(height: 12),
              TextField(controller: _headline, decoration: const InputDecoration(labelText: 'HEADLINE')),
              const SizedBox(height: 12),
              TextField(controller: _lede, maxLines: 5, decoration: const InputDecoration(labelText: 'LEDE')),
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
              ServiceRow(
                id: widget.row?.id ?? '',
                slug: _slug.text.trim(),
                label: _label.text.trim(),
                kicker: _kicker.text.trim(),
                headline: _headline.text.trim(),
                lede: _lede.text.trim(),
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
