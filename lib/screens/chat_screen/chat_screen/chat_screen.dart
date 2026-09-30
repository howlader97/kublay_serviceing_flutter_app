import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/chat_model.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/screens/auth/role_setting_screen/provider/roll_settings_provider.dart';
import 'package:belwork/screens/chat_screen/provider/chat_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'package:belwork/screens/chat_screen/chat_screen/widgets/quotation_dialog.dart';
import 'package:belwork/screens/chat_screen/chat_screen/widgets/proposal_message_card.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ChatUserModel? chatUser;

  const ChatScreen({super.key, this.chatUser});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  String get _receiverId => widget.chatUser?.id ?? '';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _receiverId.isEmpty) return;
    _messageController.clear();
    final jobId = widget.chatUser?.jobId;
    ref
        .read(singleChatProvider(_receiverId).notifier)
        .sendMessage(text, jobId: jobId);
    _scrollToBottom();

    // Re-request focus to prevent the keyboard from closing automatically
    _focusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatListProvider.notifier).markPartnerAsReadLocally(_receiverId);
      if (widget.chatUser?.jobId != null &&
          widget.chatUser!.jobId!.isNotEmpty) {
        ref
            .read(singleChatProvider(_receiverId).notifier)
            .setJobId(widget.chatUser!.jobId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(singleChatProvider(_receiverId));
    final partner = chatState.partnerUser ?? widget.chatUser;

    final userName =
        (partner?.name != null &&
            partner!.name.isNotEmpty &&
            partner.name != 'User')
        ? partner.name
        : 'User';
    final userAvatar = (partner?.avatar != null && partner!.avatar.isNotEmpty)
        ? partner.avatar
        : 'https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg?w=768';

    final userRoleAsync = ref.watch(userRoleNotifierProvider);
    final userRole = userRoleAsync.asData?.value ?? 'CUSTOMER';
    final isCustomer =
        userRole.trim().toUpperCase() == 'CUSTOMER' ||
        userRole.trim().toUpperCase() == 'USER';

    ref.listen<SingleChatState>(singleChatProvider(_receiverId), (
      previous,
      next,
    ) {
      final prevCount = previous?.messages.length ?? 0;
      final nextCount = next.messages.length;

      if (nextCount > prevCount) {
        _scrollToBottom();
      }
    });

    final messages = chatState.messages;

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              userName,
              userAvatar,
              showQuotationButton: !isCustomer,
              partner: partner,
            ),

            const Divider(height: 1, color: Color(0xFFEBE6E8)),

            Expanded(
              child: chatState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : messages.isEmpty
                  ? Center(
                      child: AppText(
                        text: 'No messages yet. Say hello!',
                        fontSize: 14,
                        color: AppColors.instance.gray500,
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                      itemCount: messages.length,
                      separatorBuilder: (context, index) =>
                          const Gap(height: 14),
                      itemBuilder: (context, index) {
                        final message = messages[messages.length - 1 - index];
                        return _buildMessageBubble(message);
                      },
                    ),
            ),

            // Bottom Input Field Bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    String name,
    String avatarUrl, {
    required bool showQuotationButton,
    ChatUserModel? partner,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          BackButtonWidget(
            onTap: () {
              AppRoutes.instance.pop();
            },
          ),
          const Gap(width: 10),

          // User Avatar with Online Dot
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: AppImage(
                    url: avatarUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.instance.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const Gap(width: 10),

          // User Name & Online status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: name,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.instance.textColor,
                  maxLines: 1,
                ),
                const Gap(height: 2),
                AppText(
                  text: 'Online',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.instance.gray500,
                ),
              ],
            ),
          ),

          // Quotation Button (Hidden for Customers, Visible for Professional/Technician)
          if (showQuotationButton)
            GestureDetector(
              onTap: () {
                final activeJobId =
                    partner?.jobId ?? widget.chatUser?.jobId ?? '';
                final currentUserId =
                    ref
                        .read(singleChatProvider(_receiverId).notifier)
                        .currentUserId ??
                    '';

                showDialog(
                  context: context,
                  builder: (_) => QuotationDialog(
                    jobId: activeJobId,
                    partnerUserId: _receiverId,
                    professionalId: currentUserId,
                    onProposalCreated: (proposal, effectiveJobId) {
                      final formattedText = proposal.toFormattedChatMessage();
                      ref
                          .read(singleChatProvider(_receiverId).notifier)
                          .sendMessage(
                            formattedText,
                            jobId: effectiveJobId.isNotEmpty
                                ? effectiveJobId
                                : (activeJobId.isNotEmpty ? activeJobId : null),
                            proposalId: proposal.id,
                          );
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.instance.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  text: 'Quotation',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message) {
    final isMe = message.isMe;

    final isProposal =
        message.message.contains('JOB PROPOSAL') ||
        message.message.startsWith('📋');
    if (isProposal) {
      return ProposalMessageCard(
        message: message,
        isMe: isMe,
        fallbackJobId: widget.chatUser?.jobId,
        fallbackProfessionalId: _receiverId,
        onStatusChanged: (status) {
          if (status == 'ACCEPTED') {
            ref
                .read(singleChatProvider(_receiverId).notifier)
                .sendMessage('I have accepted your quotation proposal.');
          }
        },
      );
    }
    String timeStr = '';
    if (message.createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(message.createdAt).toLocal();
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        timeStr = '$hour:$minute';
      } catch (_) {
        timeStr = message.createdAt.length >= 16
            ? message.createdAt.substring(11, 16)
            : message.createdAt;
      }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.instance.primary : const Color(0xFFEBE6E8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.4,
                fontWeight: FontWeight.w400,
                color: isMe
                    ? AppColors.instance.white
                    : AppColors.instance.textColor,
              ),
            ),
            const Gap(height: 6),

            // Timestamp and Status Icon
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe
                        ? AppColors.instance.white.withValues(alpha: 0.8)
                        : AppColors.instance.gray500,
                  ),
                ),
                if (!isMe) ...[
                  const Gap(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: AppColors.instance.gray500,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.instance.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // TextField Container
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EFF1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  onSubmitted: (_) => _sendMessage(),
                  textInputAction: TextInputAction.send,
                  style: TextStyle(color: AppColors.instance.black),
                  decoration: InputDecoration(
                    hintText: 'Say something. . .',
                    hintStyle: TextStyle(
                      color: AppColors.instance.gray500,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const Gap(width: 10),

            // Send Button
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.instance.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AppText(
                  text: 'Send',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alias for CustomerChatMessageScreen to maintain backward compatibility across project routes
typedef CustomerChatMessageScreen = ChatScreen;
