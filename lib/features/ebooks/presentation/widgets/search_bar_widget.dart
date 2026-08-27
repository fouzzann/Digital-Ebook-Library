import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import 'glass_container.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String initialValue;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.onClear,
    this.initialValue = '',
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;
  bool _isFocused = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    setState(() {});
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderColor: _isFocused ? AppColors.primary : AppColors.borderBright.withValues(alpha: 0.2),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        child: Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: TextField(
            controller: _controller,
            onChanged: _onQueryChanged,
            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
            decoration: InputDecoration(
              hintText: AppStrings.searchPlaceholder,
              hintStyle: TextStyle(color: AppColors.getTextMuted(context), fontSize: 13),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _isFocused ? AppColors.primary : AppColors.getTextSecondary(context),
                size: 22,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded, color: AppColors.getTextSecondary(context), size: 18),
                      onPressed: () {
                        _debounceTimer?.cancel();
                        _controller.clear();
                        widget.onChanged('');
                        if (widget.onClear != null) widget.onClear!();
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}
