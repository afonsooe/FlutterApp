import 'package:test/test.dart';

abstract class Pessoa {
  late int _id;
  String nome;

  Pessoa(this.nome);

  int get id => _id;

  set id(int id) {
    if (id > 0) {
      _id = id;
    } else {
      throw ArgumentError('Identificador deve ser não negativo.');
    }
  }
}

mixin Ano {
  late int _ano;

  int get ano => _ano;

  set ano(int ano) {
    if (ano > 0) {
      _ano = ano;
    } else {
      throw ArgumentError('Ano deve ser não negativo.');
    }
  }
}

class Aluno extends Pessoa with Ano {
  Aluno(super.nome, int ano) {
    this.ano = ano;
  }
}

// Passo 5: nova classe Professor (também é uma Pessoa)
class Professor extends Pessoa {
  Professor(super.nome);
}

class Disciplina {
  String nome;

  Disciplina(this.nome);
}

class Turma with Ano {
  Disciplina disciplina;
  Professor professor; // Passo 5: novo atributo
  final List<Aluno> _alunos = [];

  Turma(this.disciplina, this.professor, int ano) {
    this.ano = ano;
  }

  void matricular(Aluno aluno) {
    if (aluno.ano == ano) {
      _alunos.add(aluno);
    } else {
      throw ArgumentError('Ano deve ser mesmo.');
    }
  }
}

class Historico extends Turma {
  Map<Aluno, List<double>> notas = {};

  Historico(super.disciplina, super.professor, super.ano);

  @override
  void matricular(Aluno aluno) {
    super.matricular(aluno);
    notas[aluno] = [];
  }

  double media(Aluno aluno) {
    List<double> notasAluno = notas[aluno]!;
    // Sem notas lançadas, a média é 0 (evita divisão 0/0 = NaN)
    if (notasAluno.isEmpty) {
      return 0.0;
    }
    double soma = 0;
    for (double nota in notasAluno) {
      soma += nota;
    }
    // Corrigido: divide pela quantidade de notas do aluno,
    // e não pela quantidade de alunos do mapa (notas.length)
    return soma / notasAluno.length;
  }

  // Passo 6: aprovado se a média for superior a seis
  bool isAprovado(Aluno aluno) {
    return media(aluno) > 6;
  }
}

void main() {
  test('Testar matrícula de alunos', () {
    Disciplina disciplina1 = Disciplina('Flutter');
    Professor professor1 = Professor('Walber');
    professor1.id = 1;
    Historico historico1 = Historico(disciplina1, professor1, 2023);

    // Cadastrar primeiro aluno sem erros
    Aluno aluno1 = Aluno('Maria', 2023);
    aluno1.id = 1;
    historico1.matricular(aluno1);
    expect(historico1.media(aluno1), 0.0);

    // Cadastrar segundo aluno com erros
    Aluno aluno2 = Aluno('Paula', 2022);
    try {
      aluno2.id = 0;
    } catch (error) {
      expect(error, isA<ArgumentError>());
    }
    try {
      historico1.matricular(aluno2);
    } catch (error) {
      expect(error, isA<ArgumentError>());
    }
  });

  test('Testar professor da turma', () {
    Professor professor1 = Professor('Walber');
    professor1.id = 10;
    Historico historico1 = Historico(Disciplina('Flutter'), professor1, 2023);

    expect(historico1.professor, professor1);
    expect(historico1.professor.nome, 'Walber');
    expect(historico1.professor.id, 10);

    // Professor também é uma Pessoa: mesma validação de identificador
    expect(() => professor1.id = 0, throwsArgumentError);
  });

  test('Testar média e aprovação', () {
    Professor professor1 = Professor('Walber');
    professor1.id = 1;
    Historico historico1 = Historico(Disciplina('Flutter'), professor1, 2023);

    Aluno aprovado = Aluno('Maria', 2023);
    aprovado.id = 1;
    Aluno naFronteira = Aluno('João', 2023);
    naFronteira.id = 2;
    Aluno reprovado = Aluno('Ana', 2023);
    reprovado.id = 3;
    Aluno semNotas = Aluno('Pedro', 2023);
    semNotas.id = 4;

    historico1.matricular(aprovado);
    historico1.matricular(naFronteira);
    historico1.matricular(reprovado);
    historico1.matricular(semNotas);

    historico1.notas[aprovado]!.addAll([8.0, 7.0]); // média 7.5
    historico1.notas[naFronteira]!.addAll([6.0, 6.0]); // média 6.0
    historico1.notas[reprovado]!.addAll([4.0, 5.0]); // média 4.5

    expect(historico1.media(aprovado), 7.5);
    expect(historico1.isAprovado(aprovado), isTrue);

    // Média igual a seis NÃO é "superior a seis"
    expect(historico1.media(naFronteira), 6.0);
    expect(historico1.isAprovado(naFronteira), isFalse);

    expect(historico1.media(reprovado), 4.5);
    expect(historico1.isAprovado(reprovado), isFalse);

    // Sem notas lançadas
    expect(historico1.media(semNotas), 0.0);
    expect(historico1.isAprovado(semNotas), isFalse);
  });
}