part of 'genui_chat_page.dart';

/// Wiadomość użytkownika — żeby było widać, na co model odpowiedział.
class _UserBubble extends StatelessWidget {
  const _UserBubble(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: bPadding12,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        padding: hPadding12 + vPadding8,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: borderRadiusL,
        ),
        child: Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
