class ChatRoomWargaItem {
  final String id;
  final String judulLaporan;
  final String kategoriMasalah;
  final String namaParalegalDitugaskan;
  final String status;
  final String lastMessage;
  final String lastTime;
  final DateTime? lastMsgTime;
  final int unreadCount;
  final String fotoLawanBicara;

  ChatRoomWargaItem({
    required this.id,
    required this.judulLaporan,
    required this.kategoriMasalah,
    required this.namaParalegalDitugaskan,
    required this.status,
    required this.lastMessage,
    required this.lastTime,
    this.lastMsgTime,
    required this.unreadCount,
    required this.fotoLawanBicara,
  });
}
