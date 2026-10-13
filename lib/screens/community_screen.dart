import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/localized_text.dart';
import '../models/community_models.dart';
import '../data/nepal_districts.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeCommunity();
  }

  Future<void> _initializeCommunity({bool force = false}) async {
    final authProvider = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();
    final user = authProvider.currentUser;

    if (user != null && (force || !_isInitialized)) {
      if (force && mounted) setState(() => _isInitialized = false);
      await communityProvider.initialize();
      if (mounted) setState(() => _isInitialized = true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LocalizedText('community'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Join or leave district communities',
            onPressed: () => _showDistrictCommunities(context),
            icon: const Icon(Icons.group_add_outlined),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.campaign), text: 'Notices'),
            Tab(icon: Icon(Icons.attach_money), text: 'Prices'),
            Tab(icon: Icon(Icons.feedback), text: 'Feedback'),
            Tab(icon: Icon(Icons.message), text: 'Messages'),
          ],
        ),
      ),
      body: Consumer<CommunityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !_isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initializeCommunity(force: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.userGroups.isEmpty || provider.selectedGroup == null) {
            return _buildNoCommunities(context, provider);
          }

          return Column(
            children: [
              _buildGroupSelector(provider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNoticesTab(provider),
                    _buildPricesTab(provider),
                    _buildFeedbackTab(provider),
                    _buildMessagesTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoCommunities(BuildContext context, CommunityProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_city, size: 64, color: Color(0xFF4CAF50)),
            const SizedBox(height: 16),
            const Text(
              'Join your district community',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your registered district community is added automatically. '
              'You can also join or leave any district community at any time.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _showDistrictCommunities(context),
              icon: const Icon(Icons.groups_outlined),
              label:
                  Text('Browse ${nepalDistricts.length} district communities'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSelector(CommunityProvider provider) {
    if (provider.selectedGroup == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.selectedGroup!.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${provider.selectedGroup!.type.displayName} • ${provider.selectedGroup!.memberCount} members',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (provider.userGroups.length > 1)
            PopupMenuButton<String>(
              icon: const Icon(Icons.swap_horiz),
              onSelected: (groupId) => provider.selectGroup(groupId),
              itemBuilder: (context) => provider.userGroups
                  .map((group) => PopupMenuItem(
                        value: group.id,
                        child: Text(group.name),
                      ))
                  .toList(),
            ),
          IconButton(
            tooltip: 'Join or leave district communities',
            onPressed: () => _showDistrictCommunities(context),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  Future<void> _showDistrictCommunities(BuildContext context) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final provider = context.read<CommunityProvider>();
    final searchController = TextEditingController();
    String? busyGroupId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final query = searchController.text.trim().toLowerCase();
          final groups = provider.districtGroups.where((group) {
            return query.isEmpty ||
                group.location.toLowerCase().contains(query);
          }).toList();
          final joinedIds =
              provider.userGroups.map((group) => group.id).toSet();
          final registeredDistrict =
              findNepalDistrict(user.district ?? user.address);

          return SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(sheetContext).height * 0.8,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'District communities',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          registeredDistrict == null
                              ? 'Join and leave communities whenever you like.'
                              : 'Your registered district is $registeredDistrict.',
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search districts',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      searchController.clear();
                                      setSheetState(() {});
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setSheetState(() {}),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        final isJoined = joinedIds.contains(group.id);
                        final isRegisteredDistrict =
                            group.location == registeredDistrict;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color(0xFF4CAF50).withValues(alpha: 0.12),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          title: Text(group.location),
                          subtitle: Text(
                            '${group.memberCount} members'
                            '${isRegisteredDistrict ? ' • Your registered district' : ''}',
                          ),
                          trailing: isJoined
                              ? TextButton(
                                  onPressed: provider.isLoading ||
                                          busyGroupId == group.id
                                      ? null
                                      : () async {
                                          setSheetState(
                                              () => busyGroupId = group.id);
                                          try {
                                            await provider.leaveDistrict(
                                              group.id,
                                            );
                                            if (sheetContext.mounted) {
                                              setSheetState(() {});
                                            }
                                          } catch (error) {
                                            if (!sheetContext.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Could not leave community: $error',
                                                ),
                                              ),
                                            );
                                          } finally {
                                            if (sheetContext.mounted) {
                                              setSheetState(
                                                  () => busyGroupId = null);
                                            }
                                          }
                                        },
                                  child: const Text('Leave'),
                                )
                              : FilledButton.tonal(
                                  onPressed: provider.isLoading ||
                                          busyGroupId == group.id
                                      ? null
                                      : () async {
                                          setSheetState(
                                              () => busyGroupId = group.id);
                                          try {
                                            await provider.joinDistrict(
                                              group.location,
                                            );
                                            if (sheetContext.mounted) {
                                              setSheetState(() {});
                                            }
                                          } catch (error) {
                                            if (!sheetContext.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Could not join community: $error',
                                                ),
                                              ),
                                            );
                                          } finally {
                                            if (sheetContext.mounted) {
                                              setSheetState(
                                                  () => busyGroupId = null);
                                            }
                                          }
                                        },
                                  child: const Text('Join'),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    searchController.dispose();
  }

  Widget _buildNoticesTab(CommunityProvider provider) {
    if (provider.notices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No notices yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.notices.length,
      itemBuilder: (context, index) {
        final notice = provider.notices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getNoticeColor(notice.type),
              child: Icon(_getNoticeIcon(notice.type), color: Colors.white),
            ),
            title: Text(
              notice.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notice.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'By ${notice.authorName} • ${_formatDate(notice.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            trailing: notice.isPinned
                ? const Icon(Icons.push_pin, color: Color(0xFF4CAF50))
                : null,
            onTap: () => _showNoticeDetails(context, notice),
          ),
        );
      },
    );
  }

  Widget _buildPricesTab(CommunityProvider provider) {
    if (provider.marketPrices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No market prices yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.marketPrices.length,
      itemBuilder: (context, index) {
        final price = provider.marketPrices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price.productName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text(price.category),
                      backgroundColor:
                          const Color(0xFF4CAF50).withValues(alpha: 0.2),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPriceInfo('Min', price.minPrice, price.unit),
                    _buildPriceInfo('Avg', price.avgPrice, price.unit),
                    _buildPriceInfo('Max', price.maxPrice, price.unit),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${price.marketLocation} • ${_formatDate(price.priceDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackTab(CommunityProvider provider) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feedback_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Feedback feature coming soon',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMessagesTab(CommunityProvider provider) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Messages feature coming soon',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(String label, double price, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          'Rs. ${price.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4CAF50),
          ),
        ),
        Text(
          'per $unit',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Color _getNoticeColor(NoticeType type) {
    switch (type) {
      case NoticeType.emergency:
        return Colors.red;
      case NoticeType.subsidy:
        return Colors.green;
      case NoticeType.training:
        return Colors.blue;
      case NoticeType.weather:
        return Colors.orange;
      case NoticeType.marketPrice:
        return Colors.purple;
      case NoticeType.program:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getNoticeIcon(NoticeType type) {
    switch (type) {
      case NoticeType.emergency:
        return Icons.warning;
      case NoticeType.subsidy:
        return Icons.monetization_on;
      case NoticeType.training:
        return Icons.school;
      case NoticeType.weather:
        return Icons.cloud;
      case NoticeType.marketPrice:
        return Icons.trending_up;
      case NoticeType.program:
        return Icons.event;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showNoticeDetails(BuildContext context, notice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notice.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notice.content),
              const SizedBox(height: 16),
              Text(
                'Posted by: ${notice.authorName}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                'Date: ${_formatDate(notice.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
