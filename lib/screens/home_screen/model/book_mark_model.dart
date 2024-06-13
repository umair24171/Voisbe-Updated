class BookmarkModel {
  String bookmarkId;
  String postId;
  String userId;

  BookmarkModel({
    required this.bookmarkId,
    required this.postId,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookmarkId': bookmarkId,
      'postId': postId,
      'userId': userId,
    };
  }

  static BookmarkModel fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      bookmarkId: map['bookmarkId'],
      postId: map['postId'],
      userId: map['userId'],
    );
  }
}
