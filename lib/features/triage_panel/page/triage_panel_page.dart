import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';
import 'package:get_it/get_it.dart';

import '../../../commons/a2ui/surface_contract.dart';
import '../../../commons/extensions/build_context_ext.dart';
import '../../../commons/resources/app_sizes.dart';
import '../../../commons/widgets/agent_banner.dart';
import '../cubit/triage_panel_cubit.dart';
import '../cubit/triage_panel_state.dart';
import '../failure/failure_injector.dart';
import '../model/support_case.dart';
import '../widget/triage_block.dart';
import '../widget/triage_widgets.dart';

part '_call_bar.dart';
part '_generated_strip.dart';
part '_order_card.dart';
part '_lab_strip.dart';

/// Trzeci tor POC-a: **asysta nad ekranem, nie zamiast ekranu**.
///
/// Proporcja jest tezą, nie estetyką: karta zamówienia (15 sekcji, zwykły
/// Flutter, zero AI) zajmuje większość widoku, generatywny jest wyłącznie pasek
/// na górze. Dlatego najgorsze, co może się stać, to ekran taki, jaki
/// konsultant miał przed wdrożeniem.
class TriagePanelPage extends StatelessWidget {
  const TriagePanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<TriagePanelCubit>(),
      child: const _TriagePanelView(),
    );
  }
}

class _TriagePanelView extends StatelessWidget {
  const _TriagePanelView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TriagePanelCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel BOK — pasek nad ekranem'),
        backgroundColor: context.colorScheme.inversePrimary,
      ),
      body: SafeArea(
        top: false,
        child: _ActionSnackbars(
          child: Column(
            children: [
              AgentBanner(
                isMock: cubit.isMock,
                label: cubit.agentLabel,
                proves: cubit.isMock
                    ? 'atrapa odgrywa zaprojektowany pasek — dowodzi '
                          'kontraktu, awarii i renderera, nie doboru komponentów'
                    : 'dobór komponentów należy do modelu; host tylko '
                          'sprawdza, czy wolno to pokazać',
              ),
              const _CallBar(),
              Expanded(
                child: ListView(
                  padding: hPadding12,
                  children: const [_GeneratedStrip(), _OrderCard(), vGap12],
                ),
              ),
              const _LabStrip(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Snackbar po kliknięciu akcji z paska — **dowód, że wykonuje host**.
///
/// Efekt uboczny, nie stan: gdyby siedział w stanie, wracałby przy każdym
/// rebuildzie, a „reklamacja złożona" pokazywałaby się drugi raz bez drugiej
/// reklamacji.
class _ActionSnackbars extends StatefulWidget {
  const _ActionSnackbars({required this.child});

  final Widget child;

  @override
  State<_ActionSnackbars> createState() => _ActionSnackbarsState();
}

class _ActionSnackbarsState extends State<_ActionSnackbars> {
  StreamSubscription<TriageSideEffect>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = context.read<TriagePanelCubit>().sideEffects.listen(
      _onEffect,
    );
  }

  void _onEffect(TriageSideEffect effect) {
    if (!mounted) return;

    switch (effect) {
      case ActionExecuted(:final action):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                '${action.label} — wykonane przez host (mock). '
                'Model nie dostał żadnego requestu.',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
