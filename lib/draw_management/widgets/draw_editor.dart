import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/view/tournament_mode_assignment_page.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/competition_draw_selection_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/draw_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/draw_editing_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/drawing_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/widgets/tournament_mode_card.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/tournament_mode_hydration.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/tournament_bracket_explorer_controller_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/group_knockout_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tournament_mode/tournament_mode.dart';

class DrawEditor extends StatelessWidget {
  const DrawEditor({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => TournamentBracketExplorerControllerCubit(),
      child: BlocBuilder<CompetitionDrawSelectionCubit,
          CompetitionDrawSelectionState>(
        builder: (context, state) {
          if (state.selectedCompetition.value == null) {
            return Center(
              child: Text(
                l10n.noDrawCompetitionSelected,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(.25),
                  fontSize: 25,
                ),
              ),
            );
          }

          Competition selectedCompetition = state.selectedCompetition.value!;

          Widget drawView;

          if (selectedCompetition.tournamentModeSettings == null) {
            drawView = _TournamentModeAssignmentMenu(
              selectedCompetition: selectedCompetition,
            );
          } else if (selectedCompetition.draw.isNotEmpty) {
            drawView = _InteractiveDraw(competition: selectedCompetition);
          } else {
            drawView = _DrawMenu(selectedCompetition: selectedCompetition);
          }

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                key: ValueKey('DrawingCubit-${selectedCompetition.id}'),
                create: (context) => DrawingCubit(
                  competition: selectedCompetition,
                  competitionRepository:
                      context.read<CollectionRepository<Competition>>(),
                ),
              ),
              BlocProvider(
                key: ValueKey('DrawDeletionCubit-${selectedCompetition.id}'),
                create: (context) => DrawDeletionCubit(
                  competition: selectedCompetition,
                  competitionRepository:
                      context.read<CollectionRepository<Competition>>(),
                ),
              ),
              BlocProvider(
                key: ValueKey<String>(
                    'DrawEditingCubit${selectedCompetition.id}'),
                create: (context) => DrawEditingCubit(
                  competition: selectedCompetition,
                  competitionRepository:
                      context.read<CollectionRepository<Competition>>(),
                ),
              ),
            ],
            child: drawView,
          );
        },
      ),
    );
  }
}

class _InteractiveDraw extends StatelessWidget {
  const _InteractiveDraw({
    required this.competition,
  });

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    TournamentMode tournament = createTournamentMode(competition);

    Widget drawView = switch (tournament) {
      BadmintonSingleElimination tournament => SingleEliminationTree(
          rounds: tournament.rounds,
          competition: competition,
          isEditable: true,
        ),
      BadmintonRoundRobin tournament => RoundRobinPlan(
          tournament: tournament,
          competition: competition,
        ),
      BadmintonGroupKnockout tournament => GroupKnockoutPlan(
          tournament: tournament,
          competition: competition,
        ),
      _ => const Text('No View implemented yet'),
    };

    return TournamentBracketExplorer(
      competition: competition,
      tournamentBracket: drawView,
    );
  }
}

class _DrawMenu extends StatelessWidget {
  const _DrawMenu({
    required this.selectedCompetition,
  });

  final Competition selectedCompetition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Builder(builder: (context) {
      var cubit = context.read<DrawingCubit>();
      return DialogListener<DrawingCubit, DrawingState, void>(
        barrierDismissable: true,
        builder: (context, state, minParticipants) => AlertDialog(
          title: Text(l10n.notEnoughDrawParticipants),
          content: Text(l10n.notEnoughDrawParticipantsInfo(minParticipants)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.confirm),
            ),
          ],
        ),
        child: Center(
          child: TournamentModeCard(
            modeSettings: selectedCompetition.tournamentModeSettings!,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: cubit.makeDraw,
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(StadiumBorder()),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      l10n.makeDraw,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                _TournamentModeAssignmentButton(
                  selectedCompetition: selectedCompetition,
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _TournamentModeAssignmentMenu extends StatelessWidget {
  const _TournamentModeAssignmentMenu({
    required this.selectedCompetition,
  });

  final Competition selectedCompetition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.noTournamentMode,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(.25),
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 30),
          _TournamentModeAssignmentButton(
            selectedCompetition: selectedCompetition,
          ),
        ],
      ),
    );
  }
}

class _TournamentModeAssignmentButton extends StatelessWidget {
  const _TournamentModeAssignmentButton({
    required this.selectedCompetition,
  });

  final Competition selectedCompetition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    bool isEditButton = selectedCompetition.tournamentModeSettings != null;

    Text buttonLabel = Text(
      isEditButton ? l10n.changeTournamentMode : l10n.assignTournamentMode,
    );

    onPressed() {
      Navigator.push(
        context,
        TournamentModeAssignmentPage.route([selectedCompetition]),
      );
    }

    if (isEditButton) {
      return TextButton(
        onPressed: onPressed,
        child: buttonLabel,
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        child: buttonLabel,
      );
    }
  }
}
