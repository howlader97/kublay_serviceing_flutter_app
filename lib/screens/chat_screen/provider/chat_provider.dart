import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/models/chat_model.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/provider/customer_profile_provider.dart';
import 'package:belwork/services/repository/chat_repository.dart';
import 'package:belwork/services/sockets/chat_socket_service.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:flutter_riverpod/legacy.dart';

class ChatListState {
  final List<ChatListItemModel> chatList;
  final bool isLoading;

  const ChatListState({this.chatList = const [], this.isLoading = false});

  ChatListState copyWith({List<ChatListItemModel>? chatList, bool? isLoading}) {
    return ChatListState(
      chatList: chatList ?? this.chatList,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatListNotifier extends StateNotifier<ChatListState> {
  final ChatRepository _repository = ChatRepository.instance;
  final ChatSocketService _socketService = ChatSocketService.instance;
  final Ref _ref;
  String? _currentUserId;
  StreamSubscription<ChatMessageModel>? _socketMessageSub;

  ChatListNotifier(this._ref) : super(const ChatListState()) {
    _init();
  }

  @override
  void dispose() {
    _socketMessageSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final userProfileAsync = _ref.read(userProfileProvider);
    _currentUserId = userProfileAsync.asData?.value?.id;
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      _currentUserId = await StorageServices.instance.getUserId();
    }
    await _socketService.initSocket();
    await fetchChatList();
    _listenSocket();
  }

  Future<void> fetchChatList() async {
    state = state.copyWith(isLoading: state.chatList.isEmpty);
    try {
      if (_currentUserId == null || _currentUserId!.isEmpty) {
        final userProfileAsync = _ref.read(userProfileProvider);
        _currentUserId = userProfileAsync.asData?.value?.id;
        if (_currentUserId == null || _currentUserId!.isEmpty) {
          _currentUserId = await StorageServices.instance.getUserId();
        }
      }

      final rawList =
          await _repository.getLastMessageList(currentUserId: _currentUserId);

      // Deduplicate: 1 card per conversation partner (latest message wins)
      final Map<String, ChatListItemModel> groupedMap = {};

      for (final item in rawList) {
        final partnerId = item.user.id;
        if (partnerId.isEmpty) continue;

        if (!groupedMap.containsKey(partnerId)) {
          groupedMap[partnerId] = item;
        } else {
          final existingDate =
              groupedMap[partnerId]?.lastMessage?.createdAt ?? '';
          final itemDate = item.lastMessage?.createdAt ?? '';
          if (itemDate.compareTo(existingDate) > 0) {
            groupedMap[partnerId] = item;
          }
        }
      }

      final missingIds = groupedMap.entries
          .where(
            (e) => e.value.user.name.isEmpty || e.value.user.name == 'User',
          )
          .map((e) => e.key)
          .toList();

      if (missingIds.isNotEmpty) {
        final fetched = await Future.wait(
          missingIds.map((id) => _repository.getUserById(id)),
        );
        for (int i = 0; i < missingIds.length; i++) {
          final profile = fetched[i];
          if (profile != null && profile.name.isNotEmpty) {
            groupedMap[missingIds[i]] = groupedMap[missingIds[i]]!.copyWith(
              user: profile,
            );
          }
        }
      }

      final sortedList = groupedMap.values.toList()
        ..sort((a, b) {
          final dateA = a.lastMessage?.createdAt ?? '';
          final dateB = b.lastMessage?.createdAt ?? '';
          return dateB.compareTo(dateA);
        });

      state = state.copyWith(
        chatList: sortedList,
        isLoading: false,
      );
    } catch (e) {
      errorLog('ChatListNotifier.fetchChatList', e);
      state = state.copyWith(isLoading: false);
    }
  }

  void _listenSocket() {
    _socketMessageSub?.cancel();
    _socketMessageSub = _socketService.onMessageReceived.listen((msg) {
      _handleIncomingMessage(msg);
    });
  }

  void _handleIncomingMessage(ChatMessageModel msg) async {
    try {
      if (_currentUserId == null || _currentUserId!.isEmpty) {
        _currentUserId = await StorageServices.instance.getUserId();
      }

      final partnerId = (msg.senderId == _currentUserId)
          ? msg.receiverId
          : msg.senderId;

      if (partnerId.isEmpty) return;

      final isSentToMe = msg.receiverId == _currentUserId ||
          (_currentUserId != null &&
              msg.senderId.isNotEmpty &&
              msg.senderId != _currentUserId);

      final isUnread = isSentToMe;

      final existingIndex =
          state.chatList.indexWhere((item) => item.user.id == partnerId);

      if (existingIndex != -1) {
        final existingItem = state.chatList[existingIndex];
        final updatedLastMsg = ChatLastMessageModel(
          id: msg.id,
          message: msg.message.isNotEmpty ? msg.message : 'New message',
          senderId: msg.senderId,
          receiverId: msg.receiverId,
          createdAt: msg.createdAt.isNotEmpty
              ? msg.createdAt
              : DateTime.now().toIso8601String(),
          isRead: !isUnread,
        );

        final updatedItem = existingItem.copyWith(
          lastMessage: updatedLastMsg,
          unreadCount: isUnread
              ? (existingItem.unreadCount + 1)
              : existingItem.unreadCount,
          isLastMsgRead: !isUnread,
        );

        final newList = List<ChatListItemModel>.from(state.chatList);
        newList.removeAt(existingIndex);
        newList.insert(0, updatedItem); // Move active conversation to top!

        state = state.copyWith(chatList: newList);
      } else {
        // If partner is not in list, fetch profile and prepend new card
        final profile = await _repository.getUserById(partnerId);
        final user = profile ??
            ChatUserModel(
              id: partnerId,
              name: 'User',
              avatar: '',
            );

        final newLastMsg = ChatLastMessageModel(
          id: msg.id,
          message: msg.message.isNotEmpty ? msg.message : 'New message',
          senderId: msg.senderId,
          receiverId: msg.receiverId,
          createdAt: msg.createdAt.isNotEmpty
              ? msg.createdAt
              : DateTime.now().toIso8601String(),
          isRead: !isUnread,
        );

        final newItem = ChatListItemModel(
          user: user,
          lastMessage: newLastMsg,
          unreadCount: isUnread ? 1 : 0,
          isLastMsgRead: !isUnread,
        );

        state = state.copyWith(chatList: [newItem, ...state.chatList]);
      }
    } catch (e) {
      errorLog('ChatListNotifier._handleIncomingMessage', e);
    }
  }

  void markPartnerAsReadLocally(String partnerId) {
    if (partnerId.isEmpty) return;
    try {
      final index =
          state.chatList.indexWhere((item) => item.user.id == partnerId);
      if (index != -1) {
        final item = state.chatList[index];
        final updatedLastMsg = item.lastMessage != null
            ? ChatLastMessageModel(
                id: item.lastMessage!.id,
                message: item.lastMessage!.message,
                senderId: item.lastMessage!.senderId,
                receiverId: item.lastMessage!.receiverId,
                createdAt: item.lastMessage!.createdAt,
                isRead: true,
              )
            : null;

        final updatedItem = item.copyWith(
          lastMessage: updatedLastMsg,
          unreadCount: 0,
          isLastMsgRead: true,
        );

        final newList = List<ChatListItemModel>.from(state.chatList);
        newList[index] = updatedItem;
        state = state.copyWith(chatList: newList);
      }
    } catch (e) {
      errorLog('ChatListNotifier.markPartnerAsReadLocally', e);
    }
  }
}

final chatListProvider = StateNotifierProvider<ChatListNotifier, ChatListState>(
  (ref) => ChatListNotifier(ref),
);

class SingleChatState {
  final List<ChatMessageModel> messages;
  final ChatUserModel? partnerUser;
  final bool isLoading;
  final bool isSending;

  const SingleChatState({
    this.messages = const [],
    this.partnerUser,
    this.isLoading = false,
    this.isSending = false,
  });

  SingleChatState copyWith({
    List<ChatMessageModel>? messages,
    ChatUserModel? partnerUser,
    bool? isLoading,
    bool? isSending,
  }) {
    return SingleChatState(
      messages: messages ?? this.messages,
      partnerUser: partnerUser ?? this.partnerUser,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
    );
  }
}

class SingleChatNotifier extends StateNotifier<SingleChatState> {
  final String receiverId;
  String? currentUserId;
  String? _activeJobId;
  bool _hasUsedJobId = false;
  bool _isDisposed = false;

  final ChatRepository _repository = ChatRepository.instance;
  final ChatSocketService _socketService = ChatSocketService.instance;
  StreamSubscription<ChatMessageModel>? _socketMessageSub;

  SingleChatNotifier({
    required this.receiverId,
    this.currentUserId,
    String? initialJobId,
  })  : _activeJobId = initialJobId,
        super(const SingleChatState()) {
    _init();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _socketMessageSub?.cancel();
    _socketService.leaveConversation(receiverId);
    super.dispose();
  }

  Future<void> _init() async {
    if (currentUserId == null || currentUserId!.isEmpty) {
      currentUserId = await StorageServices.instance.getUserId();
    }
    await _socketService.initSocket();
    _socketService.joinConversation(receiverId);
    fetchPartnerProfile();
    await _repository.markMessagesAsRead(receiverId);
    await fetchMessages();
    _listenSocket();
  }

  Future<void> fetchPartnerProfile() async {
    if (_isDisposed || receiverId.isEmpty) return;
    try {
      final user = await _repository.getUserById(receiverId);
      if (!_isDisposed && user != null && user.name.isNotEmpty) {
        state = state.copyWith(partnerUser: user);
      }
    } catch (e) {
      errorLog('SingleChatNotifier.fetchPartnerProfile', e);
    }
  }

  void setJobId(String? jobId) {
    if (jobId != null && jobId.isNotEmpty && _activeJobId != jobId) {
      _activeJobId = jobId;
    }
  }

  Future<void> fetchMessages() async {
    if (_isDisposed) return;
    state = state.copyWith(isLoading: true);
    try {
      if (currentUserId == null || currentUserId!.isEmpty) {
        currentUserId = await StorageServices.instance.getUserId();
      }
      await _repository.markMessagesAsRead(receiverId);

      List<ChatMessageModel> list = await _repository.getConversationMessages(
        userId: receiverId,
        currentUserId: currentUserId,
      );

      if (list.isEmpty &&
          _activeJobId != null &&
          _activeJobId!.isNotEmpty &&
          _activeJobId != receiverId) {
        final jobMessages = await _repository.getConversationMessages(
          userId: _activeJobId!,
          currentUserId: currentUserId,
        );
        if (jobMessages.isNotEmpty) {
          list = jobMessages;
        }
      }

      if (!_isDisposed) {
        state = state.copyWith(messages: list, isLoading: false);
      }
    } catch (e) {
      errorLog('SingleChatNotifier.fetchMessages', e);
      if (!_isDisposed) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  void _listenSocket() {
    _socketMessageSub?.cancel();
    _socketMessageSub = _socketService.onMessageReceived.listen((newMsg) {
      _handleIncomingMessage(newMsg);
    });
  }

  void _handleIncomingMessage(ChatMessageModel newMsg) {
    if (_isDisposed) return;

    final isRelevant = (newMsg.senderId == receiverId) ||
        (newMsg.receiverId == receiverId) ||
        (newMsg.senderId == currentUserId && newMsg.receiverId == receiverId) ||
        (newMsg.senderId == receiverId && newMsg.receiverId == currentUserId) ||
        newMsg.senderId.isEmpty;

    if (!isRelevant) return;

    appLog("SingleChat: Adding incoming message -> ${newMsg.message}");
    _repository.markMessagesAsRead(receiverId);

    final alreadyExists = newMsg.id.isNotEmpty &&
        state.messages.any((m) => m.id == newMsg.id);

    if (alreadyExists) return;

    final tempIndex = state.messages.indexWhere(
      (m) =>
          m.id.startsWith('temp_') &&
          m.message.trim() == newMsg.message.trim() &&
          m.isMe == newMsg.isMe,
    );

    if (tempIndex != -1) {
      final newList = List<ChatMessageModel>.from(state.messages);
      newList[tempIndex] = newMsg;
      state = state.copyWith(messages: newList);
    } else {
      state = state.copyWith(messages: [...state.messages, newMsg]);
    }
  }

  Future<bool> sendMessage(
    String text, {
    String? jobId,
    String? proposalId,
  }) async {
    if (text.trim().isEmpty) return false;

    if (currentUserId == null || currentUserId!.isEmpty) {
      currentUserId = await StorageServices.instance.getUserId();
    }

    // Use explicit jobId if provided, otherwise send on first message only
    final hasExistingServerMessages =
        state.messages.any((m) => !m.id.startsWith('temp_'));
    final effectiveJobId = jobId ??
        ((!hasExistingServerMessages && !_hasUsedJobId) ? _activeJobId : null);

    final now = DateTime.now().toIso8601String();
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticMsg = ChatMessageModel(
      id: tempId,
      senderId: currentUserId ?? '',
      receiverId: receiverId,
      message: text.trim(),
      createdAt: now,
      isMe: true,
      proposalId: proposalId,
      jobId: effectiveJobId,
    );

    // Optimistically add to UI state immediately (0ms delay!)
    state = state.copyWith(
      messages: [...state.messages, optimisticMsg],
      isSending: true,
    );

    // Also emit to socket for immediate peer delivery if supported
    final socketPayload = <String, dynamic>{
      'receiverId': receiverId,
      'message': text.trim(),
    };
    if (effectiveJobId != null) socketPayload['jobId'] = effectiveJobId;
    if (proposalId != null) socketPayload['proposalId'] = proposalId;
    _socketService.emit('send_message', socketPayload);

    try {
      final result = await _repository.sendMessage(
        receiverId: receiverId,
        message: text.trim(),
        jobId: effectiveJobId,
        proposalId: proposalId,
        currentUserId: currentUserId,
      );

      if (_isDisposed) return true;

      if (result != null) {
        _hasUsedJobId = true;
        _activeJobId = null;

        final alreadyHasServerId = result.id.isNotEmpty &&
            state.messages.any((m) => m.id == result.id);

        final updatedList = <ChatMessageModel>[];
        for (final m in state.messages) {
          if (m.id == tempId) {
            if (!alreadyHasServerId) {
              updatedList.add(result);
            }
          } else {
            updatedList.add(m);
          }
        }

        state = state.copyWith(messages: updatedList, isSending: false);
        return true;
      } else {
        final updatedList =
            state.messages.where((m) => m.id != tempId).toList();
        state = state.copyWith(messages: updatedList, isSending: false);
        return false;
      }
    } catch (e) {
      errorLog('SingleChatNotifier.sendMessage', e);
      if (!_isDisposed) {
        final updatedList =
            state.messages.where((m) => m.id != tempId).toList();
        state = state.copyWith(messages: updatedList, isSending: false);
      }
      return false;
    }
  }
}

final singleChatProvider = StateNotifierProvider.autoDispose
    .family<SingleChatNotifier, SingleChatState, String>((
  ref,
  receiverId,
) {
  final userProfileAsync = ref.watch(userProfileProvider);
  final currentUserId = userProfileAsync.asData?.value?.id;
  return SingleChatNotifier(
    receiverId: receiverId,
    currentUserId: currentUserId,
  );
});
