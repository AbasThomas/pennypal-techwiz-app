import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_providers.dart';
import '../../../shared/widgets/penny_widgets.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends ConsumerState<AdminDashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = ['Dashboard', 'Users', 'Content', 'Support'];
    final views = [
      const _AdminHome(),
      const _AdminUsers(),
      const _AdminContent(),
      const _AdminSupport(),
    ];

    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: PennyPalColors.elevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: const AppIcon(AppIcons.wallet,
                  color: PennyPalColors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'PennyPal Admin',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: PennyPalColors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const AppIcon(AppIcons.logout, color: PennyPalColors.white),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.asMap().entries.map((e) {
                  final sel = _tab == e.key;
                  return GestureDetector(
                    onTap: () => setState(() => _tab = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? PennyPalColors.white : PennyPalColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: sel
                              ? PennyPalColors.white
                              : PennyPalColors.border,
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? PennyPalColors.black : PennyPalColors.gray,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(child: views[_tab]),
        ],
      ),
    );
  }
}

class _AdminHome extends StatelessWidget {
  const _AdminHome();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: PennyPalColors.white,
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: const [
              _AdminStatCard(
                value: '1,248',
                label: 'Students',
                icon: AppIcons.users,
              ),
              _AdminStatCard(
                value: '842',
                label: 'Active Users',
                icon: AppIcons.user,
              ),
              _AdminStatCard(
                value: '12,450',
                label: 'Transactions',
                icon: AppIcons.fallback,
              ),
              _AdminStatCard(
                value: '23',
                label: 'Support Requests',
                icon: AppIcons.support,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 12),
          _AdminQuickAction(
            icon: AppIcons.chartBar,
            label: 'View Analytics',
            sub: 'Activity, categories, and trends',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _AdminQuickAction(
            icon: AppIcons.notification,
            label: 'Send Notification',
            sub: 'Push a message to all students',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.value,
    required this.label,
    required this.icon,
  });
  final String value;
  final String label;
  final List<List<dynamic>> icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PennyPalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PennyPalColors.elevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppIcon(icon, color: PennyPalColors.white, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: PennyPalColors.white,
                  )),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: PennyPalColors.gray)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminQuickAction extends StatelessWidget {
  const _AdminQuickAction({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });
  final List<List<dynamic>> icon;
  final String label;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: PennyPalColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PennyPalColors.border),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PennyPalColors.elevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                AppIcon(icon, color: PennyPalColors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: PennyPalColors.white)),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12, color: PennyPalColors.gray)),
              ],
            ),
          ),
          const AppIcon(AppIcons.chevronRight,
              color: PennyPalColors.muted),
        ]),
      ),
    );
  }
}

class _AdminUsers extends StatelessWidget {
  const _AdminUsers();

  static const _users = [
    ('Thomas Abasienyene', 'thomas@email.com', true),
    ('John Doe', 'john@email.com', true),
    ('Jane Doe', 'jane@email.com', false),
    ('Alice Benson', 'alice@email.com', true),
    ('Mark Adeleke', 'mark@email.com', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: TextField(
            style: const TextStyle(color: PennyPalColors.white),
            decoration: InputDecoration(
              hintText: 'Search studentsâ€¦',
              hintStyle: const TextStyle(color: PennyPalColors.muted),
              prefixIcon: const AppIcon(AppIcons.search,
                  color: PennyPalColors.muted, size: 20),
              filled: true,
              fillColor: PennyPalColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 13),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: PennyPalColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: PennyPalColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: PennyPalColors.white, width: 1.5)),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            itemCount: _users.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final u = _users[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PennyPalColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PennyPalColors.border),
                ),
                child: Row(children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: PennyPalColors.elevated,
                    child: Text(
                      u.$1[0],
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: PennyPalColors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.$1,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: PennyPalColors.white)),
                        Text(u.$2,
                            style: const TextStyle(
                                fontSize: 12, color: PennyPalColors.gray)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: PennyPalColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: PennyPalColors.border),
                    ),
                    child: Text(
                      u.$3 ? 'Active' : 'Suspended',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: u.$3
                            ? PennyPalColors.white
                            : PennyPalColors.lightGray,
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdminContent extends StatelessWidget {
  const _AdminContent();

  static const _content = [
    ('Budgeting 101', 'Published'),
    ('Saving Basics', 'Published'),
    ('Needs vs Wants', 'Published'),
    ('Understanding Income', 'Draft'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(children: [
            const Text('Learning Content',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PennyPalColors.white)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const AppIcon(AppIcons.add, size: 16, color: PennyPalColors.black),
              label: const Text('Add Content', style: TextStyle(color: PennyPalColors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: PennyPalColors.white,
                foregroundColor: PennyPalColors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            itemCount: _content.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final c = _content[i];
              final published = c.$2 == 'Published';
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PennyPalColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PennyPalColors.border),
                ),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: PennyPalColors.elevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                        child: AppIcon(AppIcons.book, color: PennyPalColors.white, size: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(c.$1,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: PennyPalColors.white)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: PennyPalColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: PennyPalColors.border),
                    ),
                    child: Text(
                      c.$2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: published
                            ? PennyPalColors.white
                            : PennyPalColors.lightGray,
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdminSupport extends StatelessWidget {
  const _AdminSupport();

  static const _tickets = [
    ('#1024', 'Budget problem', 'Pending'),
    ('#1023', 'Account issue', 'Resolved'),
    ('#1022', 'Transaction error', 'Pending'),
    ('#1021', 'Login issue', 'Resolved'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      itemCount: _tickets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final t = _tickets[i];
        final pending = t.$3 == 'Pending';
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PennyPalColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: PennyPalColors.border,
            ),
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: PennyPalColors.elevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppIcon(
                pending
                    ? AppIcons.fallback
                    : AppIcons.check,
                color: PennyPalColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.$2,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: PennyPalColors.white)),
                  Text(t.$1,
                      style: const TextStyle(
                          fontSize: 12, color: PennyPalColors.gray)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: PennyPalColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PennyPalColors.border),
              ),
              child: Text(
                t.$3,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: PennyPalColors.white,
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}
