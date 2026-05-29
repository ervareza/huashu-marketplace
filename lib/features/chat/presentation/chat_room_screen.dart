import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../core/theme/huashu_theme.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/global_socket_service.dart';

class ChatRoomScreen extends StatefulWidget {
  final int roomId;
  final String otherUserName;
  
  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.otherUserName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _messages = [];
  bool _isSending = false;

  io.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    await _fetchMessages();
    _connectSocket();
  }

  void _handleNewMessage(dynamic data) {
    if (mounted) {
      setState(() {
        final exists = _messages.any((m) => m['id'] == data['id']);
        if (!exists) {
          _messages.add(data);
        }
      });
      _scrollToBottom();
      GlobalSocketService().markChatsAsRead(); // Tandai dibaca karena kita sedang di room
    }
  }

  void _connectSocket() {
    _socket = GlobalSocketService().socket;
    if (_socket != null) {
      _socket!.emit('join_room', widget.roomId);
      _socket!.on('new_message', _handleNewMessage);
    } else {
      debugPrint('Global socket is null');
    }
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.dio.get('/api/chats/${widget.roomId}/messages?limit=100');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _messages = response.data['data'] as List<dynamic>? ?? [];
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else {
        setState(() => _errorMessage = response.data['message']?.toString() ?? 'Gagal memuat pesan');
      }
    } on DioException catch (e) {
      setState(() => _errorMessage = ApiService.extractErrorMessage(e));
    } catch (e) {
      setState(() => _errorMessage = 'Kesalahan sistem: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    
    // Optimistic UI update
    final tempMsg = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'content': text,
      'is_mine': true,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    setState(() {
      _messages.add(tempMsg);
      _msgController.clear();
    });
    _scrollToBottom();

    try {
      final response = await _api.dio.post(
        '/api/chats/${widget.roomId}/messages',
        data: {'content': text},
      );
      
      if (response.statusCode == 201 && response.data['success'] == true) {
        final realMsg = response.data['data'];
        setState(() {
          final index = _messages.indexWhere((m) => m['id'] == tempMsg['id']);
          if (index != -1) _messages[index] = realMsg;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim pesan')));
        setState(() {
          _messages.removeWhere((m) => m['id'] == tempMsg['id']);
        });
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _socket?.off('new_message', _handleNewMessage);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName, style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen))
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: const TextStyle(color: HuashuTheme.stainedCinnabarRed)))
                    : _messages.isEmpty
                        ? Center(child: Text('Belum ada pesan', style: GoogleFonts.inter(color: Colors.grey)))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(HuashuTheme.space16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final m = _messages[index];
                              final isMine = m['is_mine'] == true;
                              final content = m['content']?.toString() ?? '';
                              
                              return Align(
                                alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                  decoration: BoxDecoration(
                                    color: isMine ? HuashuTheme.mineralJadeGreen : HuashuTheme.xuanPaperBg,
                                    border: isMine ? null : Border.all(color: HuashuTheme.lightInkLine),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isMine ? 16 : 0),
                                      bottomRight: Radius.circular(isMine ? 0 : 16),
                                    ),
                                  ),
                                  child: Text(
                                    content,
                                    style: GoogleFonts.inter(
                                      color: isMine ? Colors.white : HuashuTheme.charcoalBlack,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          
          // ─── Input Area ───────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: HuashuTheme.xuanPaperBg,
              border: Border(top: BorderSide(color: HuashuTheme.lightInkLine)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: HuashuTheme.warmStone.withValues(alpha: 0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(color: HuashuTheme.mineralJadeGreen, shape: BoxShape.circle),
                    child: IconButton(
                      icon: _isSending 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
