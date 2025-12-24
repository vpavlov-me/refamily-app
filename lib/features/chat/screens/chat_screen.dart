import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    // Mock chat conversations
    final conversations = [
      _ChatConversation(
        name: 'Family Council',
        lastMessage: 'Victoria: Reminder about tomorrow\'s meeting',
        time: '10:30 AM',
        unread: 3,
        isGroup: true,
        avatar: null,
      ),
      _ChatConversation(
        name: 'Investment Committee',
        lastMessage: 'Michael: Q4 report is ready for review',
        time: 'Yesterday',
        unread: 1,
        isGroup: true,
        avatar: null,
      ),
      _ChatConversation(
        name: 'Victoria Reluna',
        lastMessage: 'Thanks for the update on the constitution',
        time: 'Yesterday',
        unread: 0,
        isGroup: false,
        avatar: 'https://i.pravatar.cc/150?u=victoria',
      ),
      _ChatConversation(
        name: 'Michael Reluna',
        lastMessage: 'Can we discuss the investment proposal?',
        time: 'Dec 20',
        unread: 0,
        isGroup: false,
        avatar: 'https://i.pravatar.cc/150?u=michael',
      ),
      _ChatConversation(
        name: 'Next-Gen Council',
        lastMessage: 'Sophia: Excited for the leadership workshop!',
        time: 'Dec 19',
        unread: 0,
        isGroup: true,
        avatar: null,
      ),
    ];

    return AdaptiveScaffold(
      title: 'Chat',
      actions: [
        AdaptiveIconButton(
          icon: isIOS ? CupertinoIcons.square_pencil : Icons.edit_outlined,
          onPressed: () {
            // Show new conversation dialog
            _showNewConversationDialog(context);
          },
        ),
      ],
      body: conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isIOS ? CupertinoIcons.chat_bubble_2 : Icons.chat_bubble_outline,
                    size: 64,
                    color: RelunaTheme.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: RelunaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start a conversation with family members',
                    style: TextStyle(
                      fontSize: 14,
                      color: RelunaTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 76,
              ),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return _ChatListItem(
                  conversation: conversation,
                  isIOS: isIOS,
                  onTap: () {
                    context.router.push(ChatDetailRoute(
                      chatId: 'chat_$index',
                      chatName: conversation.name,
                      isGroup: conversation.isGroup,
                    ));
                  },
                );
              },
            ),
    );
  }

  void _showNewConversationDialog(BuildContext context) {
    final familyMembers = [
      ('Victoria Reluna', 'https://i.pravatar.cc/150?u=victoria'),
      ('Michael Reluna', 'https://i.pravatar.cc/150?u=michael'),
      ('Sophia Reluna', 'https://i.pravatar.cc/150?u=sophia'),
      ('James Reluna', 'https://i.pravatar.cc/150?u=james'),
      ('Emma Reluna', 'https://i.pravatar.cc/150?u=emma'),
    ];

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'New Conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a family member to chat with',
              style: TextStyle(color: RelunaTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            ...familyMembers.map((member) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: RelunaTheme.accentColor.withValues(alpha: 0.2),
                child: Text(
                  member.$1[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: RelunaTheme.accentColor,
                  ),
                ),
              ),
              title: Text(member.$1),
              trailing: const Icon(
                Icons.chevron_right,
                color: RelunaTheme.textSecondary,
              ),
              onTap: () {
                Navigator.pop(context);
                context.router.push(ChatDetailRoute(
                  chatId: 'new_${member.$1.hashCode}',
                  chatName: member.$1,
                  isGroup: false,
                ));
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ChatConversation {
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final bool isGroup;
  final String? avatar;

  const _ChatConversation({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.isGroup,
    this.avatar,
  });
}

class _ChatListItem extends StatelessWidget {
  final _ChatConversation conversation;
  final bool isIOS;
  final VoidCallback? onTap;

  const _ChatListItem({
    required this.conversation,
    required this.isIOS,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            conversation.isGroup
                ? Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: RelunaTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isIOS ? CupertinoIcons.person_3_fill : Icons.group,
                      color: RelunaTheme.accentColor,
                      size: 24,
                    ),
                  )
                : CircleAvatar(
                    radius: 26,
                    backgroundColor: RelunaTheme.accentColor.withValues(alpha: 0.1),
                    child: conversation.avatar != null
                        ? ClipOval(
                            child: Image.network(
                              conversation.avatar!,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(
                                conversation.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: RelunaTheme.accentColor,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            conversation.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: RelunaTheme.accentColor,
                            ),
                          ),
                  ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: conversation.unread > 0
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: RelunaTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        conversation.time,
                        style: TextStyle(
                          fontSize: 13,
                          color: conversation.unread > 0
                              ? RelunaTheme.accentColor
                              : RelunaTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: conversation.unread > 0
                                ? RelunaTheme.textPrimary
                                : RelunaTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: RelunaTheme.accentColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conversation.unread}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
