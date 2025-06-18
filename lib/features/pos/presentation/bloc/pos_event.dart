abstract class PosEvent {}

class LoadPosEvent extends PosEvent {
  final String userId;

  LoadPosEvent(this.userId);
}
