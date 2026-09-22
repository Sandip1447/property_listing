import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/core/utils/validators.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';
import 'package:property_listing/features/interests/domain/repositories/interest_repository.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/domain/usecases/get_property_by_id_use_case.dart';
import 'package:uuid/uuid.dart';

@injectable
final class SubmitInterestUseCase {
  const SubmitInterestUseCase(
    this._interestRepository,
    this._getPropertyById,
    this._getCurrentSession,
    this._uuid,
  );

  final InterestRepository _interestRepository;
  final GetPropertyByIdUseCase _getPropertyById;
  final GetCurrentSessionUseCase _getCurrentSession;
  final Uuid _uuid;

  Future<Result<PropertyInterest>> call({
    required String propertyId,
    required String fullName,
    required String mobileNumber,
    required String email,
    required String message,
  }) async {
    final String? validationMessage =
        Validators.fullName(fullName) ??
        Validators.mobile(mobileNumber) ??
        Validators.email(email) ??
        Validators.interestMessage(message);
    if (validationMessage != null) {
      return FailureResult<PropertyInterest>(
        ValidationFailure(validationMessage),
      );
    }

    final Result<Property> propertyResult = await _getPropertyById(propertyId);
    final Property property;
    switch (propertyResult) {
      case Success<Property>(:final data):
        property = data;
      case FailureResult<Property>(:final failure):
        return FailureResult<PropertyInterest>(failure);
    }

    if (property.status != PropertyStatus.available &&
        property.status != PropertyStatus.underConstruction) {
      return const FailureResult<PropertyInterest>(
        ValidationFailure('Interest cannot be submitted for this property.'),
      );
    }

    final AuthSession? session = await _getCurrentSession();
    if (session == null) {
      return const FailureResult<PropertyInterest>(
        AuthenticationFailure('You must be signed in to submit interest.'),
      );
    }
    if (session.role != UserRole.user) {
      return const FailureResult<PropertyInterest>(
        AuthenticationFailure('Only users can submit property interests.'),
      );
    }

    final PropertyInterest interest = PropertyInterest(
      id: _uuid.v4(),
      propertyId: property.id,
      propertyName: property.name,
      ownerId: property.ownerId,
      userId: session.userId,
      fullName: fullName.trim(),
      mobileNumber: mobileNumber.trim(),
      email: email.trim(),
      message: message.trim(),
      createdAt: DateTime.now().toUtc(),
    );
    return _interestRepository.submitInterest(interest);
  }
}
