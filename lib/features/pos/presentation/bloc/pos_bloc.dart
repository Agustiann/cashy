import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/pos_usecase.dart';
import 'pos_event.dart';
import 'pos_state.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final GetPosSummary getPosSummary;

  PosBloc({required this.getPosSummary}) : super(PosInitial()) {
    on<LoadPosEvent>((event, emit) async {
      emit(PosLoading());
      try {
        final data = await getPosSummary(event.userId);
        if (data != null) {
          emit(PosLoaded(data));
        } else {
          emit(PosError("Data tidak ditemukan"));
        }
      } catch (e) {
        emit(PosError("Gagal memuat data: $e"));
      }
    });
  }
}
