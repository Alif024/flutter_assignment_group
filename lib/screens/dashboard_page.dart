import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/buttons/filled_btn_icon.dart';
import 'package:flutter_assignment_group/components/buttons/outlined_btn_icon.dart';
import 'package:flutter_assignment_group/components/cards/dashboard_stat_card.dart';
import 'package:flutter_assignment_group/components/cards/recent_activity_card.dart';
import 'package:flutter_assignment_group/components/cards/surface_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.onOpenDetail,
    required this.onAddAsset,
  });

  final VoidCallback onOpenDetail;
  final VoidCallback onAddAsset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF2D66DF),
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: Colors.white, width: 2),
                          image: const DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alif Wahayee',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40 / 1.5,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'Inventory Officer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.notifications, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, size: 30),
                        SizedBox(width: 10),
                        Text(
                          'Search assets...',
                          style: TextStyle(
                            fontSize: 18 / 1.5,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SurfaceCard(
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Assets',
                                  style: TextStyle(
                                    fontSize: 20 / 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '1,248',
                                  style: TextStyle(
                                    fontSize: 62 / 1.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.widgets_rounded,
                            color: Color(0xFF2D66DF),
                            size: 36,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 168,
                            child: DashboardStatCard(
                              label: 'Normal',
                              value: '1,156',
                              icon: Icons.check_circle,
                              iconColor: Color(0xFF16A34A),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 168,
                            child: DashboardStatCard(
                              label: 'Under Repair',
                              value: '92',
                              icon: Icons.handyman,
                              iconColor: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 44 / 1.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledBtnIcon(
                      text: 'Scan QR Code',
                      onPressed: () {},
                      icon: Icons.qr_code_scanner,
                    ),
                    const SizedBox(height: 12),
                    OutlinedBtnIcon(
                      text: 'Search Asset',
                      icon: Icons.search,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    FilledBtnIcon(
                      text: 'Add New Asset',
                      icon: Icons.add,
                      color: FilledBtnColor.green,
                      onPressed: onAddAsset,
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 44 / 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: onOpenDetail,
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    RecentActivityCard(
                      title: 'Dell Latitude 5420',
                      activityText: 'Status updated',
                      timeText: '2 hours ago',
                      statusText: 'Normal',
                      icon: Icons.laptop,
                      onTap: onOpenDetail,
                    ),
                    const SizedBox(height: 12),
                    const RecentActivityCard(
                      title: 'Office Chair HC-5000',
                      activityText: 'Added',
                      timeText: '5 hours ago',
                      statusText: 'New',
                      icon: Icons.chair,
                      iconColor: Color(0xFF16A34A),
                      statusColor: Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 12),
                    const RecentActivityCard(
                      title: 'HP LaserJet Pro M404',
                      activityText: 'Status updated',
                      timeText: '1 day ago',
                      statusText: 'Repair',
                      icon: Icons.print,
                      iconColor: Color(0xFFDC2626),
                      statusColor: Color(0xFFDC2626),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          if (index == 2) {
            onAddAsset();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

