import '../data/repositories/auth_repository.dart';
import '../infrastructure/controller/failure.dart';
import '../infrastructure/controller/response.dart';
import '../infrastructure/controller/rest_controller.dart';
import '../infrastructure/extenssions/request_context_ext.dart';

class SignUpController extends RestController {
  SignUpController({required this.repository});

  final AuthRepository repository;

  @override
  Future<Result<ApiResponse, Failure>>? post(RequestContext context) async {
    final body = await context.bodyAsMap();
    final login = body['login'] as String;
    final password = body['password'] as String;
    final result = await repository.signUp(login, password);
    return result.when(
      (sucess) => Success(
        ApiResponse.success({
          'jwt': sucess,
        }),
      ),
      (error) => Success(ApiResponse.badRequest(error)),
    );
  }
}
