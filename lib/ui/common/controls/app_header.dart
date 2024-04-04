import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wonders/automator.dart';
import 'package:wonders/common_libs.dart';
import 'package:wonders/ui/common/app_icons.dart';

class AppHeader extends StatelessWidget {
  const AppHeader(
      {super.key,
      this.title,
      this.subtitle,
      this.showBackBtn = true,
      this.isTransparent = false,
      this.onBack,
      this.trailing,
      this.backIcon = AppIcons.prev,
      this.backBtnSemantics});
  final String? title;
  final String? subtitle;
  final bool showBackBtn;
  final AppIcons backIcon;
  final String? backBtnSemantics;
  final bool isTransparent;
  final VoidCallback? onBack;
  final Widget Function(BuildContext context)? trailing;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: isTransparent ? Colors.transparent : $styles.colors.black,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64 * $styles.scale,
          child: Stack(
            children: [
              MergeSemantics(
                child: Semantics(
                  header: true,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null)
                          Text(
                            title!.toUpperCase(),
                            textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
                            style: $styles.text.h4.copyWith(
                              color: $styles.colors.offWhite,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (subtitle != null)
                          Text(
                            subtitle!.toUpperCase(),
                            textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
                            style: $styles.text.title1.copyWith(color: $styles.colors.accent1),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Row(
                    children: [
                      Gap($styles.insets.sm),
                      if (showBackBtn)
                        BackBtn(
                          onPressed: onBack,
                          icon: backIcon,
                          semanticLabel: backBtnSemantics,
                        ),
                      const SizedBox(width: 16.0),
                      ValueListenableBuilder<bool>(
                        valueListenable: Automator.instance.automating,
                        builder: (context, automating, _) => IconButton.filled(
                          onPressed: () {
                            if (automating) {
                              Automator.instance.stopAutomation();
                            } else {
                              unawaited(Automator.instance.beginAutomation());
                            }
                          },
                          icon: Icon(automating ? Icons.stop : Icons.play_arrow),
                        ),
                      ),
                      Spacer(),
                      if (trailing != null) trailing!.call(context),
                      Gap($styles.insets.sm),
                      //if (showBackBtn) Container(width: $styles.insets.lg * 2, alignment: Alignment.centerLeft, child: child),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
