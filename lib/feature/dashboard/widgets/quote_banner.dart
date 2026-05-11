import 'package:artistplanner/core/blocs/lang/language_bloc.dart';
import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/core/models/models.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/dashboard/bloc/quote_cubit.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Inspirational quote banner.
///
/// Performance note: a previous version put `LiquidGlass.grouped` inside the
/// per-page builder, which forced the glass renderer to re-register a shape
/// for every visible page on every frame of a swipe — heavy enough to make
/// gestures feel stuck. This version renders ONE glass card and uses a
/// `CarouselSlider` to rotate only the text/author content inside it. That
/// keeps the liquid-glass shader cost flat regardless of carousel length.
class QuoteBanner extends StatelessWidget {
  const QuoteBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuoteCubit, QuoteState>(
      builder: (context, state) {
        return LiquidGlass.grouped(
          shape: const LiquidRoundedSuperellipse(borderRadius: 28),
          child: SizedBox(
            height: 170,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Raduis.xl),
              child: CarouselSlider.builder(
                itemCount: state.quotes.length,
                options: CarouselOptions(
                  height: 170,
                  viewportFraction: 1,
                  enlargeCenterPage: false,
                  disableCenter: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 6),
                  autoPlayAnimationDuration: const Duration(milliseconds: 700),
                  autoPlayCurve: Curves.easeInOutCubic,
                  pauseAutoPlayOnTouch: true,
                  pauseAutoPlayOnManualNavigate: true,
                  onPageChanged: (i, _) => context.read<QuoteCubit>().jumpTo(i),
                ),
                itemBuilder: (context, index, realIndex) {
                  return _QuoteSlide(quote: state.quotes[index]);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuoteSlide extends StatelessWidget {
  const _QuoteSlide({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final isKhmer = context.watch<LanguageBloc>().state.selectLanguage == const Locale('km');

    return Padding(
      padding: const EdgeInsets.all(Spacing.normal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            size: 32,
            color: Colors.white70,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            isKhmer ? quote.khmerText : quote.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.35,
            ),
          ),
          const Spacer(),
          Text(
            '— ${isKhmer ? quote.khmerAuthor : quote.author}',
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
