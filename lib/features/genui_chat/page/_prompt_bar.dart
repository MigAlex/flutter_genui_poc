part of 'genui_chat_page.dart';

class _PromptBar extends StatefulWidget {
  const _PromptBar();

  @override
  State<_PromptBar> createState() => _PromptBarState();
}

class _PromptBarState extends State<_PromptBar> {
  final _controller = TextEditingController(text: 'Zaplanuj mi wyjazd');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send(BuildContext context) {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<GenUiChatCubit>().sendPrompt(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isWaiting = context.watch<GenUiChatCubit>().state.isWaiting;

    return SafeArea(
      top: false,
      child: Padding(
        padding: allPadding8,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(context),
                decoration: InputDecoration(
                  // clear button
                  suffixIcon: IconButton(
                    onPressed: () => _controller.clear(),
                    icon: const Icon(Icons.clear),
                  ),
                  hintText: 'Napisz se prompta…',
                  border: const OutlineInputBorder(),
                  contentPadding: hPadding12 + vPadding8,
                ),
              ),
            ),
            hGap8,
            IconButton.filled(
              onPressed: isWaiting ? null : () => _send(context),
              icon: isWaiting
                  ? const SizedBox.square(
                      dimension: AppSizes.p20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
