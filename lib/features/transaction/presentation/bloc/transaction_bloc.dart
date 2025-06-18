import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/usecases/transaction_usecases.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final AddTransaction addTransactionUseCase;

  TransactionBloc({required this.addTransactionUseCase})
      : super(TransactionInitial()) {
    on<LoadSources>(_onLoadSources);
    on<AddNewTransaction>(_onAddNewTransaction);
  }

  Future<void> _onLoadSources(
      LoadSources event, Emitter<TransactionState> emit) async {
    emit(SourceLoading());
    try {
      final response =
          await Supabase.instance.client.rpc('get_budget_sources') as List;
      final List<String> sources =
          response.map((e) => e['source'] as String).toList();
      emit(SourceLoaded(sources));
    } catch (e) {
      emit(SourceError('Gagal memuat sumber anggaran'));
    }
  }

  Future<void> _onAddNewTransaction(
      AddNewTransaction event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());

    try {
      final isExpense = event.source != null;

      final transaction = TransactionEntity(
        userId: event.userId,
        amount: event.amount,
        type: isExpense ? 'expense' : 'income',
        category: event.category,
        note: event.note,
        date: event.date,
        source: event.source,
      );

      final client = Supabase.instance.client;

      if (isExpense) {
        final month = event.date.month;
        final year = event.date.year;

        final budgetData = await client
            .from('budget_allocation')
            .select()
            .eq('user_id', event.userId)
            .eq('month', month)
            .eq('year', year)
            .maybeSingle();

        if (budgetData == null) {
          emit(TransactionFailure("Belum ada alokasi anggaran bulan ini"));
          return;
        }

        final currentAmount = event.amount;
        final source = event.source!;

        final budgetValue = budgetData[source] as num? ?? 0;

        if (budgetValue < currentAmount) {
          String msg = switch (source) {
            'needs' => "dana kebutuhan tidak cukup",
            'wants' => "dana keinginan tidak cukup",
            'savings' => "dana tabungan tidak cukup",
            _ => "dana tidak cukup",
          };
          emit(TransactionFailure(msg));
          return;
        }
        final updatedValue = budgetValue - currentAmount;
        final newTotalExpense =
            (budgetData['total_expense'] as num? ?? 0) + currentAmount;

        await client
            .from('budget_allocation')
            .update({
              source: updatedValue,
              'total_expense': newTotalExpense,
            })
            .eq('user_id', event.userId)
            .eq('month', month)
            .eq('year', year);
      }

      await addTransactionUseCase(transaction);

      emit(TransactionSuccess());
    } catch (e) {
      emit(TransactionFailure(e.toString()));
    }
  }
}
