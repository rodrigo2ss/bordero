import 'package:flutter/material.dart';
import 'package:titulos/api/api_service.dart';
import 'package:titulos/components/componets_color.dart';
import 'package:titulos/screens/login_screen.dart';
import 'package:titulos/models/titulo.dart';
import 'titulos_screen.dart';

class ListaBorderosScreen extends StatefulWidget {
  const ListaBorderosScreen({super.key});

  @override
  ListaBorderosScreenState createState() => ListaBorderosScreenState();
}

class ListaBorderosScreenState extends State<ListaBorderosScreen> {
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  List<Bordero> _filteredBorderos = [];
  List<Bordero> _allBorderos = [];
  bool _isLoading = true;
  bool _hasError = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _searchController.addListener(_filterBorderos);

    _fetchBorderos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBorderos() async {
    try {
      List<Bordero> borderos = await _apiService.fetchBorderos(
        borderoDe: "000461",
        borderoAte: "000462",
        cfilial: "01",
      );

      setState(() {
        _allBorderos = borderos;
        _filteredBorderos = borderos;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _filterBorderos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBorderos = _allBorderos
          .where((bordero) => bordero.id.toLowerCase().contains(query))
          .toList();
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   'assets/logo.png',
              //   height: 110,
              // ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.account_circle,
                color: Color(0xFFd7342f),
              ),
              onSelected: (String result) {
                if (result == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Color(0xFFd7342f)),
                      SizedBox(width: 8),
                      Text('Sair do Sistema'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            decoration: const BoxDecoration(
              color: cardBackgroundColor,
              border: Border(
                bottom: BorderSide(color: cardBackgroundColor, width: 1.0),
              ),
            ),
            child: const Center(
              child: Text(
                'Selecione um Borderô para visualizar seus títulos',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Pesquisar pelo ID',
                    labelStyle: const TextStyle(color: primaryColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    prefixIcon: const Icon(Icons.search, color: primaryColor),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? const Center(child: Text("Erro ao carregar borderôs"))
                    : isWeb
                        ? _buildWebTable(_filteredBorderos)
                        : _buildMobileList(_filteredBorderos),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<Bordero> borderos) {
    return ListView.builder(
      itemCount: borderos.length,
      itemBuilder: (context, index) {
        final bordero = borderos[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TitulosScreen(bordero: bordero)),
            );
          },
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: ListTile(
              leading: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFd7342f),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(Icons.folder, color: Colors.white, size: 30),
              ),
              title: Text(bordero.descricao,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: Text('ID: ${bordero.id}',
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFFd7342f))),
              trailing:
                  const Icon(Icons.arrow_forward_ios, color: Color(0xFFd7342f)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebTable(List<Bordero> borderos) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho da Tabela
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.white,
                      secondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ID',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                      Text(
                        'Descrição',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                      Text(
                        'Ações',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Corpo da Tabela com Scroll corrigido
            Flexible(
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thickness: 6,
                  radius: const Radius.circular(10),
                  trackVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    primary: false,
                    shrinkWrap: true,
                    itemCount: borderos.length,
                    itemBuilder: (context, index) {
                      final bordero = borderos[index];
                      return _buildTableRow(bordero, context, index);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(Bordero bordero, BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(bordero.id,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          Expanded(
            child: Center(
              child: Text(bordero.descricao,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TitulosScreen(bordero: bordero)));
            },
            icon: const Icon(Icons.visibility, size: 18, color: Colors.white),
            label:
                const Text('Visualizar', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFd7342f),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              elevation: 3,
            ),
          ),
        ],
      ),
    );
  }
}
