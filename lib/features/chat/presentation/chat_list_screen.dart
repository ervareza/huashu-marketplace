import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/network/api_service.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _chats = [];
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final userIdStr = await _api.secureStorage.read(key: 'user_id');
    _myUserId = userIdStr;
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.dio.get('/api/chats');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _chats = response.data['data'] as List<dynamic>? ?? [];
        });
      } else {
        setState(() => _errorMessage = response.data['message']?.toString() ?? 'Gagal memuat daftar chat');
      }
    } on DioException catch (e) {
      setState(() => _errorMessage = ApiService.extractErrorMessage(e));
    } catch (e) {
      setState(() => _errorMessage = 'Kesalahan sistem: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pesan',
          style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const HuashuSeal(character: '誤'),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: const TextStyle(color: HuashuTheme.stainedCinnabarRed)),
                      TextButton(onPressed: _fetchChats, child: const Text('COBA LAGI')),
                    ],
                  ),
                )
              : _chats.isEmpty
                  ? const HuashuEmptyState(icon: Icons.chat_bubble_outline, message: 'Belum ada percakapan.')
                  : RefreshIndicator(
                      onRefresh: _fetchChats,
                      color: HuashuTheme.mineralJadeGreen,
                      child: ListView.separated(
                        itemCount: _chats.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: HuashuTheme.lightInkLine),
                        itemBuilder: (context, index) {
                          final chat = _chats[index];
                          final participants = chat['participants'] as List<dynamic>? ?? [];
                          
                          // Cari participant selain user sendiri
                          final otherParticipant = participants.firstWhere(
                            (p) => p['user'] != null && p['user']['id'].toString() != _myUserId,
                            orElse: () => null,
                          );

                          final otherUser = otherParticipant?['user'];
                          final otherName = otherUser?['name'] ?? 'Pengguna Tidak Dikenal';
                          final otherAvatar = otherUser?['avatar_url'];
                          
                          final lastMessage = chat['last_message'];
                          final lastMsgContent = lastMessage != null ? lastMessage['content'] : 'Belum ada pesan';
                          final unreadCount = chat['unread_count'] ?? 0;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: HuashuTheme.space24, vertical: 8),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: HuashuTheme.mineralJadeGreen.withValues(alpha: 0.1),
                              backgroundImage: otherAvatar != null ? NetworkImage(ApiService.sanitizeImageUrl(otherAvatar)) : null,
                              child: otherAvatar == null ? Text(otherName.substring(0, 1).toUpperCase(), style: const TextStyle(color: HuashuTheme.mineralJadeGreen, fontWeight: FontWeight.bold)) : null,
                            ),
                            title: Text(otherName, style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Text(
                              lastMsgContent,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 13, color: unreadCount > 0 ? HuashuTheme.charcoalBlack : Colors.grey, fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal),
                            ),
                            trailing: unreadCount > 0
                                ? Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(color: HuashuTheme.stainedCinnabarRed, shape: BoxShape.circle),
                                    child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  )
                                : null,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ChatRoomScreen(roomId: chat['id'], otherUserName: otherName)),
                              );
                              _fetchChats(); // Refresh after returning
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}
