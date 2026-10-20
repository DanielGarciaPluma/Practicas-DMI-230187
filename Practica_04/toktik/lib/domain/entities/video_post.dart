class VideoPost {
  final String id;
  final String caption;
  final String videoUrl;
  final int likes;
  final int views;
  final bool isLiked;
  final String source;

  VideoPost({
    required this.id,
    required this.caption,
    required this.videoUrl,
    this.likes = 0,
    this.views = 0,
    this.isLiked = false,
    this.source = 'local',
  }) : assert(likes >= 0);

  VideoPost copyWith({
    String? id,
    String? caption,
    String? videoUrl,
    int? likes,
    int? views,
    bool? isLiked,
    String? source,
  }) {
    return VideoPost(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      videoUrl: videoUrl ?? this.videoUrl,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      isLiked: isLiked ?? this.isLiked,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'caption': caption,
        'videoUrl': videoUrl,
        'likes': likes,
        'views': views,
        'isLiked': isLiked,
        'source': source,
      };

  factory VideoPost.fromJson(Map<String, dynamic> json) => VideoPost(
        id: json['id'] as String,
        caption: json['caption'] as String,
        videoUrl: json['videoUrl'] as String,
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        views: (json['views'] as num?)?.toInt() ?? 0,
        isLiked: json['isLiked'] as bool? ?? false,
        source: json['source'] as String? ?? 'local',
      );
}
