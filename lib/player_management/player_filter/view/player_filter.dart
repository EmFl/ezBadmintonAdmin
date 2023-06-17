import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';
import 'package:ez_badminton_admin_app/widgets/multi_chip/multi_chip.dart';
import 'package:ez_badminton_admin_app/widgets/popover_menu/popover_menu.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class PlayerFilter extends StatelessWidget {
  const PlayerFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 1150,
      child: Column(
        children: [
          _FilterMenus(),
          SizedBox(height: 10),
          _FilterChips(),
        ],
      ),
    );
  }
}

class _FilterMenus extends StatelessWidget {
  const _FilterMenus();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return BlocListener<PlayerFilterCubit, PlayerFilterState>(
      listenWhen: (_, current) => current.filterPredicate != null,
      listener: (context, state) {
        var listFilter = context.read<PredicateFilterCubit>();
        listFilter.consumePredicate(state.filterPredicate!);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FilterPopoverMenu(
            filterMenu: _PlayingLevelFilterForm(backgroudContext: context),
            buttonText: l10n.playingLevel,
          ),
          const SizedBox(width: 10),
          FilterPopoverMenu(
            filterMenu: _AgeFilterForm(backgroundContext: context),
            buttonText: l10n.age,
          ),
          const SizedBox(width: 10),
          FilterPopoverMenu(
            filterMenu: _GenderCategoryFilterForm(backgroundContext: context),
            buttonText: l10n.category,
          ),
          const SizedBox(width: 10),
          FilterPopoverMenu(
            filterMenu: _CompetitionTypeFilterForm(backgroudContext: context),
            buttonText: l10n.competition,
          ),
          const SizedBox(width: 10),
          FilterPopoverMenu(
            filterMenu: _StatusFilterForm(backgroudContext: context),
            buttonText: l10n.status,
          ),
          const SizedBox(width: 30),
          Expanded(child: _SearchField()),
        ],
      ),
    );
  }
}

class _PlayingLevelFilterForm extends StatelessWidget {
  const _PlayingLevelFilterForm({
    required this.backgroudContext,
  });

  final BuildContext backgroudContext;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
      bloc: backgroudContext.read<PlayerFilterCubit>(),
      buildWhen: (previous, current) =>
          previous.allPlayingLevels != current.allPlayingLevels,
      builder: (_, state) {
        PlayerFilterCubit cubit = backgroudContext.read<PlayerFilterCubit>();
        PlayingLevelPredicateProducer predicateProducer =
            cubit.getPredicateProducer<PlayingLevelPredicateProducer>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: state.allPlayingLevels
              .map(
                (playingLevel) => _FilterCheckbox(
                  backgroundContext: backgroudContext,
                  checkboxValue: playingLevel,
                  predicateProducer: predicateProducer,
                  toggledValuesGetter: () => predicateProducer.playingLevels,
                  onToggle: predicateProducer.playingLevelToggled,
                  label: playingLevel.name,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _CompetitionTypeFilterForm extends StatelessWidget {
  const _CompetitionTypeFilterForm({
    required this.backgroudContext,
  });

  final BuildContext backgroudContext;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    PlayerFilterCubit cubit = backgroudContext.read<PlayerFilterCubit>();
    CompetitionTypePredicateProducer predicateProducer =
        cubit.getPredicateProducer<CompetitionTypePredicateProducer>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: CompetitionType.values
          .map(
            (competitionType) => _FilterCheckbox(
              backgroundContext: backgroudContext,
              checkboxValue: competitionType,
              predicateProducer: predicateProducer,
              toggledValuesGetter: () => predicateProducer.competitionTypes,
              onToggle: predicateProducer.competitionTypeToggled,
              label: l10n.competitionType(competitionType.name),
            ),
          )
          .toList(),
    );
  }
}

class _SearchField extends StatelessWidget {
  _SearchField();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var predicateProducer = context
        .read<PlayerFilterCubit>()
        .getPredicateProducer<SearchPredicateProducer>();
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
      buildWhen: (_, current) => predicateProducer.searchTerm.isEmpty,
      builder: (_, __) {
        _controller.text = predicateProducer.searchTerm;
        return TextField(
          controller: _controller,
          onChanged: (searchTerm) =>
              predicateProducer.searchTermChanged(searchTerm),
          decoration: InputDecoration(
            hintText: l10n.playerSearchHint,
            prefixIcon: const Icon(Icons.search),
          ),
        );
      },
    );
  }
}

class _GenderCategoryFilterForm extends StatelessWidget {
  const _GenderCategoryFilterForm({
    required this.backgroundContext,
  });

  final BuildContext backgroundContext;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    PlayerFilterCubit cubit = backgroundContext.read<PlayerFilterCubit>();
    GenderCategoryPredicateProducer predicateProducer =
        cubit.getPredicateProducer<GenderCategoryPredicateProducer>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (GenderCategory category in [
          GenderCategory.female,
          GenderCategory.male,
        ]) ...[
          _FilterCheckbox(
            backgroundContext: backgroundContext,
            label: l10n.genderCategory(category.name),
            checkboxValue: category,
            onToggle: predicateProducer.categoryToggled,
            predicateProducer: predicateProducer,
            toggledValuesGetter: () => predicateProducer.categories,
          ),
          if (category != GenderCategory.male) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _AgeFilterForm extends StatelessWidget {
  const _AgeFilterForm({
    required this.backgroundContext,
  });

  final BuildContext backgroundContext;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _AgeInput(
          overAge: false,
          labelText: l10n.underAge,
          filterCubit: backgroundContext.read<PlayerFilterCubit>(),
        ),
        const SizedBox(height: 10),
        _AgeInput(
          overAge: true,
          labelText: l10n.overAge,
          filterCubit: backgroundContext.read<PlayerFilterCubit>(),
        ),
      ],
    );
  }
}

class _StatusFilterForm extends StatelessWidget {
  const _StatusFilterForm({
    required this.backgroudContext,
  });

  final BuildContext backgroudContext;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    PlayerFilterCubit cubit = backgroudContext.read<PlayerFilterCubit>();
    StatusPredicateProducer predicateProducer =
        cubit.getPredicateProducer<StatusPredicateProducer>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: PlayerStatus.values
          .map(
            (playerStatus) => _FilterCheckbox(
              backgroundContext: backgroudContext,
              checkboxValue: playerStatus,
              predicateProducer: predicateProducer,
              toggledValuesGetter: () => predicateProducer.statusList,
              onToggle: predicateProducer.statusToggled,
              label: l10n.playerStatus(playerStatus.name),
            ),
          )
          .toList(),
    );
  }
}

class _FilterCheckbox<T> extends StatelessWidget {
  const _FilterCheckbox({
    required this.backgroundContext,
    required this.checkboxValue,
    required this.predicateProducer,
    required this.toggledValuesGetter,
    required this.onToggle,
    required this.label,
  });

  final BuildContext backgroundContext;
  final T checkboxValue;
  final PredicateProducer predicateProducer;
  final List<T> Function() toggledValuesGetter;
  final Function(T) onToggle;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
          bloc: backgroundContext.read<PlayerFilterCubit>(),
          buildWhen: (_, current) =>
              current.filterPredicate != null &&
              predicateProducer.producesDomain(current.filterPredicate!.domain),
          builder: (_, __) {
            return Checkbox(
              value: toggledValuesGetter().contains(checkboxValue),
              onChanged: (value) {
                onToggle(checkboxValue);
              },
            );
          },
        ),
        Center(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class FilterPopoverMenu extends StatelessWidget {
  const FilterPopoverMenu({
    super.key,
    required this.filterMenu,
    required this.buttonText,
  });

  final String buttonText;
  final Widget filterMenu;

  @override
  Widget build(BuildContext context) {
    return PopoverMenuButton(
      menu: Card(
        margin: const EdgeInsets.all(0.0),
        color: Theme.of(context).cardColor,
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.background,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: filterMenu,
        ),
      ),
      label: Text(buttonText),
    );
  }
}

class _AgeInput extends StatelessWidget {
  _AgeInput({
    required this.overAge,
    required this.labelText,
    required this.filterCubit,
  })  : _focusNode = FocusNode(),
        _controller = TextEditingController() {
    var predicateProducer =
        filterCubit.getPredicateProducer<AgePredicateProducer>();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        predicateProducer.produceAgePredicates();
      }
    });
    _controller.text =
        overAge ? predicateProducer.overAge : predicateProducer.underAge;
    if (!overAge) {
      _focusNode.requestFocus();
    }
  }

  final bool overAge;
  final String labelText;
  final PlayerFilterCubit filterCubit;
  final FocusNode _focusNode;
  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    var predicateProducer =
        filterCubit.getPredicateProducer<AgePredicateProducer>();
    return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
      bloc: filterCubit,
      builder: (context, state) {
        return Card(
          margin: EdgeInsets.zero,
          color: Theme.of(context).primaryColor,
          shape: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 40),
                  child: SizedBox(
                    child: Text(
                      labelText,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 30,
                  child: TextField(
                    key: Key(
                      'ageFilterForm_${overAge ? 'over' : 'under'}AgeInput_textField',
                    ),
                    controller: _controller,
                    onChanged: overAge
                        ? (age) => predicateProducer.overAgeChanged(age)
                        : (age) => predicateProducer.underAgeChanged(age),
                    onSubmitted: (_) => PopoverMenu.of(context).close(),
                    focusNode: _focusNode,
                    textAlignVertical: TextAlignVertical.top,
                    cursorColor: Theme.of(context).colorScheme.onPrimary,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(2),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          HSLColor.fromColor(Theme.of(context).primaryColor)
                              .withLightness(.65)
                              .toColor(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 7),
                      isDense: true,
                      enabledBorder:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PredicateFilterCubit, PredicateFilterState>(
      builder: (context, state) {
        Iterable<FilterPredicate> predicates =
            state.filterPredicates.values.expand((p) => p);
        Iterable<FilterPredicate> disjunctPredicates =
            predicates.where((p) => p.disjunction != null);
        Iterable<FilterPredicate> conjunctPredicates =
            predicates.where((p) => p.disjunction == null);
        Map<FilterGroup, List<FilterPredicate>> disjunctGroups =
            groupBy<FilterPredicate, FilterGroup>(
          disjunctPredicates,
          (p) => p.disjunction!,
        );
        Map<FilterGroup, List<FilterPredicate>> conjunctGroups =
            groupBy<FilterPredicate, FilterGroup>(
          conjunctPredicates,
          (p) => p.domain,
        );
        Map<FilterGroup, List<FilterPredicate>> filterGroups = conjunctGroups
          ..removeWhere((key, _) => key == FilterGroup.search)
          ..addAll(disjunctGroups);

        // Age filters go into the same MultiChip despite being in different
        // filter groups
        List<MapEntry<FilterGroup, List<FilterPredicate>>> ageFilters =
            filterGroups
                .entries
                .where((e) =>
                    [FilterGroup.overAge, FilterGroup.underAge].contains(e.key))
                .toList();
        filterGroups.removeWhere(
          (key, _) => [FilterGroup.overAge, FilterGroup.underAge].contains(key),
        );

        return Wrap(
          children: [
            for (MapEntry<FilterGroup, List<FilterPredicate>> filterGroup
                in filterGroups.entries)
              _FilterGroupChip(
                filterGroupName:
                    display_strings.filterChipGroup(l10n, filterGroup.key),
                namedFilters: {
                  for (FilterPredicate filter in filterGroup.value)
                    display_strings.filterChip(
                      l10n,
                      filterGroup.key,
                      filter.name,
                    ): filter,
                },
              ),
            if (ageFilters.isNotEmpty)
              _FilterGroupChip(
                filterGroupName:
                    display_strings.filterChipGroup(l10n, ageFilters.first.key),
                namedFilters: {
                  for (MapEntry<FilterGroup, List<FilterPredicate>> ageFilter
                      in ageFilters)
                    display_strings.filterChip(
                      l10n,
                      ageFilter.key,
                      ageFilter.value.first.name,
                    ): ageFilter.value.first,
                },
              ),
          ],
        );
      },
    );
  }
}

class _FilterGroupChip extends StatelessWidget {
  const _FilterGroupChip({
    required this.filterGroupName,
    required this.namedFilters,
  });

  final String filterGroupName;
  final Map<String, FilterPredicate> namedFilters;

  @override
  Widget build(BuildContext context) {
    PlayerFilterCubit cubit = context.read<PlayerFilterCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5.0,
        vertical: 3.0,
      ),
      child: MultiChip(
        title: filterGroupName,
        items: namedFilters.keys.map((filterName) => Text(filterName)).toList(),
        onDeleted: namedFilters.values
            .map(
              (p) => () {
                cubit.onPredicateRemoved(p);
              },
            )
            .toList(),
      ),
    );
  }
}
