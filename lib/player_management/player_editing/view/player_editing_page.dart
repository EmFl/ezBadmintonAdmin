import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/layout/fab_location.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/player_editing_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/view/player_editing_form.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/progress_indicator_icon/progress_indicator_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';
import 'package:provider/provider.dart';

class PlayerEditingPage extends StatelessWidget {
  const PlayerEditingPage({
    super.key,
  });

  static Route<Player?> route() {
    return MaterialPageRoute<Player?>(
      builder: (_) => const PlayerEditingPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => PlayerEditingCubit(
        context: context,
        playerRepository: context.read<CollectionRepository<Player>>(),
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
        clubRepository: context.read<CollectionRepository<Club>>(),
        playingLevelRepository:
            context.read<CollectionRepository<PlayingLevel>>(),
        teamRepository: context.read<CollectionRepository<Team>>(),
      ),
      child: BlocConsumer<PlayerEditingCubit, PlayerEditingState>(
        listenWhen: (previous, current) =>
            current.formStatus == FormzSubmissionStatus.success,
        listener: (context, state) {
          Navigator.of(context).pop(state.player);
        },
        buildWhen: (previous, current) =>
            previous.isPure != current.isPure ||
            previous.formStatus != current.formStatus,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.addPlayer)),
            floatingActionButton: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 80, 40),
              child: FloatingActionButton.extended(
                onPressed: context.read<PlayerEditingCubit>().formSubmitted,
                label: Text(l10n.save),
                icon: state.formStatus == FormzSubmissionStatus.inProgress
                    ? const ProgressIndicatorIcon()
                    : const Icon(Icons.save),
              ),
            ),
            floatingActionButtonAnimator:
                FabTranslationAnimator(speedFactor: 2.5),
            floatingActionButtonLocation: state.isPure
                ? const EndOffscreenFabLocation()
                : FloatingActionButtonLocation.endFloat,
            body: _PlayerEditingPageContent(),
          );
        },
      ),
    );
  }
}

class _PlayerEditingPageContent extends StatelessWidget {
  _PlayerEditingPageContent();

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<PlayerEditingCubit>();
    return BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
      buildWhen: (previous, current) =>
          previous.loadingStatus != current.loadingStatus,
      builder: (context, state) {
        return LoadingScreen(
          loadingStatusGetter: () => state.loadingStatus,
          onRetry: () => cubit.loadPlayerData(),
          builder: (_) => Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 640,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  child: ChangeNotifierProvider.value(
                    value: scrollController,
                    child: const PlayerEditingForm(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
