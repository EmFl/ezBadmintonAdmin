// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:collection_repository/collection_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCollectionRepository<M extends Model> extends Mock
    implements CollectionRepository<M> {}

void main() {
  late CachedCollectionRepository<Player> sut;
  late CollectionRepository<Player> targetCollectionRepository;
  late CollectionRepository<Club> clubRepository;

  group('call delegation to the wrapped targetCollectionRepository', () {
    setUp(() {
      targetCollectionRepository = MockCollectionRepository<Player>();
      sut = CachedCollectionRepository(targetCollectionRepository);

      when(
        () => targetCollectionRepository.updateStream,
      ).thenAnswer((_) => Stream.fromIterable([]));

      when(
        () => targetCollectionRepository.dispose(),
      ).thenAnswer((invocation) async {});
    });

    test(
      'decorator returns update stream of targetCollectionRepository',
      () {
        sut.updateStream;
        verify(() => targetCollectionRepository.updateStream).called(1);
      },
    );

    test(
      'decorator calls dispose() of targetCollectionRepository',
      () {
        sut.dispose();
        verify(() => targetCollectionRepository.dispose()).called(1);
      },
    );
  });

  group('cached collection queries', () {
    List<Player> playerCollection = ['0', '1', '2']
        .map((id) => Player.newPlayer().copyWith(id: id))
        .toList();
    setUp(() {
      targetCollectionRepository = TestCollectionRepository<Player>(
        initialCollection: playerCollection,
        responseDelay: const Duration(milliseconds: 1),
      );
      sut = CachedCollectionRepository(targetCollectionRepository);
    });

    Completer<T> wrapInCompleter<T>(Future<T> future) {
      final completer = Completer<T>();
      future.then(completer.complete);
      return completer;
    }

    test(
      """first list fetch is cache miss, following is cache hit, both fetch
      results are equal""",
      () async {
        var uncachedFetch = wrapInCompleter(sut.getList());
        await Future.delayed(Duration.zero);
        expect(uncachedFetch.isCompleted, false);
        var uncachedResult = await uncachedFetch.future;

        var cachedFetch = wrapInCompleter(sut.getList());
        await Future.delayed(Duration.zero);
        expect(cachedFetch.isCompleted, true);
        var cachedResult = await cachedFetch.future;

        expect(uncachedResult, cachedResult);
      },
    );

    test(
      """first single fetch is cache miss, following is cache hit, both fetch
      results are equal""",
      () async {
        var uncachedFetch = wrapInCompleter(sut.getModel('0'));
        await Future.delayed(Duration.zero);
        expect(uncachedFetch.isCompleted, false);
        var uncachedResult = await uncachedFetch.future;

        var cachedFetch = wrapInCompleter(sut.getModel('0'));
        await Future.delayed(Duration.zero);
        expect(cachedFetch.isCompleted, true);
        var cachedResult = await cachedFetch.future;

        expect(uncachedResult, cachedResult);
      },
    );

    test(
      'creating a model also caches it',
      () async {
        Player newPlayer = await sut.create(Player.newPlayer());
        var cachedFetch = wrapInCompleter(sut.getModel(newPlayer.id));
        await Future.delayed(Duration.zero);
        expect(cachedFetch.isCompleted, true);
        var cachedResult = await cachedFetch.future;

        expect(cachedResult, newPlayer);
      },
    );

    test(
      'updating a model also caches it',
      () async {
        expect(await sut.getList(), playerCollection);
        await sut.update(playerCollection[0].copyWith(firstName: 'updated'));
        var cachedFetch = wrapInCompleter(sut.getList());
        await Future.delayed(Duration.zero);
        expect(cachedFetch.isCompleted, true);
        var cachedResult = await cachedFetch.future;

        expect(cachedResult.length, playerCollection.length);
        expect(
          cachedResult
              .where((p) => p.id == playerCollection[0].id)
              .first
              .firstName,
          'updated',
        );
      },
    );

    test(
      'deleting a model also deletes it from cache',
      () async {
        await sut.getList();
        await sut.delete(playerCollection[0]);
        List<Player> cachedCollection = await sut.getList();
        List<Player> collection = await targetCollectionRepository.getList();

        expect(cachedCollection.length, playerCollection.length - 1);
        expect(cachedCollection.contains(playerCollection[0]), false);
        expect(collection.length, playerCollection.length - 1);
        expect(collection.contains(playerCollection[0]), false);
      },
    );

    test(
      """fetching the full list after fetching some single models replaces the
      cache with the full list""",
      () async {
        await sut.getModel('0');
        await sut.getModel('1');

        var uncachedResult = await sut.getList();

        expect(uncachedResult.length, playerCollection.length);
      },
    );
  });

  group('relation update handlers', () {
    List<Club> clubs = List.generate(
      3,
      (index) => Club.newClub(
        name: 'Club-$index',
      ).copyWith(id: 'Club-$index'),
    );
    List<Player> players = clubs
        .map(
          (club) => Player.newPlayer().copyWith(
            club: club,
            id: 'Player-${club.id}',
          ),
        )
        .toList();

    setUp(() {
      clubRepository = TestCollectionRepository<Club>(
        initialCollection: clubs,
      );
      targetCollectionRepository = TestCollectionRepository<Player>(
        initialCollection: players,
      );
      sut = CachedCollectionRepository(
        targetCollectionRepository,
        relationRepositories: [clubRepository],
        relationUpdateHandler: (collection, updateEvent) {
          Club club = updateEvent.model as Club;
          List<Player> updatedPlayers = collection
              .where((player) => player.club == club)
              .map((player) => player.copyWith(club: club))
              .toList();
          return updatedPlayers;
        },
      );
    });

    test('update events are subscribed', () {
      expect(clubRepository.updateStreamController.hasListener, isTrue);
    });

    test('relation update causes cached models to be updated', () async {
      Club updatedClub = clubs[0].copyWith(name: 'updated');
      await clubRepository.update(updatedClub);

      await Future.delayed(Duration.zero);

      Player updatedPlayer = await sut.getModel(players[0].id);
      expect(updatedPlayer.club!.name, 'updated');

      updatedPlayer = await targetCollectionRepository.getModel(players[0].id);
      expect(updatedPlayer.club!.name, isNot('updated'));
    });
  });
}
