import 'package:bonfire/bonfire.dart';

/// Utilitários para operações com [Vector2] não disponíveis diretamente
/// na versão do vector_math exportada pelo bonfire.
class VectorUtils {
  VectorUtils._();

  /// Interpola linearmente entre [a] e [b] pelo fator [t] (0.0 a 1.0).
  ///
  /// Equivalente ao `Vector2.lerp` da vector_math, que não está exposto
  /// no export atual do bonfire.
  static Vector2 lerp(Vector2 a, Vector2 b, double t) {
    return Vector2(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
    );
  }
}
