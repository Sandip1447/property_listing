import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:property_listing/core/di/injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(initializerName: 'init', preferRelativeImports: true)
Future<void> configureDependencies() async {
  await getIt.init();
}
