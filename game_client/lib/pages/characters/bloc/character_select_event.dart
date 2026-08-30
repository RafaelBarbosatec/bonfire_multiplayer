part of 'character_select_bloc.dart';

sealed class CharacterSelectEvent extends Equatable {
  const CharacterSelectEvent();

  @override
  List<Object> get props => [];
}

class LoadCharactersEvent extends CharacterSelectEvent {}

class CreateCharacterEvent extends CharacterSelectEvent {
  final String nickName;
  final PlayerSkin skin;

  const CreateCharacterEvent({required this.nickName, required this.skin});

  @override
  List<Object> get props => [nickName, skin];
}

class SelectCharacterEvent extends CharacterSelectEvent {
  final CharacterSummary character;

  const SelectCharacterEvent({required this.character});

  @override
  List<Object> get props => [character];
}

class EnterGameEvent extends CharacterSelectEvent {
  final JoinMapEvent ackEvent;

  const EnterGameEvent({required this.ackEvent});

  @override
  List<Object> get props => [ackEvent];
}

class JoinErrorEvent extends CharacterSelectEvent {
  final String message;

  const JoinErrorEvent({required this.message});

  @override
  List<Object> get props => [message];
}

class LogoutEvent extends CharacterSelectEvent {}
