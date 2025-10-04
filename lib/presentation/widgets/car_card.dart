import 'package:flutter/material.dart';
import '../../data/models/car.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  const CarCard({
    super.key,
    required this.car,
    this.onTap,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: car.imageUrl.isNotEmpty
                  ? Image.network(
                      car.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.directions_car,
                          size: 60, color: Colors.grey),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏷 Car name
                  Text(
                    car.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(Icons.directions_car,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(car.bodyType,
                          style: TextStyle(color: Colors.grey[700])),

                      const SizedBox(width: 12),
                      Icon(Icons.settings, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(car.transmission,
                          style: TextStyle(color: Colors.grey[700])),

                      const SizedBox(width: 12),
                      Icon(Icons.local_gas_station,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(car.fuelType,
                          style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${car.people} seats",
                          style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${car.pricePerDay.toStringAsFixed(0)} / day",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          Text(
                            car.isAvailable ? "Available" : "Not Available",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: car.isAvailable
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      if (onBook != null && car.isAvailable)
                        ElevatedButton(
                          onPressed: onBook,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Book Now"),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
