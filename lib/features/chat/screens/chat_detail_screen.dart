import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';

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
  final FocusNode _inputFocusNode = FocusNode();

  // Mock messages data
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      id: '1',
      senderId: 'user1',
      senderName: 'Me',
      content: 'Bro, will you re-shoot the Legend? The second part turned out to be crap.',
      timestamp: DateTime(2025, 12, 26, 12, 24),
      isMe: true,
    ),
    _ChatMessage(
      id: '2',
      senderId: 'user2',
      senderName: 'Victoria Reluna',
      content: "I'll think about it, but don't say that, I disagree.",
      timestamp: DateTime(2025, 12, 26, 12, 24),
      isMe: false,
    ),
    _ChatMessage(
      id: '3',
      senderId: 'user1',
      senderName: 'Me',
      content: 'But everyone else agrees))',
      timestamp: DateTime(2025, 12, 26, 12, 24),
      isMe: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus input field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inputFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: RelunaTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // Custom header
              _buildHeader(context),

              // Messages list - aligned to bottom
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _MessageBubble(message: message);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Input field
              _buildInputField(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          _CircleButton(
            icon: LucideIcons.chevronLeft,
            onTap: () => Navigator.of(context).pop(),
          ),

          // Title
          Expanded(
            child: Text(
              widget.chatName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: RelunaTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: RelunaTheme.textPrimary,
              ),
            ),
          ),

          // Edit button
          _CircleButton(
            icon: LucideIcons.pencil,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? 8
            : MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: RelunaTheme.textPrimary.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D0084).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Paperclip icon
            GestureDetector(
              onTap: () {},
              child: Icon(
                LucideIcons.paperclip,
                size: 20,
                color: RelunaTheme.accentColor,
              ),
            ),
            const SizedBox(width: 8),

            // Input field
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _inputFocusNode,
                style: TextStyle(
                  fontFamily: RelunaTheme.fontFamily,
                  fontSize: 14,
                  color: RelunaTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Write you message',
                  hintStyle: TextStyle(
                    fontFamily: RelunaTheme.fontFamily,
                    fontSize: 14,
                    color: RelunaTheme.textPrimary.withValues(alpha: 0.25),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),

            // Send icon
            GestureDetector(
              onTap: _sendMessage,
              child: Icon(
                LucideIcons.sendHorizontal,
                size: 20,
                color: RelunaTheme.accentColor,
              ),
            ),
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

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: RelunaTheme.textPrimary.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D0084).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 24,
          color: RelunaTheme.textPrimary,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return Padding(
      padding: EdgeInsets.only(
        left: message.isMe ? 48 : 0,
        right: message.isMe ? 0 : 48,
        bottom: 8,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: message.isMe ? RelunaTheme.accentColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: message.isMe
              ? null
              : Border.all(
                  color: RelunaTheme.textPrimary.withValues(alpha: 0.1),
                ),
          boxShadow: message.isMe
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF0D0084).withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message content
            Text(
              message.content,
              style: TextStyle(
                fontFamily: RelunaTheme.fontFamily,
                fontSize: 14,
                height: 1.4,
                color: message.isMe
                    ? RelunaTheme.background
                    : RelunaTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),

            // Time and checkmark
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  LucideIcons.check,
                  size: 16,
                  color: message.isMe
                      ? Colors.white.withValues(alpha: 0.5)
                      : RelunaTheme.textPrimary,
                ),
                const SizedBox(width: 2),
                Text(
                  timeFormat.format(message.timestamp),
                  style: TextStyle(
                    fontFamily: RelunaTheme.fontFamily,
                    fontSize: 12,
                    height: 1.3,
                    color: message.isMe
                        ? Colors.white.withValues(alpha: 0.5)
                        : RelunaTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
