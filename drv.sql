DROP DATABASE DRV_CINE;
CREATE DATABASE DRV_CINE;

USE DRV_CINE;

CREATE TABLE tb_filme(
    cd_filme INT NOT NULL,
    nm_filme VARCHAR(100) UNIQUE NOT NULL,
    ano_lancamento INT NOT NULL,
    idioma VARCHAR(20) NOT NULL,
    diretor VARCHAR(50) NOT NULL,
    sinopse TEXT NOT NULL,
    cd_tipo INT NOT NULL
);

CREATE TABLE tb_tipo(
    cd_tipo INT PRIMARY KEY AUTO_INCREMENT,
    ds_tipo VARCHAR(20) NOT NULL,
    classificacao VARCHAR(20)
);


CREATE TABLE tb_sala(
    cd_sala INT PRIMARY KEY AUTO_INCREMENT,
    nm_sala VARCHAR(20) NOT NULL,
    capacidade INT NOT NULL
);

CREATE TABLE tb_premiacoes(
    cd_premiacao INT PRIMARY KEY AUTO_INCREMENT,
    ds_premiacao VARCHAR(30) NOT NULL
);

CREATE TABLE tb_exibicao(
    cd_exibicao INT PRIMARY KEY AUTO_INCREMENT,
    quantidade INT NOT NULL,
    cd_sala INT NOT NULL,
    cd_filme INT NOT NULL,
    cd_horario INT NOT NULL
);

CREATE TABLE tb_ingresso(
    cd_ingresso INT PRIMARY KEY AUTO_INCREMENT,
    cpf_cliente VARCHAR(15) NOT NULL,
    quantidade_ingresso INT NOT NULL,
    valor_unitario DECIMAL(10,2) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    cd_exibicao INT NOT NULL
);

CREATE TABLE tb_funcionarios(
    cd_funcionario INT PRIMARY KEY AUTO_INCREMENT,
    nm_funcionario VARCHAR(30) NOT NULL,
    carteira_trabalho VARCHAR(20) NOT NULL,
    data_admissao DATE NOT NULL
);

CREATE TABLE tb_horarios(
    cd_horario INT PRIMARY KEY AUTO_INCREMENT,
    horario VARCHAR(10) NOT NULL
);

CREATE TABLE tb_funcao(
    cd_funcao INT PRIMARY KEY AUTO_INCREMENT,
    ds_funcao VARCHAR(30) NOT NULL,
    salario DECIMAL(10,2) NOT NULL
);

CREATE TABLE tb_exibicao_funcionario(
    cd_exib_func INT PRIMARY KEY AUTO_INCREMENT,
    dt_exibicao DATE NOT NULL,
    cd_funcionario INT NOT NULL,
    cd_funcao INT NOT NULL,
    cd_exibicao INT NOT NULL
);

CREATE TABLE tb_filme_premiacao(
    cd_filme_p INT PRIMARY KEY AUTO_INCREMENT,
    ano INT NOT NULL,
    cd_premiacao INT NOT NULL,
    cd_filme INT NOT NULL
);

/* Adicionando FK */

ALTER TABLE tb_filme
        ADD CONSTRAINT pk_filme_tipo
        PRIMARY KEY(cd_filme);

ALTER TABLE tb_filme
        ADD CONSTRAINT fk_filme_tipo
        FOREIGN KEY(cd_tipo) REFERENCES tb_tipo(cd_tipo);

ALTER TABLE tb_exibicao
        ADD CONSTRAINT fk_exibicao_sala
        FOREIGN KEY(cd_sala) REFERENCES tb_sala(cd_sala);
ALTER TABLE tb_exibicao
        ADD CONSTRAINT fk_exibicao_horario
        FOREIGN KEY(cd_horario) REFERENCES tb_horarios(cd_horario);
ALTER TABLE tb_exibicao
        ADD CONSTRAINT fk_exibicao_filme
        FOREIGN KEY(cd_filme) REFERENCES tb_filme(cd_filme);

ALTER TABLE tb_exibicao_funcionario
        ADD CONSTRAINT fk_exibicao_funcionario
        FOREIGN KEY(cd_funcionario) REFERENCES tb_funcionarios(cd_funcionario);
ALTER TABLE tb_exibicao_funcionario
        ADD CONSTRAINT fk_exibicao_funcionario_funcao
        FOREIGN KEY(cd_funcao) REFERENCES tb_funcao(cd_funcao);
ALTER TABLE tb_exibicao_funcionario
        ADD CONSTRAINT fk_funcionario_exibicao
        FOREIGN KEY(cd_exibicao) REFERENCES tb_exibicao(cd_exibicao);  

ALTER TABLE tb_filme_premiacao
        ADD CONSTRAINT fk_filme_premiacao
        FOREIGN KEY(cd_premiacao) REFERENCES tb_premiacoes(cd_premiacao); 
ALTER TABLE tb_filme_premiacao
        ADD CONSTRAINT fk_premiacao_filme
        FOREIGN KEY(cd_filme) REFERENCES tb_filme(cd_filme); 



/* Criando funções */
/* Função para gerar codigo filme */
DELIMITER $

CREATE FUNCTION codigo_filme()
RETURNS VARCHAR(10)
BEGIN

declare prefixo varchar(4);
declare sufixo varchar(3);
declare qtdFil int;

SET prefixo = date_format(now(), '%y%m');
SET qtdFil = (select count(*)+1 from tb_filme);
SET sufixo = LPAD(qtdFil, 3, 0);

return CONCAT(prefixo, sufixo);

END $
DELIMITER ;

/* Função para gerar valor total */
DELIMITER $

CREATE FUNCTION fnc_calcula_valor_total(quantidade INT, valor_unit DECIMAL(10,2))
RETURNS DECIMAL(10,2)
BEGIN
return quantidade * valor_unit;
END $
DELIMITER ;

/* Criando Procedures */

/* Procedure de inserção filme */
DELIMITER $
CREATE PROCEDURE pdr_cadastra_filme(
    IN nome_filme VARCHAR(100), 
    IN lancamento INT, 
    IN idioma_filme VARCHAR(20), 
    IN diretor_filme VARCHAR(50), 
    IN sinopse_filme TEXT, 
    IN codigo_tipo INT
)

BEGIN

DECLARE nome VARCHAR(100);

SELECT nm_filme INTO nome FROM tb_filme WHERE nm_filme = nome_filme AND ano_lancamento = lancamento;

IF nome IS NULL THEN

INSERT INTO tb_filme VALUES(codigo_filme(), nome_filme, lancamento, idioma_filme, diretor_filme, sinopse_filme, codigo_tipo);

ELSE
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já existe um filme cadastrado com esse nome e ano de lançamento';

END IF;
END $

DELIMITER ;

/* Procedure de deleção filme */
DELIMITER $
CREATE PROCEDURE pdr_deleta_filme(
    IN nome_filme VARCHAR(100),
    IN lancamento_filme INT
)

BEGIN

DECLARE codigo_filme VARCHAR(100);

SELECT cd_filme INTO codigo_filme FROM tb_filme WHERE nm_filme = nome_filme AND ano_lancamento = lancamento_filme;

IF codigo_filme IS NULL THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esse filme não existe na base de dados';

ELSE
DELETE FROM tb_filme WHERE cd_filme = codigo_filme;

END IF;
END $

DELIMITER ;


/* Procedure de inserção tipo */

DELIMITER $
CREATE PROCEDURE pdr_cadastra_tipo(
    IN descricao_tipo VARCHAR(20),
    IN classificacao_tipo VARCHAR(20) 
)

BEGIN

INSERT INTO tb_tipo VALUES(NULL, descricao_tipo, classificacao_tipo);

END $

DELIMITER ;


/* Procedure de deleção tipo */

DELIMITER $
CREATE PROCEDURE pdr_deleta_tipo(
    IN descricao_tipo VARCHAR(20)
)

BEGIN

DECLARE codigo_tipo INT;

SELECT cd_tipo INTO codigo_tipo FROM tb_tipo WHERE ds_tipo = descricao_tipo;

IF codigo_tipo IS NULL THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esse tipo não existe na base de dados';

ELSE
DELETE FROM tb_tipo WHERE cd_tipo = codigo_tipo;

END IF;
END $

DELIMITER ;


/* Procedure de inserção sala */
DELIMITER $
CREATE PROCEDURE pdr_cadastra_sala(
    IN nome_sala VARCHAR(20),
    IN capacidade_sala INT
)

BEGIN

DECLARE nome VARCHAR(100);

SELECT nm_sala INTO nome FROM tb_sala WHERE nm_sala = nome_sala;

IF nome IS NULL THEN

INSERT INTO tb_sala VALUES(NULL, nome_sala, capacidade_sala);

ELSE
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já existe uma sala cadastrada com esse nome ';

END IF;
END $

DELIMITER ;


/* Procedure de deleção sala */
DELIMITER $
CREATE PROCEDURE pdr_deleta_sala(
    IN nome_sala VARCHAR(20)
)

BEGIN

DECLARE codigo_sala VARCHAR(100);

SELECT cd_sala INTO codigo_sala FROM tb_sala WHERE nm_sala = nome_sala;

IF codigo_sala IS NULL THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não existe uma sala cadastrada com esse nome ';

ELSE
DELETE FROM tb_sala WHERE cd_sala = codigo_sala;

END IF;
END $

DELIMITER ;


/* Procedure de inserção premiaçao */
DELIMITER $
CREATE PROCEDURE pdr_cadastra_premiacao(
    IN descricao_premiacao VARCHAR(30)
)

BEGIN

DECLARE descricao VARCHAR(100);

SELECT ds_premiacao INTO descricao FROM tb_premiacoes WHERE ds_premiacao = descricao_premiacao;

IF descricao IS NULL THEN

INSERT INTO tb_premiacoes VALUES(NULL, descricao_premiacao);

ELSE
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já existe uma premiacao cadastrada com esse nome ';

END IF;
END $

DELIMITER ;


/* Procedure de deleção premiacao */
DELIMITER $
CREATE PROCEDURE pdr_deleta_premiacao(
    IN descricap_premiacao VARCHAR(30)
)

BEGIN

DECLARE codigo_premiacao INT;

SELECT cd_premiacao INTO codigo_premiacao FROM tb_premiacoes WHERE ds_premiacao = descricap_premiacao;

IF codigo_premiacao IS NULL THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não existe uma premiação cadastrada com esse nome ';

ELSE
DELETE FROM tb_premiacoes WHERE cd_premiacao = codigo_premiacao;

END IF;
END $

DELIMITER ;



/* Procedure de inserção exibicao */
DELIMITER $
CREATE PROCEDURE pdr_cadastra_exibicao(
    IN codigo_sala INT,
    IN codigo_filme INT,
    IN codigo_horario INT
)

BEGIN

DECLARE qtd INT;
SELECT capacidade INTO qtd FROM tb_sala WHERE cd_sala = codigo_sala;

IF qtd IS NULL THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não existe sala cadastrada com esse código';

ELSE
INSERT INTO tb_exibicao VALUES(NULL, qtd, codigo_sala, codigo_filme, codigo_horario);

END IF;
END $

DELIMITER ;


/* Procedure de deleção exibicao */
DELIMITER $
CREATE PROCEDURE pdr_deleta_exibicao(
    IN codigo_exibicao INT
)

BEGIN

DECLARE exibicao INT;

SELECT cd_exibicao INTO exibicao FROM tb_exibicao WHERE cd_exibicao = codigo_exibicao;

IF exibicao IS NULL THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não existe exibicao cadastrada com esse código';

ELSE
DELETE FROM tb_exibicao WHERE cd_exibicao = codigo_exibicao;

END IF;
END $

DELIMITER ;


/* Procedure de inserção funcionário */
DELIMITER $
CREATE PROCEDURE pdr_cadastra_funcionario(
    IN nome_funcionario VARCHAR(30),
    IN carteira_trabalho_funcionario VARCHAR(20)
)

BEGIN

DECLARE clt VARCHAR(20);
SELECT carteira_trabalho INTO clt FROM tb_funcionarios WHERE carteira_trabalho = carteira_trabalho_funcionario;

IF clt IS NULL THEN
INSERT INTO tb_funcionarios VALUES(NULL, nome_funcionario, carteira_trabalho_funcionario, NOW());

ELSE
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já existe um funcinário cadastrado com essa carteira';

END IF;
END $

DELIMITER ;


/* Procedure de deleção funcionario */
DELIMITER $
CREATE PROCEDURE pdr_deleta_funcionario(
    IN carteira_funcionario INT
)

BEGIN

DECLARE funcionario INT;

SELECT carteira_trabalho INTO funcionario FROM tb_funcionario WHERE carteira_trabalho = carteira_funcionario;

IF funcionario IS NULL THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não existe funcionário cadastrado com essa carteira';

ELSE
DELETE FROM tb_funcionarios WHERE carteira_trabalho = carteira_funcionario;

END IF;
END $

DELIMITER ;


/* Procedure de inserção horario */
DELIMITER $
CREATE PROCEDURE pdr_cadastra_horario(
    IN hora_exib VARCHAR(10)
)

BEGIN

DECLARE horario_exibicao VARCHAR(10);
SELECT horario INTO horario_exibicao FROM tb_horarios WHERE horario = hora_exib;

IF horario_exibicao IS NULL THEN
INSERT INTO tb_horarios VALUES(NULL, hora_exib);

ELSE
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esse horário ja foi cadastrado';

END IF;
END $

DELIMITER ;


/* Procedure de deleção horário */
DELIMITER $
CREATE PROCEDURE pdr_deleta_horario(
    IN hora_exibe INT
)

BEGIN

DECLARE codigo_horario INT;

SELECT cd_horario INTO codigo_horario FROM tb_horarios WHERE horario = hora_exibe;

IF codigo_horario IS NULL THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não existe horario cadastrado com esse código';

ELSE
DELETE FROM tb_horarios WHERE cd_horario = codigo_horario;

END IF;
END $

DELIMITER ;


/* Procedure de inserção funcao */
DELIMITER $
CREATE PROCEDURE pdr_cadastra_funcao(
    IN descricao_funcao VARCHAR(30),
    IN salario_funcao DECIMAL(10,2)
)

BEGIN

DECLARE funcao VARCHAR(30);
SELECT ds_funcao INTO funcao FROM tb_funcao WHERE ds_funcao = descricao_funcao;

IF funcao IS NULL THEN
INSERT INTO tb_funcao VALUES(NULL, descricao_funcao, salario_funcao);

ELSE
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Essa função ja foi cadastrada';

END IF;
END $

DELIMITER ;


/* Procedure de deleção funcao */
DELIMITER $
CREATE PROCEDURE pdr_deleta_funcao(
    IN descricao_funcao INT
)

BEGIN

DECLARE codigo_funcao INT;

SELECT cd_funcao INTO codigo_funcao FROM tb_funcao WHERE ds_funcao = descricao_funcao;

IF codigo_funcao IS NULL THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não existe função cadastrada com esse código';

ELSE
DELETE FROM tb_funcao WHERE cd_funcao = codigo_funcao;

END IF;
END $

DELIMITER ;


/* Procedure de inserção venda */
DELIMITER $
CREATE PROCEDURE pdr_cadastra_venda(
    IN qtd_ingresso INT,
    IN CGC VARCHAR(15),
    IN valor_unit DECIMAL(10,2),
    IN codigo_exibicao INT
)

BEGIN

DECLARE qtd_capacidade INT;

SELECT quantidade INTO qtd_capacidade FROM tb_exibicao WHERE cd_exibicao = codigo_exibicao;
IF (qtd_ingresso > qtd_capacidade) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não existem mais poltronas disponiveis';

ELSE
INSERT INTO tb_ingresso VALUES(NULL, CGC, qtd_ingresso,  valor_unit, fnc_calcula_valor_total(valor_unit,qtd_ingresso), codigo_exibicao);
UPDATE tb_exibicao SET quantidade = qtd_capacidade - qtd_ingresso WHERE cd_exibicao = codigo_exibicao;
END IF;
END $

DELIMITER ;




/*CHAMADA PARA CADASTRAR CATEGORIA DE FILME*/

CALL pdr_cadastra_tipo('COMÉDIA','+18');
CALL pdr_cadastra_tipo('TERROR','+12');
CALL pdr_cadastra_tipo('AÇÃO','+16');
CALL pdr_cadastra_tipo('AVENTURA','+18');

SELECT * FROM tb_tipo;
/*call pdr_deleta_tipo('COMÉDIA');*/

/*CHAMADA PARA CADASTRAR FILMES*/

CALL pdr_cadastra_filme('YOHAN EM AÇÃO','2021', 'ESPANHOL', 'ALERRANDRO BARRETO','UM JOVEM MENINO TENTA GANHAR A VIDA NA CIDADE GRANDE DE MANAUS, MAS ELE NÃO CONTA COM OS TIPOS DE ADVERSIDADE A ENCONTRAR EM SUA JORNADA',4);
CALL pdr_cadastra_filme('MUNDO DO XEROX','2021', 'PORTUGUES', 'VICTOR ALEXANDRE','UM HOMEM RICO ACOSTUMADO COM SUA VIDA MONÓTONA TENTA VISITAR TODOS OS PAÍSES DO MUNDO, PORÉM ELE NÃO ESPERAVA OQUE ACONTECERIA EM SUA JORNADA',3);
CALL pdr_cadastra_filme('THE ÉDY SON','2022', 'INGLÊS','ANDRIW AMORIM', 'NARRA A ESTORIA DE UM PROFESSOR, ACOSTUMADO A FERRAR COM A TURMA EM SUAS AVALIAÇÕES, OS MESMOS TENTAM TIRA-LO DA SALA O MAIS BREVE POSSÍVEL',2);
CALL pdr_cadastra_filme('THE FÃ METRÔ','2019', 'PORTUGUES','DOM CHIQUITO', 'NARRA A ESTORIA DE UMA INSTITUIÇÃO DE ENSINO FEITA EM UM SUBTERRANEO DE UM METRÔ, O MESMO EXISTEM MUITAS AVENTURAS E BRINCADEIRAS',1);
CALL pdr_cadastra_filme('THE FÃ METRÔ 2','2019', 'PORTUGUES','DOM CHIQUITO', 'NARRA A ESTORIA DE UMA INSTITUIÇÃO DE ENSINO FEITA EM UM SUBTERRANEO DE UM METRÔ, O MESMO EXISTEM MUITAS AVENTURAS E BRINCADEIRAS',1);

SELECT * FROM tb_filme;
/*call pdr_deleta_filme('YOHAN EM AÇÃO');*/

/*CHAMADA PARA CADASTRAR SALAS*/

call pdr_cadastra_sala('SALA BLUE', 150);
call pdr_cadastra_sala('SALA RED', 50);
call pdr_cadastra_sala('SALA BACK', 200);
call pdr_cadastra_sala('SALA WHITE', 100);
call pdr_cadastra_sala('SALA PINK', 90);

SELECT * FROM tb_sala;
/*call pdr_deleta_sala('SALA BLUE');*/

/*CHAMADA PARA CADASTRAR PREMIAÇÕES*/

CALL pdr_cadastra_premiacao('PALMA DE OURO');
CALL pdr_cadastra_premiacao('OSCAR 2000');
CALL pdr_cadastra_premiacao('GLOBO DE OURO');

SELECT * FROM tb_premiacoes;
/*call pdr_deleta_premiacoes('PALMA DE OURO');*/

/*CHAMADA PARACADASTRAR FUNCIONÁRIOS*/

call pdr_cadastra_funcionario('DIEGA MOREIRA','69692424');
call pdr_cadastra_funcionario('YOHANA DILUCAS','70704040');
call pdr_cadastra_funcionario('ALERRANDRA DIBIMCA','68686235');
call pdr_cadastra_funcionario('VICTORIA ALEXANDRA','62451258');
call pdr_cadastra_funcionario('ANDRIWA XEROXA','47475656');

SELECT * FROM tb_funcionarios;
/*call pdr_deleta_funcionario('DIEGA MOREIRA');*/


/*CHAMADA PARACADASTRAR FUNÇÃO*/

CALL pdr_cadastra_funcao('PIPOQUEIRO', 1500.00);
CALL pdr_cadastra_funcao('CAIXA', 2000.00);
CALL pdr_cadastra_funcao('BALAS', 1250.00);
CALL pdr_cadastra_funcao('LANTERNINHA', 1700.00);
CALL pdr_cadastra_funcao('BILHETEIRO', 3000.00);

SELECT * FROM tb_funcao;
/*call pdr_deleta_funcao('PIPOQUEIRO');*/


/*CHAMADA PARA CADASTRAR HORÁRIOS*/

CALL pdr_cadastra_horario('16:00');
CALL pdr_cadastra_horario('17:00');
CALL pdr_cadastra_horario('18:00');
CALL pdr_cadastra_horario('19:30');
CALL pdr_cadastra_horario('20:00');
CALL pdr_cadastra_horario('22:00');
CALL pdr_cadastra_horario('00:00');

SELECT * FROM tb_horarios;
/*call pdr_deleta_horario('PIPOQUEIRO');*/


/*CHAMA PARA CADASTRAR EXIBIÇÃO*/

CALL pdr_cadastra_exibicao(1,2304001,1);
CALL pdr_cadastra_exibicao(1,2304002,2);
CALL pdr_cadastra_exibicao(1,2304003,3);
CALL pdr_cadastra_exibicao(1,2304004,4);

/*SELECT * FROM tb_exibicao;*/
/*CALL pdr_deleta_exibicao(2)*/

/*CHAMADA PARA CADASTRAR VENDAS DE INGRESSOS*/

call pdr_cadastra_venda(100,'02340756278', 25.00,2);
call pdr_cadastra_venda(50,'00055544432', 35.00,3);
call pdr_cadastra_venda(75,'22255544496', 24.00,4);
call pdr_cadastra_venda(85,'15426325658', 19.90,5);

SELECT * FROM tb_ingresso;