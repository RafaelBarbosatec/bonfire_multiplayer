import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/bootstrap_injector.dart';
import 'package:bonfire_multiplayer/data/models/character_summary.dart';
import 'package:bonfire_multiplayer/pages/characters/bloc/character_select_bloc.dart';
import 'package:bonfire_multiplayer/pages/game/game_route.dart';
import 'package:bonfire_multiplayer/pages/login/login_route.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterSelectPage extends StatefulWidget {
  const CharacterSelectPage({super.key});

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage> {
  late CharacterSelectBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = inject();
    _bloc.add(LoadCharactersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CharacterSelectBloc, CharacterSelectState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state.ackEvent != null) {
          GameRoute.open(context, state.ackEvent!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Seus personagens'),
            actions: [
              IconButton(
                tooltip: 'Sair',
                icon: const Icon(Icons.logout),
                onPressed: () {
                  _bloc.add(LogoutEvent());
                  LoginRoute.open(context);
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: state.creating || state.joining
                ? null
                : () => _showCreateDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Novo personagem'),
          ),
          body: Stack(
            children: [
              _buildBody(state),
              if (state.joining) ...[
                Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Entrando no mundo...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(CharacterSelectState state) {
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _bloc.add(LoadCharactersEvent()),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.characters.isEmpty) {
      return const Center(
        child: Text(
          'Você ainda não tem personagens.\nCrie o primeiro!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: state.characters.length,
      itemBuilder: (context, index) {
        final character = state.characters[index];
        return _CharacterCard(
          character: character,
          onTap: () => _bloc.add(SelectCharacterEvent(character: character)),
        );
      },
    );
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<_CreateCharacterData>(
      context: context,
      builder: (dialogContext) => const _CreateCharacterDialog(),
    );
    // Only touch the bloc AFTER the dialog route is fully popped. Adding the
    // event while the pop is in-flight made the page rebuild collide with the
    // dialog teardown (framework `_dependents.isEmpty` assertion).
    if (result != null && mounted) {
      _bloc.add(CreateCharacterEvent(
        nickName: result.nickName,
        skin: result.skin,
      ));
    }
  }
}

class _CreateCharacterData {
  const _CreateCharacterData({required this.nickName, required this.skin});

  final String nickName;
  final PlayerSkin skin;
}

class _CreateCharacterDialog extends StatefulWidget {
  const _CreateCharacterDialog();

  @override
  State<_CreateCharacterDialog> createState() => _CreateCharacterDialogState();
}

class _CreateCharacterDialogState extends State<_CreateCharacterDialog> {
  final _nickNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  PlayerSkin _skin = PlayerSkin.boy;

  @override
  void dispose() {
    _nickNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo personagem'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nickNameController,
              decoration: const InputDecoration(
                labelText: 'Apelido',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Informe um apelido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: PlayerSkin.values.map((skinOption) {
                final selected = skinOption == _skin;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: InkWell(
                    onTap: () => setState(() => _skin = skinOption),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected ? Colors.green : Colors.grey,
                              width: selected ? 3 : 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: FutureBuilder(
                            future: Sprite.load(
                              skinOption.path,
                              srcSize: Vector2.all(32),
                              srcPosition: Vector2(0, 32),
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox(
                                  width: 48,
                                  height: 48,
                                );
                              }
                              return SizedBox(
                                width: 48,
                                height: 48,
                                child: snapshot.data!.asWidget(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          skinOption.name,
                          style: TextStyle(
                            color: selected ? Colors.green : null,
                            fontWeight: selected ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(
                _CreateCharacterData(
                  nickName: _nickNameController.text.trim(),
                  skin: _skin,
                ),
              );
            }
          },
          child: const Text('Criar'),
        ),
      ],
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.character,
    required this.onTap,
  });

  final CharacterSummary character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final skin = PlayerSkin.fromName(character.skin);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: Sprite.load(
                skin.path,
                srcSize: Vector2.all(32),
                srcPosition: Vector2(0, 32),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    width: 80,
                    height: 80,
                  );
                }
                return SizedBox(
                  width: 80,
                  height: 80,
                  child: snapshot.data!.asWidget(),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              character.nickName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              character.mapId,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
