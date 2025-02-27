import 'package:flutter/material.dart';
import 'package:titulos/components/componets_color.dart';
import 'package:titulos/models/titulo.dart';

class TitulosScreen extends StatefulWidget {
  final Bordero bordero;

  const TitulosScreen({super.key, required this.bordero});

  @override
  TitulosScreenState createState() => TitulosScreenState();
}

class TitulosScreenState extends State<TitulosScreen> {
  late List<Titulo> titulos;
  late List<Titulo> _filteredTitulos;
  late TextEditingController _searchController;
  double totalSelecionado = 0.0;

  @override
  void initState() {
    super.initState();
    titulos = widget.bordero.titulos;
    _filteredTitulos = titulos;
    _searchController = TextEditingController();

    // Listener para filtrar os títulos com base na pesquisa
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredTitulos = titulos.where((titulo) {
          return titulo.cliente.toLowerCase().contains(query) ||
              titulo.titulo.toLowerCase().contains(query);
        }).toList();
      });
    });

    // Recalcular total ao carregar a tela novamente
    calcularTotal();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void calcularTotal() {
    totalSelecionado = _filteredTitulos
        .where((titulo) => titulo.selecionado)
        .fold(0.0, (sum, titulo) => sum + titulo.valor);
  }

  bool get hasSelection => _filteredTitulos.any((titulo) => titulo.selecionado);

  void _mostrarModalSucesso() {
    List<Titulo> titulosEnviados =
        _filteredTitulos.where((titulo) => titulo.selecionado).toList();
    double totalEnviado =
        titulosEnviados.fold(0.0, (sum, titulo) => sum + titulo.valor);

    ScrollController scrollController = ScrollController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(
                  const Color(0xFFd7342f)), // Cor da barra de rolagem
              trackColor:
                  WidgetStateProperty.all(Colors.grey[300]), // Cor do trilho
              thickness: WidgetStateProperty.all(6), // Largura da barra
              radius: const Radius.circular(10), // Arredondamento
            ),
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 50,
                  color: Color(0xFFd7342f),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Títulos Enviados com Sucesso!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFd7342f),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Enviado: R\$ ${totalEnviado.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              height: 250, // Define uma altura para ativar a rolagem
              child: Scrollbar(
                controller: scrollController,
                thumbVisibility:
                    true, // Torna a barra de rolagem sempre visível
                thickness: 6, // Largura da barra
                radius: const Radius.circular(10), // Arredondamento da barra
                trackVisibility: true, // Deixa a trilha visível
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Os seguintes títulos foram enviados:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: titulosEnviados.map((titulo) {
                          return Container(
                            padding: const EdgeInsets.all(8.0),
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Título: ${titulo.titulo}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Cliente: ${titulo.cliente}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Valor: R\$ ${titulo.valor.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFd7342f),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'FECHAR',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
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
          iconTheme: const IconThemeData(
            color: Color(0xFFd7342f),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  secondaryColor,
                ],
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
              //   height: 40,
              // ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildBorderoHeader(),
          _buildSearchField(), // Campo de pesquisa adicionado aqui
          Expanded(child: isWeb ? _buildWebTable() : _buildMobileList()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildBorderoHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        color: cardBackgroundColor,
        border: Border(
          bottom: BorderSide(color: cardBackgroundColor, width: 1.0),
        ),
      ),
      child: Center(
        child: Text(
          'Títulos do Borderô ID: ${widget.bordero.id}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 1200), // Definindo largura máxima
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Pesquisar por Cliente ou Título',
              labelStyle: const TextStyle(color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: cardBackgroundColor, width: 2.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 2.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return Scrollbar(
      thumbVisibility: true,
      thickness: 6,
      radius: const Radius.circular(10),
      trackVisibility: true,
      scrollbarOrientation: ScrollbarOrientation.right,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          setState(() {});
          return false;
        },
        child: Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(
                const Color(0xFFd7342f),
              ),
            ),
          ),
          child: ListView.builder(
            itemCount: _filteredTitulos.length,
            itemBuilder: (context, index) {
              final titulo = _filteredTitulos[index];
              return Card(
                elevation: 4,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: titulo.selecionado,
                        activeColor: const Color(0xFFd7342f),
                        onChanged: (bool? value) {
                          setState(() {
                            titulo.selecionado = value ?? false;
                            calcularTotal();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTituloDetails(titulo),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWebTable() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            // Cabeçalho fixo
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFd7342f),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: const [
                  Expanded(flex: 1, child: Center(child: SizedBox())),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        'Título',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        'Cliente',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        'Valor',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        'Vencimento',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Corpo Rolável da Tabela
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 6,
                radius: const Radius.circular(10),
                trackVisibility: true,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    scrollbarTheme: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.all(
                        const Color(0xFFd7342f),
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: _filteredTitulos
                          .map((titulo) => _buildWebTableRow(titulo))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebTableRow(Titulo titulo) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.5,
            style: BorderStyle.solid,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Checkbox(
                value: titulo.selecionado,
                activeColor: const Color(0xFFd7342f),
                onChanged: (bool? value) {
                  setState(() {
                    titulo.selecionado = value ?? false;
                    calcularTotal();
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                titulo.titulo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                titulo.cliente,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'R\$ ${titulo.valor.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                titulo.vencimento,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTituloDetails(Titulo titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Título: ${titulo.titulo}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Cliente: ${titulo.cliente}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Valor: R\$ ${titulo.valor.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Vencimento: ${titulo.vencimento}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final isWeb = MediaQuery.of(context).size.width > 900; // Verifica se é web
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: isWeb
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Total Selecionado
                    RichText(
                      text: TextSpan(
                        text: "Total Selecionado: ",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: 'R\$ ${totalSelecionado.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botão de Enviar
                    ElevatedButton(
                      onPressed: hasSelection ? _mostrarModalSucesso : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasSelection
                            ? const Color(0xFFd7342f)
                            : Colors.grey[400],
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'ENVIAR TÍTULOS SELECIONADOS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Selecionado:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'R\$ ${totalSelecionado.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: hasSelection ? _mostrarModalSucesso : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasSelection
                          ? const Color(0xFFd7342f)
                          : Colors.grey[400],
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'ENVIAR TÍTULOS SELECIONADOS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
