import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../services/chat_service.dart';
import '../chat/chat_screen.dart';

class AdminChatUsersScreen extends StatefulWidget {
  const AdminChatUsersScreen({super.key});

  @override
  State<AdminChatUsersScreen> createState() => _AdminChatUsersScreenState();
}

class _AdminChatUsersScreenState extends State<AdminChatUsersScreen> {
  final ChatService chatService = ChatService();

  List<dynamic> users = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(loadUsers);
  }

  Future<void> loadUsers() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => isLoading = true);

    try {
      users = await chatService.getChatUsers(token);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Tin nhắn khách hàng'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text('Chưa có khách hàng'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = users[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(user['fullName'] ?? 'Khách hàng'),
              subtitle: Text(user['email'] ?? ''),
              trailing: (user['unreadCount'] ?? 0) > 0
                  ? CircleAvatar(
                radius: 13,
                backgroundColor: Colors.red,
                child: Text(
                  '${user['unreadCount']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  : const Icon(Icons.chevron_right),

              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      receiverId: user['id'],
                      receiverName: user['fullName'] ?? 'Khách hàng',
                    ),
                  ),
                );

                loadUsers(); // quay lại thì cập nhật đã đọc
              },
            )
          );
        },
      ),
    );
  }
}