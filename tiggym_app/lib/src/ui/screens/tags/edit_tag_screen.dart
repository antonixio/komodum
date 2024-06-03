import 'package:flutter/material.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/repository/tag_repository/tag_repository.dart';
import '../../../util/extensions/build_context_extensions.dart';
import '../../widgets/c_confirmation_dialog/c_confirmation_dialog_widget.dart';
import '../../widgets/c_item_list_select/c_item_list_select_widget.dart';
import '../../widgets/c_tag_item/c_tag_item_widget.dart';

class EditTagScreen extends StatefulWidget {
  final TagModel? tag;
  const EditTagScreen({
    super.key,
    this.tag,
  });

  @override
  State<EditTagScreen> createState() => _EditTagScreenState();
}

class _EditTagScreenState extends State<EditTagScreen> {
  final tagRepository = GetIt.I.get<TagRepository>();

  late final tag = BehaviorSubject.seeded(widget.tag ?? TagModel.dummy);
  final GlobalKey<FormState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          actions: [
            if (!tag.value.fromApp)
              IconButton(
                onPressed: () async {
                  if (key.currentState!.validate()) {
                    if (tag.value.id <= 0) {
                      context.pop();

                      tagRepository.insert(tag.value);
                    } else {
                      final mainTag = tagRepository.tagCategories.value.firstWhereOrNull((element) => element.mainTag.id == tag.value.mainTagId)?.mainTag;
                      bool widgetTagIsMain = widget.tag?.mainTag ?? false;
                      bool confirm = (!widgetTagIsMain ||
                          (widgetTagIsMain && tag.value.mainTag) ||
                          widgetTagIsMain &&
                              !tag.value.mainTag &&
                              await CConfirmationDialogWidget.show(
                                context: context,
                                message: AppLocale.messageChangingMainTagToNormalTag.getTranslation(context).replaceAll('%changingtag%', tag.value.name).replaceAll('%tagunder%', mainTag?.name ?? ''),
                              ));

                      if (confirm) {
                        if (mounted) {
                          context.pop();
                        }
                        tagRepository.updateAndValidateUnder(tag.value, tag.value.id);
                      }
                    }
                  }
                },
                icon: const Icon(Icons.check),
              )
          ],
        ),
        body: StreamBuilder(
            stream: tag,
            initialData: tag.value,
            builder: (context, snapshot) {
              final data = snapshot.data!;
              return Form(
                key: key,
                child: ListView(
                  padding: const EdgeInsets.all(32),
                  children: [
                    if (tag.value.fromApp)
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning,
                              color: Theme.of(context).colorScheme.error,
                              size: 16,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                AppLocale.messageDefaultTag.getTranslation(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    TextFormField(
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                      readOnly: tag.value.fromApp,
                      initialValue: data.getName(context),
                      onChanged: (v) {
                        tag.add(tag.value.copyWith(name: v));
                      },
                      validator: (v) {
                        if (tag.value.name.trim().isEmpty) {
                          return AppLocale.labelRequired.getTranslation(context);
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: AppLocale.labelName.getTranslation(context),
                        border: InputBorder.none,
                      ),
                    ),
                    const Gap(8),
                    Row(
                      children: [
                        Text(AppLocale.labelUnder.getTranslation(context)),
                        const Gap(8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CTagItemTappableWidget(
                            tag: tagRepository.tagCategories.value.firstWhereOrNull((element) => element.mainTag.id == data.mainTagId)?.mainTag ?? TagModel.tagNone,
                            onTap: data.fromApp
                                ? () {}
                                : () async {
                                    final t = await context.push(
                                      (context) => CItemListSelectWidget(
                                        items: [TagModel.tagNone, ...tagRepository.tagCategories.value.map((e) => e.mainTag)],
                                        itemBuilder: (t) => Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            CTagItemTappableWidget(
                                              tag: t,
                                              onTap: () {
                                                context.pop(t);
                                              },
                                            ),
                                          ],
                                        ),
                                        filterable: false,
                                        filter: (_) => [],
                                      ),
                                    );
                                    if (t != null && t is TagModel) {
                                      tag.add(
                                        tag.value.copyWith(
                                          mainTagId: () => t.id <= 0 ? null : t.id,
                                          mainTag: t.id <= 0 ? true : false,
                                          color: t.id <= 0 ? TagModel.dummy.color : t.color,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    if (data.mainTag) ...[
                      Text(AppLocale.labelColor.getTranslation(context)),
                      const Gap(4),
                      GridView.count(
                        crossAxisCount: (MediaQuery.sizeOf(context).width / 28).ceil(),
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        shrinkWrap: true,
                        children: Colors.accents
                            .fold(<Color>[], (p, e) => p..addAll([e.shade100, e.shade200, e, e.shade400, e.shade700]))
                            .map(
                              (e) => Material(
                                  color: e,
                                  borderRadius: BorderRadius.circular(6),
                                  child: InkWell(
                                    onTap: data.fromApp
                                        ? null
                                        : () {
                                            tag.add(tag.value.copyWith(color: e));
                                          },
                                    child: data.color == e
                                        ? Center(
                                            child: Icon(
                                              Icons.check,
                                              size: 16,
                                              color: e.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                            ),
                                          )
                                        : null,
                                  )),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              );
            }),
      ),
    );
  }
}
