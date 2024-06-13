class Track {
  final String id;
  final String name;
  final List<String> artists;
  final int durationMs;
  final String externalUrl;
  final String? trackUrl;
  // Added field for track URL

  Track({
    required this.id,
    required this.name,
    required this.artists,
    required this.durationMs,
    required this.externalUrl,
    this.trackUrl, // Updated constructor
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      name: json['name'],
      artists: (json['artists'] as List<dynamic>)
          .map((artist) => artist['name'].toString())
          .toList(),
      durationMs: json['duration_ms'],
      externalUrl: json['external_urls']['spotify'],
      // Set track URL to the Spotify URL
    );
  }
}
