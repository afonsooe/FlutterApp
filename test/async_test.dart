import 'package:test/test.dart';

Future<int> process() async {
  await Future.delayed(Duration(seconds: 5));
  return 0;
}

Map<String, List<double>> alunos = {
  'Maria': [8.0, 9.0],
  'Bruna': [7.0, 7.0],
  'Carla': [10.0, 9.0],
};

Future<List<double>?> search(String key) async {
  return Future.delayed(Duration(seconds: 2), () {
    if (alunos.containsKey(key)) {
      return alunos[key]!;
    }
    throw ArgumentError('Aluno não encontrado.');
  });
}

Stream<int> count() async* {
  for (int i = 1; i <= 3; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

// Passo 5: Stream que calcula a média das notas de cada aluno da lista.
// Cada média é emitida assim que a pesquisa daquele aluno termina.
// Se o aluno não existir, search lança ArgumentError e a Stream
// emite o erro e é encerrada.
Stream<double> media(List<String> nomes) async* {
  for (String nome in nomes) {
    List<double>? notas = await search(nome);
    if (notas == null || notas.isEmpty) {
      yield 0.0;
      continue;
    }
    double soma = 0;
    for (double nota in notas) {
      soma += nota;
    }
    yield soma / notas.length;
  }
}

void main() {
  group('Testes de programação assíncrona', () {
    late Future<int> result;

    setUp(() => result = process());

    test('Aguardando...', () => expect(result, isNotNull));

    test('Testando o resultado', () async {
      int num = await result;
      expect(num, 0);
    });

    test('Testando busca sem erros em Future', () async {
      List<double>? notas = await search('Maria');
      expect(notas, [8.0, 9.0]);
    });

    test('Testando busca com erros em Future', () async {
      await expectLater(search('Paula'), throwsA(isA<ArgumentError>()));
    });

    test('Testando contagem em Stream', () async {
      await expectLater(count(), emitsInOrder([1, 2, 3, emitsDone]));
    });

    test('Testando media em Stream', () async {
      List<double> resultados = await media(['Maria', 'Bruna']).toList();
      expect(resultados, [8.5, 7.0]);
    });

    test('Testando media em Stream com aluno inexistente', () async {
      // Maria é calculada; Paula gera o erro e encerra a Stream.
      await expectLater(
        media(['Maria', 'Paula', 'Bruna']),
        emitsInOrder([8.5, emitsError(isA<ArgumentError>()), emitsDone]),
      );
    });
  });
}