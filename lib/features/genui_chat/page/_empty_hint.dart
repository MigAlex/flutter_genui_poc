part of 'genui_chat_page.dart';

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: allPadding16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 56,
              color: context.colorScheme.primary,
            ),
            vGap12,
            Text(
              'Napisz cokolwiek poniżej',
              style: context.textTheme.titleMedium,
            ),
            vGap8,
            Text(
              'Model odpowie interaktywnym UI (przyciski/karty), '
              'nie ścianą tekstu. Kliknij wygenerowany przycisk — '
              'pętla wygeneruje kolejny ekran.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall,
            ),
            vGap12,
            Chip(
              avatar: const Icon(Icons.bolt, size: 18),
              label: Text(context.read<GenUiChatCubit>().agentLabel),
            ),
          ],
        ),
      ),
    );
  }
}
