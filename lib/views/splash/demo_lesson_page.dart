// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/service/demo_lesson_service.dart';
import 'package:words625/views/theme.dart';

class DemoLessonPage extends StatefulWidget {
  const DemoLessonPage({
    required this.initialQuestion,
    required this.service,
    super.key,
  });

  final DemoQuestion initialQuestion;
  final DemoLessonService service;

  @override
  State<DemoLessonPage> createState() => _DemoLessonPageState();
}

class _DemoLessonPageState extends State<DemoLessonPage> {
  late DemoQuestion _question = widget.initialQuestion;
  String? _selectedAnswer;
  bool _checked = false;
  bool _loading = false;

  bool get _isCorrect => _selectedAnswer == _question.correctAnswer;

  Future<void> _nextDemo() async {
    setState(() => _loading = true);
    try {
      final question = await widget.service.loadRandomQuestion();
      await widget.service.recordStart();
      if (!mounted) return;
      setState(() {
        _question = question;
        _selectedAnswer = null;
        _checked = false;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(color: context.appDanger),
        title: const Text('Quick demo'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Demo #${widget.service.count}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(VarnamalaTheme.radiusRound),
                    ),
                    child: Text(
                      '${_question.language} · ${_question.nativeLanguage}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: colors.tertiaryContainer,
                      borderRadius:
                          BorderRadius.circular(VarnamalaTheme.radiusRound),
                    ),
                    child: Text(
                      'Basics · Level ${_question.level}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colors.onTertiaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                _question.prompt,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius:
                      BorderRadius.circular(VarnamalaTheme.radiusLarge),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Text(
                  _question.sentence,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        height: 1.35,
                      ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: _question.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = _question.options[index];
                    final selected = option == _selectedAnswer;
                    final correct =
                        _checked && option == _question.correctAnswer;
                    final incorrect = _checked && selected && !correct;
                    final borderColor = correct
                        ? context.appSuccess
                        : incorrect
                            ? colors.error
                            : selected
                                ? colors.primary
                                : colors.outlineVariant;
                    final fillColor = correct
                        ? context.appSuccess.withValues(alpha: 0.14)
                        : incorrect
                            ? colors.error.withValues(alpha: 0.1)
                            : selected
                                ? colors.primary.withValues(alpha: 0.1)
                                : colors.surface;

                    return InkWell(
                      onTap: _checked
                          ? null
                          : () => setState(() => _selectedAnswer = option),
                      borderRadius:
                          BorderRadius.circular(VarnamalaTheme.radiusMedium),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(
                              VarnamalaTheme.radiusMedium),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (correct)
                              Icon(Icons.check_circle_rounded,
                                  color: context.appSuccess)
                            else if (incorrect)
                              Icon(Icons.cancel_rounded, color: colors.error)
                            else if (selected)
                              Icon(Icons.radio_button_checked_rounded,
                                  color: colors.primary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_checked) ...[
                const SizedBox(height: 8),
                Text(
                  _isCorrect ? 'Correct!' : 'The correct answer is:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _isCorrect ? context.appSuccess : colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (!_isCorrect)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_question.correctAnswer),
                  ),
                if (_question.translation case final translation?)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      translation,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _loading || (!_checked && _selectedAnswer == null)
                    ? null
                    : _checked
                        ? _nextDemo
                        : () => setState(() => _checked = true),
                child: _loading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_checked ? 'TRY ANOTHER LANGUAGE' : 'CHECK ANSWER'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: context.appInfo),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      'Demo answers and progress are never sent to Firebase. '
                      'Only this device keeps the number of demos started.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
