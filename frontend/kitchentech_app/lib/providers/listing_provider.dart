import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/listing.dart';

class ListingProvider with ChangeNotifier {
  List<Listing> _listings = [];
  List<Listing> _myListings = [];
  bool _isLoading = false;

  List<Listing> get listings => _listings;
  List<Listing> get myListings => _myListings;
  bool get isLoading => _isLoading;

  Future<void> fetchListings({String? city, double? minPrice, double? maxPrice}) async {
    _isLoading = true;
    notifyListeners();

    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.listings}');

      Map<String, String> queryParams = {};
      if (city != null) queryParams['city'] = city;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _listings = data.map((json) => Listing.fromJson(json)).toList();
      }
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyListings(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.myListings}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _myListings = data.map((json) => Listing.fromJson(json)).toList();
      }
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createListing(Listing listing, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.listings}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(listing.toJson()),
      );

      if (response.statusCode == 201) {
        await fetchMyListings(token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteListing(int listingId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.listings}/$listingId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        await fetchMyListings(token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
