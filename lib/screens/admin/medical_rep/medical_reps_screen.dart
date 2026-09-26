import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/medical_rep.dart';
import '../../../providers/medical_rep_provider.dart';
import 'add_medical_rep_screen.dart';
import 'medical_rep_details_screen.dart';

class MedicalRepsScreen extends ConsumerStatefulWidget {
  const MedicalRepsScreen({super.key});

  @override
  ConsumerState<MedicalRepsScreen> createState() => _MedicalRepsScreenState();
}

class _MedicalRepsScreenState extends ConsumerState<MedicalRepsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repsAsync = ref.watch(filteredMedicalRepsProvider);
    final showInactive = ref.watch(medicalRepShowInactiveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Representatives'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: showInactive ? 'Hide Inactive' : 'Show Inactive',
            icon: Icon(
              showInactive ? Icons.visibility : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              ref.read(medicalRepShowInactiveProvider.notifier).toggle();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddMedicalRepScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Representative'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      ref
                          .read(medicalRepSearchQueryProvider.notifier)
                          .setQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search representatives...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(medicalRepSearchQueryProvider.notifier)
                                    .clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  if (showInactive) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Showing inactive representatives',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Representatives List View
            Expanded(
              child: repsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Failed to load representatives: $error',
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (reps) {
                  if (reps.isEmpty) {
                    final isFiltering = _searchController.text.isNotEmpty;
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_alt_outlined,
                              size: 64,
                              color: theme.colorScheme.primary.withAlpha(128),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isFiltering
                                  ? 'No matching representatives'
                                  : 'No representatives added yet',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isFiltering
                                  ? 'Try searching by name, email, or phone'
                                  : 'Tap "+ Add Representative" to create your first representative profile',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (!isFiltering) ...[
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AddMedicalRepScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Representative'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: reps.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final rep = reps[index];
                      return _MedicalRepCard(
                        rep: rep,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MedicalRepDetailsScreen(
                                repId: rep.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalRepCard extends StatelessWidget {
  final MedicalRep rep;
  final VoidCallback onTap;

  const _MedicalRepCard({
    required this.rep,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rep Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF7C3AED).withAlpha(25),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF7C3AED),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Rep info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            rep.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: rep.active
                                ? const Color(0xFF10B981).withAlpha(30)
                                : Colors.grey.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: rep.active
                                  ? const Color(0xFF10B981)
                                  : Colors.grey,
                            ),
                          ),
                          child: Text(
                            rep.active ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: rep.active
                                  ? const Color(0xFF047857)
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Email row
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            rep.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Phone row
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          rep.phone,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
