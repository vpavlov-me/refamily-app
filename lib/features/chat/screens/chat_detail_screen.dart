import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';

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
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AdaptiveScaffold(
        title: widget.chatName,
        hasBackButton: true,
        actions: [
          AdaptiveIconButton(
            icon: isIOS ? CupertinoIcons.info : Icons.info_outline,
            onPressed: () => _showChatInfo(context),
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
              color: RelunaTheme.surfaceLight,
              border: Border(
                top: BorderSide(color: RelunaTheme.divider),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    isIOS ? CupertinoIcons.paperclip : Icons.attach_file,
                    color: RelunaTheme.textSecondary,
                  ),
                  onPressed: () {},
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: RelunaTheme.textTertiary),
                      filled: true,
                      fillColor: RelunaTheme.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: RelunaTheme.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: RelunaTheme.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: RelunaTheme.accentColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: RelunaTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isIOS ? CupertinoIcons.paperplane_fill : Icons.send,
                      color: Colors.white,
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

  void _showChatInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RelunaTheme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.isGroup ? Icons.group : Icons.person,
                size: 48,
                color: RelunaTheme.accentColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.chatName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isGroup ? '4 members' : 'Family member',
              style: TextStyle(color: RelunaTheme.textSecondary),
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
            color: RelunaTheme.divider,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: const TextStyle(
              fontSize: 12,
              color: RelunaTheme.textSecondary,
            ),
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
    final timeFormat = DateFormat('h:mm a');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe && showAvatar)
            CircleAvatar(
              radius: 16,
              backgroundColor: RelunaTheme.accentColor.withValues(alpha: 0.2),
              child: Text(
                message.senderName[0],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: RelunaTheme.accentColor,
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
                    ? RelunaTheme.accentColor
                    : const Color(0xFFEEEFF1),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: RelunaTheme.accentColor,
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : RelunaTheme.textPrimary,
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
                              ? Colors.white70
                              : RelunaTheme.textSecondary,
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all,
                          size: 14,
                          color: Colors.white70,
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RelunaTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: RelunaTheme.accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: RelunaTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
