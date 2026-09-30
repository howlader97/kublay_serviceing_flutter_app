class ChatMessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final List<String> fileUrl;
  final String type;
  final String status;
  final bool isRead;
  final String createdAt;
  final String? updatedAt;
  final bool isMe;
  final String? proposalId;
  final String? jobId;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.fileUrl = const [],
    this.type = 'TEXT',
    this.status = 'SENT',
    this.isRead = false,
    required this.createdAt,
    this.updatedAt,
    this.isMe = false,
    this.proposalId,
    this.jobId,
  });

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final msgId = json['id']?.toString() ?? json['_id']?.toString() ?? '';

    final sId =
        json['senderId']?.toString() ??
        json['sender_id']?.toString() ??
        (json['sender'] is Map
            ? (json['sender']['id']?.toString() ??
                  json['sender']['_id']?.toString())
            : (json['sender'] is String ? json['sender']?.toString() : null)) ??
        '';

    final rId =
        json['receiverId']?.toString() ??
        json['receiver_id']?.toString() ??
        (json['receiver'] is Map
            ? (json['receiver']['id']?.toString() ??
                  json['receiver']['_id']?.toString())
            : (json['receiver'] is String
                  ? json['receiver']?.toString()
                  : null)) ??
        '';

    final filesRaw = json['fileUrl'] ?? json['file_url'];
    List<String> files = [];
    if (filesRaw is List) {
      files = filesRaw.map((e) => e.toString()).toList();
    }

    final pId =
        json['proposalId']?.toString() ??
        json['proposal_id']?.toString() ??
        (json['proposal'] is Map
            ? (json['proposal']['id']?.toString() ??
                  json['proposal']['_id']?.toString())
            : null);
    final jId = json['jobId']?.toString() ?? json['job_id']?.toString();

    return ChatMessageModel(
      id: msgId,
      senderId: sId,
      receiverId: rId,
      message: json['message']?.toString() ?? '',
      fileUrl: files,
      type: json['type']?.toString() ?? 'TEXT',
      status: json['status']?.toString() ?? 'SENT',
      isRead: json['isRead'] == true || json['is_read'] == true,
      createdAt:
          json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
      updatedAt:
          json['updatedAt']?.toString() ?? json['updated_at']?.toString(),
      isMe: (currentUserId != null && currentUserId.isNotEmpty)
          ? (sId == currentUserId)
          : false,
      proposalId: pId,
      jobId: jId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'fileUrl': fileUrl,
      'type': type,
      'status': status,
      'isRead': isRead,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (proposalId != null) 'proposalId': proposalId,
      if (jobId != null) 'jobId': jobId,
    };
  }
}

class ChatUserModel {
  final String id;
  final String name;
  final String avatar;
  final String? jobId;

  ChatUserModel({
    required this.id,
    required this.name,
    required this.avatar,
    this.jobId,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar:
          json['avatar']?.toString() ?? json['profilePic']?.toString() ?? '',
      jobId: json['jobId']?.toString() ?? json['job_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avatar': avatar, 'jobId': jobId};
  }
}

class ChatLastMessageModel {
  final String id;
  final String message;
  final String senderId;
  final String receiverId;
  final String createdAt;
  final bool isRead;

  ChatLastMessageModel({
    required this.id,
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    required this.isRead,
  });

  factory ChatLastMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatLastMessageModel(
      id: json['id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      senderId:
          json['senderId']?.toString() ?? json['sender_id']?.toString() ?? '',
      receiverId:
          json['receiverId']?.toString() ??
          json['receiver_id']?.toString() ??
          '',
      createdAt:
          json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
      isRead: json['isRead'] == true || json['is_read'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'senderId': senderId,
      'receiverId': receiverId,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }
}

class ChatListItemModel {
  final ChatUserModel user;
  final ChatLastMessageModel? lastMessage;
  final int unreadCount;
  final bool isLastMsgRead;

  ChatListItemModel({
    required this.user,
    this.lastMessage,
    this.unreadCount = 0,
    this.isLastMsgRead = true,
  });

  ChatListItemModel copyWith({
    ChatUserModel? user,
    ChatLastMessageModel? lastMessage,
    int? unreadCount,
    bool? isLastMsgRead,
  }) {
    return ChatListItemModel(
      user: user ?? this.user,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isLastMsgRead: isLastMsgRead ?? this.isLastMsgRead,
    );
  }

  factory ChatListItemModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final senderId = json['senderId']?.toString() ??
        json['sender_id']?.toString() ??
        (json['sender'] is Map
            ? (json['sender']['id']?.toString() ??
                json['sender']['_id']?.toString())
            : '') ??
        '';

    final receiverId = json['receiverId']?.toString() ??
        json['receiver_id']?.toString() ??
        (json['receiver'] is Map
            ? (json['receiver']['id']?.toString() ??
                json['receiver']['_id']?.toString())
            : '') ??
        '';

    final isRead = json['isRead'] == true || json['is_read'] == true;

    // Is this an unread message sent to ME?
    bool isIncomingUnread = false;
    if (currentUserId != null && currentUserId.isNotEmpty) {
      if (receiverId == currentUserId && !isRead) {
        isIncomingUnread = true;
      } else if (senderId.isNotEmpty && senderId != currentUserId && !isRead) {
        isIncomingUnread = true;
      }
    } else {
      if (!isRead) {
        isIncomingUnread = true;
      }
    }

    if (json.containsKey('participant') &&
        json['participant'] is Map<String, dynamic>) {
      final participantMap = json['participant'] as Map<String, dynamic>;
      final user = ChatUserModel.fromJson(participantMap);

      final rootJobId =
          json['jobId']?.toString() ?? json['job_id']?.toString();
      final finalUser = (rootJobId != null && rootJobId.isNotEmpty)
          ? ChatUserModel(
              id: user.id,
              name: user.name,
              avatar: user.avatar,
              jobId: rootJobId,
            )
          : user;

      String msgText = json['lastMessage']?.toString() ??
          json['message']?.toString() ??
          '';
      if (msgText.isEmpty || msgText == 'null') {
        final typeStr = json['type']?.toString().toUpperCase() ?? '';
        if (typeStr == 'IMAGE' ||
            (json['fileUrl'] is List && (json['fileUrl'] as List).isNotEmpty)) {
          msgText = '📷 Image';
        } else if (typeStr == 'FILE') {
          msgText = '📁 File';
        } else {
          msgText = 'Start chatting...';
        }
      }

      final lastMsg = ChatLastMessageModel(
        id: json['id']?.toString() ?? '',
        message: msgText,
        senderId: senderId,
        receiverId: receiverId.isNotEmpty ? receiverId : user.id,
        createdAt: json['createdAt']?.toString() ??
            json['created_at']?.toString() ??
            '',
        isRead: isRead,
      );

      final unreadCount = json['unreadCount'] is num
          ? (json['unreadCount'] as num).toInt()
          : (isIncomingUnread ? 1 : 0);

      return ChatListItemModel(
        user: finalUser,
        lastMessage: lastMsg,
        unreadCount: unreadCount,
        isLastMsgRead: !isIncomingUnread && unreadCount == 0,
      );
    }

    // ─── NEW / SENDER & RECEIVER FORMAT ──────────────────────────────────────────
    if (json.containsKey('sender') || json.containsKey('receiver')) {
      final message = json['message']?.toString() ?? '';
      final createdAt = json['createdAt']?.toString() ?? '';
      final msgId = json['id']?.toString() ?? '';

      ChatUserModel partner;
      if (currentUserId != null &&
          currentUserId.isNotEmpty &&
          senderId == currentUserId) {
        // I sent -> show receiver's info
        partner = ChatUserModel.fromJson(
          json['receiver'] is Map<String, dynamic> ? json['receiver'] : {},
        );
      } else {
        // Partner sent -> show sender's info
        partner = ChatUserModel.fromJson(
          json['sender'] is Map<String, dynamic> ? json['sender'] : {},
        );
      }

      final unreadCount = json['unreadCount'] is num
          ? (json['unreadCount'] as num).toInt()
          : (isIncomingUnread ? 1 : 0);

      final lastMsg = ChatLastMessageModel(
        id: msgId,
        message: message,
        senderId: senderId,
        receiverId: receiverId,
        createdAt: createdAt,
        isRead: isRead,
      );

      return ChatListItemModel(
        user: partner,
        lastMessage: lastMsg,
        unreadCount: unreadCount,
        isLastMsgRead: !isIncomingUnread && unreadCount == 0,
      );
    }

    // ─── OLD FORMAT ───────────────────────────────────────────────────────────
    final lastMsg = json['lastMessage'] != null &&
            json['lastMessage'] is Map<String, dynamic>
        ? ChatLastMessageModel.fromJson(json['lastMessage'])
        : null;

    final parsedUser = ChatUserModel.fromJson(
      json['user'] is Map<String, dynamic> ? json['user'] : {},
    );

    ChatUserModel finalUser = parsedUser;

    if (currentUserId != null &&
        currentUserId.isNotEmpty &&
        parsedUser.id == currentUserId) {
      final partnerId = lastMsg != null
          ? (lastMsg.senderId != currentUserId
              ? lastMsg.senderId
              : lastMsg.receiverId)
          : '';
      finalUser = ChatUserModel(id: partnerId, name: '', avatar: '');
    }

    final unread = json['unreadCount'] is num
        ? (json['unreadCount'] as num).toInt()
        : int.tryParse(json['unreadCount']?.toString() ?? '') ?? 0;

    final lastMsgIsIncomingUnread = (lastMsg != null) &&
        (lastMsg.receiverId == currentUserId ||
            (currentUserId != null && lastMsg.senderId != currentUserId)) &&
        !lastMsg.isRead;

    final isLastMsgRead = (unread == 0) && !lastMsgIsIncomingUnread;

    return ChatListItemModel(
      user: finalUser,
      lastMessage: lastMsg,
      unreadCount: unread > 0 ? unread : (lastMsgIsIncomingUnread ? 1 : 0),
      isLastMsgRead: isLastMsgRead,
    );
  }
}
