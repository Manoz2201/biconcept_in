import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/data/models.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:biconcept_in/features/admin/admin_shell.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

const _kinds = ['architecture', 'interiors', 'real-estate'];

class AdminShowcasePage extends StatefulWidget {
  const AdminShowcasePage({super.key});

  @override
  State<AdminShowcasePage> createState() => _AdminShowcasePageState();
}

class _AdminShowcasePageState extends State<AdminShowcasePage> {
  final _repo = ShowcaseRepository();
  late Future<List<ShowcaseRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.listAll();
  }

  void _reload() => setState(() => _future = _repo.listAll());

  Future<void> _edit([ShowcaseRow? row]) async {
    final saved = await showDialog<ShowcaseRow>(
      context: context,
      builder: (context) => _ShowcaseEditor(row: row),
    );
    if (saved == null) return;
    await _repo.upsert(saved);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageFrame(
      title: 'Showcase',
      action: GoldButton(label: 'Add project', onPressed: () => _edit()),
      child: FutureBuilder<List<ShowcaseRow>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: BcAdminColors.gold));
          }
          if (snapshot.hasError) {
            return AdminError('Could not load showcase.', onRetry: _reload);
          }
          final rows = snapshot.data ?? const <ShowcaseRow>[];
          if (rows.isEmpty) {
            return const Text('No CMS projects yet. Published rows replace the static Work portfolio.');
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
                        '${row.kind} · ${row.location} · ${row.year}${row.published ? '' : ' · hidden'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
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

class _ShowcaseEditor extends StatefulWidget {
  const _ShowcaseEditor({this.row});

  final ShowcaseRow? row;

  @override
  State<_ShowcaseEditor> createState() => _ShowcaseEditorState();
}

class _ShowcaseEditorState extends State<_ShowcaseEditor> {
  late final TextEditingController _slug;
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _year;
  late final TextEditingController _lede;
  late final TextEditingController _story;
  late final TextEditingController _hero;
  late String _kind;
  late bool _published;
  late bool _featured;
  bool _uploading = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    final row = widget.row;
    _slug = TextEditingController(text: row?.slug ?? '');
    _title = TextEditingController(text: row?.title ?? '');
    _location = TextEditingController(text: row?.location ?? '');
    _year = TextEditingController(text: row?.year ?? '');
    _lede = TextEditingController(text: row?.lede ?? '');
    _story = TextEditingController(text: row?.story ?? '');
    _hero = TextEditingController(text: row?.heroFileId ?? '');
    _kind = row?.kind.isNotEmpty == true ? row!.kind : 'architecture';
    _published = row?.published ?? true;
    _featured = row?.featured ?? false;
  }

  @override
  void dispose() {
    _slug.dispose();
    _title.dispose();
    _location.dispose();
    _year.dispose();
    _lede.dispose();
    _story.dispose();
    _hero.dispose();
    super.dispose();
  }

  Future<void> _uploadHero() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = picked?.files.firstOrNull;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return;
    setState(() {
      _uploading = true;
      _uploadError = null;
    });
    try {
      final id = await MediaRepository().uploadImage(
        bytes: bytes,
        filename: file.name,
      );
      if (!mounted) return;
      setState(() {
        _hero.text = id;
        _uploading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _uploadError = 'Upload failed. Sign in and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BcAdminColors.panel,
      title: Text(widget.row == null ? 'Add showcase' : 'Edit showcase'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _slug, decoration: const InputDecoration(labelText: 'SLUG')),
              const SizedBox(height: 12),
              TextField(controller: _title, decoration: const InputDecoration(labelText: 'TITLE')),
              const SizedBox(height: 12),
              TextField(controller: _location, decoration: const InputDecoration(labelText: 'LOCATION')),
              const SizedBox(height: 12),
              TextField(controller: _year, decoration: const InputDecoration(labelText: 'YEAR')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _kinds.contains(_kind) ? _kind : 'architecture',
                dropdownColor: BcAdminColors.charcoal,
                decoration: const InputDecoration(labelText: 'KIND'),
                items: [
                  for (final item in _kinds) DropdownMenuItem(value: item, child: Text(item)),
                ],
                onChanged: (value) => setState(() => _kind = value ?? _kind),
              ),
              const SizedBox(height: 12),
              TextField(controller: _lede, maxLines: 3, decoration: const InputDecoration(labelText: 'LEDE')),
              const SizedBox(height: 12),
              TextField(controller: _story, maxLines: 6, decoration: const InputDecoration(labelText: 'STORY')),
              const SizedBox(height: 12),
              TextField(
                controller: _hero,
                decoration: const InputDecoration(
                  labelText: 'HERO FILE ID',
                  helperText: 'Upload to the media bucket. File ID is stored, not a public URL.',
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: GoldButton(
                  label: _uploading ? 'Uploading…' : 'Upload image',
                  variant: GoldButtonVariant.outline,
                  onPressed: _uploading ? null : _uploadHero,
                ),
              ),
              if (_uploadError != null) ...[
                const SizedBox(height: 8),
                Text(_uploadError!, style: const TextStyle(color: BcAdminColors.danger)),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Published'),
                value: _published,
                activeThumbColor: BcAdminColors.gold,
                onChanged: (value) => setState(() => _published = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Featured'),
                value: _featured,
                activeThumbColor: BcAdminColors.gold,
                onChanged: (value) => setState(() => _featured = value),
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
              ShowcaseRow(
                id: widget.row?.id ?? '',
                slug: _slug.text.trim(),
                title: _title.text.trim(),
                location: _location.text.trim(),
                year: _year.text.trim(),
                kind: _kind,
                lede: _lede.text.trim(),
                story: _story.text.trim(),
                heroFileId: _hero.text.trim(),
                published: _published,
                featured: _featured,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
