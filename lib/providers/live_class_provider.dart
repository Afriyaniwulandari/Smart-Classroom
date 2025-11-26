import 'package:flutter/material.dart';
import '../models/live_class.dart';
import '../models/chat_message.dart';
import '../models/poll.dart';
import '../services/live_class_service.dart';

class LiveClassProvider with ChangeNotifier {
  final LiveClassService _liveClassService = LiveClassService();

  List<LiveClass> _liveClasses = [];
  LiveClass? _currentLiveClass;
  List<ChatMessage> _chatMessages = [];
  List<Poll> _polls = [];
  bool _isLoading = false;

  List<LiveClass> get liveClasses => _liveClasses;
  LiveClass? get currentLiveClass => _currentLiveClass;
  List<ChatMessage> get chatMessages => _chatMessages;
  List<Poll> get polls => _polls;
  bool get isLoading => _isLoading;

  Future<void> loadLiveClasses(String lessonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _liveClasses = await _liveClassService.getLiveClasses(lessonId);
    } catch (e) {
      _liveClasses = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLiveClass(String liveClassId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentLiveClass = await _liveClassService.getLiveClass(liveClassId);
    } catch (e) {
      _currentLiveClass = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadChatMessages(String liveClassId) async {
    try {
      _chatMessages = await _liveClassService.getChatMessages(liveClassId);
      notifyListeners();
    } catch (e) {
      _chatMessages = [];
    }
  }

  Future<void> loadPolls(String liveClassId) async {
    try {
      _polls = await _liveClassService.getPolls(liveClassId);
      notifyListeners();
    } catch (e) {
      _polls = [];
    }
  }

  Future<bool> createLiveClass(LiveClass liveClass) async {
    try {
      final success = await _liveClassService.createLiveClass(liveClass);
      if (success) {
        _liveClasses.add(liveClass);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> startLiveClass(String liveClassId) async {
    try {
      final success = await _liveClassService.startLiveClass(liveClassId);
      if (success) {
        final liveClassIndex = _liveClasses.indexWhere((lc) => lc.id == liveClassId);
        if (liveClassIndex != -1) {
          _liveClasses[liveClassIndex] = LiveClass(
            id: _liveClasses[liveClassIndex].id,
            lessonId: _liveClasses[liveClassIndex].lessonId,
            title: _liveClasses[liveClassIndex].title,
            description: _liveClasses[liveClassIndex].description,
            scheduledDate: _liveClasses[liveClassIndex].scheduledDate,
            durationMinutes: _liveClasses[liveClassIndex].durationMinutes,
            isActive: true,
            participants: _liveClasses[liveClassIndex].participants,
            attendance: _liveClasses[liveClassIndex].attendance,
            raisedHands: _liveClasses[liveClassIndex].raisedHands,
            currentPollId: _liveClasses[liveClassIndex].currentPollId,
            createdAt: _liveClasses[liveClassIndex].createdAt,
          );
        }
        if (_currentLiveClass?.id == liveClassId) {
          _currentLiveClass = _liveClasses[liveClassIndex];
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> endLiveClass(String liveClassId) async {
    try {
      final success = await _liveClassService.endLiveClass(liveClassId);
      if (success) {
        final liveClassIndex = _liveClasses.indexWhere((lc) => lc.id == liveClassId);
        if (liveClassIndex != -1) {
          _liveClasses[liveClassIndex] = LiveClass(
            id: _liveClasses[liveClassIndex].id,
            lessonId: _liveClasses[liveClassIndex].lessonId,
            title: _liveClasses[liveClassIndex].title,
            description: _liveClasses[liveClassIndex].description,
            scheduledDate: _liveClasses[liveClassIndex].scheduledDate,
            durationMinutes: _liveClasses[liveClassIndex].durationMinutes,
            isActive: false,
            participants: _liveClasses[liveClassIndex].participants,
            attendance: _liveClasses[liveClassIndex].attendance,
            raisedHands: _liveClasses[liveClassIndex].raisedHands,
            currentPollId: _liveClasses[liveClassIndex].currentPollId,
            createdAt: _liveClasses[liveClassIndex].createdAt,
          );
        }
        if (_currentLiveClass?.id == liveClassId) {
          _currentLiveClass = _liveClasses[liveClassIndex];
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> joinLiveClass(String liveClassId, String userId) async {
    try {
      final success = await _liveClassService.joinLiveClass(liveClassId, userId);
      if (success) {
        final liveClassIndex = _liveClasses.indexWhere((lc) => lc.id == liveClassId);
        if (liveClassIndex != -1) {
          final updatedParticipants = List<String>.from(_liveClasses[liveClassIndex].participants);
          final updatedAttendance = Map<String, DateTime>.from(_liveClasses[liveClassIndex].attendance);

          if (!updatedParticipants.contains(userId)) {
            updatedParticipants.add(userId);
            updatedAttendance[userId] = DateTime.now();
          }

          _liveClasses[liveClassIndex] = LiveClass(
            id: _liveClasses[liveClassIndex].id,
            lessonId: _liveClasses[liveClassIndex].lessonId,
            title: _liveClasses[liveClassIndex].title,
            description: _liveClasses[liveClassIndex].description,
            scheduledDate: _liveClasses[liveClassIndex].scheduledDate,
            durationMinutes: _liveClasses[liveClassIndex].durationMinutes,
            isActive: _liveClasses[liveClassIndex].isActive,
            participants: updatedParticipants,
            attendance: updatedAttendance,
            raisedHands: _liveClasses[liveClassIndex].raisedHands,
            currentPollId: _liveClasses[liveClassIndex].currentPollId,
            createdAt: _liveClasses[liveClassIndex].createdAt,
          );
        }
        if (_currentLiveClass?.id == liveClassId) {
          await loadLiveClass(liveClassId);
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> leaveLiveClass(String liveClassId, String userId) async {
    try {
      final success = await _liveClassService.leaveLiveClass(liveClassId, userId);
      if (success) {
        final liveClassIndex = _liveClasses.indexWhere((lc) => lc.id == liveClassId);
        if (liveClassIndex != -1) {
          final updatedParticipants = List<String>.from(_liveClasses[liveClassIndex].participants);
          final updatedRaisedHands = List<String>.from(_liveClasses[liveClassIndex].raisedHands);

          updatedParticipants.remove(userId);
          updatedRaisedHands.remove(userId);

          _liveClasses[liveClassIndex] = LiveClass(
            id: _liveClasses[liveClassIndex].id,
            lessonId: _liveClasses[liveClassIndex].lessonId,
            title: _liveClasses[liveClassIndex].title,
            description: _liveClasses[liveClassIndex].description,
            scheduledDate: _liveClasses[liveClassIndex].scheduledDate,
            durationMinutes: _liveClasses[liveClassIndex].durationMinutes,
            isActive: _liveClasses[liveClassIndex].isActive,
            participants: updatedParticipants,
            attendance: _liveClasses[liveClassIndex].attendance,
            raisedHands: updatedRaisedHands,
            currentPollId: _liveClasses[liveClassIndex].currentPollId,
            createdAt: _liveClasses[liveClassIndex].createdAt,
          );
        }
        if (_currentLiveClass?.id == liveClassId) {
          await loadLiveClass(liveClassId);
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> raiseHand(String liveClassId, String userId) async {
    try {
      final success = await _liveClassService.raiseHand(liveClassId, userId);
      if (success) {
        final liveClassIndex = _liveClasses.indexWhere((lc) => lc.id == liveClassId);
        if (liveClassIndex != -1) {
          final updatedRaisedHands = List<String>.from(_liveClasses[liveClassIndex].raisedHands);
          if (!updatedRaisedHands.contains(userId)) {
            updatedRaisedHands.add(userId);
          }

          _liveClasses[liveClassIndex] = LiveClass(
            id: _liveClasses[liveClassIndex].id,
            lessonId: _liveClasses[liveClassIndex].lessonId,
            title: _liveClasses[liveClassIndex].title,
            description: _liveClasses[liveClassIndex].description,
            scheduledDate: _liveClasses[liveClassIndex].scheduledDate,
            durationMinutes: _liveClasses[liveClassIndex].durationMinutes,
            isActive: _liveClasses[liveClassIndex].isActive,
            participants: _liveClasses[liveClassIndex].participants,
            attendance: _liveClasses[liveClassIndex].attendance,
            raisedHands: updatedRaisedHands,
            currentPollId: _liveClasses[liveClassIndex].currentPollId,
            createdAt: _liveClasses[liveClassIndex].createdAt,
          );
        }
        if (_currentLiveClass?.id == liveClassId) {
          await loadLiveClass(liveClassId);
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> lowerHand(String liveClassId, String userId) async {
    try {
      final success = await _liveClassService.lowerHand(liveClassId, userId);
      if (success) {
        final liveClassIndex = _liveClasses.indexWhere((lc) => lc.id == liveClassId);
        if (liveClassIndex != -1) {
          final updatedRaisedHands = List<String>.from(_liveClasses[liveClassIndex].raisedHands);
          updatedRaisedHands.remove(userId);

          _liveClasses[liveClassIndex] = LiveClass(
            id: _liveClasses[liveClassIndex].id,
            lessonId: _liveClasses[liveClassIndex].lessonId,
            title: _liveClasses[liveClassIndex].title,
            description: _liveClasses[liveClassIndex].description,
            scheduledDate: _liveClasses[liveClassIndex].scheduledDate,
            durationMinutes: _liveClasses[liveClassIndex].durationMinutes,
            isActive: _liveClasses[liveClassIndex].isActive,
            participants: _liveClasses[liveClassIndex].participants,
            attendance: _liveClasses[liveClassIndex].attendance,
            raisedHands: updatedRaisedHands,
            currentPollId: _liveClasses[liveClassIndex].currentPollId,
            createdAt: _liveClasses[liveClassIndex].createdAt,
          );
        }
        if (_currentLiveClass?.id == liveClassId) {
          await loadLiveClass(liveClassId);
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendChatMessage(ChatMessage message) async {
    try {
      final success = await _liveClassService.sendChatMessage(message);
      if (success) {
        _chatMessages.add(message);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createPoll(Poll poll) async {
    try {
      final success = await _liveClassService.createPoll(poll);
      if (success) {
        _polls.add(poll);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitPollResponse(String pollId, String userId, int optionIndex) async {
    try {
      final success = await _liveClassService.submitPollResponse(pollId, userId, optionIndex);
      if (success) {
        final pollIndex = _polls.indexWhere((poll) => poll.id == pollId);
        if (pollIndex != -1) {
          final updatedResponses = Map<String, int>.from(_polls[pollIndex].responses);
          updatedResponses[userId] = optionIndex;

          _polls[pollIndex] = Poll(
            id: _polls[pollIndex].id,
            liveClassId: _polls[pollIndex].liveClassId,
            question: _polls[pollIndex].question,
            options: _polls[pollIndex].options,
            responses: updatedResponses,
            isActive: _polls[pollIndex].isActive,
            createdAt: _polls[pollIndex].createdAt,
            endTime: _polls[pollIndex].endTime,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> endPoll(String pollId) async {
    try {
      final success = await _liveClassService.endPoll(pollId);
      if (success) {
        final pollIndex = _polls.indexWhere((poll) => poll.id == pollId);
        if (pollIndex != -1) {
          _polls[pollIndex] = Poll(
            id: _polls[pollIndex].id,
            liveClassId: _polls[pollIndex].liveClassId,
            question: _polls[pollIndex].question,
            options: _polls[pollIndex].options,
            responses: _polls[pollIndex].responses,
            isActive: false,
            createdAt: _polls[pollIndex].createdAt,
            endTime: _polls[pollIndex].endTime,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}