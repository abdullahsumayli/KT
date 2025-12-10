import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/listing.dart';
import '../providers/listing_provider.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingProvider>(context, listen: false).fetchListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Kitchens'),
      ),
      body: Consumer<ListingProvider>(
        builder: (context, listingProvider, child) {
          if (listingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (listingProvider.listings.isEmpty) {
            return const Center(
              child: Text('No kitchens available at the moment'),
            );
          }

          return ListView.builder(
            itemCount: listingProvider.listings.length,
            itemBuilder: (context, index) {
              final listing = listingProvider.listings[index];
              return _buildListingCard(listing);
            },
          );
        },
      ),
    );
  }

  Widget _buildListingCard(Listing listing) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: const Icon(Icons.kitchen, size: 40, color: Colors.orange),
        title: Text(listing.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${listing.city}, ${listing.state ?? ''}'),
            Text('\$${listing.pricePerHour}/hour',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (listing.kitchenType != null) Text(listing.kitchenType!),
          ],
        ),
        trailing: listing.isAvailable
            ? const Chip(label: Text('Available'))
            : const Chip(label: Text('Unavailable')),
        isThreeLine: true,
      ),
    );
  }
}
