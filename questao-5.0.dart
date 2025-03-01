import 'dart:io';

class MetodoPagamento {
  final String tipo;
  final String numero;
  final String validade; 
  final String cvv;

  MetodoPagamento(this.tipo, this.numero, this.validade, this.cvv);

  bool validar() {
    switch (tipo) {
      case 'cartao_credito':
        return validarCartaoCredito(numero) &&
               validarDataValidade(validade) &&
               validarCVV(cvv);
      case 'boleto':
        return validarNossoNumero(numero);
      case 'paypal':
        return validarEmailPayPal(numero);
      case 'pix':
        return validarChavePix(numero);
      default:
        return false;
    }
  }

  bool validarCartaoCredito(String numeroCartao) {
    numeroCartao = numeroCartao.replaceAll(RegExp(r'\D'), '');
    if (numeroCartao.length != 16) return false;
    int soma = 0;
    bool deveDobrar = false;
    for (int i = numeroCartao.length - 1; i >= 0; i--) {
      int digito = int.parse(numeroCartao[i]);
      if (deveDobrar) {
        digito *= 2;
        if (digito > 9) digito -= 9;
      }
      soma += digito;
      deveDobrar = !deveDobrar;
    }
    return soma % 10 == 0;
  }

  bool validarNossoNumero(String nossoNumero) {
    return nossoNumero.length == 11 && RegExp(r'^\d{11}$').hasMatch(nossoNumero);
  }

  bool validarDataValidade(String validade) {
    RegExp exp = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
    if (!exp.hasMatch(validade)) return false;
    DateTime dataValidade = DateTime.parse('20${validade.split('/')[1]}-${validade.split('/')[0]}-01');
    return dataValidade.isAfter(DateTime.now());
  }

  bool validarCVV(String cvv) {
    return RegExp(r'^\d{3,4}$').hasMatch(cvv);
  }

  bool validarEmailPayPal(String email) {
    RegExp exp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return exp.hasMatch(email);
  }

  bool validarChavePix(String chave) {
    RegExp exp = RegExp(r'^\d{11}$');
    return exp.hasMatch(chave);
  }
}

void solicitarMetodoPagamento() {
  print('Escolha o método de pagamento desejado:');
  print('1. Cartão de Crédito');
  print('2. Boleto');
  print('3. PayPal');
  print('4. PIX');
  stdout.write('Digite o número correspondente ao método desejado: ');

  String? escolha = stdin.readLineSync();

  if (escolha == null || int.tryParse(escolha) == null || int.parse(escolha) < 1 || int.parse(escolha) > 4) {
    print('Opção inválida. Tente novamente.');
    solicitarMetodoPagamento();
    return;
  }

  String tipoPagamento = '';
  switch (escolha) {
    case '1':
      tipoPagamento = 'cartao_credito';
      break;
    case '2':
      tipoPagamento = 'boleto';
      break;
    case '3':
      tipoPagamento = 'paypal';
      break;
    case '4':
      tipoPagamento = 'pix';
      break;
  }


  stdout.write('Digite o número identificador do pagamento: ');
  String? numero = stdin.readLineSync() ?? '';

  String validade = '';
  String cvv = '';
  if (tipoPagamento == 'cartao_credito') {
    stdout.write('Digite a data de validade (MM/AA): ');
    validade = stdin.readLineSync() ?? '';
    stdout.write('Digite o CVV do cartão: ');
    cvv = stdin.readLineSync() ?? '';
  }

  MetodoPagamento metodo = MetodoPagamento(tipoPagamento, numero, validade, cvv);

  if (metodo.validar()) {
    print('Pagamento validado com sucesso!');
  } else {
    print('Dados de pagamento inválidos. Tente novamente.');
    solicitarMetodoPagamento();
  }
}

void main() {
  solicitarMetodoPagamento();
}
