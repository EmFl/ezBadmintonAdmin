import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/creation_date_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/utils/competition_registration.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'player_list_state.dart';

class PlayerListCubit extends CollectionFetcherCubit<PlayerListState> {
  PlayerListCubit({
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required CollectionRepository<Club> clubRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
            playerRepository,
            playingLevelRepository,
            ageGroupRepository,
            clubRepository,
          ],
          const PlayerListState(),
        ) {
    loadPlayerData();
    subscribeToCollectionUpdates(playerRepository, _collectionUpdated);
    subscribeToCollectionUpdates(competitionRepository, _collectionUpdated);
  }

  void loadPlayerData() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Player>(),
        collectionFetcher<Competition>(),
        collectionFetcher<PlayingLevel>(),
        collectionFetcher<AgeGroup>(),
        collectionFetcher<Club>(),
      ],
      onSuccess: (updatedState) {
        var playerCompetitions = mapCompetitionRegistrations(
          updatedState.getCollection<Player>(),
          updatedState.getCollection<Competition>(),
        );
        updatedState = updatedState.copyWith(
          competitionRegistrations: playerCompetitions,
          filteredPlayers: _sortPlayers(updatedState.getCollection<Player>()),
          loadingStatus: LoadingStatus.done,
        );
        emit(updatedState);
        filterChanged(null);
      },
      onFailure: () =>
          emit(state.copyWith(loadingStatus: LoadingStatus.failed)),
    );
  }

  void filterChanged(Map<Type, Predicate>? filters) {
    // Calling with filters == null just reapplies the current filters
    filters = filters ?? state.filters;
    var filtered = state.getCollection<Player>();
    List<Player>? filteredByCompetition;
    if (filters.containsKey(Player)) {
      filtered = filtered.where(filters[Player]!).toList();
    }
    if (filters.containsKey(Competition)) {
      var filteredCompetitions = state
          .getCollection<Competition>()
          .where(filters[Competition]!)
          .toList();
      var teams = filteredCompetitions
          .map((comp) => comp.registrations)
          .expand((teamList) => teamList);
      filteredByCompetition = teams
          .map((team) => team.players)
          .expand((playerList) => playerList)
          .toList();
    }
    if (filteredByCompetition != null) {
      filtered = filtered
          .where((player) => filteredByCompetition!.contains(player))
          .toList();
    }
    var newState = state.copyWith(
      filteredPlayers: _sortPlayers(filtered),
      filters: filters,
    );
    emit(newState);
  }

  void comparatorChanged(ListSortingComparator<Player> comparator) {
    emit(state.copyWith(sortingComparator: comparator));
    List<Player> sorted = _sortPlayers(state.filteredPlayers);
    emit(state.copyWith(filteredPlayers: sorted));
  }

  List<Player> _sortPlayers(List<Player> players) {
    Comparator<Player> comparator = state.sortingComparator.comparator;
    return players.sorted(comparator);
  }

  void _collectionUpdated(CollectionUpdateEvent event) {
    loadPlayerData();
  }
}
