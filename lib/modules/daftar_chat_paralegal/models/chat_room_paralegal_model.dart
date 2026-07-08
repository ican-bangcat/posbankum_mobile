class ChatRoomItem {
  final String id;
  final String judulKasus;
  final String namaLawanBicara; // Klien
  final String pesanTerakhir;
  final String waktuwaktu;
  final int unreadCount;
  final String status; // 'Aktif', 'Selesai', 'Menunggu'
  final DateTime? lastMsgTime; // Untuk sorting
  final String fotoLawanBicara;

  ChatRoomItem({
    required this.id,
    required this.judulKasus,
    required this.namaLawanBicara,
    required this.pesanTerakhir,
    required this.waktuwaktu,
    this.unreadCount = 0,
    required this.status,
    this.lastMsgTime,
    this.fotoLawanBicara = '',
  });
}
