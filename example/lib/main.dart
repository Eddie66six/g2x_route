import 'package:flutter/material.dart';
import 'package:g2x_route/g2x_route.dart';

void main() {
  runApp(MyApp());
}

var globalNavigatorKey = GlobalKey<NavigatorState>();
class MyApp extends StatelessWidget {
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
          var id = routeParam['id'];
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
        showArgumentsToRoute: true,
        build: (_, arguments, ___) {
          var args = arguments as Map<String, String>;
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

  @override
  Widget build(BuildContext context) {
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
  }
}

class Splash extends StatelessWidget {
  const Splash({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Splash"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: (){
                  Navigator.pushNamedAndRemoveUntil(context, "/page1/12", (route) => false);
                },
                child: Text("Go to page1")
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  const Page1({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Page1"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, "/page2", arguments: {"id": "15"});
                },
                child: Text("Go to page2")
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, "/page1/12/details");
                },
                child: Text("Go to details")
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, "/menu/home");
                },
                child: Text("Go to menu")
              ),
            )
          ],
        ),
      ),
    );
  }
}
class Page1Details extends StatelessWidget {
  const Page1Details({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          "Page1 details"
        ),
      ),
    );
  }
}
class Page2 extends StatelessWidget {
  const Page2({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text("Page2"),
      ),
    );
  }
}

class MenuPage extends StatefulWidget {
  final String route;
  const MenuPage({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  var menuNavigatorKey = GlobalKey<NavigatorState>();
  var currentIndex = 0;

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

  @override
  void initState() {
    currentIndex = rotas.routes.indexWhere((element) => element.name == '/menu${widget.route}');
    if(currentIndex == -1) currentIndex = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
  }
}