class PixabayVideo {
  final int id;
  final String pageURL;
  final String type;
  final String tags;
  final int duration;
  final Videos videos;
  final int views;
  final int downloads;
  final int likes;
  final int comments;
  final int userId;
  final String user;
  final String userImageURL;

  PixabayVideo({
    required this.id,
    required this.pageURL,
    required this.type,
    required this.tags,
    required this.duration,
    required this.videos,
    required this.views,
    required this.downloads,
    required this.likes,
    required this.comments,
    required this.userId,
    required this.user,
    required this.userImageURL,
  });

  factory PixabayVideo.fromJson(Map<String, dynamic> json) {
    return PixabayVideo(
      id: json['id'],
      pageURL: json['pageURL'],
      type: json['type'],
      tags: json['tags'],
      duration: json['duration'],
      videos: Videos.fromJson(json['videos']),
      views: json['views'],
      downloads: json['downloads'],
      likes: json['likes'],
      comments: json['comments'],
      userId: json['user_id'],
      user: json['user'],
      userImageURL: json['userImageURL'],
    );
  }
}

class Videos {
  final VideoDetails large;
  final VideoDetails medium;
  final VideoDetails small;
  final VideoDetails tiny;

  Videos({
    required this.large,
    required this.medium,
    required this.small,
    required this.tiny,
  });

  factory Videos.fromJson(Map<String, dynamic> json) {
    return Videos(
      large: VideoDetails.fromJson(json['large']),
      medium: VideoDetails.fromJson(json['medium']),
      small: VideoDetails.fromJson(json['small']),
      tiny: VideoDetails.fromJson(json['tiny']),
    );
  }
}

class VideoDetails {
  final String url;
  final int width;
  final int height;
  final int size;
  final String thumbnail;

  VideoDetails({
    required this.url,
    required this.width,
    required this.height,
    required this.size,
    required this.thumbnail,
  });

  factory VideoDetails.fromJson(Map<String, dynamic> json) {
    return VideoDetails(
      url: json['url'],
      width: json['width'],
      height: json['height'],
      size: json['size'],
      thumbnail: json['thumbnail'],
    );
  }
}
