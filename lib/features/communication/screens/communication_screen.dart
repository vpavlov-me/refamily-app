import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../../../data/models/communication.dart';

// Mock data providers
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    Announcement(
      id: '1',
      title: 'Annual Family Meeting Scheduled',
      content: 'The annual family meeting has been scheduled for January 15th, 2026. All family members are expected to attend. Please confirm your attendance by December 30th.',
      type: AnnouncementType.event,
      priority: AnnouncementPriority.high,
      authorId: 'user1',
      authorName: 'Robert Johnson',
      createdAt: DateTime(2025, 12, 20),
      isPinned: true,
      readByIds: ['user2'],
    ),
    Announcement(
      id: '2',
      title: 'Important: Constitution Amendment Vote',
      content: 'A vote on the proposed constitution amendment regarding voting procedures will be held next week. Please review the proposal document before the vote.',
      type: AnnouncementType.decision,
      priority: AnnouncementPriority.high,
      authorId: 'user1',
      authorName: 'Robert Johnson',
      createdAt: DateTime(2025, 12, 18),
      isPinned: true,
      readByIds: ['user2', 'user3'],
    ),
    Announcement(
      id: '3',
      title: 'Happy Birthday Emily! 🎂',
      content: 'Wishing our dear Emily a very happy birthday! May this year bring you joy, success, and wonderful memories with family.',
      type: AnnouncementType.celebration,
      authorId: 'user2',
      authorName: 'Sarah Johnson',
      createdAt: DateTime(2025, 12, 15),
      readByIds: ['user1', 'user2', 'user3', 'user4'],
    ),
    Announcement(
      id: '4',
      title: 'Q4 Financial Report Available',
      content: 'The quarterly financial report for Q4 2025 is now available in the documents section. Please review at your earliest convenience.',
      type: AnnouncementType.general,
      authorId: 'user1',
      authorName: 'Robert Johnson',
      createdAt: DateTime(2025, 12, 10),
      readByIds: ['user1', 'user2'],
    ),
    Announcement(
      id: '5',
      title: 'Reminder: Charity Gala RSVP',
      content: 'This is a reminder to RSVP for the annual charity gala by December 25th. Please confirm dietary restrictions and guest count.',
      type: AnnouncementType.reminder,
      authorId: 'user2',
      authorName: 'Sarah Johnson',
      createdAt: DateTime(2025, 12, 8),
      expiresAt: DateTime(2025, 12, 25),
    ),
  ];
});

final familyMessagesProvider = FutureProvider<List<FamilyMessage>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    FamilyMessage(
      id: '1',
      senderId: 'user2',
      senderName: 'Sarah Johnson',
      content: 'Has everyone seen the agenda for the upcoming meeting? Please share any items you\'d like to add.',
      sentAt: DateTime(2025, 12, 23, 14, 30),
    ),
    FamilyMessage(
      id: '2',
      senderId: 'user3',
      senderName: 'Michael Johnson',
      content: 'I\'d like to discuss the new investment opportunity I mentioned last week.',
      sentAt: DateTime(2025, 12, 23, 15, 45),
    ),
    FamilyMessage(
      id: '3',
      senderId: 'user4',
      senderName: 'Emily Johnson',
      content: 'Can we also allocate time for the education fund review?',
      sentAt: DateTime(2025, 12, 23, 16, 10),
    ),
    FamilyMessage(
      id: '4',
      senderId: 'user1',
      senderName: 'Robert Johnson',
      content: 'Great suggestions! I\'ve added both items to the agenda. See you all on the 15th.',
      sentAt: DateTime(2025, 12, 24, 9, 0),
    ),
  ];
});

final communicationSummaryProvider = FutureProvider<CommunicationSummary>((ref) async {
  final announcements = await ref.watch(announcementsProvider.future);
  
  return CommunicationSummary(
    unreadAnnouncements: announcements.where((a) => !a.readByIds.contains('currentUser')).length,
    unreadMessages: 2,
    pinnedAnnouncements: announcements.where((a) => a.isPinned).length,
    urgentItems: announcements.where((a) => a.type == AnnouncementType.urgent).length,
  );
});

@RoutePage()
class CommunicationScreen extends ConsumerStatefulWidget {
  const CommunicationScreen({super.key});

  @override
  ConsumerState<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends ConsumerState<CommunicationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final announcements = ref.watch(announcementsProvider);
    final messages = ref.watch(familyMessagesProvider);
    final summary = ref.watch(communicationSummaryProvider);
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return AdaptiveScaffold(
      title: 'Communication',
      hasBackButton: true,
      actions: [
        AdaptiveIconButton(
          icon: isIOS ? CupertinoIcons.add : Icons.add,
          onPressed: () => _showCreateAnnouncementDialog(context),
        ),
      ],
      body: Column(
        children: [
          // Summary Card
          summary.when(
            data: (data) => Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RelunaTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: RelunaTheme.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _QuickStat(
                    icon: Icons.notifications_active,
                    value: '${data.unreadAnnouncements}',
                    label: 'Unread',
                    color: data.unreadAnnouncements > 0 ? RelunaTheme.accentColor : RelunaTheme.textSecondary,
                  ),
                  _QuickStat(
                    icon: Icons.push_pin,
                    value: '${data.pinnedAnnouncements}',
                    label: 'Pinned',
                    color: RelunaTheme.warning,
                  ),
                  _QuickStat(
                    icon: Icons.message,
                    value: '${data.unreadMessages}',
                    label: 'Messages',
                    color: data.unreadMessages > 0 ? RelunaTheme.info : RelunaTheme.textSecondary,
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: RelunaTheme.surfaceDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: RelunaTheme.accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: RelunaTheme.textSecondary,
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Announcements'),
                Tab(text: 'Family Chat'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Announcements Tab
                announcements.when(
                  data: (data) {
                    final pinned = data.where((a) => a.isPinned).toList();
                    final regular = data.where((a) => !a.isPinned).toList();

                    if (data.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.campaign_outlined, size: 64, color: RelunaTheme.textSecondary),
                            const SizedBox(height: 16),
                            Text('No announcements', style: TextStyle(color: RelunaTheme.textSecondary)),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        if (pinned.isNotEmpty) ...[
                          const _SectionHeader('📌 Pinned'),
                          ...pinned.map((a) => _AnnouncementCard(
                            announcement: a,
                            onTap: () => _showAnnouncementDetails(context, a),
                          )),
                          const SizedBox(height: 8),
                        ],
                        if (regular.isNotEmpty) ...[
                          const _SectionHeader('Recent'),
                          ...regular.map((a) => _AnnouncementCard(
                            announcement: a,
                            onTap: () => _showAnnouncementDetails(context, a),
                          )),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),

                // Family Chat Tab
                messages.when(
                  data: (data) => Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          reverse: true,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final message = data[data.length - 1 - index];
                            final isMe = message.senderId == 'user1'; // Mock current user
                            return _MessageBubble(message: message, isMe: isMe);
                          },
                        ),
                      ),
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
                          children: [
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
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (_messageController.text.isNotEmpty) {
                                  _messageController.clear();
                                }
                              },
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
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateAnnouncementDialog(BuildContext context) {
    AdaptiveDialog.show(
      context: context,
      title: 'New Announcement',
      content: 'Create an announcement to share with family members.',
      confirmText: 'Create',
      cancelText: 'Cancel',
      onConfirm: () {
        // Create announcement logic would go here
      },
    );
  }

  void _showAnnouncementDetails(BuildContext context, Announcement announcement) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: announcement.typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(announcement.typeIcon, color: announcement.typeColor),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: announcement.typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(announcement.typeLabel, style: TextStyle(
                            color: announcement.typeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          )),
                        ),
                        if (announcement.isPinned) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.push_pin, size: 18, color: RelunaTheme.warning),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(announcement.title, style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: RelunaTheme.accentColor.withValues(alpha: 0.2),
                          child: Text(announcement.authorName[0], style: const TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(width: 8),
                        Text(announcement.authorName, style: TextStyle(
                          color: RelunaTheme.textSecondary)),
                        const Text(' • ', style: TextStyle(color: RelunaTheme.textSecondary)),
                        Text(dateFormat.format(announcement.createdAt), style: TextStyle(
                          color: RelunaTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(announcement.content, style: const TextStyle(
                      fontSize: 16, height: 1.6)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.visibility, size: 18, color: RelunaTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text('Read by ${announcement.readByIds.length} members',
                            style: TextStyle(color: RelunaTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(
          color: color, fontWeight: FontWeight.bold, fontSize: 20)),
        Text(label, style: TextStyle(color: RelunaTheme.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const _AnnouncementCard({required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: announcement.isPinned 
                ? RelunaTheme.warning.withValues(alpha: 0.3)
                : RelunaTheme.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: announcement.typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(announcement.typeIcon, color: announcement.typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(announcement.title, style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      Row(
                        children: [
                          Text(announcement.authorName, style: TextStyle(
                            color: RelunaTheme.textSecondary, fontSize: 12)),
                          const Text(' • ', style: TextStyle(color: RelunaTheme.textSecondary)),
                          Text(dateFormat.format(announcement.createdAt), style: TextStyle(
                            color: RelunaTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: RelunaTheme.textSecondary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              announcement.content,
              style: TextStyle(color: RelunaTheme.textSecondary, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final FamilyMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: RelunaTheme.accentColor.withValues(alpha: 0.2),
              child: Text(message.senderName[0], style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? RelunaTheme.accentColor : const Color(0xFFEEEFF1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(message.senderName, style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: RelunaTheme.accentColor,
                      )),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : RelunaTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeFormat.format(message.sentAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : RelunaTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
