import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// --- Global Product Data ---
const List<Map<String, dynamic>> products = [
  {'id': 'nike-tanjun-m','name': 'Nike Tanjun Mens','price': 120,'image': "assets/1NikeShoe-man.png",'details': 'Classic comfort enhanced...','bgColor': Color(0xFFFDECEC)},
  {'id': 'nike-tennis-court-m','name': 'Nike Tennis Men','price': 160,'image': "assets/2NikeShoe-Mens.png",'details': 'Blue Nike Court Lite...','bgColor': Color(0xFFE3F2FD)},
  {'id': 'nike-run-swift-m','name': 'Nike Running Mens','price': 85,'image': 'assets/3Nike-Shoe.png','details': 'Breathable mesh upper...','bgColor': Color(0xFFF5F5F5)}, // Example product shown in Image 3
  {'id': 'nike-vapor-lite3-m','name': 'Nike Vapor Lite 3 Mens','price': 140,'image': 'assets/4-Nikeshoe-mens (2).png','details': 'Thunder Blue Vapor Lite...','bgColor': Color(0xFFBBDEFB)},
  {'id': 'nike-air-max-1-m','name': 'Nike Air Max 1 Mens','price': 110,'image': 'assets/5NikeShoe-mens.png','details': 'Iconic style...','bgColor': Color(0xFFEEEEEE)},
  {'id': 'nike-court-vision-m','name': 'Men Tennis Shoes','price': 110,'image': 'assets/6Nikeshoe-Men.png','details': 'Green and white classic...','bgColor': Color(0xFFFFECB3)},
];
// --- End Global Product Data ---


// ***** STATE MANAGEMENT USING VALUENOTIFIER *****
// Wrap global lists in ValueNotifiers
final ValueNotifier<List<Map<String, dynamic>>> cartNotifier = ValueNotifier([]);
final ValueNotifier<List<String>> favoritesNotifier = ValueNotifier([]);
// ***** END STATE MANAGEMENT *****


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MobileShopApp());
}

// --- App Structure ---
class MobileShopApp extends StatelessWidget {
  const MobileShopApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nike Shoes Shop', debugShowCheckedModeBanner: false,
      theme: ThemeData( /* ... Theme data as before ... */
          primaryColor: const Color(0xFF0D47A1), scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData( style: ElevatedButton.styleFrom( backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14),),),
          inputDecorationTheme: InputDecorationTheme( filled: true, fillColor: Colors.white.withOpacity(0.1), hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)), labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)), enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white54),), focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white, width: 1.5),), border: OutlineInputBorder( borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white54),),),
          outlinedButtonTheme: OutlinedButtonThemeData( style: OutlinedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: BorderSide(color: Colors.grey[400]!), textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),)),
          textTheme: const TextTheme( headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 28), headlineSmall: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 24), titleLarge: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 20), titleMedium: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 16), titleSmall: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 14), bodyMedium: TextStyle(color: Colors.black54, fontSize: 14), bodySmall: TextStyle(color: Colors.black54, fontSize: 12),),
          colorScheme: ColorScheme.fromSwatch().copyWith( primary: const Color(0xFF0D47A1), secondary: Colors.blueAccent, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black87, background: Colors.white, onBackground: Colors.black87,),
          appBarTheme: const AppBarTheme( backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0.5, iconTheme: IconThemeData(color: Colors.black), titleTextStyle: TextStyle( color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold,),),
          bottomNavigationBarTheme: BottomNavigationBarThemeData( backgroundColor: Colors.white, selectedItemColor: const Color(0xFF0D47A1), unselectedItemColor: Colors.grey[600], showUnselectedLabels: true, type: BottomNavigationBarType.fixed, elevation: 5.0,)
      ), home: const AuthWrapper(), );
  }
}

// --- Auth Wrapper ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override Widget build(BuildContext context) {
    return StreamBuilder<User?>( stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) { if (snapshot.connectionState == ConnectionState.waiting) { return const Scaffold(body: Center(child: CircularProgressIndicator())); } if (snapshot.hasData) { print("AuthWrapper: User is logged in (${snapshot.data!.uid}). Navigating to HomePage."); return const HomePage(); } else { print("AuthWrapper: User is NOT logged in. Navigating to LoginPage."); return const LoginPage(); } }, );
  }
}

// --- Login Page ---
class LoginPage extends StatefulWidget { const LoginPage({super.key}); @override State<LoginPage> createState() => _LoginPageState(); }
class _LoginPageState extends State<LoginPage> { final emailController = TextEditingController(); final passwordController = TextEditingController(); bool _isLoading = false; @override void dispose() { emailController.dispose(); passwordController.dispose(); super.dispose(); } void login() async { FocusScope.of(context).unfocus(); if (_isLoading) return; setState(() => _isLoading = true); final scaffoldMessenger = ScaffoldMessenger.of(context); try { await FirebaseAuth.instance.signInWithEmailAndPassword( email: emailController.text.trim(), password: passwordController.text.trim()); } on FirebaseAuthException catch (e) { if (!mounted) return; String message = 'Login failed.'; if (e.code == 'user-not-found' || e.code == 'invalid-credential') message = 'Incorrect email or password.'; else if (e.code == 'invalid-email') message = 'Invalid email address.'; else if (e.code == 'too-many-requests') message = 'Too many login attempts.'; scaffoldMessenger.showSnackBar(SnackBar( content: Text(message), backgroundColor: Colors.red[700], behavior: SnackBarBehavior.floating)); } catch (e) { if (!mounted) return; scaffoldMessenger.showSnackBar(const SnackBar( content: Text('An unexpected error occurred.'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating)); } finally { if (mounted) { Future.delayed(const Duration(milliseconds: 100), () { if (mounted) { setState(() => _isLoading = false); } }); } } } @override Widget build(BuildContext context) { return Scaffold( body: Container( decoration: const BoxDecoration( gradient: LinearGradient( begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1976D2), Color(0xFF64B5F6)], ), ), child: SafeArea( child: Center( child: SingleChildScrollView( padding: const EdgeInsets.symmetric(horizontal: 24), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Container( decoration: const BoxDecoration( shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))],), child: CircleAvatar( backgroundColor: Colors.white, radius: 65, child: Padding( padding: const EdgeInsets.all(12), child: Image.asset('assets/1logo.png', errorBuilder: (c,e,s) => Icon(Icons.shopping_bag, size: 50, color: Theme.of(context).primaryColor))),),), const SizedBox(height: 30), const Text( 'NIKE SHOES SHOP', style: TextStyle( fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2,),), const SizedBox(height: 10), const Text( 'Sign in to continue', style: TextStyle(color: Color(0xCCFFFFFF))), const SizedBox(height: 40), Column( children: [ TextField( controller: emailController, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: Colors.white), decoration: const InputDecoration( labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: Colors.white)),), const SizedBox(height: 16), TextField( controller: passwordController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration( labelText: 'Password', prefixIcon: Icon(Icons.lock_outline, color: Colors.white)), obscureText: true,), const SizedBox(height: 30), SizedBox( width: double.infinity, child: ElevatedButton( onPressed: _isLoading ? null : login, style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.white, foregroundColor: const Color(0xFF0D47A1)), child: _isLoading ? const SizedBox( height: 20, width: 20, child: CircularProgressIndicator( color: Color(0xFF0D47A1), strokeWidth: 2)) : const Text('LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),),), ],), const SizedBox(height: 20), TextButton( onPressed: _isLoading ? null : () { Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())); }, child: const Text( 'Don\'t have an account? Sign Up', style: TextStyle(color: Color(0xE6FFFFFF), fontWeight: FontWeight.w500),),), ],),),),),),); }
}

// --- Sign Up Page ---
class SignUpPage extends StatefulWidget { const SignUpPage({super.key}); @override State<SignUpPage> createState() => _SignUpPageState(); }
class _SignUpPageState extends State<SignUpPage> { final emailController = TextEditingController(); final passwordController = TextEditingController(); bool _isLoading = false; @override void dispose() { emailController.dispose(); passwordController.dispose(); super.dispose(); } void signUp() async { FocusScope.of(context).unfocus(); if (_isLoading) return; setState(() => _isLoading = true); final scaffoldMessenger = ScaffoldMessenger.of(context); final navigator = Navigator.of(context); try { await FirebaseAuth.instance.createUserWithEmailAndPassword( email: emailController.text.trim(), password: passwordController.text.trim()); if (!mounted) return; scaffoldMessenger.showSnackBar(const SnackBar( content: Text('Account created successfully! Please sign in.'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating)); await FirebaseAuth.instance.signOut(); navigator.pop(); } on FirebaseAuthException catch (e) { if (!mounted) return; String message = 'Signup failed.'; if (e.code == 'weak-password') message = 'Password is too weak (min. 6 characters).'; else if (e.code == 'email-already-in-use') message = 'An account already exists for that email.'; else if (e.code == 'invalid-email') message = 'The email address is not valid.'; scaffoldMessenger.showSnackBar(SnackBar( content: Text(message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating)); setState(() => _isLoading = false); } catch (e) { if (!mounted) return; scaffoldMessenger.showSnackBar(const SnackBar( content: Text('An unexpected error occurred during sign up.'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating)); setState(() => _isLoading = false); } } @override Widget build(BuildContext context) { return Scaffold( extendBodyBehindAppBar: true, appBar: AppBar( title: const Text('Create Account'), backgroundColor: Colors.transparent, elevation: 0, leading: IconButton( icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context),),), body: Container( width: double.infinity, height: double.infinity, decoration: const BoxDecoration( gradient: LinearGradient( begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],),), child: SafeArea( child: Center( child: SingleChildScrollView( padding: const EdgeInsets.symmetric(horizontal: 24), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ CircleAvatar( backgroundColor: Colors.white, radius: 65, child: Padding( padding: const EdgeInsets.all(12), child: Image.asset('assets/11logo.png', errorBuilder: (c,e,s) => Icon(Icons.shopping_bag, size: 50, color: Theme.of(context).primaryColor))),), const SizedBox(height: 30), const Text( 'NIKE SHOES SHOP', style: TextStyle( fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2,),), const SizedBox(height: 40), Column( children: [ TextField( controller: emailController, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: Colors.white), decoration: const InputDecoration( labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: Colors.white)),), const SizedBox(height: 16), TextField( controller: passwordController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration( labelText: 'Password (min. 6 characters)', prefixIcon: Icon(Icons.lock_outline, color: Colors.white)), obscureText: true,), const SizedBox(height: 30), SizedBox( width: double.infinity, child: ElevatedButton( onPressed: _isLoading ? null : signUp, style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.white, foregroundColor: const Color(0xFF0D47A1)), child: _isLoading ? const SizedBox( height: 20, width: 20, child: CircularProgressIndicator( color: Color(0xFF0D47A1), strokeWidth: 2)) : const Text('SIGN UP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),),), ],), ],),),),),),); }
}


// --- HomePage (Main screen with Bottom Navigation) ---
class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  // *** REMOVED CartPageWrapper from here, use CartPage directly ***
  static final List<Widget> _widgetOptions = <Widget>[ const ProductGridPage(), const FavoritesPage(), const CartPage(), const ProfilePlaceholderPage(), ];

  void _onItemTapped(int index) { setState(() { _selectedIndex = index; print("HomePage: Tab tapped, selected index set to $_selectedIndex. Rebuilding."); }); }
  // void _updateCartBadge() { if (mounted) setState(() {}); } // Keep this for now for the badge
  void _navigateToCart() { int cartIndex = _widgetOptions.indexWhere((widget) => widget is CartPage); if (cartIndex != -1) { _onItemTapped(cartIndex); } else { Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())).then((_) => {}); } } // Update badge via listener now
  void _navigateToHistory() { Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryPage())); }
  void _navigateToFavorites() { int favIndex = _widgetOptions.indexWhere((widget) => widget is FavoritesPage); if (favIndex != -1) { _onItemTapped(favIndex); } else { ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("Favorites page not available"), duration: Duration(seconds: 1)),); } }
  void _search() { Navigator.push( context, MaterialPageRoute(builder: (context) => const SearchPage()), ); }
  Future<void> _logout() async { await FirebaseAuth.instance.signOut(); if (!mounted) return; // Clear notifiers on logout
  cartNotifier.value = []; favoritesNotifier.value = []; }

  @override
  Widget build(BuildContext context) { final theme = Theme.of(context); print("HomePage: Building with selected index $_selectedIndex"); return Scaffold( appBar: AppBar( title: Image.asset( 'assets/nike_logo_black.png', height: 25, errorBuilder: (c, e, s) => const Text( 'Nike', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),),), centerTitle: true, actions: [ IconButton( tooltip: 'Search', icon: const Icon(Icons.search), onPressed: _search, ),
    // **** Use ValueListenableBuilder for Cart Badge ****
    ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: cartNotifier,
        builder: (context, cartItems, child) {
          return IconButton( tooltip: 'Shopping Cart', icon: Stack( clipBehavior: Clip.none, children: [ const Icon(Icons.shopping_bag_outlined), if (cartItems.isNotEmpty) Positioned( right: -5, top: -5, child: Container( padding: const EdgeInsets.all(3), decoration: BoxDecoration( color: theme.primaryColor, shape: BoxShape.circle,), constraints: const BoxConstraints(minWidth: 16, minHeight: 16), child: Text( '${cartItems.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),),) ],), onPressed: _navigateToCart, );
        }
    ), const SizedBox(width: 8), ], ), drawer: Drawer( child: ListView( padding: EdgeInsets.zero, children: [ DrawerHeader( decoration: BoxDecoration(color: theme.primaryColor), child: Text( FirebaseAuth.instance.currentUser?.email ?? 'Nike Menu', style: const TextStyle(color: Colors.white, fontSize: 24), ), ), ListTile( leading: const Icon(Icons.home_outlined), title: const Text('Home'), onTap: () { Navigator.pop(context); _onItemTapped(0); }, ), ListTile( leading: const Icon(Icons.favorite_border), title: const Text('Favorites'), onTap: () { Navigator.pop(context); _navigateToFavorites(); }, ), ListTile( leading: const Icon(Icons.shopping_cart_outlined), title: const Text('Shopping Cart'), onTap: () { Navigator.pop(context); _navigateToCart(); }, ), ListTile( leading: const Icon(Icons.history), title: const Text('Purchase History'), onTap: () { Navigator.pop(context); _navigateToHistory(); }, ), const Divider(), ListTile( leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () { Navigator.pop(context); _logout(); }, ), ],),), body: IndexedStack( index: _selectedIndex, children: _widgetOptions,), bottomNavigationBar: BottomNavigationBar( items: const <BottomNavigationBarItem>[ BottomNavigationBarItem( icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home',), BottomNavigationBarItem( icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Favorites',), BottomNavigationBarItem( icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Cart',), BottomNavigationBarItem( icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile',), ], currentIndex: _selectedIndex, onTap: _onItemTapped, ),); }
}

// --- Product Grid Page ---
class ProductGridPage extends StatelessWidget { const ProductGridPage({super.key}); /* void _updateCartBadge(BuildContext context) { final homePageState = context.findAncestorStateOfType<_HomePageState>(); homePageState?._updateCartBadge(); } */ void _goToDetails(BuildContext context, Map<String, dynamic> product) { Navigator.push( context, MaterialPageRoute( builder: (_) => ProductDetailPage( productId: product['id'], productName: product['name'], price: product['price'], details: product['details'], imageUrl: product['image'], ), ), ); /* Badge update handled by listener */ } @override Widget build(BuildContext context) { print("ProductGridPage: Building"); final productsToShow = products; return GridView.builder( padding: const EdgeInsets.all(16), itemCount: productsToShow.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9,), itemBuilder: (context, index) { final product = productsToShow[index]; final Color itemBgColor = product['bgColor'] as Color? ?? Colors.grey[200]!; return InkWell( onTap: () => _goToDetails(context, product), child: Container( decoration: BoxDecoration( color: itemBgColor, borderRadius: BorderRadius.circular(15),), clipBehavior: Clip.antiAlias, child: Padding( padding: const EdgeInsets.all(12.0), child: Hero( tag: product['id'], child: Image.asset( product['image'], fit: BoxFit.contain, errorBuilder: (c, e, s) => const Center( child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),),),),),);},); } }

// --- Favorites Page ---
class FavoritesPage extends StatefulWidget { const FavoritesPage({super.key}); @override State<FavoritesPage> createState() => _FavoritesPageState(); }
class _FavoritesPageState extends State<FavoritesPage> {
  // No need for _updateCartBadge here unless favorites page adds to cart
  void _goToDetails(Map<String, dynamic> product) { Navigator.push( context, MaterialPageRoute( builder: (_) => ProductDetailPage( productId: product['id'], productName: product['name'], price: product['price'], details: product['details'], imageUrl: product['image'],),),); /* Rebuild handled by listener */ }

  // **** MODIFIED: Use ValueListenableBuilder ****
  @override Widget build(BuildContext context) {
    print("FavoritesPage: Building");
    final theme = Theme.of(context);
    return ValueListenableBuilder<List<String>>(
        valueListenable: favoritesNotifier,
        builder: (context, favoriteIds, child) {
          print("FavoritesPage ValueListenableBuilder: Building with IDs: $favoriteIds");
          final favoriteItems = products.where((p) => favoriteIds.contains(p['id'])).toList();
          return favoriteItems.isEmpty ? const Center( child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(Icons.favorite_border, size: 80, color: Colors.grey), SizedBox(height: 16), Text('No favorites yet!', style: TextStyle(fontSize: 18, color: Colors.grey)), SizedBox(height: 8), Text('Tap the heart on products you like.', style: TextStyle(color: Colors.grey)), ],),)
              : ListView.builder( padding: const EdgeInsets.all(8.0), itemCount: favoriteItems.length, itemBuilder: (context, index) { final item = favoriteItems[index]; final imageUrl = item['image'] ?? 'assets/logo1.jpg'; return Card( margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), child: ListTile( contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), leading: ClipRRect( borderRadius: BorderRadius.circular(8), child: Image.asset( imageUrl, width: 60, height: 60, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 30, color: Colors.grey)) ), ), title: Text(item['name'] ?? 'Unknown Product', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), subtitle: Text('\$${item['price']}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.w500)), trailing: IconButton( icon: const Icon(Icons.favorite, color: Colors.redAccent), tooltip: 'Remove from Favorites', onPressed: () {
            // **** Update notifier value ****
            final currentFavorites = List<String>.from(favoritesNotifier.value);
            currentFavorites.remove(item['id']);
            favoritesNotifier.value = currentFavorites;
            // **** End Update ****
            ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("Removed from favorites"), duration: Duration(milliseconds: 800), behavior: SnackBarBehavior.floating) ); }, ), onTap: () => _goToDetails(item), ),);},);
        }
    );
  }
}


// --- Cart Page Wrapper (REMOVED - No longer needed) ---


// --- Profile Placeholder Page ---
class ProfilePlaceholderPage extends StatelessWidget { const ProfilePlaceholderPage({super.key}); @override Widget build(BuildContext context) { final user = FirebaseAuth.instance.currentUser; print("ProfilePlaceholderPage: Building"); return Center( child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ const Icon(Icons.person, size: 80, color: Colors.grey), const SizedBox(height: 16), const Text('Profile Screen', style: TextStyle(fontSize: 18, color: Colors.grey)), const SizedBox(height: 8), if (user != null) Text('Logged in as:\n${user.email}', style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center,), const SizedBox(height: 20), ElevatedButton.icon( icon: const Icon(Icons.history), label: const Text('View Purchase History'), onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryPage())); }, ), const SizedBox(height: 10), ElevatedButton.icon( icon: const Icon(Icons.logout), label: const Text('Logout'), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () async { await FirebaseAuth.instance.signOut(); cartNotifier.value = []; favoritesNotifier.value = []; }, ), ],),); } }

// --- Product Detail Page ---
class ProductDetailPage extends StatefulWidget { final String productId, productName, details, imageUrl; final int price; const ProductDetailPage({ super.key, required this.productId, required this.productName, required this.price, required this.details, required this.imageUrl,}); @override State<ProductDetailPage> createState() => _ProductDetailPageState(); }
class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1; bool _isProcessing = false;
  // **** Local state still useful for immediate UI feedback ****
  late bool _isFavorite;
  @override void initState() { super.initState(); _isFavorite = favoritesNotifier.value.contains(widget.productId); }

  // **** MODIFIED: Update Notifier ****
  void _toggleFavorite() {
    final currentFavorites = List<String>.from(favoritesNotifier.value); // Create mutable copy
    setState(() { // Update local state for immediate icon change
      _isFavorite = !_isFavorite;
      if (_isFavorite) {
        if (!currentFavorites.contains(widget.productId)) {
          currentFavorites.add(widget.productId);
          favoritesNotifier.value = currentFavorites; // Update notifier
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar( content: Text('Added to favorites!'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating,));
        }
      } else {
        if (currentFavorites.remove(widget.productId)) {
          favoritesNotifier.value = currentFavorites; // Update notifier
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar( content: Text('Removed from favorites.'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating,));
        }
      }
      print("ProductDetailPage: Toggled favorite. Notifier value: ${favoritesNotifier.value}");
    });
  }

  // **** MODIFIED: Update Notifier ****
  void _addToCart() { if (_isProcessing) return; setState(() => _isProcessing = true);
  final currentCart = List<Map<String, dynamic>>.from(cartNotifier.value); // Create mutable copy
  int existingIndex = currentCart.indexWhere((item) => item['productId'] == widget.productId); String message;
  if (existingIndex != -1) {
    // Update quantity in the item map directly (maps are reference types)
    currentCart[existingIndex]['quantity'] = currentCart[existingIndex]['quantity'] + quantity;
    message = '${widget.productName} quantity updated in cart!';
  } else {
    final cartItem = { 'productId': widget.productId, 'productName': widget.productName, 'pricePerItem': widget.price, 'quantity': quantity, 'imageUrl': widget.imageUrl };
    currentCart.add(cartItem); // Add to the copied list
    message = '${widget.productName} (Qty: $quantity) added to cart!';
  }
  cartNotifier.value = currentCart; // Assign the modified list back to the notifier
  print("ProductDetailPage: Added to cart. Notifier value: ${cartNotifier.value}");
  if (mounted) { ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(message), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating, action: SnackBarAction( label: "VIEW CART", onPressed: () { ScaffoldMessenger.of(context).hideCurrentSnackBar(); Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())); } ),) ); }
  Future.delayed(const Duration(milliseconds: 400), () { if (mounted) setState(() => _isProcessing = false); });
  }
  @override Widget build(BuildContext context) { final theme = Theme.of(context); final screenSize = MediaQuery.of(context).size; return Scaffold( backgroundColor: Colors.grey[100], extendBodyBehindAppBar: true, appBar: AppBar( backgroundColor: Colors.transparent, elevation: 0, leading: Padding( padding: const EdgeInsets.all(8.0), child: CircleAvatar( backgroundColor: Colors.black.withOpacity(0.35), child: IconButton( icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18), onPressed: () => Navigator.pop(context), tooltip: 'Back', splashRadius: 20,),),), actions: [ Padding( padding: const EdgeInsets.all(8.0), child: CircleAvatar( backgroundColor: Colors.black.withOpacity(0.35), child: IconButton( icon: Icon( _isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.redAccent : Colors.white, size: 20,), onPressed: _toggleFavorite, tooltip: 'Favorite', splashRadius: 20,),),),],), body: Stack( children: [ Positioned( top: 0, left: 0, right: 0, height: screenSize.height * 0.65, child: Hero( tag: widget.productId, child: Image.asset( widget.imageUrl, fit: BoxFit.contain, errorBuilder: (ctx, err, st) => const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey)), ),),), Positioned( bottom: 0, left: 0, right: 0, child: Container( padding: const EdgeInsets.fromLTRB(24, 24, 24, 30), decoration: BoxDecoration( color: Colors.grey[900], borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 15, spreadRadius: 5) ] ), child: SingleChildScrollView( child: Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [ Text( "Nike", style: theme.textTheme.headlineMedium?.copyWith( color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 20 ), ), Text( widget.productName, style: theme.textTheme.headlineSmall?.copyWith( color: Colors.white, fontWeight: FontWeight.bold, height: 1.2, fontSize: 26 ), ), const SizedBox(height: 12), Text( widget.details, style: theme.textTheme.bodyMedium?.copyWith( color: Colors.white.withOpacity(0.7), height: 1.5 ), maxLines: 3, overflow: TextOverflow.ellipsis, ), const SizedBox(height: 20), Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text( NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(widget.price), style: theme.textTheme.headlineSmall?.copyWith( color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24 ) ), Container( decoration: BoxDecoration( color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(10)), child: Row( children: [ IconButton( onPressed: _isProcessing ? null : () { if (quantity > 1) setState(() => quantity--); }, icon: const Icon(Icons.remove, color: Colors.white70), iconSize: 18, splashRadius: 18, constraints: const BoxConstraints(), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4) ), Container( constraints: const BoxConstraints(minWidth: 35), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: Text( '$quantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white))), IconButton( onPressed: _isProcessing ? null : () { setState(() => quantity++); }, icon: const Icon(Icons.add, color: Colors.white70), iconSize: 18, splashRadius: 18, constraints: const BoxConstraints(), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4) ), ],),),],), const SizedBox(height: 25), SizedBox( width: double.infinity, child: ElevatedButton.icon( icon: Icon(_isProcessing ? Icons.hourglass_empty_outlined : Icons.add_shopping_cart_outlined, size: 20), label: Text( _isProcessing ? 'ADDING...' : 'ADD TO CART', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5) ), onPressed: _isProcessing ? null : _addToCart, style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: const TextStyle(fontWeight: FontWeight.bold) ),),),],),),),), if (_isProcessing) Container( color: Colors.black.withOpacity(0.5), child: const Center(child: CircularProgressIndicator(color: Colors.white))),],),); }
}


// --- Cart Page ---
// **** MODIFIED: Use ValueListenableBuilder, removed callback ****
class CartPage extends StatelessWidget { // Changed to StatelessWidget
  const CartPage({super.key});

  // No need for StatefulWidget or callback logic anymore

  void removeFromCart(int index, List<Map<String, dynamic>> currentCartData) {
    final currentCart = List<Map<String, dynamic>>.from(currentCartData); // Create mutable copy
    if (currentCart[index]['quantity'] > 1) {
      currentCart[index]['quantity'] = currentCart[index]['quantity'] - 1;
    } else {
      currentCart.removeAt(index);
    }
    cartNotifier.value = currentCart; // Update notifier
    // No need to call notifyParent or setState here
    // Show snackbar (need context - can't do directly in StatelessWidget method)
    // We'll show snackbar from where this is called if needed, or pass context.
    // For simplicity, removing snackbar from these helper methods.
  }

  void addToCart(int index, List<Map<String, dynamic>> currentCartData) {
    final currentCart = List<Map<String, dynamic>>.from(currentCartData); // Create mutable copy
    currentCart[index]['quantity'] = currentCart[index]['quantity'] + 1;
    cartNotifier.value = currentCart; // Update notifier
    // Removing snackbar here for simplicity
  }

  // **** Context is available in build method for dialogs/navigation ****
  void _handlePayment(BuildContext context, String paymentMethod, List<Map<String, dynamic>> currentCartData) {
    if (currentCartData.isEmpty) { ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("Your cart is empty!"), behavior: SnackBarBehavior.floating)); return; }
    final User? user = FirebaseAuth.instance.currentUser; final scaffoldMessenger = ScaffoldMessenger.of(context); final navigator = Navigator.of(context);
    if (user == null) { scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Error: User not logged in."), behavior: SnackBarBehavior.floating)); return; }
    List<Map<String, dynamic>> orderItems = List.from(currentCartData.map((item) => Map<String, dynamic>.from(item))); // Deep copy
    int finalTotalPrice = currentCartData.map<int>((item) => (item['pricePerItem'] * item['quantity']) as int).reduce((value, element) => value + element);
    final orderData = { 'userId': user.uid, 'userEmail': user.email, 'items': orderItems, 'totalPrice': finalTotalPrice, 'paymentMethod': paymentMethod, 'orderDate': FieldValue.serverTimestamp(), 'orderStatus': 'Processing' };
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => const Dialog( /* ... Dialog UI ... */ shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))), child: Padding( padding: EdgeInsets.all(20.0), child: Row(mainAxisSize: MainAxisSize.min, children: [ CircularProgressIndicator(), SizedBox(width: 20), Text("Placing Order...")]))));
    FirebaseFirestore.instance.collection('orders').add(orderData).then((docRef) {
      if (context.mounted) navigator.pop(); // Close processing dialog
      // **** Clear notifier value ****
      cartNotifier.value = [];
      // **** End Clear ****
      if (context.mounted) showDialog( context: context, builder: (ctx) => AlertDialog( /* ... Success Dialog UI ... */ shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), title: const Text("Order Placed Successfully!"), content: Text("Your order (ID: ${docRef.id}) has been placed using $paymentMethod.\nTotal: \$${NumberFormat("#,##0").format(finalTotalPrice)}."), actions: [ TextButton( onPressed: () => Navigator.pop(ctx), child: const Text("OK")) ],));
    }).catchError((error) {
      if (context.mounted) navigator.pop();
      debugPrint("Error placing order: $error");
      if (context.mounted) scaffoldMessenger.showSnackBar( SnackBar(content: Text("Error placing order: $error"), behavior: SnackBarBehavior.floating) );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    print("CartPage: Building");

    return ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: cartNotifier,
        builder: (context, currentCartItems, child) {
          print("CartPage ValueListenableBuilder: Building with cart items: $currentCartItems");
          int cartTotalPrice = 0;
          if (currentCartItems.isNotEmpty) {
            cartTotalPrice = currentCartItems.map<int>((item) => (item['pricePerItem'] * item['quantity']) as int).reduce((value, element) => value + element);
          }

          return currentCartItems.isEmpty
              ? const Center(child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey), SizedBox(height: 16), Text('Your cart is empty.', style: TextStyle(fontSize: 18, color: Colors.grey)), SizedBox(height: 8), Text('Add some awesome shoes!', style: TextStyle(color: Colors.grey)), ],))
              : Column( children: [
            Expanded( child: ListView.builder( padding: const EdgeInsets.all(8.0), itemCount: currentCartItems.length, itemBuilder: (context, index) {
              final item = currentCartItems[index];
              final itemTotalPrice = item['pricePerItem'] * item['quantity'];
              final imageUrl = item['imageUrl'] ?? 'assets/logo1.jpg';
              return Card( margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), child: Padding( padding: const EdgeInsets.all(10.0), child: Row( children: [
                ClipRRect( borderRadius: BorderRadius.circular(8), child: Image.asset( imageUrl, width: 70, height: 70, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 35, color: Colors.grey)) ), ), const SizedBox(width: 12),
                Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(item['productName'] ?? 'Unknown Product', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), Text('\$${item['pricePerItem']} each', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])), const SizedBox(height: 5),
                  Row( children: [
                    SizedBox( height: 30, width: 30, child: IconButton( padding: EdgeInsets.zero, iconSize: 22, icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () {
                        removeFromCart(index, currentCartItems); // Pass current data
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cart updated"), duration: Duration(milliseconds: 800), behavior: SnackBarBehavior.floating)); // Show snackbar here
                      }, tooltip: 'Decrease quantity',)),
                    Padding( padding: const EdgeInsets.symmetric(horizontal: 10.0), child: Text("${item['quantity']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    SizedBox( height: 30, width: 30, child: IconButton( padding: EdgeInsets.zero, iconSize: 22, icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: () {
                        addToCart(index, currentCartItems); // Pass current data
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quantity updated"), duration: Duration(milliseconds: 800), behavior: SnackBarBehavior.floating)); // Show snackbar here
                      }, tooltip: 'Increase quantity',)), ],), ],), ),
                Text( NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(itemTotalPrice), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) ), ],),), ); }, ), ),
            Container( padding: const EdgeInsets.all(16.0), decoration: BoxDecoration( color: theme.colorScheme.surface, boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0,-4)) ], borderRadius: const BorderRadius.vertical(top: Radius.circular(16)) ), child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [ Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text('Subtotal:', style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey[700])), Text( NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(cartTotalPrice), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold) ) ] ), const Divider(height: 20, thickness: 1), const Text("Select Payment Method:", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 12),
              // Pass context and currentCartItems to _handlePayment
              SizedBox( width: double.infinity, child: OutlinedButton.icon( icon: const Icon(Icons.money, size: 22), label: const Text('Pay with Cash (Simulated)'), onPressed: () => _handlePayment(context, 'Cash', currentCartItems), style: theme.outlinedButtonTheme.style?.copyWith( foregroundColor: MaterialStateProperty.all(Colors.green[700]), side: MaterialStateProperty.all(BorderSide(color: Colors.green[700]!, width: 1.5)), overlayColor: MaterialStateProperty.all(Colors.green.withOpacity(0.1)), ) ),), const SizedBox(height: 10),
              SizedBox( width: double.infinity, child: OutlinedButton.icon( icon: const Icon(Icons.paypal, size: 22), label: const Text('Pay with PayPal (Simulated)'), onPressed: () => _handlePayment(context, 'PayPal', currentCartItems), style: theme.outlinedButtonTheme.style?.copyWith( foregroundColor: MaterialStateProperty.all(const Color(0xFF003087)), side: MaterialStateProperty.all(const BorderSide(color: Color(0xFF003087), width: 1.5)), overlayColor: MaterialStateProperty.all(const Color(0xFF003087).withOpacity(0.1)), ) ),), const SizedBox(height: 10),
              SizedBox( width: double.infinity, child: OutlinedButton.icon( icon: const Icon(Icons.credit_card, size: 22), label: const Text('Pay with Credit Card (Simulated)'), onPressed: () => _handlePayment(context, 'Credit Card', currentCartItems), style: theme.outlinedButtonTheme.style?.copyWith( foregroundColor: MaterialStateProperty.all(Colors.deepOrange[700]), side: MaterialStateProperty.all(BorderSide(color: Colors.deepOrange[700]!, width: 1.5)), overlayColor: MaterialStateProperty.all(Colors.deepOrange.withOpacity(0.1)), ) ), ), ],),)],);
        }
    );
  }
}

// --- Order History Page ---
class OrderHistoryPage extends StatelessWidget { const OrderHistoryPage({super.key}); @override Widget build(BuildContext context) { final FirebaseFirestore firestore = FirebaseFirestore.instance; final FirebaseAuth auth = FirebaseAuth.instance; final User? user = auth.currentUser; final theme = Theme.of(context); print("OrderHistoryPage: Building..."); if (user == null) { print("OrderHistoryPage: User is NULL"); return Scaffold( appBar: AppBar(title: const Text("Purchase History")), body: const Center(child: Text("Please log in to view order history.")), ); } print("OrderHistoryPage: User found: ${user.uid}"); return Scaffold( appBar: AppBar( title: const Text("Purchase History") ), body: StreamBuilder<QuerySnapshot>( stream: firestore .collection('orders') .where('userId', isEqualTo: user.uid) .orderBy('orderDate', descending: true) .snapshots(), builder: (context, snapshot) { print("OrderHistoryPage StreamBuilder: state=${snapshot.connectionState}"); if (snapshot.connectionState == ConnectionState.waiting) { print("OrderHistoryPage StreamBuilder: Waiting..."); return const Center(child: CircularProgressIndicator()); } if (snapshot.hasError) { print("!!! OrderHistoryPage StreamBuilder ERROR: ${snapshot.error}"); debugPrintStack(label: snapshot.error.toString(), maxFrames: 5); return Center(child: Text("Error loading orders: ${snapshot.error}\n\nCheck debug console for details.\nEnsure Firestore index exists.")); } if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { print("OrderHistoryPage StreamBuilder: No data or empty docs."); return const Center(child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(Icons.history_toggle_off, size: 80, color: Colors.grey), SizedBox(height: 16), Text('No orders placed yet.', style: TextStyle(fontSize: 18, color: Colors.grey)), ],)); } final orderDocs = snapshot.data!.docs; print("OrderHistoryPage StreamBuilder: Found ${orderDocs.length} orders."); return ListView.builder( padding: const EdgeInsets.all(8.0), itemCount: orderDocs.length, itemBuilder: (context, index) { try { final orderData = orderDocs[index].data() as Map<String, dynamic>; final orderId = orderDocs[index].id; int totalPrice = orderData['totalPrice'] ?? 0; String paymentMethod = orderData['paymentMethod'] ?? 'N/A'; String orderStatus = orderData['orderStatus'] ?? 'Unknown'; Timestamp? orderTimestamp = orderData['orderDate']; String formattedDate = 'Date Unknown'; if (orderTimestamp != null) { try { DateTime dt = orderTimestamp.toDate(); formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(dt); } catch (e) { print("Error formatting date for order $orderId: $e"); formattedDate = 'Invalid Date'; } } else { print("Order $orderId has null orderDate"); } List<dynamic> itemsDynamic = orderData['items'] ?? []; List<Map<String, dynamic>> items = []; if (itemsDynamic is List) { items = itemsDynamic .map((item) { if (item is Map) { return Map<String, dynamic>.from(item); } else { print("Order $orderId contains non-map item: $item"); return <String, dynamic>{}; } }).where((itemMap) => itemMap.isNotEmpty) .toList(); } else { print("Order $orderId items field is not a List: $itemsDynamic"); } String itemSummary = items .map((item) => "- ${item['productName'] ?? 'Item Name Missing'} (Qty: ${item['quantity'] ?? '?'})") .join('\n'); if (itemSummary.isEmpty) itemSummary = "No valid item details found"; return Card( elevation: 2, margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), child: Padding( padding: const EdgeInsets.all(12.0), child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( "Order ID: $orderId", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const Divider(height: 10), Text('Total: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalPrice)}', style: theme.textTheme.bodyMedium), Text('Status: $orderStatus', style: theme.textTheme.bodyMedium?.copyWith(color: _getStatusColor(orderStatus))), Text('Payment: $paymentMethod', style: theme.textTheme.bodyMedium), Text('Date: $formattedDate', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])), const SizedBox(height: 8), Text('Items:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)), Padding( padding: const EdgeInsets.only(left: 8.0, top: 4.0), child: Text(itemSummary, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700], height: 1.3)), ), ],), ) ); } catch (e) { print("!!! Error processing order at index $index: $e"); debugPrintStack(label: "Order Processing Error", maxFrames: 3); return Card( color: Colors.red[100], margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), child: Padding( padding: const EdgeInsets.all(12.0), child: Text("Error displaying order.\nID: ${orderDocs[index].id}\nError: $e"), ), ); } }, ); }, ), ); } Color _getStatusColor(String status) { switch (status.toLowerCase()) { case 'processing': return Colors.orange; case 'shipped': return Colors.blue; case 'delivered': return Colors.green; case 'cancelled': return Colors.red; default: return Colors.grey; } } }

// --- Search Page ---
class SearchPage extends StatefulWidget { const SearchPage({super.key}); @override State<SearchPage> createState() => _SearchPageState(); }
class _SearchPageState extends State<SearchPage> { final TextEditingController _searchController = TextEditingController(); List<Map<String, dynamic>> _searchResults = []; List<Map<String, dynamic>> _allProducts = []; @override void initState() { super.initState(); _allProducts = products; _searchResults = []; _searchController.addListener(_onSearchChanged); } @override void dispose() { _searchController.removeListener(_onSearchChanged); _searchController.dispose(); super.dispose(); } void _onSearchChanged() { String query = _searchController.text.trim().toLowerCase(); if (query.isEmpty) { setState(() { _searchResults = []; }); return; } final results = _allProducts.where((product) { final name = product['name']?.toLowerCase() ?? ''; final details = product['details']?.toLowerCase() ?? ''; return name.contains(query) || details.contains(query); }).toList(); setState(() { _searchResults = results; }); } void _goToDetails(Map<String, dynamic> product) { FocusScope.of(context).unfocus(); Navigator.push( context, MaterialPageRoute( builder: (_) => ProductDetailPage( productId: product['id'], productName: product['name'], price: product['price'], details: product['details'], imageUrl: product['image'],),),); } @override Widget build(BuildContext context) { final theme = Theme.of(context); return Scaffold( appBar: AppBar( title: Container( width: double.infinity, height: 40, decoration: BoxDecoration( color: Colors.grey[200], borderRadius: BorderRadius.circular(10)), child: Center( child: TextField( controller: _searchController, autofocus: true, decoration: InputDecoration( prefixIcon: const Icon(Icons.search, color: Colors.grey), suffixIcon: IconButton( icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () { _searchController.clear(); },), hintText: 'Search shoes...', border: InputBorder.none),),),),), body: _searchResults.isEmpty && _searchController.text.isNotEmpty ? Center( child: Text( 'No results found for "${_searchController.text}"', style: const TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center,),) : _searchResults.isEmpty && _searchController.text.isEmpty ? const Center( child: Text( 'Type to search for products', style: TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center,),) : ListView.builder( padding: const EdgeInsets.all(8.0), itemCount: _searchResults.length, itemBuilder: (context, index) { final item = _searchResults[index]; final imageUrl = item['image'] ?? 'assets/logo1.jpg'; return Card( margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4), child: ListTile( leading: ClipRRect( borderRadius: BorderRadius.circular(4), child: Image.asset( imageUrl, width: 50, height: 50, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[100], child: const Icon(Icons.broken_image, size: 25, color: Colors.grey)) ), ), title: Text(item['name'] ?? 'Unknown Product', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)), subtitle: Text( NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(item['price']), style: theme.textTheme.bodySmall?.copyWith(color: theme.primaryColor) ), trailing: const Icon(Icons.chevron_right), onTap: () => _goToDetails(item), ), ); },),); } }