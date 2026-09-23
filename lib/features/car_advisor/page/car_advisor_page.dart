import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';
import 'package:get_it/get_it.dart';

import '../../../commons/resources/app_sizes.dart';
import '../../../commons/extensions/build_context_ext.dart';
import '../../../commons/widgets/agent_banner.dart';
import '../cubit/car_advisor_cubit.dart';
import '../cubit/car_advisor_state.dart';
import '../model/advisor_criteria.dart';
import '../model/car_fuel.dart';

part '_criteria_panel.dart';
part '_advisor_surface.dart';
part '_lab_strip.dart';

/// Drugi tor POC-a: **GenUI poza czatem**.
///
/// Nie ma tu pola tekstowego. Wejściem jest stan kontrolek, wyjściem jedna
/// powierzchnia przebudowywana w miejscu. Zysk: adaptacyjny panel. Koszt:
/// tracisz naturalną pętlę „napisz cokolwiek" — user może poprosić tylko
/// o to, co przewidziałeś w kontrolkach.
class CarAdvisorPage extends StatelessWidget {
  const CarAdvisorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<CarAdvisorCubit>(),
      child: const _CarAdvisorView(),
    );
  }
}

class _CarAdvisorView extends StatelessWidget {
  const _CarAdvisorView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarAdvisorCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doradca auta — panel generatywny'),
        backgroundColor: context.colorScheme.inversePrimary,
      ),
      // top: false — górę zasłania AppBar; chodzi o systemową nawigację
      // u dołu, która na Androidzie przykrywała pasek akcji.
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AgentBanner(
              isMock: cubit.isMock,
              label: cubit.agentLabel,
              proves: cubit.isMock
                  ? 'atrapa respektuje przełącznik, ale nie udaje decyzji '
                        'modelu — dowodzi renderera, nie zachowania AI'
                  : 'wybór komponentów należy do modelu — przełącznik '
                        'katalogu jest miarodajny',
            ),
            const _CriteriaPanel(),
            const Expanded(child: _AdvisorSurface()),
            const _LabStrip(),
          ],
        ),
      ),
    );
  }
}
