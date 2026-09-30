import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/chat_model.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/chat_screen/provider/chat_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class MessageScreen extends ConsumerWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatListState = ref.watch(chatListProvider);
    final chatList = chatListState.chatList;

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(chatListProvider.notifier).fetchChatList();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 14.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(),
                const Gap(height: 20),
                if (chatListState.isLoading && chatList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (chatList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Center(
                      child: AppText(
                        text: 'No conversations found',
                        fontSize: 14,
                        color: AppColors.instance.gray500,
                      ),
                    ),
                  )
                else
                  _buildChatList(context, ref, chatList),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Secured communication',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.instance.textColor,
        ),
        const SizedBox(height: 2),
        AppText(
          text: 'BelWork Chats & Devis',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.instance.gray500,
        ),
      ],
    );
  }

  Widget _buildChatList(
    BuildContext context,
    WidgetRef ref,
    List<ChatListItemModel> chatList,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        final item = chatList[index];
        return _buildChatItem(context, ref, item);
      },
    );
  }

  Widget _buildChatItem(
    BuildContext context,
    WidgetRef ref,
    ChatListItemModel item,
  ) {
    final avatarUrl = item.user.avatar.isNotEmpty
        ? item.user.avatar
        : 'https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg?w=768';

    final lastMsg = item.lastMessage?.message ?? 'Start chatting...';
    final isUnread = !item.isLastMsgRead;

    return GestureDetector(
      onTap: () {
        AppRoutes.instance
            .pushNamed(AppRoutesKey.instance.chatScreen, extra: item.user)
            .then((_) {
              ref.read(chatListProvider.notifier).fetchChatList();
            });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.instance.containerBackground,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            // User Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                width: 48,
                height: 48,
                child: AppImage(
                  url: avatarUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Gap(width: 14),

            // Name & Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: item.user.name.isNotEmpty ? item.user.name : 'User',
                    fontSize: 16,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                    color: AppColors.instance.textColor,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    text: lastMsg,
                    fontSize: 13,
                    fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
                    color: isUnread
                        ? AppColors.instance.textColor
                        : AppColors.instance.gray500,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            const Gap(width: 8),

            // Right: Dot indicator for read/unread
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.instance.primary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
