class Titulo {
  final String titulo;
  final String cliente;
  final double valor;
  final String vencimento;
  bool selecionado;

  Titulo({
    required this.titulo,
    required this.cliente,
    required this.valor,
    required this.vencimento,
    this.selecionado = false,
  });
}

class Bordero {
  final String id;
  final String descricao;
  final List<Titulo> titulos;

  Bordero({
    required this.id,
    required this.descricao,
    required this.titulos,
  });
}
