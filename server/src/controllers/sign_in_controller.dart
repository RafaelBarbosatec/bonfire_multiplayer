import '../infrastructure/controller/failure.dart';
import '../infrastructure/controller/response.dart';
import '../infrastructure/controller/rest_controller.dart';

class SignInController extends RestController {
  @override
  Future<Result<ApiResponse, Failure>>? post(RequestContext context) async {
    return Success(ApiResponse.success('Hello World'));
  }
}
