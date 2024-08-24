CREATE DATABASE academia;

CREATE TABLE Aluno(
	Codigo_aluno		INT				NOT NULL,
	Nome				VARCHAR(100)	NOT NULL
	PRIMARY KEY(Codigo_aluno)
)

CREATE TABLE Atividade(
	Codigo_atividade	INT				NOT NULL,
	Descricao			VARCHAR(500)	NOT NULL,
	IMC					DECIMAL(3,1)	NOT NULL
	PRIMARY KEY(Codigo_atividade)
)

INSERT INTO Atividade VALUES
	(1, 'Corrida + Step', 18.5),
	(2, 'Biceps + Costas + Pernas', 24.9),
	(3, 'Esteira + Biceps + Costas + Pernas', 29.9),
	(4, 'Bicicleta + Biceps + Costas + Pernas', 34.9),
	(5, 'Esteira + Bicicleta', 39.9)

CREATE TABLE Atividadealuno(
	Codigo_aluno		INT				NOT NULL,
	Altura				DECIMAL(3,2)	NOT NULL,
	Peso				DECIMAL(4,1)	NOT NULL,
	IMC					DECIMAL(3,1)	NOT NULL,
	Atividade			INT				NOT NULL
	PRIMARY KEY(Codigo_aluno, Atividade)
	FOREIGN KEY(Codigo_aluno) REFERENCES Aluno(Codigo_aluno),
	FOREIGN KEY(Atividade) REFERENCES Atividade(Codigo_atividade)
)

CREATE PROCEDURE sp_inserir (@codigo_aluno INT , @nome VARCHAR(100), @altura DECIMAL(3,2), @peso DECIMAL(4,1), @imc DECIMAL(3,1), @atividade INT)
AS
	INSERT INTO Aluno VALUES(@codigo_aluno, @nome)
	INSERT INTO Atividadealuno VALUES(@codigo_aluno, @altura, @peso, @imc, @atividade)


CREATE PROCEDURE sp_atualizar (@codigo_aluno INT , @nome VARCHAR(100), @altura DECIMAL(3,2), @peso DECIMAL(4,1), @imc DECIMAL(3,1), @atividade INT)
AS 
	UPDATE Aluno
	SET Nome = @nome
	WHERE Codigo_aluno = @codigo_aluno

	UPDATE Atividadealuno
	SET Altura = @altura, Peso = @peso, IMC = @imc, Atividade = @atividade
	WHERE Codigo_aluno = @codigo_aluno

CREATE PROCEDURE sp_verificarcodigo (@codigo_aluno INT, @existe BIT OUTPUT)
AS 
	DECLARE @codigo_verificar INT
	SET @codigo_verificar =(
		SELECT Codigo_aluno FROM Aluno
		WHERE @codigo_aluno = Codigo_aluno
	)
	IF(@codigo_verificar IS NOT NULL)
	BEGIN
		SET @existe = 1
	END
	ELSE
	BEGIN
		SET @existe = 0
	END

CREATE PROCEDURE sp_codigoaluno(@codigo_aluno INT OUTPUT)
AS
	SET @codigo_aluno = (
			SELECT TOP 1 Codigo_aluno FROM Aluno
			ORDER BY Codigo_aluno DESC
		)
	SET @codigo_aluno = @codigo_aluno + 1;
	IF(@codigo_aluno IS NULL)
	BEGIN
		SET @codigo_aluno = 1;
	END


CREATE PROCEDURE sp_calcularatividade(@altura	DECIMAL(3,2), @peso	DECIMAL(4,1), @imc	DECIMAL(3,1), @atividade INT OUTPUT)
AS
	SET @atividade =
	(
		SELECT TOP 1 Codigo_atividade FROM Atividade
		WHERE @imc <= IMC
	)
	IF(@imc > 39.9)
	BEGIN
		SET @atividade = 5;
	END

CREATE PROCEDURE sp_alunoatividades(@codigo_aluno INT, @nome VARCHAR(100), @altura DECIMAL(3,2), @peso DECIMAL(4,1), @imc DECIMAL(3,1))
AS
	DECLARE @atividade INT, @existe BIT
	IF(@codigo_aluno IS NULL)
	BEGIN
		EXEC sp_codigoaluno @codigo_aluno OUTPUT
		EXEC sp_calcularatividade @altura, @peso, @imc, @atividade OUTPUT
		EXEC sp_inserir @codigo_aluno, @nome, @altura, @peso, @imc, @atividade
	END

	IF(@codigo_aluno IS NOT NULL AND @altura IS NOT NULL AND @peso IS NOT NULL)
	BEGIN
		EXEC sp_verificarcodigo @codigo_aluno, @existe OUTPUT
		IF(@existe = 1)
		BEGIN 
			EXEC sp_calcularatividade @altura, @peso, @imc, @atividade OUTPUT
			EXEC sp_atualizar @codigo_aluno, @nome, @altura, @peso, @imc, @atividade
		END
	END

DECLARE @altura	DECIMAL(3,2), @peso	DECIMAL(4,1), @imc	DECIMAL(3,1), @atividade INT, @nome VARCHAR(100), @codigo_aluno INT
SET @nome = 'Carlos da Silva';
SET @peso = 160.5;
SET @altura = 1.82;
SET @imc = @peso/(@altura*@altura);
EXEC sp_alunoatividades @codigo_aluno, @nome, @altura, @peso, @imc


SELECT ativ.Codigo_aluno, a.Nome, ativ.Altura, ativ.IMC, ativ.Peso, ativ.IMC, Atividade.Descricao
FROM Atividadealuno as ativ, Aluno as a, Atividade
WHERE a.Codigo_aluno = ativ.Codigo_aluno AND Codigo_atividade = ativ.Atividade
