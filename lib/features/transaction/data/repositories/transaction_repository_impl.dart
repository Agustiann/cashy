import 'package:cashy/features/transaction/domain/entities/transaction_entity.dart';
import 'package:cashy/features/transaction/domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    await remoteDataSource.addTransaction(transaction);
  }
}
