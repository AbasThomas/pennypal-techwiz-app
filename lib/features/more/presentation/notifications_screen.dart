import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Notifications',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all read',
                style:
                    TextStyle(color: AppColors.primary, fontSize: 13)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _DateLabel(label: 'Today'),
          const SizedBox(height: 8),
          _NotifTile(
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.gold,
            iconBg: const Color(0xFFFFFBEB),
            title: 'Budget Alert',
            body: "You've used 85% of your Food budget.",
            time: '2 min ago',
            unread: true,
          ),
          _NotifTile(
            icon: Icons.flag_rounded,
            iconColor: AppColors.primary,
            iconBg: const Color(0xFFF0FDF4),
            title: 'Savings Update',
            body: "You're ₦5,000 away from your Laptop goal.",
            time: '1 hr ago',
            unread: true,
          ),
          _NotifTile(
            icon: Icons.lightbulb_outline_rounded,
            iconColor: const Color(0xFF7C3AED),
            iconBg: const Color(0xFFF5F3FF),
            title: 'PennyPal Tip',
            body: 'Try setting aside your savings first each month.',
            time: '3 hr ago',
            unread: false,
          ),
          const SizedBox(height: 16),
          _DateLabel(label: 'Yesterday'),
          const SizedBox(height: 8),
          _NotifTile(
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppColors.primary,
            iconBg: const Color(0xFFF0FDF4),
            title: 'Transaction Added',
            body: 'Expense of ₦3,500 was recorded successfully.',
            time: 'Sep 23',
            unread: false,
          ),
          _NotifTile(
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFF4F46E5),
            iconBg: const Color(0xFFF0F4FF),
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
            color: AppColors.muted,
          ),
        ),
      );
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String body;
  final String time;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unread
              ? AppColors.primary.withValues(alpha: 0.25)
              : const Color(0xFFE2E8F0),
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
                  color: iconBg, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: iconColor, size: 20),
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
                              color: AppColors.text)),
                    ),
                    Text(time,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.muted)),
                  ]),
                  const SizedBox(height: 4),
                  Text(body,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
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
                  color: AppColors.primary,
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
