class ChatMessageWarga {
  final String text;
  final bool isSender; // true = Warga (Kanan), false = Posbankum (Kiri)
  final String time;
  final bool isRead;

  ChatMessageWarga({
    required this.text,
    required this.isSender,
    required this.time,
    this.isRead = false,
  });
}
