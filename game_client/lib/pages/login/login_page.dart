import 'package:bonfire_multiplayer/bootstrap_injector.dart';
import 'package:bonfire_multiplayer/data/auth/auth_session.dart';
import 'package:bonfire_multiplayer/pages/characters/character_select_route.dart';
import 'package:bonfire_multiplayer/pages/common/ro_theme.dart';
import 'package:bonfire_multiplayer/pages/home/home_route.dart';
import 'package:bonfire_multiplayer/pages/login/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginBloc _bloc;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _bloc = inject();
    // Already logged in this session? Go straight to the character select.
    if (AuthSession.instance.isLogged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) CharacterSelectRoute.open(context);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state.success) {
          CharacterSelectRoute.open(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: RoColors.bgTop,
          body: Stack(
            children: [
              const RoBackground(),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 460,
                          ),
                          child: RoOrnatePanel(
                            title: 'RPG MULTIPLAYER',
                            titleIcon: Icons.sports_esports,
                            child: SingleChildScrollView(
                              padding:
                                  const EdgeInsets.fromLTRB(22, 14, 22, 18),
                              child: _buildForm(state),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForm(LoginState state) {
    final busy = state.loading;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bem-vindo, aventureiro',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RoColors.goldBright,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Entre para continuar sua jornada',
            textAlign: TextAlign.center,
            style: TextStyle(color: RoColors.textSoft, fontSize: 12),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            enabled: !busy,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            style: const TextStyle(color: RoColors.ivory),
            cursorColor: RoColors.gold,
            decoration: roInputDecoration(
              label: 'Email',
              prefixIcon: Icons.alternate_email,
            ),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Informe seu email';
              if (!v.contains('@') || !v.contains('.')) {
                return 'Email inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            enabled: !busy,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            style: const TextStyle(color: RoColors.ivory),
            cursorColor: RoColors.gold,
            decoration: roInputDecoration(
              label: 'Senha',
              prefixIcon: Icons.lock_outline,
            ),
            validator: (value) {
              if ((value ?? '').isEmpty) return 'Informe sua senha';
              if ((value ?? '').length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
            onFieldSubmitted: (_) => _submit(signUp: false),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 14),
            RoErrorBar(message: state.error!),
          ],
          const SizedBox(height: 20),
          RoPrimaryButton(
            label: 'ENTRAR',
            loading: busy,
            enabled: !busy,
            onTap: () => _submit(signUp: false),
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              RoPillAction(
                icon: Icons.person_add_alt_1,
                label: 'CRIAR CONTA',
                onTap: busy ? null : () => _submit(signUp: true),
              ),
              RoPillAction(
                icon: Icons.travel_explore,
                label: 'SEM CONTA (TESTE)',
                onTap: busy ? null : () => HomeRoute.open(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit({required bool signUp}) {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (signUp) {
      _bloc.add(SignUpEvent(email: email, password: password));
    } else {
      _bloc.add(SignInEvent(email: email, password: password));
    }
  }
}
