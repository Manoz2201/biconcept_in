import 'package:biconcept_in/content/ncr_locations.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/data/models.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:biconcept_in/features/admin/admin_shell.dart';
import 'package:flutter/material.dart';

const _statuses = ['upcoming', 'pre-launch', 'launched', 'under-construction', 'ready'];
const _typologies = ['apartment', 'villa', 'plot', 'mixed', 'commercial'];

class AdminListingsPage extends StatefulWidget {
  const AdminListingsPage({super.key});

  @override
  State<AdminListingsPage> createState() => _AdminListingsPageState();
}

class _AdminListingsPageState extends State<AdminListingsPage> {
  final _repo = ListingsRepository();
  late Future<List<MarketListing>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.listAll();
  }

  void _reload() => setState(() => _future = _repo.listAll());

  Future<void> _edit([MarketListing? listing]) async {
    final saved = await showDialog<MarketListing>(
      context: context,
      builder: (context) => _ListingEditor(listing: listing),
    );
    if (saved == null) return;
    await _repo.upsert(saved, id: saved.id.isEmpty ? null : saved.id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageFrame(
      title: 'Listings',
      action: GoldButton(label: 'Add listing', onPressed: () => _edit()),
      child: FutureBuilder<List<MarketListing>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: BcAdminColors.gold));
          }
          if (snapshot.hasError) {
            return AdminError('Could not load listings.', onRetry: _reload);
          }
          final listings = snapshot.data ?? const <MarketListing>[];
          if (listings.isEmpty) {
            return const Text('No researched projects yet. Run the market agent or add a listing.');
          }
          return Column(
            children: [
              for (final listing in listings) ...[
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
                      Text(
                        '${listing.title}${listing.published ? '' : '  ·  hidden'}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${listing.placeLabel} · ${listing.developer} · ${listing.status}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        children: [
                          GoldButton(label: 'Edit', onPressed: () => _edit(listing)),
                          GoldButton(
                            label: listing.published ? 'Unpublish' : 'Publish',
                            variant: GoldButtonVariant.outline,
                            onPressed: () async {
                              await _repo.setPublished(listing.id, !listing.published);
                              _reload();
                            },
                          ),
                          GoldButton(
                            label: 'Delete',
                            variant: GoldButtonVariant.ghost,
                            onPressed: () async {
                              await _repo.delete(listing.id);
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

class _ListingEditor extends StatefulWidget {
  const _ListingEditor({this.listing});

  final MarketListing? listing;

  @override
  State<_ListingEditor> createState() => _ListingEditorState();
}

class _ListingEditorState extends State<_ListingEditor> {
  late final TextEditingController _title;
  late final TextEditingController _developer;
  late final TextEditingController _locality;
  late final TextEditingController _price;
  late final TextEditingController _summary;
  late final TextEditingController _sourceUrl;
  late final TextEditingController _sourceName;
  late String _city;
  late String _sector;
  late String _status;
  late String _typology;
  late bool _published;

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    _title = TextEditingController(text: listing?.title ?? '');
    _developer = TextEditingController(text: listing?.developer ?? '');
    _locality = TextEditingController(text: listing?.locality ?? '');
    _price = TextEditingController(text: listing?.priceBand ?? '');
    _summary = TextEditingController(text: listing?.summary ?? '');
    _sourceUrl = TextEditingController(text: listing?.sourceUrl ?? '');
    _sourceName = TextEditingController(text: listing?.sourceName ?? '');
    _city = listing?.city.isNotEmpty == true ? listing!.city : NcrLocations.noida.slug;
    _sector = listing?.sector ?? '';
    _status = listing?.status.isNotEmpty == true ? listing!.status : 'upcoming';
    _typology = listing?.typology.isNotEmpty == true ? listing!.typology : 'apartment';
    _published = listing?.published ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _developer.dispose();
    _locality.dispose();
    _price.dispose();
    _summary.dispose();
    _sourceUrl.dispose();
    _sourceName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final city = NcrLocations.bySlug(_city) ?? NcrLocations.noida;
    return AlertDialog(
      backgroundColor: BcAdminColors.panel,
      title: Text(widget.listing == null ? 'Add listing' : 'Edit listing'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _title, decoration: const InputDecoration(labelText: 'TITLE')),
              const SizedBox(height: 12),
              TextField(controller: _developer, decoration: const InputDecoration(labelText: 'DEVELOPER')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _city,
                dropdownColor: BcAdminColors.charcoal,
                decoration: const InputDecoration(labelText: 'CITY'),
                items: [
                  for (final item in NcrLocations.all)
                    DropdownMenuItem(value: item.slug, child: Text(item.label)),
                ],
                onChanged: (value) => setState(() {
                  _city = value ?? _city;
                  _sector = '';
                }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: city.sectorBySlug(_sector) == null ? null : _sector,
                dropdownColor: BcAdminColors.charcoal,
                decoration: InputDecoration(labelText: city.sectorNoun.toUpperCase()),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Unspecified')),
                  for (final item in city.sectors)
                    DropdownMenuItem(value: item.slug, child: Text(item.label)),
                ],
                onChanged: (value) => setState(() => _sector = value ?? ''),
              ),
              const SizedBox(height: 12),
              TextField(controller: _locality, decoration: const InputDecoration(labelText: 'LOCALITY')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _statuses.contains(_status) ? _status : 'upcoming',
                dropdownColor: BcAdminColors.charcoal,
                decoration: const InputDecoration(labelText: 'STATUS'),
                items: [
                  for (final item in _statuses) DropdownMenuItem(value: item, child: Text(item)),
                ],
                onChanged: (value) => setState(() => _status = value ?? _status),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _typologies.contains(_typology) ? _typology : 'apartment',
                dropdownColor: BcAdminColors.charcoal,
                decoration: const InputDecoration(labelText: 'TYPOLOGY'),
                items: [
                  for (final item in _typologies) DropdownMenuItem(value: item, child: Text(item)),
                ],
                onChanged: (value) => setState(() => _typology = value ?? _typology),
              ),
              const SizedBox(height: 12),
              TextField(controller: _price, decoration: const InputDecoration(labelText: 'PRICE BAND')),
              const SizedBox(height: 12),
              TextField(
                controller: _summary,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'SUMMARY'),
              ),
              const SizedBox(height: 12),
              TextField(controller: _sourceUrl, decoration: const InputDecoration(labelText: 'SOURCE URL')),
              const SizedBox(height: 12),
              TextField(controller: _sourceName, decoration: const InputDecoration(labelText: 'SOURCE NAME')),
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
              MarketListing(
                id: widget.listing?.id ?? '',
                title: _title.text.trim(),
                developer: _developer.text.trim(),
                city: _city,
                sector: _sector,
                locality: _locality.text.trim(),
                status: _status,
                typology: _typology,
                priceBand: _price.text.trim(),
                summary: _summary.text.trim(),
                sourceUrl: _sourceUrl.text.trim(),
                sourceName: _sourceName.text.trim(),
                published: _published,
                researchedAt: DateTime.now().toUtc().toIso8601String(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
