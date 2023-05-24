import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/player_editing_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/view/competition_registration_form.dart';
import 'package:ez_badminton_admin_app/widgets/constrained_autocomplete/constrained_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class PlayerEditingForm extends StatelessWidget {
  const PlayerEditingForm({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return BlocListener<PlayerEditingCubit, PlayerEditingState>(
      listenWhen: (previous, current) =>
          previous.formStatus == FormzSubmissionStatus.inProgress &&
          current.formStatus == FormzSubmissionStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.saveError)));
      },
      child: const _PlayerEditingFormFields(),
    );
  }
}

class _PlayerEditingFormFields extends StatelessWidget {
  const _PlayerEditingFormFields();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<PlayerEditingCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.personalData,
          style: const TextStyle(fontSize: 22),
        ),
        const Divider(height: 25, indent: 20, endIndent: 20),
        Row(
          children: [
            _NameInput(
              labelText: '${l10n.firstName}*',
              onChanged: cubit.firstNameChanged,
              formInputGetter: (state) => state.firstName,
              initialValue: cubit.state.firstName.value,
            ),
            const SizedBox(width: 25),
            _NameInput(
              labelText: '${l10n.lastName}*',
              onChanged: cubit.lastNameChanged,
              formInputGetter: (state) => state.lastName,
              initialValue: cubit.state.lastName.value,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            _DateOfBirthInput(
              onChanged: cubit.dateOfBirthChanged,
              formInputGetter: (state) => state.dateOfBirth,
              initialValue: cubit.state.dateOfBirth.value,
            ),
            const SizedBox(width: 25),
            _EMailInput(
              onChanged: cubit.eMailChanged,
              formInputGetter: (state) => state.eMail,
              initialValue: cubit.state.eMail.value,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            _ClubInput(
              onChanged: cubit.clubNameChanged,
              initialValue: cubit.state.clubName.value,
            ),
            const SizedBox(width: 25),
            _PlayingLevelInput(onChanged: cubit.playingLevelChanged),
          ],
        ),
        const SizedBox(height: 60),
        Text(
          l10n.registeredCompetitions,
          style: const TextStyle(fontSize: 22),
        ),
        const Divider(height: 25, indent: 20, endIndent: 20),
        const CompetitionRegistrationForm(),
      ],
    );
  }
}

class _EMailInput extends StatelessWidget {
  _EMailInput({
    required this.onChanged,
    required this.formInputGetter,
    required String initialValue,
  }) {
    _controller.text = initialValue;
  }

  final void Function(String value) onChanged;
  final FormzInput Function(PlayerEditingState state) formInputGetter;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
        builder: (context, state) {
          return TextField(
            onChanged: onChanged,
            controller: _controller,
            decoration: InputDecoration(
              label: Text(l10n.eMail),
              errorText: (state.formStatus == FormzSubmissionStatus.failure &&
                      formInputGetter(state).isNotValid)
                  ? l10n.formatError
                  : null,
              counterText: ' ',
            ),
          );
        },
      ),
    );
  }
}

class _DateOfBirthInput extends StatelessWidget {
  _DateOfBirthInput({
    required this.onChanged,
    required this.formInputGetter,
    required String initialValue,
  }) {
    _controller.text = initialValue;
  }

  final void Function(String value) onChanged;
  final FormzInput Function(PlayerEditingState state) formInputGetter;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
        builder: (context, state) {
          return TextField(
            onChanged: onChanged,
            controller: _controller,
            decoration: InputDecoration(
              label: Text(l10n.dateOfBirth),
              hintText: MaterialLocalizations.of(context)
                  .dateHelpText, // DateFormat.yMd()
              errorText: (state.formStatus == FormzSubmissionStatus.failure &&
                      formInputGetter(state).isNotValid)
                  ? l10n.formatError
                  : null,
              counterText: ' ',
              suffixIcon: IconButton(
                onPressed: () => showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                ).then((date) {
                  if (date == null) {
                    return;
                  }
                  String formatted =
                      MaterialLocalizations.of(context).formatCompactDate(date);
                  _controller.text = formatted;
                  onChanged(formatted);
                }),
                icon: const Icon(Icons.calendar_month_outlined),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlayingLevelInput extends StatelessWidget {
  _PlayingLevelInput({
    required this.onChanged,
  });

  final void Function(PlayingLevel? value) onChanged;
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
        builder: (context, state) {
          return DropdownButtonFormField<PlayingLevel>(
            value: state.playingLevel.value,
            onChanged: onChanged,
            items: state.playingLevels
                .map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level.name),
                    ))
                .toList(),
            focusNode: _focusNode,
            decoration: InputDecoration(
              label: Text(l10n.playingLevel),
              counterText: ' ',
              suffixIcon: state.playingLevel.value == null
                  ? null
                  : IconButton(
                      tooltip:
                          MaterialLocalizations.of(context).deleteButtonTooltip,
                      onPressed: () {
                        onChanged(null);
                        _focusNode.unfocus();
                      },
                      icon: const Icon(Icons.highlight_remove),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _ClubInput extends StatelessWidget {
  _ClubInput({
    required this.onChanged,
    required String initialValue,
  }) {
    _controller.text = initialValue;
  }

  final void Function(String value) onChanged;
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) =>
            BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
          buildWhen: (previous, current) =>
              previous.clubName != current.clubName ||
              previous.clubs != current.clubs,
          builder: (context, state) {
            return ConstrainedAutocomplete<String>(
              optionsBuilder: (clubName) => _createClubSuggestions(
                clubName.text,
                state.clubs.map((c) => c.name),
              ),
              onSelected: onChanged,
              constraints: constraints,
              fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) =>
                  TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  label: Text(l10n.club),
                  counterText: ' ',
                ),
                onChanged: onChanged,
              ),
              focusNode: _focus,
              textEditingController: _controller,
            );
          },
        ),
      ),
    );
  }

  static List<String> _createClubSuggestions(
    String clubName,
    Iterable<String> allClubNames,
  ) {
    if (clubName.isEmpty) {
      return allClubNames.toList();
    }
    var begins = allClubNames.where(
      (n) => n.toLowerCase().startsWith(clubName.toLowerCase()),
    );
    var contains = allClubNames.where(
      (n) =>
          n.toLowerCase().contains(clubName.toLowerCase()) &&
          !begins.contains(n),
    );

    var suggestions = begins.toList()..addAll(contains);
    return suggestions;
  }
}

class _NameInput extends StatelessWidget {
  _NameInput({
    required this.labelText,
    required this.onChanged,
    required this.formInputGetter,
    required String initialValue,
  }) {
    _controller.text = initialValue;
  }

  final String labelText;
  final FormzInput Function(PlayerEditingState state) formInputGetter;
  final void Function(String value) onChanged;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
        builder: (context, state) {
          return TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: labelText,
              errorText: (state.formStatus == FormzSubmissionStatus.failure &&
                      formInputGetter(state).isNotValid)
                  ? l10n.pleaseFillIn
                  : null,
              counterText: ' ',
            ),
            onChanged: onChanged,
          );
        },
      ),
    );
  }
}
