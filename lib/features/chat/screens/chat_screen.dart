import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

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

    return AppScaffold(
      title: 'Chat',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {
            _showNewConversationDialog(context, theme);
          },
        ),
      ],
      body: conversations.isEmpty
          ? EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No conversations yet',
              subtitle: 'Start a conversation with family members',
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: conversations.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 76,
                color: theme.colorScheme.border,
              ),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return _ChatListItem(
                  conversation: conversation,
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

  void _showNewConversationDialog(BuildContext context, ShadThemeData theme) {
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
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: theme.colorScheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('New Conversation', style: theme.textTheme.h4),
            const SizedBox(height: 8),
            Text(
              'Select a family member to chat with',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: 20),
            ...familyMembers.map((member) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  member.$1[0],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              title: Text(member.$1),
              trailing: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.mutedForeground,
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
  final VoidCallback? onTap;

  const _ChatListItem({
    required this.conversation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
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
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.group,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  )
                : conversation.avatar != null
                    ? ShadAvatar(
                        conversation.avatar!,
                        size: const Size(52, 52),
                      )
                    : Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          conversation.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
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
                            color: theme.colorScheme.foreground,
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
                              ? theme.colorScheme.primary
                              : theme.colorScheme.mutedForeground,
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
                                ? theme.colorScheme.foreground
                                : theme.colorScheme.mutedForeground,
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
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conversation.unread}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primaryForeground,
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
