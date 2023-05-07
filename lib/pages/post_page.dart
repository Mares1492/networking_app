import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:networking_app/auth/auth.dart';

import '../db/firebase/controllers/firebase_posts_controller.dart';

class PostPage extends StatefulWidget {
  final Map post;
  final String postKey;

  const PostPage({
    Key? key,
    required this.post,
    required this.postKey,
  }) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool _isUsersPost = false;
  Color _likeButtonColor = Colors.grey;
  Color _favoriteButtonColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isUsersPost = widget.post['authorId'] == Auth().currentUser!.uid;
      //TODO: Used when implementing like functionality
      /* if (widget.post['likedBy'] != null) {
       _likeButtonColor =
           widget.post['likedBy'].contains(Auth().currentUser!.uid)
               ? Colors.blue
               : Colors.grey;
     } */
    });
  }

  Widget _buildTags(tags) {
    // * If there are no tags, return an empty container due to the fact that firebase doesn't save empty lists and returns null instead
    // * This could be altered to storing some placeholder value in firebase instead of null in the future
    if (tags == null) {
      return Container();
    }
    List<String> tagsToDisplay = tags.cast<String>();
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 10, left: 0),
      child: Wrap(
          spacing: 5,
          runSpacing: 5,
          children: tagsToDisplay.map((tag) {
            return Chip(
              label: Text(tag),
              padding: EdgeInsets.zero,
            );
          }).toList()),
    );
  }

  Widget _buildPostTime(int time) {
    return Text(
      DateFormat('EEEE, dd MMMM, yyyy HH:mm')
          .format(DateTime.fromMillisecondsSinceEpoch(time)),
      style: const TextStyle(
        color: Colors.grey,
      ),
    );
  }

  Widget _buildEventTime(int? eventTime) {
    if (eventTime == null) {
      return Container();
    }
    return Text(
      'Event on: ${DateFormat('EEEE, dd MMMM, yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(eventTime))}',
      style: TextStyle(
        color: Colors.grey[800],
        fontWeight: FontWeight.bold,
        fontSize: 20.0,
      ),
    );
  }

  Widget _buildLikes(int likes) {
    return Row(
      children: [
        Text(
          'Likes: $likes',
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 5.0),
        IconButton(
          onPressed: _handleLikeButtonClick,
          color: _likeButtonColor,
          icon: const Icon(Icons.thumb_up),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_getAppTitle()),
      actions: [
        IconButton(
            onPressed: _handleFavoriteButtonClick,
            icon: const Icon(Icons.favorite),
            color: _favoriteButtonColor),
        if (_isUsersPost)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
        if (_isUsersPost)
          IconButton(
            onPressed: _handleDeleteButtonClick,
            icon: const Icon(Icons.delete),
          ),
      ],
    );
  }

  String _getAppTitle() {
    if (_isUsersPost) {
      return 'Your post';
    }
    return 'Post by ${widget.post['author']}';
  }

  void _handleLikeButtonClick() {
    //TODO: Implement liking a post and saving it to firebase
    setState(() {
      if (_likeButtonColor == Colors.grey) {
        _likeButtonColor = Colors.blue;
        widget.post['likes']++;
      } else {
        _likeButtonColor = Colors.grey;
        widget.post['likes']--;
      }
    });
  }

  void _handleFavoriteButtonClick() {
    //TODO: Implement saving a post to favorites and saving it to firebase
    if (_favoriteButtonColor == Colors.grey) {
      setState(() {
        _favoriteButtonColor = Colors.red;
      });
    } else {
      setState(() {
        _favoriteButtonColor = Colors.grey;
      });
    }
  }

  Future<void> _handleDeleteButtonClick() async {
    bool? isAccept = await _promptDeletePost();
    if (isAccept == null || !isAccept) {
      return;
    }
    await FirebasePostsController()
        .deletePost(widget.postKey)
        .then((value) => Navigator.of(context).pop());
  }

  Future<bool?> _promptDeletePost() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to delete this post?'),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40.0,
              ),
            ),
            const SizedBox(height: 8.0),
            _buildPostTime(widget.post['time']),
            const SizedBox(height: 16.0),
            Text(
              widget.post['body'],
              style: const TextStyle(
                fontSize: 25.0,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildEventTime(widget.post['eventTime']),
            const SizedBox(height: 8.0),
            _buildLikes(widget.post['likes']),
            const SizedBox(height: 8.0),
            _buildTags(widget.post['tags']),
          ],
        ),
      ),
    );
  }
}
