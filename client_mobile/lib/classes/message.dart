class MessageL {
  final String? gameId;
  final String playerName;
  final String content;
  final DateTime date;
  final bool isSentByMe;

  const MessageL({
    this.gameId,
    required this.playerName,
    required this.content,
    required this.date,
    required this.isSentByMe,
  });
}
