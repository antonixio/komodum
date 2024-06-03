import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

class CItemListSelectWidget<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T) itemBuilder;
  final bool filterable;

  final List<T> Function(String) filter;
  const CItemListSelectWidget({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.filter,
    this.filterable = true,
  });

  @override
  State<CItemListSelectWidget<T>> createState() => _CItemListSelectWidgetState<T>();
}

class _CItemListSelectWidgetState<T> extends State<CItemListSelectWidget<T>> {
  late List<T> filtered = widget.items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32, top: 32),
        child: Column(
          children: [
            // if (widget.filterable) ...[
            //   CTextFieldWidget(
            //     hintText: AppLocale.search.getTranslation(context),
            //     onChanged: (t) {
            //       final text = t ?? '';

            //       if (text.isNotEmpty) {
            //         filtered = widget.filter(text);
            //       } else {
            //         filtered = widget.items;
            //       }
            //       setState(() {});
            //     },
            //   ),
            //   const Gap(16),
            // ],
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: filtered.map((e) => widget.itemBuilder.call(e)).addBetween(const Gap(8)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
