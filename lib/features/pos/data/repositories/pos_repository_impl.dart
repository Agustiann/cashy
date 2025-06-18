import '../../domain/entities/pos_entity.dart';
import '../../domain/repositories/pos_repository.dart';
import '../datasources/pos_remote_datasource.dart';

class PosRepositoryImpl implements PosRepository {
  final PosRemoteDataSource remoteDataSource;

  PosRepositoryImpl(this.remoteDataSource);

  @override
  Future<PosEntity?> getPosSummary(String userId) {
    return remoteDataSource.fetchPosData(userId);
  }
}
