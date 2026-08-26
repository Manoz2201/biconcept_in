import 'package:appwrite/appwrite.dart';
import 'package:biconcept_in/core/theme/colors.dart';
import 'package:biconcept_in/data/models.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:biconcept_in/features/admin/admin_shell.dart';
import 'package:flutter/material.dart';

class _AgentSpec {
  const _AgentSpec({
    required this.id,
    required this.name,
    required this.blurb,
    required this.schedule,
    required this.runnable,
  });

  final String id;
  final String name;
  final String blurb;
  final String schedule;
  final bool runnable;
}

const _catalog = [
  _AgentSpec(
    id: 'market',
    name: 'Market',
    blurb: 'NCR listings from public search. Publishes them live (cap 15).',
    schedule: 'Every 6 hours · GitHub dispatcher every 15 min',
    runnable: true,
  ),
  _AgentSpec(
    id: 'offers',
    name: 'Offers',
    blurb: 'Studio promotions for the NCR practice. Cap 2 live offers.',
    schedule: 'Daily 07:00 IST · GitHub dispatcher every 15 min',
    runnable: true,
  ),
  _AgentSpec(
    id: 'seo',
    name: 'SEO / copy',
    blurb: 'Allowlisted copy and sitemap only. Merges after flutter test.',
    schedule: 'Daily 12:00 IST · GitHub dispatcher every 15 min',
    runnable: true,
  ),
  _AgentSpec(
    id: 'concierge',
    name: 'Concierge',
    blurb: 'Signed-in chat that can publish listings and offers, and update leads.',
    schedule: 'On demand — use the panel below',
    runnable: false,
  ),
];

class AdminAgentsPage extends StatefulWidget {
  const AdminAgentsPage({super.key});

  @override
  State<AdminAgentsPage> createState() => _AdminAgentsPageState();
}

class _AdminAgentsPageState extends State<AdminAgentsPage> {
  final _jobsRepo = AgentJobsRepository();
  final _concierge = ConciergeRepository();
  final _chat = TextEditingController();
  final _thread = <(bool, String)>[];
  RealtimeSubscription? _sub;
  List<AgentJob> _jobs = const [];
  bool _loading = true;
  String? _error;
  bool _sending = false;
  String? _busyAgent;

  @override
  void initState() {
    super.initState();
    _reload();
    _sub = _jobsRepo.subscribe(_reload);
  }

  @override
  void dispose() {
    _sub?.close();
    _chat.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    try {
      final jobs = await _jobsRepo.listRecent();
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  AgentJob? _lastFor(String agentId) {
    for (final job in _jobs) {
      if (job.agentId == agentId) return job;
    }
    return null;
  }

  Future<void> _runNow(_AgentSpec spec) async {
    setState(() => _busyAgent = spec.id);
    try {
      await _jobsRepo.enqueue(
        agentId: spec.id,
        title: '${spec.name} — manual run',
      );
      await _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not queue ${spec.name}: $error')),
      );
    } finally {
      if (mounted) setState(() => _busyAgent = null);
    }
  }

  Future<void> _sendChat() async {
    final message = _chat.text.trim();
    if (message.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _thread.add((true, message));
      _chat.clear();
    });
    try {
      final reply = await _concierge.ask(message);
      if (!mounted) return;
      setState(() => _thread.add((false, reply)));
      await _reload();
    } catch (error) {
      if (!mounted) return;
      setState(() => _thread.add((false, error.toString())));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageFrame(
      title: 'Agents',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Run now writes a queued job. A GitHub Action on main picks those up every 15 minutes and actually runs Market, Offers, or SEO. Until that workflow is pushed, jobs stay queued. Concierge chat runs immediately.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final spec in _catalog)
                _AgentCard(
                  spec: spec,
                  last: _lastFor(spec.id),
                  busy: _busyAgent == spec.id,
                  onRun: spec.runnable ? () => _runNow(spec) : null,
                ),
            ],
          ),
          const SizedBox(height: 36),
          Text('Live jobs', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: BcAdminColors.gold))
          else if (_error != null)
            AdminError(_error!, onRetry: _reload)
          else if (_jobs.isEmpty)
            const Text('No jobs yet. Queue a run or wait for the next schedule.')
          else
            Column(
              children: [
                for (final job in _jobs) ...[
                  _JobCard(job: job),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          const SizedBox(height: 36),
          Text('Concierge', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Signed-in only. Can upsert listings and offers, and update lead status. Keys stay on the Function.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
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
                if (_thread.isEmpty)
                  Text(
                    'Ask to publish a listing, add an offer, or update a lead. Listings go live on the public site.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                for (final turn in _thread) ...[
                  Align(
                    alignment: turn.$1 ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 560),
                      color: turn.$1
                          ? BcAdminColors.gold.withValues(alpha: 0.16)
                          : BcAdminColors.panel,
                      child: Text(turn.$2),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chat,
                        minLines: 1,
                        maxLines: 4,
                        onSubmitted: (_) => _sendChat(),
                        decoration: const InputDecoration(
                          hintText: 'Message the studio concierge…',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _sending ? null : _sendChat,
                      child: Text(_sending ? 'Sending' : 'Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  const _AgentCard({
    required this.spec,
    required this.last,
    required this.busy,
    required this.onRun,
  });

  final _AgentSpec spec;
  final AgentJob? last;
  final bool busy;
  final VoidCallback? onRun;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: BcAdminColors.charcoal,
        border: Border.all(color: BcAdminColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(spec.name.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 10),
          Text(spec.blurb, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text(spec.schedule, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            last == null
                ? 'No runs yet'
                : 'Last: ${last!.status}${last!.summary.isEmpty ? '' : ' — ${last!.summary}'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          if (onRun != null)
            FilledButton(
              onPressed: busy ? null : onRun,
              child: Text(busy ? 'Queuing…' : 'Run now'),
            )
          else
            Text('Chat only', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});

  final AgentJob job;

  @override
  Widget build(BuildContext context) {
    final active = job.isActive;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BcAdminColors.charcoal,
        border: Border.all(color: BcAdminColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(job.title, style: Theme.of(context).textTheme.titleMedium),
              ),
              Text(job.status.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: job.progress.clamp(0, 100) / 100,
            color: BcAdminColors.gold,
            backgroundColor: BcAdminColors.line,
          ),
          const SizedBox(height: 8),
          Text(
            job.summary.isEmpty ? '${job.progress}%' : job.summary,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (job.log.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              job.log.length > 800 ? job.log.substring(job.log.length - 800) : job.log,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (active)
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}
