import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import '../../../core/network/api_service.dart';

class DestinationSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final ApiService _api = ApiService();

  @override
  String get searchFieldLabel => 'Cari kota atau kecamatan...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Ketik nama kota atau kecamatan tujuan...'),
      );
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<Response>(
      future: _searchDestinations(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan pencarian.'));
        }

        final response = snapshot.data;
        if (response == null || response.statusCode != 200 || response.data['success'] != true) {
          return const Center(child: Text('Destinasi tidak ditemukan.'));
        }

        final List<dynamic> results = response.data['data'] ?? [];

        if (results.isEmpty) {
          return const Center(child: Text('Tidak ada hasil yang cocok.'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            final type = item['type'] ?? '';
            final city = item['city'] ?? '';
            final province = item['province'] ?? '';
            final subdistrict = item['subdistrict'];
            
            final title = subdistrict != null ? '$subdistrict, $type $city' : '$type $city';
            
            return ListTile(
              title: Text(title),
              subtitle: Text(province),
              onTap: () {
                close(context, item);
              },
            );
          },
        );
      },
    );
  }

  Future<Response> _searchDestinations(String q) async {
    // Implement simple debounce here if needed, but FutureBuilder handles it somewhat
    return await _api.dio.get('/api/shipping/search', queryParameters: {'q': q, 'limit': 20});
  }
}
