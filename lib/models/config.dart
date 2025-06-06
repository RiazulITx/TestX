// ignore_for_file: invalid_annotation_target

import 'package:collection/collection.dart';
import 'package:errorx/common/common.dart';
import 'package:errorx/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'models.dart';

part 'generated/config.freezed.dart';
part 'generated/config.g.dart';

const defaultBypassDomain = [
  "*errorx.net",
  "localhost",
  "*.local",
  "127.*",
  "192.168.*"
];

const defaultAppSettingProps = AppSettingProps();
const defaultVpnProps = VpnProps();
const defaultNetworkProps = NetworkProps();
const defaultProxiesStyle = ProxiesStyle();
const defaultWindowProps = WindowProps();
const defaultAccessControl = AccessControl();
final defaultThemeProps = ThemeProps().copyWith(
  primaryColor: null,
  themeMode: ThemeMode.system,
);

const List<DashboardWidget> defaultDashboardWidgets = [
  DashboardWidget.networkSpeed,
  DashboardWidget.systemProxyButton,
  DashboardWidget.tunButton,
  DashboardWidget.outboundMode,
  DashboardWidget.networkDetection,
  DashboardWidget.trafficUsage,
  DashboardWidget.intranetIp,
];

List<DashboardWidget> dashboardWidgetsSafeFormJson(
  List<dynamic>? dashboardWidgets,
) {
  try {
    return dashboardWidgets
            ?.map((e) => $enumDecode(_$DashboardWidgetEnumMap, e))
            .toList() ??
        defaultDashboardWidgets;
  } catch (_) {
    return defaultDashboardWidgets;
  }
}

@freezed
class AppSettingProps with _$AppSettingProps {
  const factory AppSettingProps({
    String? locale,
    @Default(defaultDashboardWidgets)
    @JsonKey(fromJson: dashboardWidgetsSafeFormJson)
    List<DashboardWidget> dashboardWidgets,
    @Default(false) bool onlyStatisticsProxy,
    @Default(false) bool autoLaunch,
    @Default(false) bool silentLaunch,
    @Default(false) bool autoRun,
    @Default(false) bool openLogs,
    @Default(true) bool closeConnections,
    @Default(defaultTestUrl) String testUrl,
    @Default(true) bool isAnimateToPage,
    @Default(true) bool autoCheckUpdate,
    @Default(false) bool showLabel,
    @Default(false) bool disclaimerAccepted,
    @Default(true) bool minimizeOnExit,
    @Default(false) bool hidden,
  }) = _AppSettingProps;

  factory AppSettingProps.fromJson(Map<String, Object?> json) =>
      _$AppSettingPropsFromJson(json);

  factory AppSettingProps.safeFromJson(Map<String, Object?>? json) {
    return json == null
        ? defaultAppSettingProps
        : AppSettingProps.fromJson(json);
  }
}

@freezed
class AccessControl with _$AccessControl {
  const factory AccessControl({
    @Default(false) bool enable,
    @Default(AccessControlMode.rejectSelected) AccessControlMode mode,
    @Default([]) List<String> acceptList,
    @Default([]) List<String> rejectList,
    @Default(AccessSortType.none) AccessSortType sort,
    @Default(true) bool isFilterSystemApp,
  }) = _AccessControl;

  factory AccessControl.fromJson(Map<String, Object?> json) =>
      _$AccessControlFromJson(json);
}

extension AccessControlExt on AccessControl {
  List<String> get currentList => switch (mode) {
        AccessControlMode.acceptSelected => acceptList,
        AccessControlMode.rejectSelected => rejectList,
      };
}

@freezed
class WindowProps with _$WindowProps {
  const factory WindowProps({
    @Default(750) double width,
    @Default(600) double height,
    double? top,
    double? left,
  }) = _WindowProps;

  factory WindowProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const WindowProps() : _$WindowPropsFromJson(json);
}

@freezed
class VpnProps with _$VpnProps {
  const factory VpnProps({
    @Default(true) bool enable,
    @Default(true) bool systemProxy,
    @Default(false) bool ipv6,
    @Default(true) bool allowBypass,
    @Default(defaultAccessControl) AccessControl accessControl,
  }) = _VpnProps;

  factory VpnProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const VpnProps() : _$VpnPropsFromJson(json);
}

@freezed
class NetworkProps with _$NetworkProps {
  const factory NetworkProps({
    @Default(true) bool systemProxy,
    @Default(defaultBypassDomain) List<String> bypassDomain,
    @Default(RouteMode.bypassPrivate) RouteMode routeMode,
  }) = _NetworkProps;

  factory NetworkProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const NetworkProps() : _$NetworkPropsFromJson(json);
}

@freezed
class ProxiesStyle with _$ProxiesStyle {
  const factory ProxiesStyle({
    @Default(ProxiesType.tab) ProxiesType type,
    @Default(ProxiesSortType.none) ProxiesSortType sortType,
    @Default(ProxiesLayout.standard) ProxiesLayout layout,
    @Default(ProxiesIconStyle.standard) ProxiesIconStyle iconStyle,
    @Default(ProxyCardType.expand) ProxyCardType cardType,
    @Default({}) Map<String, String> iconMap,
  }) = _ProxiesStyle;

  factory ProxiesStyle.fromJson(Map<String, Object?>? json) =>
      json == null ? defaultProxiesStyle : _$ProxiesStyleFromJson(json);
}

@freezed
class ThemeProps with _$ThemeProps {
  const factory ThemeProps({
    int? primaryColor,
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(false) bool pureBlack,
  }) = _ThemeProps;

  factory ThemeProps.fromJson(Map<String, Object?> json) =>
      _$ThemePropsFromJson(json);

  factory ThemeProps.safeFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultThemeProps;
    }
    try {
      return ThemeProps.fromJson(json);
    } catch (_) {
      return defaultThemeProps;
    }
  }
}

@freezed
class Config with _$Config {
  const factory Config({
    @JsonKey(fromJson: AppSettingProps.safeFromJson)
    @Default(defaultAppSettingProps)
    AppSettingProps appSetting,
    @Default([]) List<Profile> profiles,
    @Default([]) List<HotKeyAction> hotKeyActions,
    String? currentProfileId,
    @Default(false) bool overrideDns,
    DAV? dav,
    @Default(defaultNetworkProps) NetworkProps networkProps,
    @Default(defaultVpnProps) VpnProps vpnProps,
    @JsonKey(fromJson: ThemeProps.safeFromJson) required ThemeProps themeProps,
    @Default(defaultProxiesStyle) ProxiesStyle proxiesStyle,
    @Default(defaultWindowProps) WindowProps windowProps,
    @Default(defaultClashConfig) ClashConfig patchClashConfig,
  }) = _Config;

  factory Config.fromJson(Map<String, Object?> json) => _$ConfigFromJson(json);

  factory Config.compatibleFromJson(Map<String, Object?> json) {
    try {
      final accessControlMap = json["accessControl"];
      final isAccessControl = json["isAccessControl"];
      if (accessControlMap != null) {
        (accessControlMap as Map)["enable"] = isAccessControl;
        if (json["vpnProps"] != null) {
          (json["vpnProps"] as Map)["accessControl"] = accessControlMap;
        }
      }
    } catch (_) {}
    return Config.fromJson(json);
  }
}

extension ConfigExt on Config {
  Profile? get currentProfile {
    return profiles.getProfile(currentProfileId);
  }
}
