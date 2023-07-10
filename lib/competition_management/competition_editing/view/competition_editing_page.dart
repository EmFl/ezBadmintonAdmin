import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_editing/cubit/competition_adding_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_editing/view/competition_addition_preview.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/widgets/checkbox_group/checkbox_column.dart';
import 'package:ez_badminton_admin_app/widgets/checkbox_group/checkbox_group.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class CompetitionEditingPage extends StatelessWidget {
  const CompetitionEditingPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const CompetitionEditingPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompetitionAddingCubit(
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
        ageGroupRepository: context.read<CollectionRepository<AgeGroup>>(),
        playingLevelRepository:
            context.read<CollectionRepository<PlayingLevel>>(),
      ),
      child: const _CompetitionEditingPageScaffold(),
    );
  }
}

class _CompetitionEditingPageScaffold extends StatelessWidget {
  const _CompetitionEditingPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addSubject(l10n.competition(2))),
      ),
      body: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 1150,
          child: BlocBuilder<CompetitionAddingCubit, CompetitionAddingState>(
            builder: (context, state) {
              return LoadingScreen(
                loadingStatus: _getLoadingScreenStatus(state),
                builder: (_) => const Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _AgeGroupSelectionForm(),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: _PlayingLevelSelectionForm(),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    _CompetitionCategorySelectionForm(),
                    SizedBox(height: 40),
                    CompetitionAdditionPreview(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  LoadingStatus _getLoadingScreenStatus(CompetitionAddingState state) {
    if (state.collections.isNotEmpty &&
        state.loadingStatus == LoadingStatus.loading) {
      return LoadingStatus.done;
    }
    return state.loadingStatus;
  }
}

class _AgeGroupSelectionForm extends StatelessWidget {
  const _AgeGroupSelectionForm();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<CompetitionAddingCubit>();
    return BlocBuilder<CompetitionAddingCubit, CompetitionAddingState>(
      builder: (context, state) {
        return CheckboxGroup<AgeGroup>(
          title: Text(
            l10n.ageGroup(2),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          elements: state.getCollection<AgeGroup>(),
          onChange: cubit.ageGroupsChanged,
          groupBuilder: (context, ageGroups, onToggle, isEnabled) {
            return CheckboxColumn(
              children: ageGroups,
              onToggle: onToggle,
              isEnabled: isEnabled,
              displayStringFunction: (ageGroup) =>
                  display_strings.ageGroup(l10n, ageGroup),
            );
          },
        );
      },
    );
  }
}

class _PlayingLevelSelectionForm extends StatelessWidget {
  const _PlayingLevelSelectionForm();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<CompetitionAddingCubit>();
    return BlocBuilder<CompetitionAddingCubit, CompetitionAddingState>(
      builder: (context, state) {
        return CheckboxGroup<PlayingLevel>(
          title: Text(
            l10n.playingLevel(2),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          elements: state.getCollection<PlayingLevel>(),
          onChange: cubit.playingLevelsChanged,
          groupBuilder: (context, playingLevels, onToggle, isEnabled) {
            return CheckboxColumn(
              children: playingLevels,
              onToggle: onToggle,
              isEnabled: isEnabled,
              displayStringFunction: (playingLevel) => playingLevel.name,
            );
          },
        );
      },
    );
  }
}

class _CompetitionCategorySelectionForm extends StatelessWidget {
  const _CompetitionCategorySelectionForm();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<CompetitionAddingCubit>();
    return BlocBuilder<CompetitionAddingCubit, CompetitionAddingState>(
      builder: (context, state) {
        return CheckboxGroup<CompetitionCategory>(
          title: Text(
            l10n.basicCompetition(2),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          elements: CompetitionCategory.defaultCompetitions,
          onChange: cubit.competitionCategoriesChanged,
          groupBuilder: (context, competitionCategories, onToggle, isEnabled) {
            return Wrap(
              children: [
                for (CompetitionCategory competitionCategory
                    in competitionCategories)
                  FractionallySizedBox(
                    widthFactor: .5,
                    child: CheckboxListTile(
                      title: Text(
                        display_strings.competitionCategory(
                          l10n,
                          competitionCategory,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: isEnabled(competitionCategory),
                      onChanged: (_) => onToggle(competitionCategory),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}