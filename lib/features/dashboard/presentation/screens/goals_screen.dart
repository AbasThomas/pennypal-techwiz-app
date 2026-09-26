import 'package:flutter/material.dart';
import 'plan_screen.dart';

/// Kept for route compatibility. Savings goals are managed by the live Plans view.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlanScreen();
}
