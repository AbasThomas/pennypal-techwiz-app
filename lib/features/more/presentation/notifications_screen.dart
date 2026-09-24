import 'package:flutter/material.dart';
import 'package:bootstrap_flutter/core/widgets/app_icon.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PennyPalColors.black,
      appBar: AppBar(
        backgroundColor: PennyPalColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Notifications',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PennyPalColors.white)),
        iconTheme: const IconThemeData(color: PennyPalColors.white),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all read',
                style:
                    TextStyle(color: PennyPalColors.white, fontSize: 13)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: const [
          _DateLabel(label: 'Today'),
          SizedBox(height: 8),
          _NotifTile(
            icon: AppIcons.warning,
            title: 'Budget Alert',
            body: "You've used 85% of your Food budget.",
            time: '2 min ago',
            unread: true,
          ),
          _NotifTile(
            icon: AppIcons.piggyBank,
            title: 'Savings Update',
            body: "You're 5,000 away from your Laptop goal.",
            time: '1 hr ago',
            unread: true,
          ),
          _NotifTile(
            icon: AppIcons.bulb,
            title: 'PennyPal Tip',
            body: 'Try setting aside your savings first each month.',
            time: '3 hr ago',
            unread: false,
          ),
          SizedBox(height: 16),
          _DateLabel(label: 'Yesterday'),
          SizedBox(height: 8),
          _NotifTile(
            icon: AppIcons.check,
            title: 'Transaction Added',
            body: 'Expense of 3,500 was recorded successfully.',
            time: 'Sep 23',
            unread: false,
          ),
          _NotifTile(
            icon: AppIcons.chartBar,
            title: 'Monthly Summary Ready',
            body: 'Your September report is now available.',
            time: 'Sep 23',
            unread: false,
          ),
        ],
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: PennyPalColors.muted,
          ),
        ),
      );
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
  });

  final List<List<dynamic>> icon;
  final String title;
  final String body;
  final String time;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: PennyPalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unread
              ? PennyPalColors.border
              : PennyPalColors.mutedBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: PennyPalColors.elevated,
                  borderRadius: BorderRadius.circular(11)),
              child: Center(
                child: AppIcon(icon, color: PennyPalColors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(title,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: unread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: PennyPalColors.white)),
                    ),
                    Text(time,
                        style: const TextStyle(
                            fontSize: 11, color: PennyPalColors.muted)),
                  ]),
                  const SizedBox(height: 4),
                  Text(body,
                      style: const TextStyle(
                          fontSize: 13,
                          color: PennyPalColors.gray,
                          height: 1.4)),
                ],
              ),
            ),
            if (unread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: PennyPalColors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
