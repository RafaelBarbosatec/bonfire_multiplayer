import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/bootstrap_injector.dart';
import 'package:bonfire_multiplayer/data/models/character_summary.dart';
import 'package:bonfire_multiplayer/pages/characters/bloc/character_select_bloc.dart';
import 'package:bonfire_multiplayer/pages/common/ro_theme.dart';
import 'package:bonfire_multiplayer/pages/game/game_route.dart';
import 'package:bonfire_multiplayer/pages/login/login_route.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _mapNames = <String, String>{
  'florestId': 'Floresta',
  'desertId': 'Deserto',
};

const _skinNames = <String, String>{
  'girl': 'Menina',
  'boy': 'Menino',
};

final Map<String, Future<Sprite>> _spriteFutures = {};

/// Idle "down" frame (row 1, column 0) of a skin spritesheet, cached.
Future<Sprite> _idleSprite(String path) {
  return _spriteFutures.putIfAbsent(
    '$path|idle',
    () => Sprite.load(
      path,
      srcSize: Vector2.all(32),
      srcPosition: Vector2(0, 32),
    ),
  );
}

String _mapName(String mapId) => _mapNames[mapId] ?? mapId;
String _skinName(String skin) => _skinNames[skin] ?? skin;

class CharacterSelectPage extends StatefulWidget {
  const CharacterSelectPage({super.key});

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage>
    with SingleTickerProviderStateMixin {
  late CharacterSelectBloc _bloc;
  late final AnimationController _glow;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _bloc = inject();
    _bloc.add(LoadCharactersEvent());
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  CharacterSummary? _selectedOf(CharacterSelectState state) {
    if (state.characters.isEmpty) return null;
    for (final c in state.characters) {
      if (c.id == _selectedId) return c;
    }
    return state.characters.first;
  }

  void _enterWith(CharacterSummary character) {
    _bloc.add(SelectCharacterEvent(character: character));
  }

  Future<void> _openCreateDialog() async {
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

  void _logout() {
    _bloc.add(LogoutEvent());
    LoginRoute.open(context);
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
        final selected = _selectedOf(state);
        return Scaffold(
          backgroundColor: RoColors.bgTop,
          body: Stack(
            children: [
              const RoBackground(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 620) {
                              return _buildNarrow(state, selected);
                            }
                            return _buildWide(state, selected);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.joining) ...[
                const _JoiningOverlay(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildWide(
    CharacterSelectState state,
    CharacterSummary? selected,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 320,
          child: _buildSlotsPanel(state),
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildShowcase(state, selected)),
      ],
    );
  }

  Widget _buildNarrow(
    CharacterSelectState state,
    CharacterSummary? selected,
  ) {
    // Very narrow (portrait-ish) fallback: slots on top, showcase below.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 170, child: _buildSlotsPanel(state)),
        const SizedBox(height: 12),
        Expanded(child: _buildShowcase(state, selected)),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Left panel: the character slots
  // ---------------------------------------------------------------------
  Widget _buildSlotsPanel(CharacterSelectState state) {
    final busy = state.joining || state.creating;
    final canCreate = !busy;
    return RoOrnatePanel(
      title: 'PERSONAGENS',
      titleIcon: Icons.people_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: state.loading && state.characters.isEmpty
                ? const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: RoColors.gold,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                    itemCount: state.characters.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == state.characters.length) {
                        return _GhostSlot(
                          onTap: canCreate ? _openCreateDialog : null,
                        );
                      }
                      final character = state.characters[index];
                      final isSelected = character.id == _selectedId ||
                          (state.characters.length > 0 &&
                              _selectedId == null &&
                              index == 0);
                      return _SlotCard(
                        character: character,
                        selected: isSelected,
                        enabled: !busy,
                        onTap: () =>
                            setState(() => _selectedId = character.id),
                        onEnter: () => _enterWith(character),
                      );
                    },
                  ),
          ),
          if (state.error != null && state.characters.isNotEmpty)
            RoErrorBar(message: state.error!),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Right panel: showcase + actions
  // ---------------------------------------------------------------------
  Widget _buildShowcase(CharacterSelectState state, CharacterSummary? selected) {
    if (state.loading && state.characters.isEmpty) {
      return const RoOrnatePanel(
        title: 'AVENTUREIRO',
        child: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: RoColors.gold,
            ),
          ),
        ),
      );
    }

    if (state.error != null && state.characters.isEmpty) {
      return RoOrnatePanel(
        title: 'AVENTUREIRO',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: RoColors.danger, size: 40),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: RoColors.ivory, fontSize: 15),
                ),
              ),
              const SizedBox(height: 16),
              RoPillAction(
                icon: Icons.refresh,
                label: 'TENTAR NOVAMENTE',
                onTap: () => _bloc.add(LoadCharactersEvent()),
              ),
            ],
          ),
        ),
      );
    }

    if (selected == null) {
      return RoOrnatePanel(
        title: 'AVENTUREIRO',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_add_alt_1, color: RoColors.gold, size: 56),
              const SizedBox(height: 16),
              const Text(
                'Nenhum personagem ainda.\nCrie seu primeiro herói!',
                textAlign: TextAlign.center,
                style: TextStyle(color: RoColors.ivory, fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 20),
              RoPillAction(
                icon: Icons.add,
                label: 'CRIAR PERSONAGEM',
                onTap: state.creating ? null : _openCreateDialog,
              ),
            ],
          ),
        ),
      );
    }

    final busy = state.joining || state.creating;
    return RoOrnatePanel(
      title: 'AVENTUREIRO',
      titleIcon: Icons.star_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Center(
                child: _CharacterShowcase(
                  character: selected,
                  glow: _glow,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Row(
              children: [
                RoPillAction(
                  icon: Icons.add,
                  label: 'NOVO',
                  onTap: busy ? null : _openCreateDialog,
                ),
                const SizedBox(width: 8),
                RoPillAction(
                  icon: Icons.logout,
                  label: 'SAIR',
                  onTap: busy ? null : _logout,
                ),
                const Spacer(),
                RoPrimaryButton(
                  enabled: !busy,
                  onTap: () => _enterWith(selected),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Slot card (left list)
// ===========================================================================
class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.character,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.onEnter,
  });

  final CharacterSummary character;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final skin = PlayerSkin.fromName(character.skin);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? onTap : null,
        onDoubleTap: enabled ? onEnter : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected
                ? const Color(0x2EFFFFFF)
                : const Color(0x12000000),
            border: Border.all(
              color: selected ? RoColors.gold : RoColors.borderDark,
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x33E8C36A),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              _CharacterSprite(skin.path, size: 48),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      character.nickName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? RoColors.goldBright : RoColors.ivory,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_skinName(character.skin)}  •  ${_mapName(character.mapId)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RoColors.textSoft,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.check_circle, color: RoColors.gold, size: 18),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.chevron_right,
                    color: RoColors.textFaint,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostSlot extends StatelessWidget {
  const _GhostSlot({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: RoColors.borderDark.withValues(alpha: 0.7),
              width: 1.2,
            ),
            color: const Color(0x0AFFFFFF),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: RoColors.gold, size: 18),
              SizedBox(width: 8),
              Text(
                'NOVO PERSONAGEM',
                style: TextStyle(
                  color: RoColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Character showcase (right panel)
// ===========================================================================
class _CharacterShowcase extends StatelessWidget {
  const _CharacterShowcase({required this.character, required this.glow});

  final CharacterSummary character;
  final Animation<double> glow;

  @override
  Widget build(BuildContext context) {
    final skin = PlayerSkin.fromName(character.skin);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sprite with pulsing halo + pedestal.
            SizedBox(
              height: 138,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AnimatedBuilder(
                    animation: glow,
                    builder: (context, _) {
                      final opacity = 0.16 + glow.value * 0.14;
                      return Container(
                        width: 150,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              RoColors.gold.withValues(alpha: opacity),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Character portrait (pixelated idle frame).
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween(begin: 0.92, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: child,
                      ),
                    ),
                    child: Padding(
                      key: ValueKey(character.id),
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CharacterSprite(skin.path, size: 92),
                    ),
                  ),
                  // Pedestal.
                  Container(
                    width: 116,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF6E5B2E), Color(0xFF2E2412)],
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0x66000000), blurRadius: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              character.nickName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: RoColors.goldBright,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                shadows: [
                  Shadow(color: Color(0x99000000), blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 70),
              child: Divider(color: RoColors.border, height: 1),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                _InfoChip(icon: Icons.face, label: _skinName(character.skin)),
                _InfoChip(
                  icon: Icons.map_outlined,
                  label: 'Local: ${_mapName(character.mapId)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0x1FFFFFFF),
        border: Border.all(color: RoColors.borderDark, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: RoColors.gold, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: RoColors.ivory, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Joining overlay / error bar
// ===========================================================================
class _JoiningOverlay extends StatelessWidget {
  const _JoiningOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xB8030A14),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RoColors.gold, width: 1.4),
            color: const Color(0xE6142339),
            boxShadow: const [
              BoxShadow(color: Color(0x88000000), blurRadius: 20),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: RoColors.gold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'ENTRANDO NO MUNDO...',
                style: TextStyle(
                  color: RoColors.goldBright,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Pixelated sprite rendering (avoids bilinear blur when upscaling)
// ===========================================================================
class _CharacterSprite extends StatelessWidget {
  const _CharacterSprite(this.path, {required this.size});

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Sprite>(
      future: _idleSprite(path),
      builder: (context, snapshot) {
        final sprite = snapshot.data;
        if (sprite == null) {
          return Container(
            width: size,
            height: size,
            color: const Color(0x14FFFFFF),
          );
        }
        return CustomPaint(
          size: Size.square(size),
          painter: _SpritePainter(sprite),
        );
      },
    );
  }
}

class _SpritePainter extends CustomPainter {
  _SpritePainter(this.sprite);

  final Sprite sprite;

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      sprite.srcPosition.x,
      sprite.srcPosition.y,
      sprite.srcSize.x,
      sprite.srcSize.y,
    );
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(
      sprite.image,
      src,
      dst,
      Paint()..filterQuality = ui.FilterQuality.none,
    );
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) =>
      oldDelegate.sprite != sprite;
}

// ===========================================================================
// Create character dialog
// ===========================================================================
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
    final media = MediaQuery.of(context);
    final dialogWidth = (media.size.width - 40).clamp(300.0, 430.0);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: media.size.height - 40,
        ),
        child: Container(
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: RoColors.gold, width: 1.6),
          boxShadow: const [
            BoxShadow(color: Color(0x99000000), blurRadius: 24),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xF2263A5E), Color(0xF2122036)],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 18),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  const Text(
                    '✦  NOVO PERSONAGEM  ✦',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: RoColors.goldBright,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Forje seu novo herói',
                    style: TextStyle(color: RoColors.textSoft, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nickNameController,
                    style: const TextStyle(color: RoColors.ivory),
                    cursorColor: RoColors.gold,
                    maxLength: 20,
                    decoration: InputDecoration(
                      labelText: 'Apelido',
                      labelStyle: const TextStyle(color: RoColors.textSoft),
                      counterStyle: const TextStyle(color: RoColors.textFaint),
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0x33000000),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: RoColors.borderDark,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: RoColors.gold,
                          width: 1.4,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: RoColors.danger,
                          width: 1.2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: RoColors.danger,
                          width: 1.4,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Informe um apelido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha sua aparência',
                    style: TextStyle(color: RoColors.textSoft, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: PlayerSkin.values.map((skinOption) {
                      final selected = skinOption == _skin;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => setState(() => _skin = skinOption),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: selected
                                  ? const Color(0x33E8C36A)
                                  : const Color(0x12000000),
                              border: Border.all(
                                color: selected ? RoColors.gold : RoColors.borderDark,
                                width: selected ? 1.8 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _CharacterSprite(
                                  skinOption.path,
                                  size: 56,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _skinName(skinOption.name),
                                  style: TextStyle(
                                    color: selected
                                        ? RoColors.goldBright
                                        : RoColors.ivory,
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _DialogButton(
                        label: 'CANCELAR',
                        outlined: true,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      _DialogButton(
                        label: 'CRIAR',
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop(
                              _CreateCharacterData(
                                nickName: _nickNameController.text.trim(),
                                skin: _skin,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: outlined
                ? null
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [RoColors.btnTop, RoColors.btnBottom],
                  ),
            color: outlined ? const Color(0x1FFFFFFF) : null,
            border: Border.all(
              color: outlined ? RoColors.border : RoColors.gold,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: RoColors.goldBright,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
