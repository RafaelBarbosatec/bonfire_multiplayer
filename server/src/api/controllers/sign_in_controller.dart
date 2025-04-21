import '../../infrastructure/controller/failure.dart';
import '../../infrastructure/controller/response.dart';
import '../../infrastructure/controller/rest_controller.dart';
import '../../infrastructure/extenssions/request_context_ext.dart';
import '../data/repositories/user_repository.dart';
import '../usecases/generate_jwt_usecase.dart';

class SignInController extends RestController {
  SignInController({
    required this.repository,
    required this.generateJwtUsecase,
  });

  final UserRepository repository;
  final GenerateJwtUsecase generateJwtUsecase;
  @override
  Future<Result<ApiResponse, Failure>>? post(RequestContext context) async {
    final body = await context.bodyAsMap();
    final login = body['login'] as String;
    final password = body['password'] as String;
    final result = await repository.getUserByLogin(login, password);
    return result.when(
      (user) {
        final token = generateJwtUsecase(user);
        return Success(
          ApiResponse.success(
            {
              'jwt': token,
            },
          ),
        );
      },
      (error) => Error(
        Failure.badRequest(
          message: error.toString(),
        ),
      ),
    );
  }
}
