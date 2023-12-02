import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_round_robin_ranking.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/mouse_hover_builder/mouse_hover_builder.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_participant_label.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RoundRobinResults extends StatelessWidget {
  const RoundRobinResults({
    super.key,
    required this.tournament,
    this.parentTournament,
  });

  final BadmintonRoundRobin tournament;

  final GroupKnockout? parentTournament;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundRobinLeaderboard(
          tournament: tournament,
          parentTournament: parentTournament,
        ),
        const SizedBox(height: 30),
        _MatchResultList(tournament: tournament),
      ],
    );
  }
}

class _RoundRobinLeaderboard extends StatelessWidget {
  const _RoundRobinLeaderboard({
    required this.tournament,
    this.parentTournament,
  });

  final BadmintonRoundRobin tournament;

  final GroupKnockout? parentTournament;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    const TextStyle statNameStyle = TextStyle(fontSize: 11);
    TableRow leaderboardHeader = TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).disabledColor,
            width: 2,
          ),
        ),
      ),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14.0),
          child: Center(child: Text('#')),
        ),
        _buildTitle(context),
        Center(child: Text(l10n.match(2), style: statNameStyle)),
        Center(child: Text(l10n.win(2), style: statNameStyle)),
        Center(child: Text(l10n.game(2), style: statNameStyle)),
        Center(child: Text(l10n.point(2), style: statNameStyle)),
      ],
    );

    BadmintonRoundRobinRanking ranking =
        tournament.finalRanking as BadmintonRoundRobinRanking;

    List<List<MatchParticipant<Team>>> ranks = ranking.currentTiedRank();
    Map<Team, RoundRobinStats> stats = ranking.getStats();

    List<TableRow> leaderboardEntries = [];
    for (List<MatchParticipant<Team>> rank in ranks) {
      for (MatchParticipant<Team> participant in rank) {
        Team team = participant.resolvePlayer()!;
        RoundRobinStats teamStats = stats[team]!;

        TableRow row = TableRow(
          children: [
            if (rank.first == participant)
              _RankNumber(rankIndex: ranks.indexOf(rank))
            else
              const _RankNumber(rankIndex: null),
            MatchParticipantLabel(
              participant,
              teamSize: tournament.competition.teamSize,
              isEditable: false,
              padding: const EdgeInsets.all(8.0),
            ),
            _StatNumber(teamStats.numMatches),
            _DualStatNumber(teamStats.wins, teamStats.losses),
            _DualStatNumber(teamStats.setsWon, teamStats.setsLost),
            _DualStatNumber(teamStats.pointsWon, teamStats.pointsLost),
          ],
        );

        leaderboardEntries.add(row);
      }
    }

    const double rankWidth = 42;
    const double teamWidth = 250;
    const double statNumberWidth = 50;
    const double dualStatNumberWidth = 65;

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(rankWidth),
        1: FixedColumnWidth(teamWidth),
        2: FixedColumnWidth(statNumberWidth),
        3: FixedColumnWidth(dualStatNumberWidth),
        4: FixedColumnWidth(dualStatNumberWidth),
        5: FixedColumnWidth(dualStatNumberWidth),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.2),
        borderRadius: BorderRadius.circular(10),
      ),
      children: [
        leaderboardHeader,
        ...leaderboardEntries,
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    if (parentTournament == null) {
      return const SizedBox();
    }

    int groupIndex =
        parentTournament!.groupPhase.groupRoundRobins.indexOf(tournament);

    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: Container(
        color: Theme.of(context).primaryColor.withOpacity(.45),
        child: Center(
          child: Text(
            l10n.groupNumber(groupIndex + 1),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchResultList extends StatelessWidget {
  const _MatchResultList({
    required this.tournament,
  });

  final BadmintonRoundRobin tournament;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (RoundRobinRound round in tournament.rounds) ...[
          Text(
            l10n.encounterNumber(round.roundNumber + 1),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          for (BadmintonMatch match in round.matches.cast())
            MatchupCard(
              match: match,
              showResult: true,
              width: 330,
            ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RankNumber extends StatelessWidget {
  const _RankNumber({
    this.rankIndex,
  });

  final int? rankIndex;

  @override
  Widget build(BuildContext context) {
    TextStyle rankStyle = const TextStyle(fontWeight: FontWeight.bold);

    Widget number = rankIndex == null
        ? const SizedBox()
        : Text('${rankIndex! + 1}.', style: rankStyle);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: number,
      ),
    );
  }
}

class _StatNumber extends StatelessWidget {
  const _StatNumber(this.number);

  final int number;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child: Text('$number')),
    );
  }
}

class _DualStatNumber extends StatelessWidget {
  const _DualStatNumber(this.number1, this.number2);

  final int number1;
  final int number2;

  int get _difference => number1 - number2;

  @override
  Widget build(BuildContext context) {
    TextStyle numberStyle =
        TextStyle(color: Theme.of(context).colorScheme.onSurface);

    TextStyle colonStyle = TextStyle(color: Theme.of(context).disabledColor);

    Widget dualNumber = RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '$number1', style: numberStyle),
          const WidgetSpan(child: SizedBox(width: 1)),
          TextSpan(text: ':', style: colonStyle),
          const WidgetSpan(child: SizedBox(width: 1)),
          TextSpan(text: '$number2', style: numberStyle),
        ],
      ),
    );

    Color differenceColor = switch (_difference) {
      > 0 => Colors.greenAccent.withOpacity(.4),
      < 0 => Colors.redAccent.withOpacity(.3),
      _ => Theme.of(context).colorScheme.surface,
    };
    String differenceSign = switch (_difference) {
      > 0 => '+',
      < 0 => '-',
      _ => '±',
    };
    int absDifference = _difference.abs();
    Widget difference = Text('$differenceSign$absDifference');

    return MouseHoverBuilder(
      builder: (context, isHovered) => Container(
        color: isHovered ? differenceColor : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: isHovered ? difference : dualNumber,
          ),
        ),
      ),
    );
  }
}
