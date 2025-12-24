import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';

@RoutePage()
class ChatDetailScreen extends ConsumerStatefulWidget {
  @PathParam('chatId')
  final String chatId;
  final String chatName;
  final bool isGroup;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.isGroup,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock messages data
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      id: '1',
      senderId: 'user2',
      senderName: 'Victoria Reluna',
      content: 'Hi everyone! Just a reminder about tomorrow\'s meeting.',
      timestamp: DateTime(2025, 12, 24, 9, 30),
      isMe: false,
    ),
    _ChatMessage(
      id: '2',
      senderId: 'user3',
      senderName: 'Michael Reluna',
      content: 'Thanks for the reminder, Victoria. I\'ll be there.',
      timestamp: DateTime(2025, 12, 24, 9, 45),
      isMe: false,
    ),
    _ChatMessage(
      id: '3',
      senderId: 'user1',
      senderName: 'Me',
      content: 'Great! I\'ve prepared the agenda. Will share it before the meeting.',
      timestamp: DateTime(2025, 12, 24, 10, 0),
      isMe: true,
    ),
    _ChatMessage(
      id: '4',
      senderId: 'user2',
      senderName: 'Victoria Reluna',
      content: 'Perfect! Looking forward to it. 👍',
      timestamp: DateTime(2025, 12, 24, 10, 15),
      isMe: false,
    ),
    _ChatMessage(
      id: '5',
      senderId: 'user3',
      senderName: 'Michael Reluna',
      content: 'Should we also discuss the Q4 investment report?',
      timestamp: DateTime(2025, 12, 24, 10, 30),
      isMe: false,
    ),
    _ChatMessage(
      id: '6',
      senderId: 'user1',
      senderName: 'Me',
      content: 'Yes, that\'s already on the agenda. We\'ll review the performance and discuss the next quarter strategy.',
      timestamp: DateTime(2025, 12, 24, 10, 35),
      isMe: true,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'user1',
        senderName: 'Me',
        content: _messageController.text.trim(),
        timestamp: DateTime.now(),
        isMe: true,
      ));
    });
    _messageController.clear();
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AppScaffold(
        title: widget.chatName,
        hasBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showChatInfo(context, theme),
          ),
        ],
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final showDate = index == 0 ||
                      !_isSameDay(_messages[index - 1].timestamp, message.timestamp);
                  final showAvatar = !message.isMe &&
                      (index == _messages.length - 1 ||
                          _messages[index + 1].senderId != message.senderId);

                  return Column(
                    children: [
                      if (showDate) _DateSeparator(date: message.timestamp),
                      _MessageBubble(
                        message: message,
                        showAvatar: showAvatar,
                        isGroup: widget.isGroup,
                      ),
                    ],
                  );
                },
              ),
            ),

            // Input field
            Container(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 
                    ? 8 
                    : MediaQuery.of(context).padding.bottom + 8,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.border),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.attach_file,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    onPressed: () {},
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ShadInput(
                      controller: _messageController,
                      placeholder: const Text('Type a message...'),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send,
                        color: theme.colorScheme.primaryForeground,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showChatInfo(BuildContext context, ShadThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.isGroup ? Icons.group : Icons.person,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.chatName, style: theme.textTheme.h3),
            const SizedBox(height: 8),
            Text(
              widget.isGroup ? '4 members' : 'Family member',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InfoAction(
                  icon: Icons.notifications_outlined,
                  label: 'Mute',
                  onTap: () {},
                ),
                _InfoAction(
                  icon: Icons.search,
                  label: 'Search',
                  onTap: () {},
                ),
                _InfoAction(
                  icon: Icons.folder_outlined,
                  label: 'Media',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isMe;

  const _ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isMe,
  });
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final isYesterday = date.year == now.year && 
        date.month == now.month && 
        date.day == now.day - 1;

    String dateText;
    if (isToday) {
      dateText = 'Today';
    } else if (isYesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('MMM d, yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.muted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: theme.textTheme.small,
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool showAvatar;
  final bool isGroup;

  const _MessageBubble({
    required this.message,
    required this.showAvatar,
    required this.isGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final timeFormat = DateFormat('h:mm a');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe && showAvatar)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                message.senderName[0],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          else if (!message.isMe)
            const SizedBox(width: 32),
          if (!message.isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isMe
                    ? theme.colorScheme.primary
                    : theme.colorScheme.muted,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isMe ? 18 : 4),
                  bottomRight: Radius.circular(message.isMe ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isMe && isGroup)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isMe 
                          ? theme.colorScheme.primaryForeground 
                          : theme.colorScheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeFormat.format(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: message.isMe
                              ? theme.colorScheme.primaryForeground.withValues(alpha: 0.7)
                              : theme.colorScheme.mutedForeground,
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all,
                          size: 14,
                          color: theme.colorScheme.primaryForeground.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (message.isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _InfoAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InfoAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.small,
          ),
        ],
      ),
    );
  }
}
