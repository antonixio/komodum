import 'package:flutter/material.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

class CSetGroupsWidget extends StatelessWidget {
  final List<ExerciseSetGroupTrainingSessionModel> groups;
  const CSetGroupsWidget({
    super.key,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const Text("No sets...");
    }
    return Wrap(
      children: groups.map((e) => CSetGroupResumeWidget(group: e)).toList(),
    );
  }
}

class CSetGroupResumeWidget extends StatelessWidget {
  final ExerciseSetGroupTrainingSessionModel group;
  const CSetGroupResumeWidget({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final checked = group.sets.isNotEmpty && group.sets.every((element) => element.done);
    return Icon(
      checked ? Icons.check_circle : Icons.circle_outlined,
      size: 16,
      color: checked ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
    );
  }
}
