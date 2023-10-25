-- 1

delimiter //
create trigger horario after insert on Clientes
for each row insert into Auditoria (mensagem, data_hora) values ("Data e hora do inserção:", now())

// delimiter ;

-- 2

delimiter //
create trigger exclusao after delete on Clientes
for each row insert into Auditoria (mensagem) values (concat('Tentativa de exclusão', Old.nome))

// delimiter ;


-- 3

DELIMITER //
CREATE TRIGGER atualiza_cliente_trigger
AFTER UPDATE ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem)
    VALUES (CONCAT('Nome do cliente ', OLD.nome, ' foi alterado para ', NEW.nome));
END;
//
DELIMITER ;

-- 4

DELIMITER //
CREATE TRIGGER nao_atualiza_nome_vazio
BEFORE UPDATE ON Clientes
FOR EACH ROW
BEGIN
    IF NEW.nome IS NULL OR NEW.nome = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nome do cliente não pode ser vazio ou nulo';
    ELSE
    END IF;
END;
//
DELIMITER ;

-- 5

DELIMITER //
CREATE TRIGGER atualiza_estoque_e_auditoria
AFTER INSERT ON Pedidos
FOR EACH ROW
BEGIN
    -- Decrementa o estoque do produto
    UPDATE Produtos
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.produto_id;

    -- Verifica se o estoque ficou abaixo de 5 unidades
    IF (SELECT estoque FROM Produtos WHERE id = NEW.produto_id) < 5 THEN
        INSERT INTO Auditoria (mensagem)
        VALUES (CONCAT('Estoque baixo para o produto ', NEW.produto_id));
    END IF;
END;
//
DELIMITER ;
