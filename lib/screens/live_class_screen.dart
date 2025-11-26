import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/live_class_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/live_class.dart';
import '../models/chat_message.dart';
import '../models/poll.dart';
import '../models/attendance.dart';

class LiveClassScreen extends StatefulWidget {
  final LiveClass liveClass;

  const LiveClassScreen({super.key, required this.liveClass});

  @override
  State<LiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptionControllers = [];
  bool _isHandRaised = false;
  bool _isJoined = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final liveClassProvider = Provider.of<LiveClassProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Load initial data
    liveClassProvider.loadChatMessages(widget.liveClass.id);
    liveClassProvider.loadPolls(widget.liveClass.id);

    // Auto-join if class is active
    if (widget.liveClass.isActive && authProvider.user != null) {
      _joinClass();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _pollQuestionController.dispose();
    for (var controller in _pollOptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _joinClass() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final liveClassProvider = Provider.of<LiveClassProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    if (authProvider.user != null) {
      final success = await liveClassProvider.joinLiveClass(widget.liveClass.id, authProvider.user!.id);
      if (success) {
        setState(() {
          _isJoined = true;
        });

        // Automatically mark attendance for students
        if (authProvider.isStudent) {
          await attendanceProvider.markAttendance(
            authProvider.user!.id,
            authProvider.user!.name,
            widget.liveClass.id,
            widget.liveClass.title,
            AttendanceType.automatic,
            notes: 'Auto-marked on class join',
          );
        }
      }
    }
  }

  Future<void> _leaveClass() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final liveClassProvider = Provider.of<LiveClassProvider>(context, listen: false);

    if (authProvider.user != null) {
      final success = await liveClassProvider.leaveLiveClass(widget.liveClass.id, authProvider.user!.id);
      if (success) {
        setState(() {
          _isJoined = false;
          _isHandRaised = false;
        });
      }
    }
  }

  Future<void> _toggleHand() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final liveClassProvider = Provider.of<LiveClassProvider>(context, listen: false);

    if (authProvider.user == null) return;

    bool success;
    if (_isHandRaised) {
      success = await liveClassProvider.lowerHand(widget.liveClass.id, authProvider.user!.id);
    } else {
      success = await liveClassProvider.raiseHand(widget.liveClass.id, authProvider.user!.id);
    }

    if (success) {
      setState(() {
        _isHandRaised = !_isHandRaised;
      });
    }
  }

  Future<void> _sendMessage(bool isQuestion) async {
    if (_chatController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final liveClassProvider = Provider.of<LiveClassProvider>(context, listen: false);

    if (authProvider.user == null) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      liveClassId: widget.liveClass.id,
      senderId: authProvider.user!.id,
      senderName: authProvider.user!.name,
      message: _chatController.text.trim(),
      timestamp: DateTime.now(),
      isQuestion: isQuestion,
    );

    final success = await liveClassProvider.sendChatMessage(message);
    if (success) {
      _chatController.clear();
    }
  }

  void _showCreatePollDialog() {
    _pollOptionControllers.clear();
    _pollOptionControllers.addAll([TextEditingController(), TextEditingController()]);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Poll'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _pollQuestionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                ),
                const SizedBox(height: 16),
                ..._pollOptionControllers.map((controller) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Option ${_pollOptionControllers.indexOf(controller) + 1}',
                          ),
                        ),
                      ),
                      if (_pollOptionControllers.length > 2)
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              final index = _pollOptionControllers.indexOf(controller);
                              _pollOptionControllers.removeAt(index);
                            });
                          },
                        ),
                    ],
                  ),
                )),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pollOptionControllers.add(TextEditingController());
                    });
                  },
                  child: const Text('Add Option'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _createPoll(),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPoll() async {
    if (_pollQuestionController.text.trim().isEmpty) return;

    final options = _pollOptionControllers
        .map((controller) => controller.text.trim())
        .where((option) => option.isNotEmpty)
        .toList();

    if (options.length < 2) return;

    final liveClassProvider = Provider.of<LiveClassProvider>(context, listen: false);

    final poll = Poll(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      liveClassId: widget.liveClass.id,
      question: _pollQuestionController.text.trim(),
      options: options,
      createdAt: DateTime.now(),
    );

    final success = await liveClassProvider.createPoll(poll);
    if (success) {
      _pollQuestionController.clear();
      for (var controller in _pollOptionControllers) {
        controller.clear();
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final liveClassProvider = Provider.of<LiveClassProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.liveClass.title),
        actions: [
          if (widget.liveClass.isActive && _isJoined)
            IconButton(
              icon: Icon(
                _isHandRaised ? Icons.back_hand : Icons.back_hand_outlined,
                color: _isHandRaised ? Colors.orange : null,
              ),
              onPressed: _toggleHand,
              tooltip: _isHandRaised ? 'Lower Hand' : 'Raise Hand',
            ),
          if (authProvider.user?.role == 'teacher' && widget.liveClass.isActive)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'start':
                    liveClassProvider.startLiveClass(widget.liveClass.id);
                    break;
                  case 'end':
                    liveClassProvider.endLiveClass(widget.liveClass.id);
                    break;
                  case 'poll':
                    _showCreatePollDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                if (!widget.liveClass.isActive)
                  const PopupMenuItem(value: 'start', child: Text('Start Class')),
                if (widget.liveClass.isActive)
                  const PopupMenuItem(value: 'end', child: Text('End Class')),
                if (widget.liveClass.isActive)
                  const PopupMenuItem(value: 'poll', child: Text('Create Poll')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Video Conference Area (Mock)
          Container(
            height: 200,
            color: Colors.black87,
            child: widget.liveClass.isActive
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam, size: 48, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'Live Video Conference',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          'WebRTC Mock Implementation',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Text(
                      'Class not started yet',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
          ),

          // Join/Leave Button
          if (widget.liveClass.isActive)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _isJoined ? _leaveClass : _joinClass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isJoined ? Colors.red : Colors.green,
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: Text(_isJoined ? 'Leave Class' : 'Join Class'),
              ),
            ),

          // Participants Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.people, size: 20),
                const SizedBox(width: 8),
                Text('${widget.liveClass.participants.length} participants'),
                if (widget.liveClass.raisedHands.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.back_hand, size: 20, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text('${widget.liveClass.raisedHands.length} raised hands'),
                ],
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Chat'),
              Tab(text: 'Q&A'),
              Tab(text: 'Polls'),
              Tab(text: 'Forum'),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatTab(isQuestion: false),
                _buildChatTab(isQuestion: true),
                _buildPollsTab(),
                _buildForumTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab({required bool isQuestion}) {
    final liveClassProvider = Provider.of<LiveClassProvider>(context);
    final messages = liveClassProvider.chatMessages
        .where((msg) => msg.isQuestion == isQuestion)
        .toList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(message.senderName),
                  subtitle: Text(message.message),
                  trailing: Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isJoined)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: isQuestion ? 'Ask a question...' : 'Type a message...',
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(isQuestion),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(isQuestion),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPollsTab() {
    final liveClassProvider = Provider.of<LiveClassProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: liveClassProvider.polls.length,
      itemBuilder: (context, index) {
        final poll = liveClassProvider.polls[index];
        final userResponse = poll.responses[authProvider.user?.id];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poll.question,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...poll.options.map((option) {
                  final optionIndex = poll.options.indexOf(option);
                  final count = poll.responses.values.where((r) => r == optionIndex).length;
                  final percentage = poll.responses.isEmpty ? 0.0 : count / poll.responses.length;

                  return Column(
                    children: [
                      if (_isJoined && poll.isActive && userResponse == null)
                        RadioListTile<int>(
                          title: Text(option),
                          value: optionIndex,
                          groupValue: null,
                          onChanged: (value) {
                            if (value != null && authProvider.user != null) {
                              liveClassProvider.submitPollResponse(poll.id, authProvider.user!.id, value);
                            }
                          },
                        )
                      else
                        ListTile(
                          title: Text(option),
                          subtitle: poll.responses.isNotEmpty
                              ? Text('${count} votes (${(percentage * 100).toStringAsFixed(1)}%)')
                              : null,
                          leading: userResponse == optionIndex
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.radio_button_unchecked),
                        ),
                      if (poll.responses.isNotEmpty)
                        LinearProgressIndicator(value: percentage),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
                if (authProvider.user?.role == 'teacher' && poll.isActive)
                  TextButton(
                    onPressed: () => liveClassProvider.endPoll(poll.id),
                    child: const Text('End Poll'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForumTab() {
    // Mock forum implementation
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Discussion Forum',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Forum discussions per subject will be implemented here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}