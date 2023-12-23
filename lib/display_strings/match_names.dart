import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension EliminationMatchNames on EliminationRound {
  String getEliminationMatchName(AppLocalizations l10n, BadmintonMatch match) {
    switch (tournament) {
      case BadmintonSingleElimination _:
        return _getSingleEliminationMatchName(l10n, match);
      case BadmintonSingleEliminationWithConsolation _:
        return _getConsolationMatchName(l10n, match);
      default:
        throw Exception(
          'This EliminationRound has no match naming implemented',
        );
    }
  }

  String _getSingleEliminationMatchName(
    AppLocalizations l10n,
    BadmintonMatch match,
  ) {
    String roundName = l10n.roundOfN('$roundSize');

    if (roundSize == 2) {
      // Final needs no round number
      return roundName;
    }

    int roundIndex = matches.indexOf(match) % (roundSize ~/ 2);

    return l10n.roundN(roundName, '${roundIndex + 1}');
  }

  String _getConsolationMatchName(
    AppLocalizations l10n,
    BadmintonMatch match,
  ) {
    BadmintonSingleEliminationWithConsolation tournament =
        this.tournament as BadmintonSingleEliminationWithConsolation;

    BracketWithConsolation consolationBracket = tournament.allBrackets
        .firstWhere((bracket) => bracket.bracket.matches.contains(match));

    String eliminationMatchName = _getSingleEliminationMatchName(l10n, match);

    if (consolationBracket.parent == null) {
      /// The main bracket has no consolation round name
      return eliminationMatchName;
    }

    (int, int) rankRange = consolationBracket.getRankRange();

    String consolationRoundName;
    if (rankRange == (2, 3)) {
      return l10n.matchForThrid;
    } else {
      consolationRoundName =
          l10n.upperToLowerRank(rankRange.$2 + 1, rankRange.$1 + 1);
    }

    return '$consolationRoundName\n$eliminationMatchName';
  }
}

extension RoundRobinMatchNames on RoundRobinRound {
  String getRoundRobinMatchName(AppLocalizations l10n) {
    return l10n.roundRobinMatchN(roundNumber + 1);
  }
}

extension GroupPhaseMatchNames on GroupPhaseRound<BadmintonMatch> {
  String getGroupMatchName(AppLocalizations l10n, BadmintonMatch match) {
    RoundRobinRound<BadmintonMatch> groupRound = nestedRounds.firstWhere(
      (roundRobin) => roundRobin.matches.contains(match),
    );

    int groupNumber = nestedRounds.indexOf(groupRound);

    return l10n.groupNMatchN(groupNumber + 1, roundNumber + 1);
  }
}

extension DoubleEliminationMatchNames on DoubleEliminationRound {
  String getDoubleEliminationMatchName(
    AppLocalizations l10n,
    BadmintonMatch match,
  ) {
    bool isInWinnerBracket = winnerRound?.matches.contains(match) ?? false;

    if (isInWinnerBracket) {
      bool isUpperFinal =
          winnerRound!.roundSize == 2 && this.loserRound != null;

      if (isUpperFinal) {
        return l10n.upperFinal;
      }

      return winnerRound!.getEliminationMatchName(l10n, match);
    }

    EliminationRound loserRound = this.loserRound!;

    String losersBracket = l10n.losersBracket;
    String roundName = l10n.roundOfN('${loserRound.roundSize}');

    int loserBracketRoundStage = winnerRound != null ? 1 : 2;

    String roundNumber;
    if (loserRound.roundSize == 2) {
      roundNumber = '$loserBracketRoundStage';
    } else {
      int matchIndex = loserRound.matches.indexOf(match);

      roundNumber = '$loserBracketRoundStage.${matchIndex + 1}';
    }

    return '$losersBracket\n$roundName $roundNumber';
  }
}