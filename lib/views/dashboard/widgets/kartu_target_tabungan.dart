import 'package:flutter/material.dart';
import '../../../models/tabungan_models.dart';

class KartuTargetTabungan extends StatelessWidget {
  final List<ModelTabungan> goals;

  const KartuTargetTabungan({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target Tabungan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              // Menu: Tabungan placeholder
            ],
          ),
          SizedBox(height: 24),
          if (goals.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Tidak ada target aktif',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: goals
                    .map((goal) => _buildCircularGoal(context, goal))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircularGoal(BuildContext context, ModelTabungan goal) {
    // Determine color based on goal or random
    final color = goal.title.toLowerCase().contains('car')
        ? Color(0xFF4CAF50) // Green for car
        : Color(0xFF2196F3); // Blue for others

    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: goal.progress,
                      backgroundColor: Theme.of(context).dividerColor,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          goal.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '(${(goal.progress * 100).toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
