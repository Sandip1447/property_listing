abstract final class AppRoutes {
  static const String splashName = 'splash';
  static const String splashPath = '/';

  static const String loginName = 'login';
  static const String loginPath = '/login';

  static const String userDashboardName = 'user-dashboard';
  static const String userDashboardPath = '/user';
  static const String userPropertiesName = 'user-properties';
  static const String userPropertiesPath = '/user/properties';
  static const String userPropertyDetailName = 'user-property-detail';
  static const String userPropertyDetailPath = '/user/properties/:propertyId';
  static const String submitInterestName = 'submit-interest';
  static const String submitInterestPath =
      '/user/properties/:propertyId/interest';
  static const String userFavouritesName = 'user-favourites';
  static const String userFavouritesPath = '/user/favourites';

  static const String ownerDashboardName = 'owner-dashboard';
  static const String ownerDashboardPath = '/owner';
  static const String ownerPropertiesName = 'owner-properties';
  static const String ownerPropertiesPath = '/owner/properties';
  static const String ownerAddPropertyName = 'owner-add-property';
  static const String ownerAddPropertyPath = '/owner/properties/add';
  static const String ownerEditPropertyName = 'owner-edit-property';
  static const String ownerEditPropertyPath =
      '/owner/properties/:propertyId/edit';
  static const String ownerPropertyDetailName = 'owner-property-detail';
  static const String ownerPropertyDetailPath = '/owner/properties/:propertyId';
  static const String ownerInterestsName = 'owner-interests';
  static const String ownerInterestsPath = '/owner/interests';
}
