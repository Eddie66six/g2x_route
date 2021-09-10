library g2x_route;

import 'package:flutter/material.dart';

class G2xRoute {
  final String initialRoute;
  final List<G2xNestedRoute> routes;
  final G2xNestedRouteNotFound? notFound;
  final RouteTransitionsBuilder? transitionsBuilder;
  G2xRoute({
    required this.routes, required this.initialRoute, this.notFound,
    this.transitionsBuilder
  }) {
    for (var r in routes) {
      r._updateFullName();
    }
  }

  Map<String, dynamic> _findRoute(RouteSettings settings, {List<G2xNestedRoute>? newRoutes, String? complementRoute}){
    var route = Uri.parse(settings.name!);
    var arrayUrl = route.path.split("/");
    for (var r in newRoutes ?? routes) {
      var arrayName = (r._fullName ?? r.name).split("/");
      if(arrayUrl[1] != arrayName[1]) continue;
      if(arrayName.length < arrayUrl.length && r.subroute != null){
        return _findRoute(settings, newRoutes: r.subroute);
      }
      //match (param ref)
      var _routeParams = Map<String, dynamic>();
      if(arrayName.length == arrayUrl.length && _compareSplitRoute(arrayName, arrayUrl, _routeParams)){
        var name = settings.name!;
        if(r.showArgumentsToRoute && settings.arguments != null
          && settings.arguments is Map<String, String>){
            name = Uri(path: name, queryParameters: settings.arguments as Map<String, String>).toString();
        }
        return {
          "notFound": false,
          "route": RouteSettings(name: name),
          "widget": r.build(_routeParams, settings.arguments ?? route.queryParameters, complementRoute),
        };
      }
    }
    var _notFound = notFound ?? G2xNestedRouteNotFound(
      routes[0].name,
      build: () => routes[0].build(Map<String, dynamic>() , null, null)
    );
    return {
      "notFound": true,
      "route": RouteSettings(name: _notFound.name),
      "widget": _notFound.build(),
    };
  }

  bool _compareSplitRoute(List<String> parameter, List<String> lst2, Map<String, dynamic> routeParams){
    var isValid = true;
    for (var i = 0; i < parameter.length; i++) {
      if(parameter[i].contains(":")){
        routeParams[parameter[i].replaceAll(":", "")] = lst2[i];
        continue;
      }
      if(parameter[i] != lst2[i]){
        isValid = false;
        break;
      }
    }
    return isValid;
  }

  Route onGenerateRoute(RouteSettings settings) {
    var result = _findRoute(settings);
    if(result['notFound'] && settings.name!.contains("/")){
      //look for a closer route
      var route = settings.name!.substring(0, settings.name!.lastIndexOf("/"));
      if(route.length > 0){
        result = _findRoute(RouteSettings(name: route), complementRoute: settings.name!.replaceAll(route, ""));
      }
    }
    return PageRouteBuilder(
      settings: result['route'],
      pageBuilder: (_, __, ___) => result['widget'],
      transitionsBuilder: transitionsBuilder ?? _defaultTransitionsBuilder
    );
  }

  Widget _defaultTransitionsBuilder(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  List<Route<dynamic>> onGenerateInitialRoutes(String initialRouteName) {
    final List<Route<dynamic>?> result = <Route<dynamic>?>[];
    if(initialRouteName.contains("/") && initialRouteName.length > 1){
      var initial = onGenerateRoute(RouteSettings(name: initialRoute));
      result.add(initial);  
    }
    var other = onGenerateRoute(RouteSettings(name: initialRouteName));
    result.add(other);
    return result.cast<Route<dynamic>>();
  }
}

class G2xNestedRouteNotFound{
  final String name;
  final Widget Function() build;
  G2xNestedRouteNotFound(
    this.name,
    {required this.build}
  );
}

class G2xNestedRoute{
  final String name;
  final Widget Function(Map<String, dynamic> routeParams, Object? arguments, String? complementRoute) build;
  final List<G2xNestedRoute>? subroute;
  ///the arguments(push) must be Map<String,String>
  ///if true can't have subroute
  final bool showArgumentsToRoute;
  final bool isModule;
  G2xNestedRoute(
    this.name, 
    {required  this.build, this.subroute, 
    this.showArgumentsToRoute = false, this.isModule = false}
  ): assert(
    !showArgumentsToRoute || (showArgumentsToRoute && (subroute?.length ?? 0) == 0),
    "showArgumentsToRoute is true and can't have subroute");

  String? _fullName;
  void _updateFullName(){
    if(subroute == null) return;
    for (var r in subroute!){  
      r._fullName = "${_fullName ?? name}/${r.name.replaceFirst("/", "")}";
      if(r.subroute != null){
        r._updateFullName();
      }
    } 
  }
}