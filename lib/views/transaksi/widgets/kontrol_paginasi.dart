import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/transaksi_controllers.dart';

class KontrolPaginasi extends StatelessWidget {
  final KontrolerTransaksi controller;

  const KontrolPaginasi({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              'Page ${controller.currentPage.value}',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),

          Row(
            children: [
              Obx(
                () => IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: controller.currentPage.value > 1
                      ? controller.prevPage
                      : null,
                  color: controller.currentPage.value > 1
                      ? Theme.of(context).iconTheme.color
                      : Theme.of(context).disabledColor,
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Obx(
                  () => Text(
                    '${controller.currentPage.value}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: controller.nextPage,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
