import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/network/api_service.dart';
import '../../order/presentation/order_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.dio.get('/api/notifications');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _notifications = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Gagal fetch notifikasi: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await _api.dio.put('/api/notifications/read-all');
      if (response.statusCode == 200) {
        setState(() {
          for (var notif in _notifications) {
            notif['is_read'] = true;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Semua notifikasi ditandai sudah dibaca')),
          );
        }
      }
    } catch (e) {
      debugPrint("Gagal mark all as read: $e");
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM, HH:mm').format(date);
    } catch (e) {
      return isoString;
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'order_status': return Icons.local_shipping_outlined;
      case 'promo': return Icons.local_offer_outlined;
      case 'dispute': return Icons.gavel_outlined;
      default: return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (_notifications.any((n) => n['is_read'] == false))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Tandai semua dibaca',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Belum ada notifikasi', style: GoogleFonts.inter(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  color: HuashuTheme.mineralJadeGreen,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final isRead = notif['is_read'] == true;
                      
                      return Container(
                        color: isRead ? Colors.transparent : HuashuTheme.mineralJadeGreen.withValues(alpha: 0.05),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: isRead ? HuashuTheme.warmStone : HuashuTheme.mineralJadeGreen,
                            child: Icon(
                              _getIconForType(notif['type'] ?? ''),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            notif['title'] ?? 'Pemberitahuan',
                            style: GoogleFonts.inter(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              color: HuashuTheme.charcoalBlack,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                notif['message'] ?? '',
                                style: GoogleFonts.inter(fontSize: 13, height: 1.4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatDate(notif['created_at'] ?? ''),
                                style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                          onTap: () async {
                            final nav = Navigator.of(context);
                            if (!isRead) {
                              try {
                                await _api.dio.put('/api/notifications/${notif['id']}/read');
                                setState(() {
                                  notif['is_read'] = true;
                                });
                              } catch (e) {
                                debugPrint("Gagal mark as read: $e");
                              }
                            }
                            
                            // Deep Linking
                            final type = notif['type'];
                            final refId = notif['reference_id'];
                            
                            if (type == 'order_status' && refId != null) {
                              nav.push(MaterialPageRoute(
                                builder: (_) => OrderDetailScreen(orderId: refId)
                              ));
                            } else if (type == 'chat' && refId != null) {
                              // We don't have otherUserName easily available, but we can just go to chat list
                              // or pass a placeholder. Passing placeholder is not ideal, so we go to Chat List.
                              nav.pop(); // close notification screen
                            } else if (type == 'dispute' && refId != null) {
                              nav.push(MaterialPageRoute(
                                builder: (_) => OrderDetailScreen(orderId: refId)
                              ));
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
