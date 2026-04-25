import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';

// ─── SharedPreferences keys ────────────────────────────────────────────────
const _prefLastCrop = 'market_last_crop';
const _prefLastState = 'market_last_state';
const _prefFavorites = 'market_favorites';

// ─── State list ────────────────────────────────────────────────────────────
const _indianStates = [
  'Telangana',
  'Andhra Pradesh',
  'Karnataka',
  'Tamil Nadu',
  'Maharashtra',
  'Kerala',
  'Gujarat',
  'Rajasthan',
  'Punjab',
  'Haryana',
  'Uttar Pradesh',
  'Madhya Pradesh',
  'West Bengal',
  'Odisha',
];

// ─── Sort options ──────────────────────────────────────────────────────────
enum _SortOption { highestFirst, lowestFirst, nameAZ, districtAZ }

extension _SortLabel on _SortOption {
  String get label {
    switch (this) {
      case _SortOption.highestFirst:
        return 'Highest Price';
      case _SortOption.lowestFirst:
        return 'Lowest Price';
      case _SortOption.nameAZ:
        return 'Market A–Z';
      case _SortOption.districtAZ:
        return 'District A–Z';
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MarketScreen
// ══════════════════════════════════════════════════════════════════════════════
class MarketScreen extends StatefulWidget {
  const MarketScreen({Key? key}) : super(key: key);

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  // ── existing state ──────────────────────────────────────────────────────
  final _cropController = TextEditingController();
  final _filterController = TextEditingController();
  String _selectedState = 'Telangana';
  List<String> _suggestions = [];
  Map<String, dynamic>? _marketData;
  bool _loading = false;
  String? _errorMessage;

  // ── Phase A state ───────────────────────────────────────────────────────
  List<String> _favorites = [];
  bool _pricePerKg = false;
  _SortOption _sortOption = _SortOption.highestFirst;
  String _marketFilter = '';

  // ── lifecycle ───────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadFavorites();
  }

  @override
  void dispose() {
    _cropController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  // ── prefs ────────────────────────────────────────────────────────────────
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCrop = prefs.getString(_prefLastCrop);
    final lastState = prefs.getString(_prefLastState);
    if (!mounted) return;
    setState(() {
      if (lastCrop != null && lastCrop.isNotEmpty) {
        _cropController.text = lastCrop;
      }
      if (lastState != null && _indianStates.contains(lastState)) {
        _selectedState = lastState;
      }
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLastCrop, _cropController.text.trim());
    await prefs.setString(_prefLastState, _selectedState);
  }

  // ── favorites ────────────────────────────────────────────────────────────
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefFavorites) ?? [];
    if (!mounted) return;
    setState(() => _favorites = raw);
  }

  Future<void> _toggleFavorite(String crop) async {
    if (crop.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = List<String>.from(_favorites);
    if (updated.contains(crop)) {
      updated.remove(crop);
    } else {
      updated.add(crop);
    }
    await prefs.setStringList(_prefFavorites, updated);
    if (!mounted) return;
    setState(() => _favorites = updated);
  }

  bool get _isFavorite =>
      _cropController.text.trim().isNotEmpty &&
      _favorites.contains(_cropController.text.trim());

  // ── autocomplete ─────────────────────────────────────────────────────────
  Future<void> _onCropChanged(String value) async {
    if (value.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final results = await ApiService.searchCommodities(value);
    if (!mounted) return;
    setState(() => _suggestions = results);
  }

  void _selectCrop(String crop) {
    setState(() {
      _cropController.text = crop;
      _suggestions = [];
    });
  }

  // ── fetch ────────────────────────────────────────────────────────────────
  Future<void> _fetchPrices() async {
    final crop = _cropController.text.trim();
    if (crop.isEmpty) return;

    setState(() {
      _loading = true;
      _marketData = null;
      _errorMessage = null;
      _suggestions = [];
      _marketFilter = '';
      _filterController.clear();
    });

    final result = await ApiService.fetchMarketPrices(
      commodity: crop,
      state: _selectedState,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      await _savePrefs();
      setState(() {
        _loading = false;
        _marketData = result['results'] as Map<String, dynamic>?;
      });
    } else {
      setState(() {
        _loading = false;
        _errorMessage =
            result['message']?.toString() ?? 'No market data found';
      });
    }
  }

  // ── price helpers ─────────────────────────────────────────────────────────
  String _fmt(num price) =>
      _pricePerKg ? (price / 100).toStringAsFixed(2) : price.toStringAsFixed(0);

  String get _unitLabel => _pricePerKg ? '/kg' : '/qtl';

  // ── processed market list ─────────────────────────────────────────────────
  List<dynamic> _processedMarkets(List<dynamic> raw) {
    var list = List<dynamic>.from(raw);

    if (_marketFilter.isNotEmpty) {
      final q = _marketFilter.toLowerCase();
      list = list.where((m) {
        final market = m as Map<String, dynamic>;
        return (market['market']?.toString().toLowerCase().contains(q) ??
                false) ||
            (market['district']?.toString().toLowerCase().contains(q) ?? false);
      }).toList();
    }

    list.sort((a, b) {
      final ma = a as Map<String, dynamic>;
      final mb = b as Map<String, dynamic>;
      switch (_sortOption) {
        case _SortOption.highestFirst:
          return ((mb['modal_price'] as int?) ?? 0)
              .compareTo((ma['modal_price'] as int?) ?? 0);
        case _SortOption.lowestFirst:
          return ((ma['modal_price'] as int?) ?? 0)
              .compareTo((mb['modal_price'] as int?) ?? 0);
        case _SortOption.nameAZ:
          return (ma['market']?.toString() ?? '')
              .compareTo(mb['market']?.toString() ?? '');
        case _SortOption.districtAZ:
          return (ma['district']?.toString() ?? '')
              .compareTo(mb['district']?.toString() ?? '');
      }
    });

    return list;
  }

  // ── insight ───────────────────────────────────────────────────────────────
  String _insight(Map<String, dynamic> summary, List<dynamic> markets) {
    final highest =
        (summary['highest_market'] as Map<String, dynamic>?) ?? {};
    final lowest =
        (summary['lowest_market'] as Map<String, dynamic>?) ?? {};

    final highName = highest['market']?.toString() ?? '';
    final highPrice = (highest['price'] as num?)?.toInt() ?? 0;
    final lowPrice = (lowest['price'] as num?)?.toInt() ?? 0;
    final avg = (summary['avg_modal_price'] as num?)?.toDouble() ?? 0;

    if (highName.isEmpty || highPrice == 0) {
      return 'Market data loaded. Compare prices across districts before selling.';
    }

    final spread = highPrice - lowPrice;
    final spreadPct = highPrice > 0 ? (spread / highPrice * 100) : 0;

    if (spreadPct > 30) {
      return 'Wide price spread (${spreadPct.toStringAsFixed(0)}%) today. '
          'Best returns at $highName — ₹${_fmt(highPrice)}$_unitLabel.';
    }
    if (avg > 3000) {
      return 'Premium prices today (avg ₹${_fmt(avg)}$_unitLabel). '
          'Best selling market: $highName.';
    }
    return 'Best selling market today: $highName at ₹${_fmt(highPrice)}$_unitLabel. '
        '${markets.length} markets available.';
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final rawMarkets =
        (_marketData?['markets'] as List<dynamic>?) ?? [];
    final processed = _marketData != null ? _processedMarkets(rawMarkets) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Dashboard'),
        elevation: 0,
      ),
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        onRefresh: _fetchPrices,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Favorites bar ─────────────────────────────────────────
              if (_favorites.isNotEmpty) ...[
                _FavoritesBar(
                  favorites: _favorites,
                  currentCrop: _cropController.text.trim(),
                  onTap: (crop) {
                    _selectCrop(crop);
                    _fetchPrices();
                  },
                  onRemove: _toggleFavorite,
                ),
                const SizedBox(height: 12),
              ],

              // ── Search card ───────────────────────────────────────────
              _SearchCard(
                cropController: _cropController,
                suggestions: _suggestions,
                selectedState: _selectedState,
                loading: _loading,
                isFavorite: _isFavorite,
                onCropChanged: _onCropChanged,
                onCropSelected: _selectCrop,
                onStateChanged: (s) => setState(() => _selectedState = s),
                onFetch: _fetchPrices,
                onToggleFavorite: () =>
                    _toggleFavorite(_cropController.text.trim()),
              ),

              const SizedBox(height: 20),

              if (_loading) const _LoadingView(),
              if (_errorMessage != null)
                _ErrorCard(message: _errorMessage!),

              // ── Results ───────────────────────────────────────────────
              if (_marketData != null)
                _ResultsView(
                  data: _marketData!,
                  pricePerKg: _pricePerKg,
                  fmt: _fmt,
                  unitLabel: _unitLabel,
                  sortOption: _sortOption,
                  filterController: _filterController,
                  processedMarkets: processed,
                  totalCount: rawMarkets.length,
                  insightFn: _insight,
                  onUnitToggle: () =>
                      setState(() => _pricePerKg = !_pricePerKg),
                  onSortChanged: (s) => setState(() => _sortOption = s),
                  onFilterChanged: (s) =>
                      setState(() => _marketFilter = s),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Favorites bar
// ══════════════════════════════════════════════════════════════════════════════
class _FavoritesBar extends StatelessWidget {
  final List<String> favorites;
  final String currentCrop;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;

  const _FavoritesBar({
    required this.favorites,
    required this.currentCrop,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.favorite, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Watchlist',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: favorites.map((crop) {
              final isActive = crop == currentCrop;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: RawChip(
                  label: Text(
                    crop,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor:
                      isActive ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                  side: BorderSide(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.3),
                  ),
                  onPressed: () => onTap(crop),
                  deleteIcon: Icon(
                    Icons.close,
                    size: 14,
                    color: isActive ? Colors.white70 : Colors.grey.shade500,
                  ),
                  onDeleted: () => onRemove(crop),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Search card
// ══════════════════════════════════════════════════════════════════════════════
class _SearchCard extends StatelessWidget {
  final TextEditingController cropController;
  final List<String> suggestions;
  final String selectedState;
  final bool loading;
  final bool isFavorite;
  final ValueChanged<String> onCropChanged;
  final ValueChanged<String> onCropSelected;
  final ValueChanged<String> onStateChanged;
  final VoidCallback onFetch;
  final VoidCallback onToggleFavorite;

  const _SearchCard({
    required this.cropController,
    required this.suggestions,
    required this.selectedState,
    required this.loading,
    required this.isFavorite,
    required this.onCropChanged,
    required this.onCropSelected,
    required this.onStateChanged,
    required this.onFetch,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final hasCrop = cropController.text.trim().isNotEmpty;

    return Container(
      decoration: AppStyle.glassCard,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop search field
          TextField(
            controller: cropController,
            onChanged: onCropChanged,
            decoration: InputDecoration(
              labelText: 'Search Crop',
              hintText: 'e.g. Tomato, Onion, Rice',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          // Autocomplete dropdown
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: suggestions.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 16),
                itemBuilder: (_, i) {
                  final item = suggestions[i];
                  return ListTile(
                    dense: true,
                    leading:
                        Icon(Icons.grain, size: 16, color: AppColors.primary),
                    title: Text(item, style: const TextStyle(fontSize: 14)),
                    onTap: () => onCropSelected(item),
                  );
                },
              ),
            ),
          ],

          // Favorite toggle (shown when crop is typed)
          if (hasCrop) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isFavorite ? Colors.red.shade400 : AppColors.primary,
                ),
                label: Text(
                  isFavorite ? 'Saved to Watchlist' : 'Save to Watchlist',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isFavorite ? Colors.red.shade400 : AppColors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // State dropdown
          DropdownButtonFormField<String>(
            value: selectedState,
            decoration: InputDecoration(
              labelText: 'State',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _indianStates
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) {
              if (val != null) onStateChanged(val);
            },
          ),

          const SizedBox(height: 16),

          // Fetch button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: loading ? null : onFetch,
              style: AppStyle.primaryButton,
              icon: const Icon(Icons.show_chart),
              label: const Text(
                'Get Live Prices',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Loading view
// ══════════════════════════════════════════════════════════════════════════════
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Fetching live market prices…',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Error card
// ══════════════════════════════════════════════════════════════════════════════
class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Could Not Fetch Prices',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Results view
// ══════════════════════════════════════════════════════════════════════════════
class _ResultsView extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool pricePerKg;
  final String Function(num) fmt;
  final String unitLabel;
  final _SortOption sortOption;
  final TextEditingController filterController;
  final List<dynamic> processedMarkets;
  final int totalCount;
  final String Function(Map<String, dynamic>, List<dynamic>) insightFn;
  final VoidCallback onUnitToggle;
  final ValueChanged<_SortOption> onSortChanged;
  final ValueChanged<String> onFilterChanged;

  const _ResultsView({
    required this.data,
    required this.pricePerKg,
    required this.fmt,
    required this.unitLabel,
    required this.sortOption,
    required this.filterController,
    required this.processedMarkets,
    required this.totalCount,
    required this.insightFn,
    required this.onUnitToggle,
    required this.onSortChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final summary = (data['summary'] as Map<String, dynamic>?) ?? {};
    final commodity = data['commodity']?.toString() ?? '';
    final state = data['state']?.toString() ?? '';

    final avg = summary['avg_modal_price'] as num?;
    final highest =
        (summary['highest_market'] as Map<String, dynamic>?) ?? {};
    final lowest =
        (summary['lowest_market'] as Map<String, dynamic>?) ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row: commodity · state + unit toggle ──────────────
        Row(
          children: [
            Expanded(
              child: Text(
                '$commodity  ·  $state',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _UnitToggle(
              pricePerKg: pricePerKg,
              onToggle: onUnitToggle,
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── Summary cards ─────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Avg Price',
                value: avg != null ? '₹${fmt(avg)}$unitLabel' : '—',
                icon: Icons.bar_chart,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Highest',
                value: highest['market']?.toString() ?? '—',
                sub: highest['price'] != null
                    ? '₹${fmt(highest['price'] as num)}$unitLabel'
                    : null,
                icon: Icons.arrow_upward,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Lowest',
                value: lowest['market']?.toString() ?? '—',
                sub: lowest['price'] != null
                    ? '₹${fmt(lowest['price'] as num)}$unitLabel'
                    : null,
                icon: Icons.arrow_downward,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── Insight card ──────────────────────────────────────────────
        if (totalCount > 0) ...[
          _InsightCard(
            text: insightFn(
              summary,
              (data['markets'] as List<dynamic>?) ?? [],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Sort + Filter controls ────────────────────────────────────
        Row(
          children: [
            // Sort dropdown
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<_SortOption>(
                    value: sortOption,
                    isDense: true,
                    icon: const Icon(Icons.unfold_more, size: 16),
                    items: _SortOption.values
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s.label,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ))
                        .toList(),
                    onChanged: (s) {
                      if (s != null) onSortChanged(s);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Filter field
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: filterController,
                  onChanged: onFilterChanged,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Filter markets…',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon:
                        const Icon(Icons.search, size: 16),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Markets header ────────────────────────────────────────────
        Row(
          children: [
            Icon(Icons.store_mall_directory_outlined,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              processedMarkets.length == totalCount
                  ? 'Markets ($totalCount)'
                  : 'Markets (${processedMarkets.length} of $totalCount)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Market cards ──────────────────────────────────────────────
        if (processedMarkets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No markets match your filter.',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          )
        else
          ...processedMarkets.map((m) => _MarketCard(
                market: m as Map<String, dynamic>,
                fmt: fmt,
                unitLabel: unitLabel,
              )),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Unit toggle
// ══════════════════════════════════════════════════════════════════════════════
class _UnitToggle extends StatelessWidget {
  final bool pricePerKg;
  final VoidCallback onToggle;

  const _UnitToggle({required this.pricePerKg, required this.onToggle});

  Widget _btn(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _btn('₹/Qtl', !pricePerKg),
            _btn('₹/Kg', pricePerKg),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Summary card
// ══════════════════════════════════════════════════════════════════════════════
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub!,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Insight card
// ══════════════════════════════════════════════════════════════════════════════
class _InsightCard extends StatelessWidget {
  final String text;
  const _InsightCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Market card
// ══════════════════════════════════════════════════════════════════════════════
class _MarketCard extends StatelessWidget {
  final Map<String, dynamic> market;
  final String Function(num) fmt;
  final String unitLabel;

  const _MarketCard({
    required this.market,
    required this.fmt,
    required this.unitLabel,
  });

  @override
  Widget build(BuildContext context) {
    final name = market['market']?.toString() ?? 'Unknown';
    final district = market['district']?.toString() ?? '';
    final modal = (market['modal_price'] as int?) ?? 0;
    final min = (market['min_price'] as int?) ?? 0;
    final max = (market['max_price'] as int?) ?? 0;
    final date = market['arrival_date']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppStyle.glassCard,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + modal badge
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '₹${fmt(modal)}$unitLabel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          // District
          if (district.isNotEmpty) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  district,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          // Price chips + date
          Row(
            children: [
              _PriceChip(
                label: 'Min',
                display: '₹${fmt(min)}',
                bg: Colors.orange.shade50,
                fg: Colors.orange.shade800,
              ),
              const SizedBox(width: 8),
              _PriceChip(
                label: 'Modal',
                display: '₹${fmt(modal)}',
                bg: AppColors.primary.withOpacity(0.1),
                fg: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _PriceChip(
                label: 'Max',
                display: '₹${fmt(max)}',
                bg: Colors.green.shade50,
                fg: Colors.green.shade800,
              ),
              const Spacer(),
              if (date.isNotEmpty)
                Text(
                  date,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Price chip
// ══════════════════════════════════════════════════════════════════════════════
class _PriceChip extends StatelessWidget {
  final String label;
  final String display;
  final Color bg;
  final Color fg;

  const _PriceChip({
    required this.label,
    required this.display,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: fg.withOpacity(0.7)),
          ),
          const SizedBox(height: 2),
          Text(
            display,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
