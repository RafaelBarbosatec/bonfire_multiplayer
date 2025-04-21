import '../data/repositories/user_repository.dart';
import '../../infrastructure/controller/failure.dart';
import '../../infrastructure/controller/response.dart';
import '../../infrastructure/controller/rest_controller.dart';
import '../../infrastructure/extenssions/request_context_ext.dart';
import '../usecases/generate_jwt_usecase.dart';

class SignUpController extends RestController {
  SignUpController({
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
    final result = await repository.createuser(login, password);
    return result.when(
      (user) {
        final token = generateJwtUsecase(user);
        return Success(
          ApiResponse.success({
            'jwt': token,
          }),
        );
      },
      (error) => Success(ApiResponse.badRequest(error)),
    );
  }
}
