import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/weather/logic/weather_provider.dart';
import 'package:flutter_application_1/features/weather/models/weather_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class WeatherScreen extends StatelessWidget {
  final CurrentModel? currentModel;
  const WeatherScreen({super.key, this.currentModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeatherProvider()..checkLocationPer(),
      child: Scaffold(
        body: Consumer<WeatherProvider>(
          builder: (context, weatherProvider, child) {
            final providerCurr = weatherProvider.currentModel;
            final providerLoc = weatherProvider.locations;
            final providerCond = weatherProvider.condition;
            final providerForecast = weatherProvider.forecastDays;

            if (providerCond == null ||
                providerCurr == null ||
                weatherProvider.currentLocation == '' ||
                providerLoc == null ||
                providerForecast.isEmpty) {
              return const _WeatherLoading();
            }

            final localTimeDate = DateTime.parse(providerLoc.localTime);
            final formattedDate = DateFormat(
              'EEEE, MMM d',
            ).format(localTimeDate);
            final updatedAt = DateFormat(
              'h:mm a',
            ).format(DateTime.parse(providerCurr.lastUpdated));
            final today = providerForecast.first;
            final animationPath =
                weatherProvider.weatherAnimation[providerCond.text] ??
                'assets/lottie/travel.json';

            return _WeatherBackground(
              condition: providerCond.text,
              child: SafeArea(
                child: RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: const Color(0xff247CFF),
                  onRefresh: () async {
                    weatherProvider.searchForCity(
                      weatherProvider.searchController.text.trim().isEmpty
                          ? weatherProvider.currentLocation
                          : weatherProvider.searchController.text.trim(),
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      _SearchHeader(weatherProvider: weatherProvider),
                      const SizedBox(height: 22),
                      _CurrentWeatherHero(
                        location: '${providerLoc.name}, ${providerLoc.country}',
                        date: formattedDate,
                        condition: providerCond.text,
                        temp: providerCurr.tempC,
                        high: today.day.maxTempC,
                        low: today.day.minTempC,
                        animationPath: animationPath,
                        updatedAt: updatedAt,
                        onOpenMap: () {
                          weatherProvider.openLocation(
                            'https://www.google.com/maps/search/?api=1&query=${providerLoc.lat},${providerLoc.lon}',
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      _WeatherMetricGrid(current: providerCurr, day: today.day),
                      const SizedBox(height: 14),
                      _SunCard(astro: today.astro),
                      const SizedBox(height: 14),
                      _HourlyForecast(
                        hours: today.hourDays,
                        weatherProvider: weatherProvider,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WeatherLoading extends StatelessWidget {
  const _WeatherLoading();

  @override
  Widget build(BuildContext context) {
    return const _WeatherBackground(
      condition: 'loading',
      child: Center(
        child: SizedBox(
          width: 52,
          height: 52,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            backgroundColor: Color(0x33FFFFFF),
          ),
        ),
      ),
    );
  }
}

class _WeatherBackground extends StatelessWidget {
  final String condition;
  final Widget child;

  const _WeatherBackground({required this.condition, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = _gradientForCondition(condition);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: child,
    );
  }

  List<Color> _gradientForCondition(String value) {
    final condition = value.toLowerCase();
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return const [Color(0xff4C669F), Color(0xff3B5B88), Color(0xffE7F2FF)];
    }
    if (condition.contains('cloud') || condition.contains('overcast')) {
      return const [Color(0xff607D8B), Color(0xff90A4AE), Color(0xffF7FAFC)];
    }
    if (condition.contains('clear')) {
      return const [Color(0xff182848), Color(0xff4B6CB7), Color(0xffDDEBFF)];
    }
    return const [Color(0xff247CFF), Color(0xff00B8A9), Color(0xffF7FBFF)];
  }
}

class _SearchHeader extends StatelessWidget {
  final WeatherProvider weatherProvider;

  const _SearchHeader({required this.weatherProvider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: weatherProvider.searchController,
            textInputAction: TextInputAction.search,
            onFieldSubmitted: weatherProvider.searchForCity,
            style: const TextStyle(
              color: Color(0xff172033),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Search city',
              hintStyle: TextStyle(
                color: const Color(0xff172033).withValues(alpha: .45),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xff247CFF)),
              suffixIcon: IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: () {
                  weatherProvider.searchForCity(
                    weatherProvider.searchController.text,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _HeaderIconButton(
          icon: Icons.my_location_rounded,
          tooltip: 'Current location',
          onPressed: () async {
            await weatherProvider.checkLocationPer();
            await weatherProvider.getCurrentLoc();
            weatherProvider.searchForCity(weatherProvider.currentLocation);
          },
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .92),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, color: const Color(0xff247CFF)),
        ),
      ),
    );
  }
}

class _CurrentWeatherHero extends StatelessWidget {
  final String location;
  final String date;
  final String condition;
  final double temp;
  final double high;
  final double low;
  final String animationPath;
  final String updatedAt;
  final VoidCallback onOpenMap;

  const _CurrentWeatherHero({
    required this.location,
    required this.date,
    required this.condition,
    required this.temp,
    required this.high,
    required this.low,
    required this.animationPath,
    required this.updatedAt,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: .42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .78),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _MapButton(onPressed: onOpenMap),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${temp.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 86,
                          fontWeight: FontWeight.w900,
                          height: .98,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      condition,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'H ${high.round()}°  L ${low.round()}°',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .78),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Lottie.asset(
                animationPath,
                height: 136,
                width: 136,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                color: Colors.white.withValues(alpha: .82),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Last updated $updatedAt',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .82),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _MapButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .22),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          tooltip: 'Open map',
          onPressed: onPressed,
          icon: const Icon(Icons.place_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class _WeatherMetricGrid extends StatelessWidget {
  final CurrentModel current;
  final DayModel day;

  const _WeatherMetricGrid({required this.current, required this.day});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        icon: Icons.water_drop_outlined,
        label: 'Humidity',
        value: '${current.humidity}%',
        accent: const Color(0xff247CFF),
      ),
      _MetricData(
        icon: Icons.air_rounded,
        label: 'Wind',
        value: '${current.windKPh.round()} km/h',
        accent: const Color(0xff00B8A9),
      ),
      _MetricData(
        icon: Icons.wb_sunny_outlined,
        label: 'UV index',
        value: current.uv.toStringAsFixed(1),
        accent: const Color(0xffFFB703),
      ),
      _MetricData(
        icon: Icons.cloud_outlined,
        label: 'Clouds',
        value: '${current.cloud}%',
        accent: const Color(0xff607D8B),
      ),
      _MetricData(
        icon: Icons.thermostat_rounded,
        label: 'Average',
        value: '${day.avgTempC.round()}°',
        accent: const Color(0xffF97316),
      ),
      _MetricData(
        icon: Icons.near_me_outlined,
        label: 'Direction',
        value: current.windDIR,
        accent: const Color(0xff7C3AED),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.65,
      ),
      itemBuilder: (context, index) => _MetricCard(data: metrics[index]),
    );
  }
}

class _MetricData {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _MetricData({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: data.accent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: data.accent, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.value,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xff172033),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
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

class _SunCard extends StatelessWidget {
  final AstroModel astro;

  const _SunCard({required this.astro});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff172033).withValues(alpha: .88),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 90,
            width: 90,
            child: Lottie.asset(
              'assets/lottie/sunrise_sunset_animation.json',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sun activity',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .7),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _SunRow(
                  icon: Icons.wb_twilight_rounded,
                  label: 'Sunrise',
                  value: astro.sunrise,
                ),
                const SizedBox(height: 8),
                _SunRow(
                  icon: Icons.nightlight_round,
                  label: 'Sunset',
                  value: astro.sunset,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SunRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SunRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xffFFB703), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .82),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HourlyForecast extends StatelessWidget {
  final List<HourDay> hours;
  final WeatherProvider weatherProvider;

  const _HourlyForecast({required this.hours, required this.weatherProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline_rounded, color: Color(0xff247CFF), size: 22),
              SizedBox(width: 8),
              Text(
                'Hourly forecast',
                style: TextStyle(
                  color: Color(0xff172033),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: AnimationLimiter(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: hours.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final hour = hours[index];
                  final animationPath =
                      weatherProvider.weatherAnimation[hour
                          .conditionHour
                          .text] ??
                      'assets/lottie/travel.json';
                  final formattedTime = DateFormat(
                    'h:mm a',
                  ).format(DateTime.parse(hour.time));

                  return AnimationConfiguration.staggeredList(
                    duration: const Duration(milliseconds: 450),
                    position: index,
                    child: SlideAnimation(
                      horizontalOffset: 44,
                      duration: const Duration(milliseconds: 450),
                      child: FadeInAnimation(
                        duration: const Duration(milliseconds: 450),
                        child: _HourCard(
                          time: formattedTime,
                          temp: hour.tempC,
                          condition: hour.conditionHour.text,
                          animationPath: animationPath,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourCard extends StatelessWidget {
  final String time;
  final double temp;
  final String condition;
  final String animationPath;

  const _HourCard({
    required this.time,
    required this.temp,
    required this.condition,
    required this.animationPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 94,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffF4F8FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffE3ECFF)),
      ),
      child: Column(
        children: [
          Text(
            time,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xff6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Lottie.asset(
            animationPath,
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          Text(
            '${temp.round()}°',
            style: const TextStyle(
              color: Color(0xff172033),
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            condition,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
