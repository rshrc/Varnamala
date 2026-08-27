// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/community_provider.dart';
import 'package:words625/application/identity_provider.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/domain/community/comment.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/identicon.dart';

/// Opens a course's discussion. Starts at two-thirds height and can be dragged
/// to fill the screen, because reading a long thread should not mean squinting
/// at a letterbox.
Future<void> showCommunitySheet(
  BuildContext context, {
  required TargetLanguage language,
  required String courseName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.4,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) => _CommunitySheet(
        language: language,
        courseName: courseName,
        scrollController: scrollController,
      ),
    ),
  );
}

class _CommunitySheet extends StatefulWidget {
  const _CommunitySheet({
    required this.language,
    required this.courseName,
    required this.scrollController,
  });

  final TargetLanguage language;
  final String courseName;
  final ScrollController scrollController;

  @override
  State<_CommunitySheet> createState() => _CommunitySheetState();
}

class _CommunitySheetState extends State<_CommunitySheet> {
  final TextEditingController _composer = TextEditingController();
  late final String _thread =
      CommunityProvider.threadId(widget.language, widget.courseName);

  CommunityComment? _replyingTo;
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().loadMyVotes(_thread);
    });
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final identity = context.read<IdentityProvider>();
    final community = context.read<CommunityProvider>();
    final text = _composer.text;
    if (text.trim().isEmpty) return;

    setState(() => _posting = true);
    final problem = await community.post(
      thread: _thread,
      text: text,
      handle: identity.handle ?? 'Learner',
      avatarSeed: identity.avatarSeed ?? identity.handle ?? 'learner',
      parentId: _replyingTo?.id,
    );
    if (!mounted) return;
    setState(() {
      _posting = false;
      if (problem == null) {
        _composer.clear();
        _replyingTo = null;
      }
    });
    if (problem != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(problem)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityProvider>();

    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _Grabber(courseName: widget.courseName),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<CommunityComment>>(
              stream: community.watch(_thread),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: context.appAccent, strokeWidth: 3),
                  );
                }
                final all = snapshot.data ?? const <CommunityComment>[];
                if (all.isEmpty)
                  return _EmptyThread(controller: widget.scrollController);

                // Top-level comments ranked by score; replies stay in the order
                // they were written so a conversation still reads top to bottom.
                final roots = all.where((c) => !c.isReply).toList()
                  ..sort((a, b) => b.score.compareTo(a.score));
                final repliesFor = <String, List<CommunityComment>>{};
                for (final comment in all.where((c) => c.isReply)) {
                  repliesFor
                      .putIfAbsent(comment.parentId!, () => [])
                      .add(comment);
                }

                return ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: roots.length,
                  itemBuilder: (context, index) {
                    final root = roots[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CommentTile(
                          comment: root,
                          thread: _thread,
                          onReply: () => setState(() => _replyingTo = root),
                        ),
                        for (final reply in repliesFor[root.id] ?? const [])
                          Padding(
                            padding: const EdgeInsets.only(left: 34),
                            child: _CommentTile(
                              comment: reply,
                              thread: _thread,
                              onReply: () => setState(() => _replyingTo = root),
                            ),
                          ),
                        const SizedBox(height: 6),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _Composer(
            controller: _composer,
            replyingTo: _replyingTo,
            isPosting: _posting,
            onCancelReply: () => setState(() => _replyingTo = null),
            onSubmit: _post,
          ),
        ],
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber({required this.courseName});

  final String courseName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: context.appBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      'Ask, explain, correct each other',
                      style: TextStyle(
                          fontSize: 12.5, color: context.appTextSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.thread,
    required this.onReply,
  });

  final CommunityComment comment;
  final String thread;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityProvider>();
    final myVote = community.myVotes[comment.id] ?? 0;
    final isMine = comment.authorId == community.currentUserId;

    if (comment.isDeleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'Comment deleted',
          style: TextStyle(
            color: context.appTextSecondary,
            fontStyle: FontStyle.italic,
            fontSize: 13,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Identicon(seed: comment.avatarSeed, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.handle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'you',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  comment.text,
                  style: const TextStyle(fontSize: 14.5, height: 1.4),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _VoteButton(
                      icon: Icons.keyboard_arrow_up_rounded,
                      active: myVote == 1,
                      onTap: () => community.vote(thread, comment.id, 1),
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${comment.score}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: myVote == 1
                              ? context.appSuccess
                              : myVote == -1
                                  ? context.appDanger
                                  : context.appTextSecondary,
                        ),
                      ),
                    ),
                    _VoteButton(
                      icon: Icons.keyboard_arrow_down_rounded,
                      active: myVote == -1,
                      onTap: () => community.vote(thread, comment.id, -1),
                    ),
                    const SizedBox(width: 8),
                    _LinkButton(label: 'Reply', onTap: onReply),
                    if (isMine) ...[
                      const SizedBox(width: 12),
                      _LinkButton(
                        label: 'Delete',
                        colour: context.appDanger,
                        onTap: () => community.deleteOwn(thread, comment),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Icon(
        icon,
        size: 24,
        color: active ? context.appAccent : context.appTextSecondary,
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.onTap,
    this.colour,
  });

  final String label;
  final VoidCallback onTap;
  final Color? colour;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: colour ?? context.appTextSecondary,
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.replyingTo,
    required this.isPosting,
    required this.onCancelReply,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final CommunityComment? replyingTo;
  final bool isPosting;
  final VoidCallback onCancelReply;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.appBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyingTo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to ${replyingTo!.handle}',
                      style: TextStyle(
                          fontSize: 12, color: context.appTextSecondary),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCancelReply,
                    child: Icon(Icons.close_rounded,
                        size: 16, color: context.appDanger),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 600,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Add a comment',
                    counterText: '',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: isPosting ? null : onSubmit,
                icon: isPosting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                color: context.appInfo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyThread extends StatelessWidget {
  const _EmptyThread({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(40, 60, 40, 40),
      children: [
        Icon(Icons.forum_rounded, size: 46, color: context.appInfo),
        const SizedBox(height: 14),
        const Text(
          'Nothing here yet',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          'Ask why a sentence works the way it does, or explain it for whoever '
          'comes next.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: context.appTextSecondary, fontSize: 13, height: 1.45),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reporting a mistake
// ---------------------------------------------------------------------------

Future<void> showReportSheet(
  BuildContext context, {
  required TargetLanguage language,
  required String courseName,
  String? commentId,
  String? sentence,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReportSheet(
      language: language,
      courseName: courseName,
      commentId: commentId,
      sentence: sentence,
    ),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({
    required this.language,
    required this.courseName,
    this.commentId,
    this.sentence,
  });

  final TargetLanguage language;
  final String courseName;
  final String? commentId;

  /// The line the learner was looking at when they hit report.
  final String? sentence;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  ReportReason _reason = ReportReason.wrongTranslation;
  final TextEditingController _detail = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final problem = await context.read<CommunityProvider>().reportContent(
          language: widget.language,
          courseName: widget.courseName,
          reason: _reason,
          detail: _detail.text,
          commentId: widget.commentId,
          sentence: widget.sentence,
        );
    if (!mounted) return;
    setState(() => _sending = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(problem ?? 'Thanks — someone will take a look.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Report a mistake',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'In ${widget.courseName}. This goes straight to whoever maintains '
              'the course — it is not posted publicly.',
              style: TextStyle(
                  fontSize: 12.5, color: context.appTextSecondary, height: 1.4),
            ),
            if (widget.sentence != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.appInfo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.sentence!,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, height: 1.35),
                ),
              ),
            ],
            const SizedBox(height: 16),
            for (final reason in ReportReason.values)
              RadioListTile<ReportReason>(
                value: reason,
                groupValue: _reason,
                onChanged: (value) => setState(() => _reason = value!),
                title: Text(reason.label, style: const TextStyle(fontSize: 14)),
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: context.appAccent,
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _detail,
              minLines: 2,
              maxLines: 4,
              maxLength: 400,
              decoration: InputDecoration(
                hintText: 'Which sentence, and what should it say?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _sending ? null : _send,
              style: FilledButton.styleFrom(
                backgroundColor: context.appAccent,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(_sending ? 'Sending...' : 'Send report'),
            ),
          ],
        ),
      ),
    );
  }
}
