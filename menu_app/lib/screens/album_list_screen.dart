import 'package:flutter/material.dart';
import 'package:menu_app/helpers/database_helper.dart';
import 'package:menu_app/models/album.dart';

class AlbumListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Album List")),
      body: FutureBuilder<List<Album>>(
        future: DatabaseHelper.instance.getAlbums(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading albums'));
          }

          final albums = snapshot.data ?? [];

          return ListView.builder(
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return ListTile(
                title: Text(album.albumName),
                subtitle: Text("Menu Items: ${album.menuItems.length}"),
              );
            },
          );
        },
      ),
    );
  }
}
