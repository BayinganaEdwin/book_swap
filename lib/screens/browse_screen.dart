import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/notification_button.dart';
import '../models/book.dart';
import 'post_book_screen.dart';
import 'my_listings_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  int _index = 0;
  final pages = [
    const _BrowseList(),
    const MyListingsScreen(),
    const ChatScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: pages[_index],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PostBookScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Post Book'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
      bottomNavigationBar: StreamBuilder<int>(
        stream: auth.user != null 
            ? FirestoreService().streamTotalUnreadChatCount(auth.user!.uid)
            : Stream.value(0),
        builder: (context, unreadSnapshot) {
          final unreadCount = unreadSnapshot.data ?? 0;
          
          return BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), 
                label: 'Browse',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_rounded), 
                label: 'My Listings',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded),
                    if (unreadCount > 0)
                      Positioned(
                        right: -8,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Chats',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded), 
                label: 'Settings',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BrowseList extends StatefulWidget {
  const _BrowseList();

  @override
  State<_BrowseList> createState() => __BrowseListState();
}

class __BrowseListState extends State<_BrowseList> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _tabIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookProv = Provider.of<BookProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Header and Search
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Discover Books',
                      style: theme.textTheme.displayMedium,
                    ),
                  ),
                  const NotificationButton(),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search books...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ],
          ),
        ),
        // Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'Books',
                  isSelected: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TabButton(
                  label: 'Received',
                  isSelected: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TabButton(
                  label: 'Sent',
                  isSelected: _tabIndex == 2,
                  onTap: () => setState(() => _tabIndex = 2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Content
        Expanded(
          child: _tabIndex == 0
              ? _buildBooksList(bookProv, auth, theme)
              : _tabIndex == 1
                  ? _buildSwapOffersList(auth, theme, isReceived: true)
                  : _buildSwapOffersList(auth, theme, isReceived: false),
        ),
      ],
    );
  }

  Widget _buildBooksList(BookProvider bookProv, AuthProvider auth, ThemeData theme) {
    return StreamBuilder<List<Book>>(
      stream: bookProv.allBooks(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading books',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting ||
            (snapshot.connectionState == ConnectionState.none && !snapshot.hasData)) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        var books = snapshot.data ?? [];
        
        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          books = books.where((book) {
            return book.title.toLowerCase().contains(_searchQuery) ||
                book.author.toLowerCase().contains(_searchQuery);
          }).toList();
        }

        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isNotEmpty ? Icons.search_off : Icons.menu_book_rounded,
                  size: 80,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty ? 'No books found' : 'No books available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Try a different search term'
                      : 'Be the first to post a book!',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        final currentAuth = Provider.of<AuthProvider>(context, listen: false);
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: books.length,
          itemBuilder: (context, i) =>
              BookCard(book: books[i], meId: currentAuth.user?.uid ?? ''),
        );
      },
    );
  }

  Widget _buildSwapOffersList(AuthProvider auth, ThemeData theme, {required bool isReceived}) {
    final firestore = FirestoreService();
    
    if (auth.user == null) {
      return const Center(child: Text('Please sign in'));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: isReceived 
          ? firestore.streamReceivedSwapOffers(auth.user!.uid)
          : firestore.streamSentSwapOffers(auth.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading swap offers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        final offers = snapshot.data ?? [];

        if (offers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swap_horiz_rounded,
                  size: 80,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No swap offers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isReceived 
                      ? 'You haven\'t received any swap offers yet'
                      : 'You haven\'t sent any swap offers yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            return _SwapOfferCard(offer: offers[index], isReceived: isReceived);
          },
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade700,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SwapOfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final bool isReceived;

  const _SwapOfferCard({required this.offer, this.isReceived = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firestore = FirestoreService();
    
    return FutureBuilder<Book?>(
      future: firestore.getBook(offer['bookId'] ?? ''),
      builder: (context, bookSnapshot) {
        final book = bookSnapshot.data;
        
        return FutureBuilder<String?>(
          future: firestore.getUserName(isReceived ? (offer['from'] ?? '') : (offer['to'] ?? '')),
          builder: (context, userSnapshot) {
            final userName = userSnapshot.data ?? 'Unknown User';
            final status = offer['state'] ?? 'pending';
            final isPending = status == 'pending';
            
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: isPending ? null : () {
                  // Navigate to chat if accepted
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              userName[0].toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  isReceived ? 'Wants to swap' : 'Swap status',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status, theme),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (book != null) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Requesting:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'by ${book.author}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (offer['offeredBookId'] != null) ...[
                          FutureBuilder<Book?>(
                            future: firestore.getBook(offer['offeredBookId']),
                            builder: (context, offeredBookSnapshot) {
                              final offeredBook = offeredBookSnapshot.data;
                              if (offeredBook == null) return const SizedBox.shrink();
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Offering:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    offeredBook.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'by ${offeredBook.author}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                      if (isPending && isReceived) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _handleDecline(context, firestore),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Decline'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                  side: BorderSide(color: theme.colorScheme.error),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleAccept(context, firestore),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Accept'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (!isPending && !isReceived) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status, theme).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getStatusColor(status, theme).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                status == 'accepted' 
                                    ? Icons.check_circle 
                                    : Icons.cancel,
                                color: _getStatusColor(status, theme),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  status == 'accepted'
                                      ? 'Your swap offer was accepted!'
                                      : 'Your swap offer was declined.',
                                  style: TextStyle(
                                    color: _getStatusColor(status, theme),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleAccept(BuildContext context, FirestoreService firestore) async {
    final offerId = offer['id'] ?? '';
    final bookId = offer['bookId'] ?? '';
    final offeredBookId = offer['offeredBookId'] ?? '';
    
    if (offerId.isEmpty || bookId.isEmpty || offeredBookId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid swap offer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await firestore.acceptSwapOffer(offerId, bookId, offeredBookId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Swap offer accepted!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDecline(BuildContext context, FirestoreService firestore) async {
    final offerId = offer['id'] ?? '';
    final bookId = offer['bookId'] ?? '';
    final offeredBookId = offer['offeredBookId'] ?? '';
    
    if (offerId.isEmpty || bookId.isEmpty || offeredBookId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid swap offer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Swap Offer'),
        content: const Text('Are you sure you want to decline this swap offer?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Decline'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await firestore.declineSwapOffer(offerId, bookId, offeredBookId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Swap offer declined'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }
}
