# g2x_route

Create named routes and subroutes.

## Getting Started

#### build parameters
    __routeParam__: page1/:id
    **arguments**: Navigator.pushNamed(context, "/page2", arguments: {"id": "15"});
    **arguments with showArgumentsToRoute = true**: Navigator.pushNamed(context, "/page2",      **arguments**: {"id": "15"}); => url: page2?id=15
    **complementRoute**: Navigator.pushNamed(context, "/menu/home"),
        G2xNestedRoute(
        '/menu',
        build: (_, __, complementRoute) {
          if(complementRoute == null) return Center(child: Text("not found"));
          return MenuPage(route: complementRoute);
        },
      )
      complementRoute is /home
    build: (routeParam, arguments, complementRoute) => Splash(),

#### create routes
    var routes = G2xRoute(
      notFound: G2xNestedRouteNotFound(
        "/not-found",
        build: ()=> Center(child: Text("not found"))
      ),
      initialRoute: "/",
      routes: <G2xNestedRoute>[
      G2xNestedRoute(
        '/',
        build: (_, __, ___) => Splash(),
      ),
      G2xNestedRoute(
        '/page1/:id',
        build: (routeParam, __, ___){
          var id = queryParam['id'];
          print(id);
          return Page1();
        },
        subroute: [
          G2xNestedRoute(
            '/details',
            build: (_, __, ___) => Page1Details(),
          ),
        ]
      ),
      G2xNestedRoute(
        '/page2',
        build: (_, arguments, ___) {
          var args = arguments as Map<String, dynamic>;
          print(args['id']);
          return Page2();
        },
      ),
      G2xNestedRoute(
        '/menu',
        build: (_, __, complementRoute) {
          if(complementRoute == null) return Center(child: Text("not found"));
          return MenuPage(route: complementRoute);
        },
      )
    ]);

#### configure
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: globalNavigatorKey,
      title: 'Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateInitialRoutes: routes.onGenerateInitialRoutes,
      onGenerateRoute: routes.onGenerateRoute,
    );

#### bottomNavigationBar
    var rotas = G2xRoute(
        notFound: G2xNestedRouteNotFound(
        "/menu/not-found",
        build: ()=> Center(child: Text("Pagina não encontrada menu"))
        ),
        initialRoute: '/menu/home',
        routes: <G2xNestedRoute>[
        G2xNestedRoute(
            '/menu/home',
            build: (_, __, ___) => Center(child: Text("Home")),
        ),
        G2xNestedRoute(
            '/menu/profile',
            build: (_, __, ___) => Center(child: Text("Profile")),
        ),
        ]
    );

    return Scaffold(
      appBar: AppBar(),
      body: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: menuNavigatorKey,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/menu${widget.route}',
        onGenerateRoute: rotas.onGenerateRoute,
        onGenerateInitialRoutes: rotas.onGenerateInitialRoutes,
      ),
    bottomNavigationBar: BottomNavigationBar(
        onTap: (int index){
          if(index == 0)
            Navigator.pushNamed(menuNavigatorKey.currentState!.context, "/menu/home");
          if(index == 1)
            Navigator.pushNamed(menuNavigatorKey.currentState!.context, "/menu/profile");
          if(index == 2)
            Navigator.pushNamed(menuNavigatorKey.currentState!.context, "/menu/contratos");
          setState(() {
            currentIndex = index;
          });
        },
				currentIndex: currentIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Home"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket),
              label: "Profile"
          ),
        ],
      ),
    );
