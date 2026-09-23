import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../commons/resources/app_sizes.dart';
import '../../../commons/extensions/build_context_ext.dart';
import '../../../app/routes.dart';
import '../../../commons/widgets/agent_banner.dart';
import '../cubit/genui_chat_cubit.dart';
import '../cubit/genui_chat_state.dart';

part '_prompt_bar.dart';
part '_empty_hint.dart';
part '_notice.dart';
part '_user_bubble.dart';

class GenUiChatPage extends StatelessWidget {
  const GenUiChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<GenUiChatCubit>(),
      child: const _GenUiChatView(),
    );
  }
}

class _GenUiChatView extends StatelessWidget {
  const _GenUiChatView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GenUiChatCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GenUI POC — model rysuje UI'),
        backgroundColor: context.colorScheme.inversePrimary,
        actions: [
          BlocBuilder<GenUiChatCubit, GenUiChatState>(
            buildWhen: (a, b) =>
                a.turns != b.turns || a.isWaiting != b.isWaiting,
            builder: (context, state) {
              final canReset = state.turns.isNotEmpty && !state.isWaiting;
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Wyczyść czat (także pamięć modelu)',
                onPressed: canReset ? cubit.resetChat : null,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Doradca auta — panel generatywny',
            onPressed: () => context.pushNamed(AppRoutes.advisor.name),
          ),
          IconButton(
            icon: const Icon(Icons.support_agent),
            tooltip: 'Panel BOK — pasek nad ekranem',
            onPressed: () => context.pushNamed(AppRoutes.triage.name),
          ),
        ],
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
                  ? 'atrapa rysuje UI z kodu — dowodzi pętli i renderera'
                  : 'każdy ekran skomponował model',
            ),
            Expanded(
              child: BlocBuilder<GenUiChatCubit, GenUiChatState>(
                builder: (context, state) {
                  if (state.turns.isEmpty &&
                      state.error == null &&
                      state.latestText == null) {
                    return const _EmptyHint();
                  }

                  return ListView(
                    padding: allPadding16,
                    children: [
                      for (final turn in state.turns) ...[
                        if (turn.prompt.isNotEmpty) _UserBubble(turn.prompt),
                        for (final id in turn.surfaceIds)
                          // Tu dzieje się magia: surowe A2UI → widgety.
                          Surface(surfaceContext: cubit.contextFor(id)),
                        vGap12,
                      ],
                      if (state.error != null) _Notice.error(state.error!),
                      // Model odpowiedział prozą zamiast UI — pokaż, nie milcz.
                      if (state.latestText != null)
                        _Notice.text(state.latestText!),
                    ],
                  );
                },
              ),
            ),
            const _PromptBar(),
          ],
        ),
      ),
    );
  }
}
