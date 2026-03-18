abstract class CreateUserException {}

class UserAlreadyExistException implements CreateUserException {
  UserAlreadyExistException();
}
