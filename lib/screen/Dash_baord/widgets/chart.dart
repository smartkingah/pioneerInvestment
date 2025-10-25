import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class LiveBTCChart extends StatefulWidget {
  const LiveBTCChart({super.key});

  @override
  State<LiveBTCChart> createState() => _LiveBTCChartState();
}

class _LiveBTCChartState extends State<LiveBTCChart> {
  List<CandleData> _chartData = [];
  bool _loading = true;
  double? _lastPrice;
  double? _priceChangePercent;
  double? _high24h;
  double? _low24h;
  double? _volume24h;
  String _selectedTimeframe = '1D';

  // Timeframe configurations
  final Map<String, Map<String, dynamic>> _timeframeConfig = {
    '1D': {'interval': '15m', 'limit': 96},
    '1W': {'interval': '1h', 'limit': 168},
    '1M': {'interval': '4h', 'limit': 180},
    '1Y': {'interval': '1d', 'limit': 365},
  };

  @override
  void initState() {
    super.initState();
    fetchBTCData();
  }

  Future<void> fetchBTCData() async {
    setState(() => _loading = true);

    try {
      final config = _timeframeConfig[_selectedTimeframe]!;

      // Fetch candlestick data
      final url = Uri.parse(
        'https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=${config['interval']}&limit=${config['limit']}',
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final candles = data.map((e) {
          return CandleData(
            time: DateTime.fromMillisecondsSinceEpoch(e[0]),
            open: double.parse(e[1]),
            high: double.parse(e[2]),
            low: double.parse(e[3]),
            close: double.parse(e[4]),
            volume: double.parse(e[5]),
          );
        }).toList();

        // Fetch 24hr ticker data
        final priceRes = await http.get(
          Uri.parse(
            'https://api.binance.com/api/v3/ticker/24hr?symbol=BTCUSDT',
          ),
        );

        if (priceRes.statusCode == 200) {
          final priceData = jsonDecode(priceRes.body);
          _lastPrice = double.tryParse(priceData['lastPrice']);
          _priceChangePercent = double.tryParse(
            priceData['priceChangePercent'],
          );
          _high24h = double.tryParse(priceData['highPrice']);
          _low24h = double.tryParse(priceData['lowPrice']);
          _volume24h = double.tryParse(priceData['volume']);
        }

        setState(() {
          _chartData = candles;
          _loading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching BTC data: $e');
      setState(() => _loading = false);
    }
  }

  void _changeTimeframe(String timeframe) {
    if (_selectedTimeframe != timeframe) {
      setState(() => _selectedTimeframe = timeframe);
      fetchBTCData();
    }
  }

  String _formatXAxis(DateTime time) {
    switch (_selectedTimeframe) {
      case '1D':
        return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
      case '1W':
        return "${time.day}/${time.month}";
      case '1M':
        return "${time.day}/${time.month}";
      case '1Y':
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return months[time.month - 1];
      default:
        return "${time.hour}:00";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPositive = (_priceChangePercent ?? 0) >= 0;
    final Color trendColor = isPositive
        ? const Color(0xFF0ECB81)
        : const Color(0xFFFF4D4D);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7931A).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.currency_bitcoin,
                            color: Color(0xFFF7931A),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "BTC/USD",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "BINANCE",
                            style: GoogleFonts.inter(
                              color: Colors.white54,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_loading)
                      const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0ECB81),
                        ),
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "\$${_lastPrice?.toStringAsFixed(2) ?? '--'}",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: trendColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isPositive
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: trendColor,
                                  size: 16,
                                ),
                                Text(
                                  "${_priceChangePercent != null ? _priceChangePercent!.abs().toStringAsFixed(2) : '--'}%",
                                  style: GoogleFonts.inter(
                                    color: trendColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Timeframe Buttons
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildTimeframeButton("1D"),
                    _buildTimeframeButton("1W"),
                    _buildTimeframeButton("1M"),
                    _buildTimeframeButton("1Y"),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // STATS ROW
          if (!_loading)
            Row(
              children: [
                _buildStatItem(
                  "24h High",
                  "\$${_high24h?.toStringAsFixed(2) ?? '--'}",
                  Colors.white70,
                ),
                const SizedBox(width: 20),
                _buildStatItem(
                  "24h Low",
                  "\$${_low24h?.toStringAsFixed(2) ?? '--'}",
                  Colors.white70,
                ),
                const SizedBox(width: 20),
                _buildStatItem(
                  "24h Volume",
                  "${(_volume24h ?? 0) > 1000 ? '${(_volume24h! / 1000).toStringAsFixed(1)}K' : _volume24h?.toStringAsFixed(0) ?? '--'} BTC",
                  Colors.white70,
                ),
              ],
            ),

          const SizedBox(height: 20),

          // CHART SECTION
          _loading
              ? const SizedBox(
                  height: 320,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF0ECB81),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Loading market data...",
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 320,
                  child: SfCartesianChart(
                    backgroundColor: Colors.transparent,
                    plotAreaBorderWidth: 0,
                    margin: const EdgeInsets.all(0),
                    primaryXAxis: CategoryAxis(
                      labelStyle: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLine: const AxisLine(width: 0),
                      labelRotation: 0,
                      labelIntersectAction: AxisLabelIntersectAction.hide,
                      interval: _selectedTimeframe == '1D' ? 12 : null,
                    ),
                    primaryYAxis: NumericAxis(
                      labelStyle: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                      majorGridLines: MajorGridLines(
                        width: 0.5,
                        color: Colors.white.withOpacity(0.05),
                        dashArray: [5, 5],
                      ),
                      axisLine: const AxisLine(width: 0),
                      numberFormat: NumberFormat.compact(),
                    ),
                    series: <CartesianSeries>[
                      // Candlestick series for better trading view
                      CandleSeries<CandleData, String>(
                        dataSource: _chartData,
                        xValueMapper: (CandleData data, _) =>
                            _formatXAxis(data.time),
                        lowValueMapper: (CandleData data, _) => data.low,
                        highValueMapper: (CandleData data, _) => data.high,
                        openValueMapper: (CandleData data, _) => data.open,
                        closeValueMapper: (CandleData data, _) => data.close,
                        bearColor: const Color(0xFFFF4D4D),
                        bullColor: const Color(0xFF0ECB81),
                        enableSolidCandles: true,
                        spacing: 0.2,
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      color: const Color(0xFF2C2C2E),
                      textStyle: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                      borderColor: Colors.white12,
                      borderWidth: 1,
                      duration: 3000,
                      animationDuration: 500,
                    ),
                    trackballBehavior: TrackballBehavior(
                      enable: true,
                      activationMode: ActivationMode.singleTap,
                      lineColor: Colors.white24,
                      lineWidth: 1,
                      lineDashArray: [5, 5],
                      tooltipSettings: InteractiveTooltip(
                        enable: true,
                        color: const Color(0xFF2C2C2E),
                        textStyle: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                        borderColor: Colors.white12,
                        borderWidth: 1,
                      ),
                    ),
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePinching: true,
                      enablePanning: true,
                      zoomMode: ZoomMode.x,
                    ),
                  ),
                ),

          const SizedBox(height: 16),

          // FOOTER ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, color: const Color(0xFF0ECB81), size: 8),
                  const SizedBox(width: 6),
                  Text(
                    "Live",
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.update, color: Colors.white38, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    "Updated ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: fetchBTCData,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "Refresh",
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeButton(String text) {
    final bool isSelected = _selectedTimeframe == text;

    return GestureDetector(
      onTap: () => _changeTimeframe(text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0ECB81) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.black : Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class CandleData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  CandleData({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
}

// Import for number formatting
