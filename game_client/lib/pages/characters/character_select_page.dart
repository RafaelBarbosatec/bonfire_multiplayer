import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/bootstrap_injector.dart';
import 'package:bonfire_multiplayer/data/models/character_summary.dart';
import 'package:bonfire_multiplayer/pages/characters/bloc/character_select_bloc.dart';
import 'package:bonfire_multiplayer/pages/game/game_route.dart';
import 'package:bonfire_multiplayer/pages/login/login_route.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ragnarok-inspired palette used across the character select screen.
class _Ro {
  static const bgTop = Color(0xFF070E1C);
  static const bgBottom = Color(0xFF14294A);
  static const panelBg = Color(0xE6122036);
  static const border = Color(0xFF8A6A2F);
  static const borderDark = Color(0xFF5A4726);
  static const gold = Color(0xFFE8C36A);
  static const goldBright = Color(0xFFFFE9A8);
  static const ivory = Color(0xFFF4EBD6);
  static const textSoft = Color(0xFFBAC5DB);
  static const textFaint = Color(0xFF8493AF);
  static const btnTop = Color(0xFF3D6CA0);
  static const btnBottom = Color(0xFF16304F);
  static const danger = Color(0xFFE08270);
}

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
          backgroundColor: _Ro.bgTop,
          body: Stack(
            children: [
              const _RoBackground(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: Column(
                    children: [
                      const _Header(),
                      const SizedBox(height: 10),
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
    return _OrnatePanel(
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
                        color: _Ro.gold,
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
            _ErrorBar(message: state.error!),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Right panel: showcase + actions
  // ---------------------------------------------------------------------
  Widget _buildShowcase(CharacterSelectState state, CharacterSummary? selected) {
    if (state.loading && state.characters.isEmpty) {
      return const _OrnatePanel(
        title: 'AVENTUREIRO',
        child: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: _Ro.gold,
            ),
          ),
        ),
      );
    }

    if (state.error != null && state.characters.isEmpty) {
      return _OrnatePanel(
        title: 'AVENTUREIRO',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: _Ro.danger, size: 40),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _Ro.ivory, fontSize: 15),
                ),
              ),
              const SizedBox(height: 16),
              _PillAction(
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
      return _OrnatePanel(
        title: 'AVENTUREIRO',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_add_alt_1, color: _Ro.gold, size: 56),
              const SizedBox(height: 16),
              const Text(
                'Nenhum personagem ainda.\nCrie seu primeiro herói!',
                textAlign: TextAlign.center,
                style: TextStyle(color: _Ro.ivory, fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 20),
              _PillAction(
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
    return _OrnatePanel(
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
                _PillAction(
                  icon: Icons.add,
                  label: 'NOVO',
                  onTap: busy ? null : _openCreateDialog,
                ),
                const SizedBox(width: 8),
                _PillAction(
                  icon: Icons.logout,
                  label: 'SAIR',
                  onTap: busy ? null : _logout,
                ),
                const Spacer(),
                _EnterButton(
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
// Background
// ===========================================================================
class _RoBackground extends StatelessWidget {
  const _RoBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_Ro.bgTop, _Ro.bgBottom],
        ),
      ),
      child: Stack(
        children: [
          // Soft golden glow (upper area) + deep blue side glow.
          Positioned(
            top: -120,
            right: -80,
            child: _Glow(
              size: 420,
              color: _Ro.gold.withValues(alpha: 0.05),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -60,
            child: _Glow(
              size: 460,
              color: const Color(0xFF2E6FA8).withValues(alpha: 0.10),
            ),
          ),
          // Vignette to focus the centre.
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.3,
                    colors: [Colors.transparent, Color(0x99020812)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

// ===========================================================================
// Ornamented panel
// ===========================================================================
class _OrnatePanel extends StatelessWidget {
  const _OrnatePanel({
    required this.child,
    this.title,
    this.titleIcon,
  });

  final Widget child;
  final String? title;
  final IconData? titleIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Ro.borderDark, width: 1.4),
        boxShadow: const [
          BoxShadow(color: Color(0x59000000), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xF21B2E4C), _Ro.panelBg],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (titleIcon != null) ...[
                        Icon(titleIcon, color: _Ro.gold, size: 16),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          title!,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _Ro.gold,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      if (titleIcon != null) ...[
                        const SizedBox(width: 8),
                        Icon(titleIcon, color: _Ro.gold, size: 16),
                      ],
                    ],
                  ),
                ),
              if (title != null)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Divider(color: _Ro.border, height: 1),
                ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Header
// ===========================================================================
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 44),
        Expanded(
          child: Column(
            children: [
              Text(
                '✦  SELEÇÃO DE PERSONAGEM  ✦',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _Ro.goldBright.withValues(alpha: 0.95),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5,
                  shadows: const [
                    Shadow(
                      color: Color(0xAA000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Escolha seu herói e continue sua jornada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _Ro.textSoft,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 44),
      ],
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
              color: selected ? _Ro.gold : _Ro.borderDark,
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
                        color: selected ? _Ro.goldBright : _Ro.ivory,
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
                        color: _Ro.textSoft,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.check_circle, color: _Ro.gold, size: 18),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.chevron_right,
                    color: _Ro.textFaint,
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
              color: _Ro.borderDark.withValues(alpha: 0.7),
              width: 1.2,
            ),
            color: const Color(0x0AFFFFFF),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: _Ro.gold, size: 18),
              SizedBox(width: 8),
              Text(
                'NOVO PERSONAGEM',
                style: TextStyle(
                  color: _Ro.gold,
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
      constraints: const BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sprite with pulsing halo + pedestal.
            SizedBox(
              height: 168,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AnimatedBuilder(
                    animation: glow,
                    builder: (context, _) {
                      final opacity = 0.16 + glow.value * 0.14;
                      return Container(
                        width: 190,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _Ro.gold.withValues(alpha: opacity),
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
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _CharacterSprite(skin.path, size: 118),
                    ),
                  ),
                  // Pedestal.
                  Container(
                    width: 150,
                    height: 12,
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
            const SizedBox(height: 8),
            Text(
              character.nickName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _Ro.goldBright,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(color: Color(0x99000000), blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: Divider(color: _Ro.border, height: 1),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                _InfoChip(icon: Icons.face, label: _skinName(character.skin)),
                _InfoChip(
                  icon: Icons.map_outlined,
                  label: 'Local: ${_mapName(character.mapId)}',
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Toque duas vezes no personagem para entrar',
              style: TextStyle(color: _Ro.textFaint, fontSize: 10.5),
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
        border: Border.all(color: _Ro.borderDark, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _Ro.gold, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: _Ro.ivory, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Buttons
// ===========================================================================
class _EnterButton extends StatelessWidget {
  const _EnterButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onTap : null,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_Ro.btnTop, _Ro.btnBottom],
              ),
              border: Border.all(color: _Ro.gold, width: 1.4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, color: _Ro.goldBright, size: 22),
                SizedBox(width: 6),
                Text(
                  'ENTRAR',
                  style: TextStyle(
                    color: _Ro.goldBright,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillAction extends StatelessWidget {
  const _PillAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0x1FFFFFFF),
              border: Border.all(
                color: enabled ? _Ro.border : _Ro.borderDark,
                width: 1.1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: _Ro.gold, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: _Ro.ivory,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
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
            border: Border.all(color: _Ro.gold, width: 1.4),
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
                  color: _Ro.gold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'ENTRANDO NO MUNDO...',
                style: TextStyle(
                  color: _Ro.goldBright,
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

class _ErrorBar extends StatelessWidget {
  const _ErrorBar({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0x33E08270),
        border: Border.all(color: _Ro.danger, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: _Ro.danger, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _Ro.ivory, fontSize: 12),
            ),
          ),
        ],
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 420,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _Ro.gold, width: 1.6),
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
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '✦  NOVO PERSONAGEM  ✦',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _Ro.goldBright,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Forje seu novo herói',
                    style: TextStyle(color: _Ro.textSoft, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nickNameController,
                    style: const TextStyle(color: _Ro.ivory),
                    cursorColor: _Ro.gold,
                    maxLength: 20,
                    decoration: InputDecoration(
                      labelText: 'Apelido',
                      labelStyle: const TextStyle(color: _Ro.textSoft),
                      counterStyle: const TextStyle(color: _Ro.textFaint),
                      filled: true,
                      fillColor: const Color(0x33000000),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: _Ro.borderDark,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: _Ro.gold,
                          width: 1.4,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: _Ro.danger,
                          width: 1.2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: _Ro.danger,
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
                    style: TextStyle(color: _Ro.textSoft, fontSize: 12),
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
                                color: selected ? _Ro.gold : _Ro.borderDark,
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
                                        ? _Ro.goldBright
                                        : _Ro.ivory,
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
                  const SizedBox(height: 18),
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
                    colors: [_Ro.btnTop, _Ro.btnBottom],
                  ),
            color: outlined ? const Color(0x1FFFFFFF) : null,
            border: Border.all(
              color: outlined ? _Ro.border : _Ro.gold,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: _Ro.goldBright,
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
