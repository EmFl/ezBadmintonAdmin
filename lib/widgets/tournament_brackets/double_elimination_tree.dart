import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/layout/elimination_tree/elimination_tree_layout.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'bracket_widths.dart' as bracket_widths;

class DoubleEliminationTree extends StatelessWidget {
  DoubleEliminationTree({
    super.key,
    required this.tournament,
    required this.competition,
    this.isEditable = false,
    this.showResults = false,
  }) {
    matchNodeSize =
        SingleEliminationTree.getMatchNodeSize(competition.teamSize);
    layoutSize = _getLayoutSize();
  }

  final BadmintonDoubleElimination tournament;
  final Competition competition;

  final bool isEditable;
  final bool showResults;

  late final Size matchNodeSize;
  late final Size layoutSize;

  @override
  Widget build(BuildContext context) {
    SingleEliminationTree winnerBracket = SingleEliminationTree(
      rounds: tournament.winnerBracket.rounds,
      competition: competition,
      isEditable: isEditable,
      showResults: showResults,
    );

    List<List<Widget>> matchNodes = [];

    List<EliminationRound<BadmintonMatch>> rounds = tournament.rounds
        .map((round) => round.loserRound)
        .whereType<EliminationRound<BadmintonMatch>>()
        .toList();

    rounds.add(tournament.rounds.last.winnerRound!);

    for (EliminationRound<BadmintonMatch> round in rounds) {
      List<Widget> roundMatchNodes = round.matches.map((match) {
        Widget matchCard = MatchupCard(
          match: match,
          showResult: showResults,
          width: matchNodeSize.width,
        );

        return matchCard;
      }).toList();

      matchNodes.add(roundMatchNodes);
    }

    return DoubleEliminationTreeLayout(
      winnerBracket: winnerBracket,
      winnerBracketSize: winnerBracket.layoutSize,
      matchNodes: matchNodes,
      layoutSize: layoutSize,
      matchNodeSize: matchNodeSize,
    );
  }

  Size _getLayoutSize() {
    int numRounds = tournament.rounds.length - 1;
    int firstRoundSize = tournament.rounds[1].loserRound!.length;

    return Size(
      numRounds * matchNodeSize.width +
          (numRounds - 1) * bracket_widths.singleEliminationRoundGap,
      firstRoundSize * matchNodeSize.height +
          matchNodeSize.height * bracket_widths.relativeIntakeRoundOffset,
    );
  }
}