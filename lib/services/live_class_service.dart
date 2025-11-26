import '../models/live_class.dart';
import '../models/chat_message.dart';
import '../models/poll.dart';

class LiveClassService {
  // Mock data for development
  final List<Map<String, dynamic>> _mockLiveClasses = [
    {
      'id': '1',
      'lessonId': '1',
      'title': 'Live Algebra Session',
      'description': 'Interactive algebra class with Q&A',
      'scheduledDate': '2024-01-15T14:00:00.000Z',
      'durationMinutes': 60,
      'isActive': false,
      'participants': <String>[],
      'attendance': <String, String>{},
      'raisedHands': <String>[],
      'currentPollId': null,
      'createdAt': '2024-01-01T00:00:00.000Z',
    },
  ];

  final List<Map<String, dynamic>> _mockChatMessages = [];
  final List<Map<String, dynamic>> _mockPolls = [];

  Future<List<LiveClass>> getLiveClasses(String lessonId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    return _mockLiveClasses
        .where((lc) => lc['lessonId'] == lessonId)
        .map((lc) => LiveClass.fromJson(lc))
        .toList();
  }

  Future<LiveClass?> getLiveClass(String liveClassId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final liveClassData = _mockLiveClasses.firstWhere(
      (lc) => lc['id'] == liveClassId,
      orElse: () => <String, dynamic>{},
    );

    if (liveClassData.isEmpty) return null;
    return LiveClass.fromJson(liveClassData);
  }

  Future<bool> createLiveClass(LiveClass liveClass) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    _mockLiveClasses.add(liveClass.toJson());
    return true;
  }

  Future<bool> startLiveClass(String liveClassId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final liveClassIndex = _mockLiveClasses.indexWhere((lc) => lc['id'] == liveClassId);
    if (liveClassIndex != -1) {
      _mockLiveClasses[liveClassIndex]['isActive'] = true;
      return true;
    }
    return false;
  }

  Future<bool> endLiveClass(String liveClassId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final liveClassIndex = _mockLiveClasses.indexWhere((lc) => lc['id'] == liveClassId);
    if (liveClassIndex != -1) {
      _mockLiveClasses[liveClassIndex]['isActive'] = false;
      return true;
    }
    return false;
  }

  Future<bool> joinLiveClass(String liveClassId, String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final liveClassIndex = _mockLiveClasses.indexWhere((lc) => lc['id'] == liveClassId);
    if (liveClassIndex != -1) {
      final participants = _mockLiveClasses[liveClassIndex]['participants'] as List;
      final attendance = _mockLiveClasses[liveClassIndex]['attendance'] as Map<String, String>;

      if (!participants.contains(userId)) {
        participants.add(userId);
        attendance[userId] = DateTime.now().toIso8601String();
      }
      return true;
    }
    return false;
  }

  Future<bool> leaveLiveClass(String liveClassId, String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final liveClassIndex = _mockLiveClasses.indexWhere((lc) => lc['id'] == liveClassId);
    if (liveClassIndex != -1) {
      final participants = _mockLiveClasses[liveClassIndex]['participants'] as List;
      final raisedHands = _mockLiveClasses[liveClassIndex]['raisedHands'] as List;

      participants.remove(userId);
      raisedHands.remove(userId);
      return true;
    }
    return false;
  }

  Future<bool> raiseHand(String liveClassId, String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    final liveClassIndex = _mockLiveClasses.indexWhere((lc) => lc['id'] == liveClassId);
    if (liveClassIndex != -1) {
      final raisedHands = _mockLiveClasses[liveClassIndex]['raisedHands'] as List;
      if (!raisedHands.contains(userId)) {
        raisedHands.add(userId);
        return true;
      }
    }
    return false;
  }

  Future<bool> lowerHand(String liveClassId, String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    final liveClassIndex = _mockLiveClasses.indexWhere((lc) => lc['id'] == liveClassId);
    if (liveClassIndex != -1) {
      final raisedHands = _mockLiveClasses[liveClassIndex]['raisedHands'] as List;
      raisedHands.remove(userId);
      return true;
    }
    return false;
  }

  // Chat methods
  Future<List<ChatMessage>> getChatMessages(String liveClassId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockChatMessages
        .where((msg) => msg['liveClassId'] == liveClassId)
        .map((msg) => ChatMessage.fromJson(msg))
        .toList();
  }

  Future<bool> sendChatMessage(ChatMessage message) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    _mockChatMessages.add(message.toJson());
    return true;
  }

  // Poll methods
  Future<List<Poll>> getPolls(String liveClassId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockPolls
        .where((poll) => poll['liveClassId'] == liveClassId)
        .map((poll) => Poll.fromJson(poll))
        .toList();
  }

  Future<bool> createPoll(Poll poll) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    _mockPolls.add(poll.toJson());
    return true;
  }

  Future<bool> submitPollResponse(String pollId, String userId, int optionIndex) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    final pollIndex = _mockPolls.indexWhere((poll) => poll['id'] == pollId);
    if (pollIndex != -1) {
      final responses = _mockPolls[pollIndex]['responses'] as Map<String, int>;
      responses[userId] = optionIndex;
      return true;
    }
    return false;
  }

  Future<bool> endPoll(String pollId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final pollIndex = _mockPolls.indexWhere((poll) => poll['id'] == pollId);
    if (pollIndex != -1) {
      _mockPolls[pollIndex]['isActive'] = false;
      return true;
    }
    return false;
  }
}