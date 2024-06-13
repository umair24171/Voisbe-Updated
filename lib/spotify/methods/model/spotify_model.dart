class SpotifyTrack {
  final String href;
  final List<SpotifyTrackItem> items;

  SpotifyTrack({
    required this.href,
    required this.items,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      href: json['href'],
      items: (json['items'] as List<dynamic>)
          .map((item) => SpotifyTrackItem.fromJson(item))
          .toList(),
    );
  }
}

class SpotifyTrackItem {
  final String addedAt;
  final SpotifyUser addedBy;
  final bool isLocal;
  final String? primaryColor;
  final SpotifyTrackInfo track;

  SpotifyTrackItem({
    required this.addedAt,
    required this.addedBy,
    required this.isLocal,
    required this.primaryColor,
    required this.track,
  });

  factory SpotifyTrackItem.fromJson(Map<String, dynamic> json) {
    return SpotifyTrackItem(
      addedAt: json['added_at'],
      addedBy: SpotifyUser.fromJson(json['added_by']),
      isLocal: json['is_local'],
      primaryColor: json['primary_color'],
      track: SpotifyTrackInfo.fromJson(json['track']),
    );
  }
}

class SpotifyUser {
  final String externalUrl;
  final String href;
  final String id;
  final String type;
  final String uri;

  SpotifyUser({
    required this.externalUrl,
    required this.href,
    required this.id,
    required this.type,
    required this.uri,
  });

  factory SpotifyUser.fromJson(Map<String, dynamic> json) {
    return SpotifyUser(
      externalUrl: json['external_urls']['spotify'],
      href: json['href'],
      id: json['id'],
      type: json['type'],
      uri: json['uri'],
    );
  }
}

class SpotifyTrackInfo {
  final SpotifyAlbum album;
  final List<SpotifyArtist> artists;
  final List<String> availableMarkets;

  SpotifyTrackInfo({
    required this.album,
    required this.artists,
    required this.availableMarkets,
  });

  factory SpotifyTrackInfo.fromJson(Map<String, dynamic> json) {
    return SpotifyTrackInfo(
      album: SpotifyAlbum.fromJson(json['album']),
      artists: (json['artists'] as List<dynamic>)
          .map((artist) => SpotifyArtist.fromJson(artist))
          .toList(),
      availableMarkets: List<String>.from(json['available_markets']),
    );
  }
}

class SpotifyAlbum {
  final String albumType;
  final List<SpotifyArtist> artists;

  SpotifyAlbum({
    required this.albumType,
    required this.artists,
  });

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) {
    return SpotifyAlbum(
      albumType: json['album_type'],
      artists: (json['artists'] as List<dynamic>)
          .map((artist) => SpotifyArtist.fromJson(artist))
          .toList(),
    );
  }
}

class SpotifyArtist {
  final String externalUrl;
  final String href;
  final String id;
  final String name;
  final String type;
  final String uri;

  SpotifyArtist({
    required this.externalUrl,
    required this.href,
    required this.id,
    required this.name,
    required this.type,
    required this.uri,
  });

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) {
    return SpotifyArtist(
      externalUrl: json['external_urls']['spotify'],
      href: json['href'],
      id: json['id'],
      name: json['name'],
      type: json['type'],
      uri: json['uri'],
    );
  }
}
