import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_events/shared_events.dart';

/// Ragnarok-style "Status" dialog: shows the six base stats (STR/AGI/VIT/
/// INT/DEX/LUK), the unspent status-points pool and the derived substats.
///
/// Data comes live from [ownState] (the own player snapshot held by the game
/// page): every allocation the server confirms flows back through the same
/// notifier, so the dialog and the HUD update together. Allocation is
/// optimistic (no ack) — the +/- buttons are enabled purely from the last
/// known server state.
Future<void> showPlayerStatsDialog(
  BuildContext context, {
  required ValueListenable<ComponentStateModel?> ownState,
  required void Function(String stat) onAllocateStat,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (context) {
      return _PlayerStatsDialog(
        ownState: ownState,
        onAllocateStat: onAllocateStat,
      );
    },
  );
}

class _StatInfo {
  const _StatInfo(this.key, this.acronym, this.name, this.color);

  final String key;
  final String acronym;
  final String name;
  final Color color;
}

const List<_StatInfo> _stats = [
  _StatInfo('str', 'STR', 'Força', Color(0xFFFFC9A0)),
  _StatInfo('agi', 'AGI', 'Agilidade', Color(0xFFA8E6A0)),
  _StatInfo('vit', 'VIT', 'Vitalidade', Color(0xFFFFA0A0)),
  _StatInfo('int', 'INT', 'Inteligência', Color(0xFFA0C8FF)),
  _StatInfo('dex', 'DEX', 'Destreza', Color(0xFFFFE9A0)),
  _StatInfo('luk', 'LUK', 'Sorte', Color(0xFFD8A0FF)),
];

class _Ro {
  static const border = Color(0xFF8A6A2F);
  static const gold = Color(0xFFE8C36A);
  static const goldBright = Color(0xFFFFE9A8);
  static const ivory = Color(0xFFF4EBD6);
  static const textSoft = Color(0xFFBAC5DB);
  static const textFaint = Color(0xFF8493AF);
  static const btnTop = Color(0xFF3D6CA0);
  static const btnBottom = Color(0xFF16304F);
  static const panelBg = Color(0xF2122036);
}

class _PlayerStatsDialog extends StatelessWidget {
  const _PlayerStatsDialog({
    required this.ownState,
    required this.onAllocateStat,
  });

  final ValueListenable<ComponentStateModel?> ownState;
  final void Function(String stat) onAllocateStat;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final dialogWidth = (screen.width - 32).clamp(280.0, 430.0);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: screen.height - 32,
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: _Ro.border, width: 1.6),
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF14294A), Color(0xFF0A1222)],
            ),
            boxShadow: const [
              BoxShadow(color: Color(0xAA000000), blurRadius: 12),
            ],
          ),
          child: ValueListenableBuilder<ComponentStateModel?>(
            valueListenable: ownState,
            builder: (context, state, _) {
              final attrs = state?.attributes;
              if (attrs == null) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, state!, attrs),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPointsRow(attrs),
                          const SizedBox(height: 10),
                          ..._buildStatRows(attrs),
                          const SizedBox(height: 10),
                          _buildDerivedPanel(attrs),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: _buildFooter(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ComponentStateModel state,
    PlayerAttributes attrs,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              state.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _Ro.ivory,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                shadows: [Shadow(color: Colors.black87)],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: _Ro.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Lv. ${attrs.level}',
              style: const TextStyle(
                color: _Ro.goldBright,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsRow(PlayerAttributes attrs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        border: Border.all(color: _Ro.border, width: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Text(
            'PONTOS',
            style: TextStyle(
              color: _Ro.gold,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          Text(
            '${attrs.statusPoints}',
            style: const TextStyle(
              color: _Ro.goldBright,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatRows(PlayerAttributes attrs) {
    return [
      for (final stat in _stats)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _StatRow(
            stat: stat,
            value: attrs.statValueOrNull(stat.key) ?? 1,
            canRaise:
                attrs.statusPoints >=
                    PlayerAttributes.costToRaiseStat(
                      attrs.statValueOrNull(stat.key) ?? 1,
                    ) &&
                (attrs.statValueOrNull(stat.key) ?? 1) <
                    PlayerAttributes.statCap,
            onRaise: () => onAllocateStat(stat.key),
          ),
        ),
    ];
  }

  Widget _buildDerivedPanel(PlayerAttributes a) {
    final rows = <(String, String)>[
      ('MaxHP', '${a.maxHp}'),
      ('MaxSP', '${a.maxStamina}'),
      ('ATK', '${a.atk}'),
      ('MATK', '${a.matkMin}~${a.matkMax}'),
      ('HIT', '${a.hit}'),
      ('FLEE', '${a.flee}'),
      ('CRIT', '${a.crit}'),
      ('DEF (VIT)', '${a.softDef}'),
    ];
    return Column(
      children: [
        for (var i = 0; i < rows.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: _DerivedItem(label: rows[i].$1, value: rows[i].$2),
                ),
                const SizedBox(width: 10),
                if (i + 1 < rows.length)
                  Expanded(
                    child: _DerivedItem(
                      label: rows[i + 1].$1,
                      value: rows[i + 1].$2,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Os pontos investidos não podem ser revertidos.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _Ro.textFaint, fontSize: 10),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          height: 34,
          child: Material(
            type: MaterialType.transparency,
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_Ro.btnTop, _Ro.btnBottom],
                ),
                border: Border.all(color: _Ro.border),
                borderRadius: BorderRadius.circular(5),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () => Navigator.of(context).pop(),
                child: const Center(
                  child: Text(
                    'FECHAR',
                    style: TextStyle(
                      color: _Ro.goldBright,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.stat,
    required this.value,
    required this.canRaise,
    required this.onRaise,
  });

  final _StatInfo stat;
  final int value;
  final bool canRaise;
  final VoidCallback onRaise;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _Ro.panelBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              stat.acronym,
              style: TextStyle(
                color: stat.color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: Text(
              stat.name,
              style: const TextStyle(color: _Ro.textSoft, fontSize: 11),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: _Ro.ivory,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          _RaiseButton(canRaise: canRaise, onRaise: onRaise),
        ],
      ),
    );
  }
}

class _RaiseButton extends StatelessWidget {
  const _RaiseButton({required this.canRaise, required this.onRaise});

  final bool canRaise;
  final VoidCallback onRaise;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: canRaise ? 1 : 0.35,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          width: 24,
          height: 22,
          decoration: BoxDecoration(
            color: canRaise ? const Color(0xFF7A5C22) : const Color(0xFF2E2E38),
            border: Border.all(color: canRaise ? _Ro.gold : _Ro.textFaint),
            borderRadius: BorderRadius.circular(3),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(3),
            onTap: canRaise ? onRaise : null,
            child: const Center(
              child: Icon(Icons.add, size: 14, color: _Ro.goldBright),
            ),
          ),
        ),
      ),
    );
  }
}

class _DerivedItem extends StatelessWidget {
  const _DerivedItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0x335A4726)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _Ro.textSoft,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _Ro.ivory,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
