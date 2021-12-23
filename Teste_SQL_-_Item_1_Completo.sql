/*
A empresa trabalha com campanhas de fidelidade, conectamos campanhas de incentivo com 
parceiro, onde temos os clientes que arrecadam pontos nas campanhas e com esses pontos 
fazem resgate de produtos nas lojas.
Usando como refer�ncia as tabelas no arquivo Excel encaminhado junto, encontre o melhor 
caminho atrav�s de scripts SQL para realizar as tarefas sugeridas.

1) Perdemos todos os registros da nossa tabela de loja (TB_LOJA), precisamos realizar 
uma nova carga de informa��es, seguindo as regras de neg�cio a seguir:

A � S� devemos vincular campanhas que estejam ativas.
*/

SELECT *
FROM   tb_campanha
WHERE  status = 'ativo' 

/*
B � Clientes n�o podem ter vinculado parceiros que sejam do mesmo segmento que 
ele, por�m concorrentes (Ex. Cliente Samsung n�o pode vincular parceiro Panasonic, 
ambos s�o do segmento de eletr�nicos por�m concorrentes).
*/

SELECT *
FROM   tb_campanha c
       CROSS JOIN tb_parceiro p
WHERE  status = 'ativo'
       AND ( c.segmento_cliente <> p.segmento
              OR ( c.segmento_cliente = p.segmento
                   AND nome_campanha LIKE '%' + nome_parceiro + '%' ) ) 


/*
C - Campanhas do segmento de constru��o, n�o podem vincular parceiros dos 
segmentos de Alimentos e nem Bebidas.
*/

SELECT *
FROM   tb_campanha c
       CROSS JOIN tb_parceiro p
WHERE  status = 'ativo'
       AND ( c.segmento_cliente <> p.segmento
              OR ( c.segmento_cliente = p.segmento
                   AND nome_campanha LIKE '%' + nome_parceiro + '%' ) )
       AND ( c.segmento_cliente <> 'constru��o'
              OR ( c.segmento_cliente = 'constru��o'
                   AND p.segmento NOT IN ( 'alimentos', 'bebidas' ) ) ) 


/*
D � Todas as lojas devem ser vinculadas como ativas e vis�veis, exceto as lojas do 
segmento de Bebidas, que devem ser vinculadas ativas e n�o vis�veis.
*/

SELECT CASE
         WHEN segmento = 'Bebidas' THEN 0
         ELSE 1
       END     AS visivel,
       'Ativo' AS status_loja
FROM   tb_campanha c
       CROSS JOIN tb_parceiro p
WHERE  status = 'ativo'
       AND ( c.segmento_cliente <> p.segmento
              OR ( c.segmento_cliente = p.segmento
                   AND nome_campanha LIKE '%' + nome_parceiro + '%' ) )
       AND ( c.segmento_cliente <> 'constru��o'
              OR ( c.segmento_cliente = 'constru��o'
                   AND p.segmento NOT IN ( 'alimentos', 'bebidas' ) ) ) 


/*
E � Na tabela de loja o campo ID_LOJA � um sequencial auto incremental.
*/

ALTER TABLE Tb_Loja
DROP COLUMN id_loja

 
ALTER TABLE Tb_loja
ADD id_loja int IDENTITY (1, 1) NOT NULL


/* 
F � Os campos ID_PARCEIRO e ID_CAMPANHA s�o chaves estrangeiras.
*/

ALTER TABLE tb_loja ADD CONSTRAINT Fk_id_parceiro FOREIGN KEY ( id_parceiro ) REFERENCES tb_parceiro ( id_parceiro ) ;

ALTER TABLE tb_loja ADD CONSTRAINT Fk_id_CAMPANHA FOREIGN KEY ( id_campanha ) REFERENCES tb_campanha ( id_campanha ) ;

SELECT id_campanha,
       id_parceiro,
       CASE
         WHEN segmento = 'Bebidas' THEN 0
         ELSE 1
       END     AS visivel,
       'Ativo' AS status_loja
FROM   tb_campanha c
       CROSS JOIN tb_parceiro p
WHERE  status = 'ativo'
       AND ( c.segmento_cliente <> p.segmento
              OR ( c.segmento_cliente = p.segmento
                   AND nome_campanha LIKE '%' + nome_parceiro + '%' ) )
       AND ( c.segmento_cliente <> 'constru��o'
              OR ( c.segmento_cliente = 'constru��o'
                   AND p.segmento NOT IN ( 'alimentos', 'bebidas' ) ) ) 


/*
G � O nome da loja por padr�o leva sempre o nome do parceiro.
*/

SELECT id_campanha,
       id_parceiro,
       nome_parceiro AS 'Nome Loja',
       CASE
         WHEN segmento = 'Bebidas' THEN 0
         ELSE 1
       END           AS visivel,
       'Ativo'       AS status_loja
FROM   tb_campanha c
       CROSS JOIN tb_parceiro p
WHERE  status = 'ativo'
       AND ( c.segmento_cliente <> p.segmento
              OR ( c.segmento_cliente = p.segmento
                   AND nome_campanha LIKE '%' + nome_parceiro + '%' ) )
       AND ( c.segmento_cliente <> 'constru��o'
              OR ( c.segmento_cliente = 'constru��o'
                   AND p.segmento NOT IN ( 'alimentos', 'bebidas' ) ) ) 


--H � O campo vis�vel � booleano.

ALTER TABLE Tb_loja
alter column visivel bit 

--I � O status da loja segue o mesmo padr�o de status das outras tabelas.

INSERT INTO tb_loja
SELECT p.id_parceiro,
       id_campanha,
       nome_parceiro AS 'Nome Loja',
       CASE
         WHEN segmento = 'Bebidas' THEN 0
         ELSE 1
       END           AS visivel,
       'Ativo'       AS status_loja
FROM   tb_campanha c
       CROSS JOIN tb_parceiro p
WHERE  status = 'ativo'
       AND ( c.segmento_cliente <> p.segmento
              OR ( c.segmento_cliente = p.segmento
                   AND nome_campanha LIKE '%' + nome_parceiro + '%' ) )
       AND ( c.segmento_cliente <> 'constru��o'
              OR ( c.segmento_cliente = 'constru��o'
                   AND p.segmento NOT IN ( 'alimentos', 'bebidas' ) ) ) 