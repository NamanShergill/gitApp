import 'package:dio_hub/app/settings/palette.dart';
import 'package:dio_hub/common/wrappers/infinite_scroll_wrapper.dart';
import 'package:dio_hub/models/repositories/branch_list_model.dart';
import 'package:dio_hub/services/repositories/repo_services.dart';
import 'package:dio_hub/style/border_radiuses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';

class BranchSelectSheet extends StatelessWidget {
  final String repoURL;
  final String? defaultBranch;
  final String? currentBranch;
  final ValueChanged<String>? onSelected;
  final ScrollController? controller;
  const BranchSelectSheet(this.repoURL,
      {this.defaultBranch,
      this.currentBranch,
      this.onSelected,
      this.controller,
      Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InfiniteScrollWrapper<RepoBranchListItemModel>(
      listEndIndicator: false,
      divider: false,
      firstDivider: false,
      future: (int pageNumber, int perPage, refresh, _) {
        return RepositoryServices.fetchBranchList(
            repoURL, pageNumber, perPage, refresh);
      },
      scrollController: controller,
      builder: (context, item, index, refresh) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Material(
            borderRadius: AppThemeBorderRadius.medBorderRadius,
            color: item.name == currentBranch
                ? Provider.of<PaletteSettings>(context).currentSetting.accent
                : Provider.of<PaletteSettings>(context)
                    .currentSetting
                    .secondary,
            child: InkWell(
              borderRadius: AppThemeBorderRadius.medBorderRadius,
              onTap: () {
                onSelected!(item.name!);
                Navigator.pop(context);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          const Icon(Octicons.git_branch),
                          const SizedBox(
                            width: 8,
                          ),
                          Flexible(
                            child: Text(
                              item.name!,
                              style: TextStyle(
                                  fontWeight: item.name == currentBranch
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: defaultBranch == item.name,
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                      replacement: Container(),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
