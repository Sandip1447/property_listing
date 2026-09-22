abstract final class StorageKeys {
  static const String accessToken = 'access_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';

  static const String displayName = 'display_name';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String lastFilter = 'last_filter';
  static const String sortPreference = 'sort_preference';
  static const String favouritePropertyIds = 'favourite_property_ids';
  static const String propertiesJson = 'properties_json';
  static const String interestsJson = 'interests_json';

  static const List<String> sessionKeys = <String>[
    accessToken,
    userId,
    userRole,
  ];
}
