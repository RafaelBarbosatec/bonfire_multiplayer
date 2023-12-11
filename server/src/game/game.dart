abstract class Game<T> {
  void start();
  void stop();
  void enterPlayer(T client);
  void leavePlayer(T client);
  void onUpdate();
  void requestUpdate();
  List<dynamic> players();
}
