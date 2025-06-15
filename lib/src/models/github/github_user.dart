import 'package:flutter/cupertino.dart';

class GithubUser {
  final String username;
  final String avatarUrl;

  GithubUser({required this.username, required this.avatarUrl});

  NetworkImage get avatar => NetworkImage(avatarUrl);
}
