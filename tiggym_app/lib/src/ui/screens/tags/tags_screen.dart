import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../../data/repository/tag_repository/tag_repository.dart';
import '../../../util/extensions/build_context_extensions.dart';
import '../../widgets/c_tag_category/c_tag_category_widget.dart';
import 'edit_tag_screen.dart';

class TagsScreen extends StatefulWidget {
  final bool isSelection;
  const TagsScreen({
    super.key,
    this.isSelection = false,
  });

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final tagRepository = GetIt.I.get<TagRepository>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          actions: [
            IconButton(
              onPressed: () {
                context.push((context) => const EditTagScreen());
              },
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: StreamBuilder(
            stream: tagRepository.tagCategories,
            initialData: tagRepository.tagCategories.value,
            builder: (context, snapshot) {
              final data = snapshot.data ?? <TagCategoryModel>[];
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
                children: data
                    .map<Widget>((e) => CTagCategoryWidget(
                          tagCategory: e,
                          isSelection: widget.isSelection,
                        ))
                    .addBetween(const Gap(20))
                    .toList(),
              );
            }),
      ),
    );
  }
}
