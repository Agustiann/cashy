import '../entities/pos_entity.dart';

abstract class PosRepository {
  Future<PosEntity?> getPosSummary(String userId);
}
