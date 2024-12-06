          if (isPlaylistsSelected) ...[
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Image.network(
                          playlists[index]["imageUrl"]!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          playlists[index]["title"]!,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        subtitle: Text(
                          playlists[index]["tracks"]!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(Icons.play_arrow, color: Colors.white),
                        onTap: () {
                          // 플레이리스트 내부의 곡 목록을 보여주는 화면으로 이동
                        },
                      );
                    },
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreatePlaylistScreen(),
                              ),
                            );
                            
                            if (result == true) {
                              _fetchPlaylists(); // 새로운 플레이리스트 생성 후 목록 새로고침
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add, color: Colors.black),
                                SizedBox(width: 8),
                                Text(
                                  'New',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),