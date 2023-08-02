part of 'age_group_editing_cubit.dart';

class AgeGroupEditingState extends CollectionFetcherState<AgeGroupEditingState>
    implements DialogState {
  AgeGroupEditingState({
    this.ageGroupType = const SelectionInput.pure(emptyAllowed: true),
    this.age = const NoValidationInput.pure(),
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(),
    super.collections = const {},
  })  : formSubmittable = _isSubmittable(
          loadingStatus,
          formStatus,
          ageGroupType.value,
          age.value,
          (collections[AgeGroup] as List<AgeGroup>?) ?? [],
        ),
        isDeletable = _isDeletable(
          loadingStatus,
          formStatus,
        );

  final SelectionInput<AgeGroupType> ageGroupType;
  final NoValidationInput age;

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  final bool formSubmittable;
  final bool isDeletable;

  @override
  final CubitDialog dialog;

  AgeGroupEditingState copyWith({
    SelectionInput<AgeGroupType>? ageGroupType,
    NoValidationInput? age,
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    CubitDialog? dialog,
    Map<Type, List<Model>>? collections,
  }) {
    return AgeGroupEditingState(
      ageGroupType: ageGroupType ?? this.ageGroupType,
      age: age ?? this.age,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      dialog: dialog ?? this.dialog,
      collections: collections ?? this.collections,
    );
  }

  static bool _isSubmittable(
    LoadingStatus loadingStatus,
    FormzSubmissionStatus formStatus,
    AgeGroupType? ageGroupType,
    String age,
    List<AgeGroup> ageGroupCollection,
  ) {
    if (loadingStatus != LoadingStatus.done ||
        formStatus == FormzSubmissionStatus.inProgress ||
        ageGroupType == null ||
        age.isEmpty) {
      return false;
    }

    int parsedAge = int.parse(age);
    AgeGroup? existingAgeGroup = ageGroupCollection
        .where((g) => g.type == ageGroupType && g.age == parsedAge)
        .firstOrNull;

    return existingAgeGroup == null;
  }

  static bool _isDeletable(
    LoadingStatus loadingStatus,
    FormzSubmissionStatus formStatus,
  ) {
    return loadingStatus == LoadingStatus.done &&
        formStatus != FormzSubmissionStatus.inProgress;
  }
}
