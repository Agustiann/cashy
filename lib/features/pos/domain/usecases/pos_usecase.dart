import '../entities/pos_entity.dart';
import '../repositories/pos_repository.dart';

class GetPosSummary {
  final PosRepository repository;

  GetPosSummary(this.repository);

  Future<PosEntity?> call(String userId) {
    return repository.getPosSummary(userId);
  }
}
