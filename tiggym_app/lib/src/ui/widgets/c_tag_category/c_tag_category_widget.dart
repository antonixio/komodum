import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import '../../../data/repository/tag_repository/tag_repository.dart';
import '../../../util/extensions/build_context_extensions.dart';
import '../../screens/tags/edit_tag_screen.dart';
import '../c_confirmation_dialog/c_confirmation_dialog_widget.dart';
import '../c_tag_item/c_tag_item_widget.dart';

class CTagCategoryWidget extends StatelessWidget {
  final bool isSelection;
  final TagCategoryModel tagCategory;
  const CTagCategoryWidget({
    super.key,
    required this.tagCategory,
    this.isSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CTagItemTappableWidget(
            tag: tagCategory.mainTag,
            onLongPress: !isSelection ? () => showOptions(context, tagCategory.mainTag) : null,
            onTap: isSelection
                ? () => context.pop(tagCategory.mainTag)
                : () {
                    context.push((context) => EditTagScreen(tag: tagCategory.mainTag));
                  },
          ),
        ),
        Wrap(
            spacing: 8,
            children: tagCategory.list
                .map((e) => CTagItemTappableWidget(
                      tag: e,
                      onLongPress: !isSelection ? () => showOptions(context, tagCategory.mainTag) : null,
                      onTap: isSelection
                          ? () => context.pop(e)
                          : () {
                              context.push((context) => EditTagScreen(tag: e));
                            },
                    ))
                .toList()),
      ],
    );
  }

  Future<void> showOptions(BuildContext context, TagModel e) async {
    context.showMaterialModalBottomSheet(
      (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        children: [
          ListTile(
            dense: true,
            onTap: () async {
              context.pop();
              context.push((context) => EditTagScreen(tag: tagCategory.mainTag));
            },
            leading: const Icon(Icons.edit, size: 12),
            title: Text(AppLocale.labelEdit.getTranslation(context)),
          ),
          if (!e.fromApp)
            ListTile(
              dense: true,
              leading: const Icon(Icons.delete, size: 12),
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              title: Text(AppLocale.labelDelete.getTranslation(context)),
              onTap: () async {
                context.pop();
                bool confirm = await CConfirmationDialogWidget.show(
                  context: context,
                  message: AppLocale.labelConfirmGenericDeletion.getTranslation(context),
                );

                if (confirm) {
                  await GetIt.I.get<TagRepository>().delete(e.id);
                }
              },
            )
        ],
      ),
    );
  }
}
