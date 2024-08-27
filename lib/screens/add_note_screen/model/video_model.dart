
// video model to show the api videos

class PexelsVideo {
  final int id;
  final int width;
  final int height;
  final int duration;
  final String url;
  final String image;
  final User user;
  final List<VideoFile> videoFiles;
  final List<VideoPicture> videoPictures;

  PexelsVideo({
    required this.id,
    required this.width,
    required this.height,
    required this.duration,
    required this.url,
    required this.image,
    required this.user,
    required this.videoFiles,
    required this.videoPictures,
  });

  factory PexelsVideo.fromJson(Map<String, dynamic> json) {
    return PexelsVideo(
      id: json['id'],
      width: json['width'],
      height: json['height'],
      duration: json['duration'],
      url: json['url'],
      image: json['image'],
      user: User.fromJson(json['user']),
      videoFiles: (json['video_files'] as List)
          .map((file) => VideoFile.fromJson(file))
          .toList(),
      videoPictures: (json['video_pictures'] as List)
          .map((picture) => VideoPicture.fromJson(picture))
          .toList(),
    );
  }
}

class User {
  final int id;
  final String name;
  final String url;

  User({
    required this.id,
    required this.name,
    required this.url,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      url: json['url'],
    );
  }
}

class VideoFile {
  final int id;
  final String quality;
  final String fileType;
  final int width;
  final int height;
  final double fps;
  final String link;
  final int size;

  VideoFile({
    required this.id,
    required this.quality,
    required this.fileType,
    required this.width,
    required this.height,
    required this.fps,
    required this.link,
    required this.size,
  });

  factory VideoFile.fromJson(Map<String, dynamic> json) {
    return VideoFile(
      id: json['id'],
      quality: json['quality'],
      fileType: json['file_type'],
      width: json['width'],
      height: json['height'],
      fps: json['fps'],
      link: json['link'],
      size: json['size'],
    );
  }
}

class VideoPicture {
  final int id;
  final int nr;
  final String picture;

  VideoPicture({
    required this.id,
    required this.nr,
    required this.picture,
  });

  factory VideoPicture.fromJson(Map<String, dynamic> json) {
    return VideoPicture(
      id: json['id'],
      nr: json['nr'],
      picture: json['picture'],
    );
  }
}
