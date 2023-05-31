import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:collection_repository/collection_repository.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

import 'model_converter.dart';

part 'generated/match_set.freezed.dart';
part 'generated/match_set.g.dart';

@freezed
class MatchSet extends Model with _$MatchSet {
  const MatchSet._();

  /// One set in a badminton [Match]
  ///
  /// A badminton [match] usually consists of 2-3 sets with the winning team
  /// reaching 21 points (2 points clear) first. The [index] signals the order
  /// of sets in the match.
  const factory MatchSet({
    required String id,
    required DateTime created,
    required DateTime updated,
    required Match match,
    required int index,
    required int team1Points,
    required int team2Points,
  }) = _MatchSet;

  factory MatchSet.fromJson(Map<String, dynamic> json) => _$MatchSetFromJson(
      ModelConverter.convertExpansions(json, expandedFields));

  static const List<ExpandedField> expandedFields = [
    ExpandedField(model: Match, key: 'match', isRequired: true, isSingle: true),
  ];

  @override
  Map<String, dynamic> toCollapsedJson() {
    Map<String, dynamic> json = this.toJson();
    return ModelConverter.collapseExpansions(json, expandedFields);
  }
}