-- 1:
DELIMITER //
CREATE FUNCTION total_livros_por_genero(nome_genero VARCHAR(255)) RETURNS INT
BEGIN
    DECLARE total INT;
    DECLARE genero_id INT;
    DECLARE done INT DEFAULT 0;
    
    SELECT id INTO genero_id FROM Genero WHERE nome_genero = nome_genero;
    
    DECLARE cur CURSOR FOR
        SELECT COUNT(*) FROM Livro WHERE id_genero = genero_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN cur;
    FETCH cur INTO total;
    CLOSE cur;
    
    RETURN total;
END;
//
DELIMITER ;

SELECT total_livros_por_genero('Romance');

-- 2:

DELIMITER //
CREATE FUNCTION listar_livros_por_autor(primeiro_nome VARCHAR(255), ultimo_nome VARCHAR(255)) RETURNS TEXT
BEGIN
    DECLARE livro_titulo TEXT;
    DECLARE lista_titulos TEXT DEFAULT '';
    DECLARE done INT DEFAULT 0;
    DECLARE autor_id INT;
    
    SELECT id INTO autor_id FROM Autor WHERE primeiro_nome = primeiro_nome AND ultimo_nome = ultimo_nome;

    DECLARE cur CURSOR FOR
        SELECT Livro.titulo
        FROM Livro
        JOIN Livro_Autor ON Livro.id = Livro_Autor.id_livro
        WHERE Livro_Autor.id_autor = autor_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO livro_titulo;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET lista_titulos = CONCAT(lista_titulos, livro_titulo, '\n');
    END LOOP;
    CLOSE cur;

    RETURN lista_titulos;
END;
//
DELIMITER ;

SELECT listar_livros_por_autor('João', 'Silva');

-- 3:

DELIMITER //
CREATE FUNCTION atualizar_resumos() RETURNS INT
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE livro_id INT;
    DECLARE livro_resumo TEXT;
    
    DECLARE cur CURSOR FOR
        SELECT id, resumo
        FROM Livro;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    update_loop: LOOP
        FETCH cur INTO livro_id, livro_resumo;
        IF done THEN
            LEAVE update_loop;
        END IF;
        
        SET livro_resumo = CONCAT(livro_resumo, '\nEste é um excelente livro!');
        UPDATE Livro SET resumo = livro_resumo WHERE id = livro_id;
    END LOOP;
    CLOSE cur;
    
    RETURN 1;
END;
//
DELIMITER ;

SELECT atualizar_resumos();


-- 4:

DELIMITER //
CREATE FUNCTION media_livros_por_editora() RETURNS DECIMAL(10,2)
BEGIN
    DECLARE media DECIMAL(10,2);
    DECLARE done INT DEFAULT 0;
    DECLARE total_livros INT;
    DECLARE editora_id INT;
    
    DECLARE cur CURSOR FOR
        SELECT id, nome_editora FROM Editora;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN cur;
    SET media = 0;
    
    calc_media: LOOP
        FETCH cur INTO editora_id;
        IF done THEN
            LEAVE calc_media;
        END IF;
        
        SELECT COUNT(*) INTO total_livros FROM Livro WHERE id_editora = editora_id;
        SET media = media + total_livros;
    END LOOP;
    
    CLOSE cur;
    
    SELECT COUNT(*) INTO total_livros FROM Livro;
    
    IF total_livros = 0 THEN
        RETURN 0;
    END IF;
    
    SET media = media / total_livros;
    
    RETURN media;
END;
//
DELIMITER ;

SELECT media_livros_por_editora();


-- 5:

DELIMITER //
CREATE FUNCTION autores_sem_livros() RETURNS TEXT
BEGIN
    DECLARE autor_nome TEXT;
    DECLARE lista_autores TEXT DEFAULT '';
    DECLARE done INT DEFAULT 0;
    
    DECLARE cur CURSOR FOR
        SELECT CONCAT(primeiro_nome, ' ', ultimo_nome) AS nome
        FROM Autor
        WHERE id NOT IN (SELECT DISTINCT id_autor FROM Livro_Autor);
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO autor_nome;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET lista_autores = CONCAT(lista_autores, autor_nome, '\n');
    END LOOP;
    CLOSE cur;
    
    RETURN lista_autores;
END;
//
DELIMITER ;

SELECT autores_sem_livros();

