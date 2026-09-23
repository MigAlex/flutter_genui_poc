part of 'genui_chat_page.dart';

/// Kafelek na to, co NIE jest wygenerowanym UI: błąd API albo zwykły tekst
/// modelu. Bez tego takie odpowiedzi znikały i ekran wyglądał na zepsuty.
class _Notice extends StatelessWidget {
  const _Notice.error(this.message) : isError = true;
  const _Notice.text(this.message) : isError = false;

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Card(
      margin: bPadding12,
      color: isError ? scheme.errorContainer : scheme.surfaceContainerHighest,
      child: Padding(
        padding: allPadding12,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.chat_bubble_outline,
              size: 20,
              color: isError
                  ? scheme.onErrorContainer
                  : scheme.onSurfaceVariant,
            ),
            hGap8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isError
                        ? 'Błąd'
                        : 'Model odpowiedział tekstem (nie wygenerował UI)',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: isError
                          ? scheme.onErrorContainer
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  vGap8,
                  SelectableText(message, style: context.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
