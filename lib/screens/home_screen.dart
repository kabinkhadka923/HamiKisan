import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/weather_market_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/localization_provider.dart';
import '../utils/app_colors.dart';
import '../models/user.dart';
import '../widgets/localized_text.dart';
import 'marketplace/marketplace_screen.dart';
import 'community_screen.dart';
import 'learning_screen.dart';
import 'doctor_screen.dart';
import 'profile_screen.dart';
import 'create_post_screen.dart';
import 'weather_detail_screen.dart';
import 'market_detail_screen.dart';
import 'post_detail_screen.dart';
import 'dashboards/farmer_dashboard_screen.dart';
import 'dashboards/doctor_dashboard_screen.dart';
import 'dashboards/kisan_admin_dashboard_screen.dart';
import 'dashboards/real_admin_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherMarketProvider>().loadWeatherAndMarketData();
      context.read<PostProvider>().loadPosts();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Route to role-specific dashboard
    switch (user.role) {
      case UserRole.kisanAdmin:
        return const KisanAdminDashboardScreen();
      case UserRole.superAdmin:
        return const RealAdminDashboardScreen();
      case UserRole.kisanDoctor:
        return const DoctorDashboardScreen();
      case UserRole.farmer:
      default:
        return const FarmerDashboardScreen();
    }
  }
}

class _OldFarmerDashboard extends StatefulWidget {
  const _OldFarmerDashboard();
  @override
  State<_OldFarmerDashboard> createState() => _OldFarmerDashboardState();
}

class _OldFarmerDashboardState extends State<_OldFarmerDashboard> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localization, child) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              _buildHomePage(),
              const MarketplaceScreen(),
              const CommunityScreen(),
              _buildDoctorPage(),
              _buildProfilePage(),
            ],
          ),
          floatingActionButton: _currentIndex == 0
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatePostScreen(),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFF4CAF50),
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedItemColor: AppColors.primaryGreen,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                activeIcon: const Icon(Icons.home),
                label: localization.translate('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.store),
                activeIcon: const Icon(Icons.store),
                label: localization.translate('marketplace'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.groups),
                activeIcon: const Icon(Icons.groups),
                label: localization.translate('community'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.health_and_safety),
                activeIcon: const Icon(Icons.health_and_safety),
                label: localization.translate('doctor'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                activeIcon: const Icon(Icons.person),
                label: localization.translate('profile'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildWeatherCard(),
            const SizedBox(height: 16),
            _buildMarketPricesCard(),
            const SizedBox(height: 24),
            _buildUserPosts(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<WeatherMarketProvider>().loadWeatherAndMarketData();
              context.read<PostProvider>().loadPosts();
            },
            child: Image.asset(
              'assets/logo/logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.agriculture,
                    size: 30, color: Colors.white);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LocalizedText(
                  'app_name',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final user = auth.currentUser;
                    final roleName =
                        user?.role.name == 'farmer' ? 'Farmer' : 'Doctor';
                    return Text(
                      '${context.tr('welcome')}, $roleName',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: _showNotifications,
                icon: const Icon(Icons.notifications,
                    color: Colors.white, size: 24),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                const LocalizedText(
                  'today_weather',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WeatherDetailScreen()),
                    );
                  },
                  child: Text(context.tr('view_details')),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<WeatherMarketProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingWeather) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (provider.weatherData != null) {
                  final weather = provider.weatherData!;
                  return Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weather.temperature.round()}°C',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            weather.weatherType,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Colors.blue.shade300,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${weather.humidity.round()}%',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          Icon(
                            Icons.air,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${weather.windSpeed.round()} km/h',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_off, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(context.tr('weather_unavailable')),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<WeatherMarketProvider>(
              builder: (context, provider, _) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.getFarmingTip(),
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketPricesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Market Prices',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MarketDetailScreen()),
                    );
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<WeatherMarketProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingMarketPrice) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (provider.marketPrices != null &&
                    provider.marketPrices!.isNotEmpty) {
                  return Column(
                    children: provider.marketPrices!.take(3).map((item) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.productName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              'Rs.${item.avgPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.priceChangePercent >= 0
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    item.priceChangePercent >= 0
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 12,
                                    color: item.priceChangePercent >= 0
                                        ? Colors.green.shade600
                                        : Colors.red.shade600,
                                  ),
                                  Text(
                                    '${item.priceChangePercent.abs().toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: item.priceChangePercent >= 0
                                          ? Colors.green.shade600
                                          : Colors.red.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.trending_flat, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Market prices not available'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPosts() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        if (postProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (postProvider.posts.isEmpty) {
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No posts yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to share your farming experience!',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Community Posts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...postProvider.posts.map((post) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPostCard(post),
                )),
          ],
        );
      },
    );
  }

  Widget _buildPostCard(post) {
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.currentUser?.id ?? '';
    final isOwnPost = post.userId == currentUserId;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: post.userRole == 'farmer'
                        ? Colors.green
                        : Colors.orange,
                    child: Icon(
                      post.userRole == 'farmer'
                          ? Icons.agriculture
                          : Icons.medical_services,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(post.createdAt),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOwnPost)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePost(post.id),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.content,
                style: const TextStyle(fontSize: 14),
              ),
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                const SizedBox(height: 12),
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(post.imageUrl!),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPostAction(
                    post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    post.likes.toString(),
                    post.isLiked ? Colors.blue : Colors.grey,
                    () => context
                        .read<PostProvider>()
                        .toggleLike(post.id, currentUserId),
                  ),
                  const SizedBox(width: 20),
                  _buildPostAction(Icons.comment_outlined,
                      post.comments.toString(), Colors.grey, null),
                  const SizedBox(width: 20),
                  _buildPostAction(Icons.share_outlined, post.shares.toString(),
                      Colors.grey, null),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostAction(
      IconData icon, String count, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  void _deletePost(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await context.read<PostProvider>().deletePost(postId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(success ? 'Post deleted' : 'Failed to delete'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplacePage() {
    return const MarketplaceScreen();
  }

  Widget _buildLearningPage() {
    return const LearningScreen();
  }

  Widget _buildDoctorPage() {
    return const DoctorScreen();
  }

  Widget _buildProfilePage() {
    return const ProfileScreen();
  }

  void _showNotifications() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: AppColors.headerGradient,
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          const Icon(Icons.notifications,
                              color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildNotificationItem(
                          'New Market Price Update',
                          'Tomato prices increased by 15% in Kathmandu',
                          Icons.trending_up,
                          Colors.green,
                          '5 min ago',
                          true,
                        ),
                        _buildNotificationItem(
                          'Weather Alert',
                          'Heavy rain expected in your area tomorrow',
                          Icons.cloud,
                          Colors.blue,
                          '1 hour ago',
                          true,
                        ),
                        _buildNotificationItem(
                          'New Post',
                          'Dr. Sharma shared farming tips for monsoon',
                          Icons.article,
                          Colors.orange,
                          '2 hours ago',
                          true,
                        ),
                        _buildNotificationItem(
                          'System Update',
                          'HamiKisan app updated to version 2.0',
                          Icons.system_update,
                          Colors.purple,
                          '1 day ago',
                          false,
                        ),
                        _buildNotificationItem(
                          'Community',
                          'Your post received 10 likes',
                          Icons.thumb_up,
                          Colors.blue,
                          '2 days ago',
                          false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  Widget _buildNotificationItem(
    String title,
    String message,
    IconData icon,
    Color color,
    String time,
    bool isNew,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isNew ? color.withOpacity(0.05) : Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isNew ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.currentUser;
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child: const Icon(Icons.person,
                          size: 30, color: Colors.green),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${user?.name.toLowerCase().replaceAll(' ', '_') ?? 'user'}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMenuTile(Icons.person, 'My Profile', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                }),
                _buildMenuTile(Icons.language,
                    'Language: ${user?.language ?? 'English'}', () {}),
                _buildMenuTile(Icons.notifications, 'Notifications', () {}),
                _buildMenuTile(Icons.shopping_bag, 'My Orders', () {}),
                _buildMenuTile(Icons.help, 'Help & Support', () {}),
                _buildMenuTile(Icons.info, 'About HamiKisan', () {}),
                _buildMenuTile(Icons.logout, 'Logout', () {
                  Navigator.pop(context);
                  auth.logout();
                }, isDestructive: true),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
