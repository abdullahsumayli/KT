import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/listing.dart';
import '../providers/auth_provider.dart';
import '../providers/listing_provider.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        Provider.of<ListingProvider>(context, listen: false).fetchMyListings(authProvider.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/create-listing');
            },
          ),
        ],
      ),
      body: Consumer<ListingProvider>(
        builder: (context, listingProvider, child) {
          if (listingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (listingProvider.myListings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You have no listings yet'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-listing');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Listing'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: listingProvider.myListings.length,
            itemBuilder: (context, index) {
              final listing = listingProvider.myListings[index];
              return _buildListingCard(listing);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-listing');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListingCard(Listing listing) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);

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
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Listing'),
                content: const Text('Are you sure you want to delete this listing?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );

            if (confirm == true && authProvider.token != null) {
              await listingProvider.deleteListing(
                listing.id!,
                authProvider.token!,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listing deleted')),
                );
              }
            }
          },
        ),
        isThreeLine: true,
      ),
    );
  }
}
