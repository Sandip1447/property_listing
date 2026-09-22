import 'package:injectable/injectable.dart';
import 'package:property_listing/features/properties/data/datasources/property_local_data_source.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';

@lazySingleton
final class PropertySeedService {
  const PropertySeedService(this._localDataSource);

  final PropertyLocalDataSource _localDataSource;

  Future<void> seedIfRequired() async {
    if (_localDataSource.isInitialized) {
      return;
    }
    await _localDataSource.saveProperties(PropertySeedData.properties);
  }
}
