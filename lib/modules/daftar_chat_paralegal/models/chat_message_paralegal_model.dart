class ChatMessage {
  final String text;
  final bool isSender; // true = Paralegal (kanan), false = Klien (kiri)
  final String time;
  final bool isRead;

  ChatMessage({
    required this.text,
    required this.isSender,
    required this.time,
    this.isRead = false,
  });
}
