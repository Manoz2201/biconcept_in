import 'package:biconcept_in/content/ncr_locations.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/core/widgets/gold_button.dart';
import 'package:biconcept_in/data/models.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:biconcept_in/features/admin/admin_shell.dart';
import 'package:flutter/material.dart';

const _leadStatuses = ['new', 'contacted', 'closed'];

class AdminLeadsPage extends StatefulWidget {
  const AdminLeadsPage({super.key});

  @override
  State<AdminLeadsPage> createState() => _AdminLeadsPageState();
}

class _AdminLeadsPageState extends State<AdminLeadsPage> {
  final _repo = LeadsRepository();
  late Future<List<StudioLead>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.listAll();
  }

  void _reload() => setState(() => _future = _repo.listAll());

  @override
  Widget build(BuildContext context) {
    return AdminPageFrame(
      title: 'Leads',
      child: FutureBuilder<List<StudioLead>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: BcColors.gold));
          }
          if (snapshot.hasError) {
            return AdminError('Could not load leads.', onRetry: _reload);
          }
          final leads = snapshot.data ?? const <StudioLead>[];
          if (leads.isEmpty) {
            return const Text('No leads yet. Inquire form and listing CTAs appear here.');
          }
          return Column(
            children: [
              for (final lead in leads) ...[
                _LeadCard(
                  lead: lead,
                  onStatus: (status) async {
                    await _repo.updateStatus(lead.id, status);
                    _reload();
                  },
                  onDelete: () async {
                    await _repo.delete(lead.id);
                    _reload();
                  },
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

class _LeadCard extends StatelessWidget {
  const _LeadCard({
    required this.lead,
    required this.onStatus,
    required this.onDelete,
  });

  final StudioLead lead;
  final ValueChanged<String> onStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final place = NcrLocations.labelFor(city: lead.city, sector: lead.sector);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BcColors.charcoal,
        border: Border.all(color: BcColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(lead.name, style: Theme.of(context).textTheme.headlineSmall),
              ),
              DropdownButton<String>(
                value: _leadStatuses.contains(lead.status) ? lead.status : 'new',
                dropdownColor: BcColors.charcoal,
                items: [
                  for (final status in _leadStatuses)
                    DropdownMenuItem(value: status, child: Text(status)),
                ],
                onChanged: (value) {
                  if (value != null) onStatus(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            [
              lead.practice,
              lead.projectType,
              if (place.isNotEmpty) place,
              lead.source,
            ].where((item) => item.isNotEmpty).join(' · '),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          if (lead.phone.isNotEmpty) Text(lead.phone),
          if (lead.email.isNotEmpty) Text(lead.email),
          if (lead.budgetBand.isNotEmpty) Text(lead.budgetBand),
          const SizedBox(height: 10),
          Text(lead.message, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GoldButton(
              label: 'Delete',
              variant: GoldButtonVariant.ghost,
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
