/*
A empresa trabalha com campanhas de fidelidade, conectamos campanhas de incentivo com 
parceiro, onde temos os clientes que arrecadam pontos nas campanhas e com esses pontos 
fazem resgate de produtos nas lojas.
Usando como referência as tabelas no arquivo Excel encaminhado junto, encontre o melhor 
caminho através de scripts SQL para realizar as tarefas sugeridas.

1) Perdemos todos os registros da nossa tabela de loja (TB_LOJA), precisamos realizar 
uma nova carga de informações, seguindo as regras de negócio a seguir:

A – Só devemos vincular campanhas que estejam ativas.
*/

SELECT *
FROM   tb_campanha
WHERE  status = 'ativo' 

/*
B – Clientes não podem ter vinculado parceiros que sejam do mesmo segmento que 
ele, porém concorrentes (Ex. Cliente Samsung não pode vincular parceiro Panasonic, 
ambos são do segmento de eletrônicos porém concorrentes).
*/

SELECT *
FROM   tb_campanha c
       CROSS JOIN tb_parceiro p
WHERE  status = 'ativo'
       AND ( c.segmento_cliente <> p.segmento
              OR ( c.segmento_cliente = p.segmento
                   AND nome_campanha LIKE '%' + nome_parceiro + '%' ) ) 


/*
C - Campanhas do segmento de construção, não podem vincular parceiros dos 
segmentos de Alimentos e nem Bebidas.
*/

SELECT *
FROM   tb_campanha c
       CROSS JOIN tb_parceiro p
WHERE  status = 'ativo'
       AND ( c.segmento_cliente <> p.segmento
              OR ( c.segmento_cliente = p.segmento
                   AND nome_campanha LIKE '%' + nome_parceiro + '%' ) )
       AND ( c.segmento_cliente <> 'construção'
              OR ( c.segmento_cliente = 'construção'
                   AND p.segmento NOT IN ( 'alimentos', 'bebidas' ) ) ) 


/*
D – Todas as lojas devem ser vinculadas como ativas e visíveis, exceto as lojas do 
segmento de Bebidas, que devem ser vinculadas ativas e não visíveis.
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
       AND ( c.segmento_cliente <> 'construção'
              OR ( c.segmento_cliente = 'construção'
                   AND p.segmento NOT IN ( 'alimentos', 'bebidas' ) ) ) 


/*
E – Na tabela de loja o campo ID_LOJA é um sequencial auto incremental.
*/

ALTER TABLE Tb_Loja
DROP COLUMN id_loja

 
ALTER TABLE Tb_loja
ADD id_loja int IDENTITY (1, 1) NOT NULL


/* 
F – Os campos ID_PARCEIRO e ID_CAMPANHA são chaves estrangeiras.
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
       AND ( c.segmento_cliente <> 'construção'
              OR ( c.segmento_cliente = 'construção'
                   AND p.segmento NOT IN ( 'alimentos', 'bebidas' ) ) ) 


/*
G – O nome da loja por padrão leva sempre o nome do parceiro.
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
       AND ( c.segmento_cliente <> 'construção'
              OR ( c.segmento_cliente = 'construção'
                   AND p.segmento NOT IN ( 'alimentos', 'bebidas' ) ) ) 


--H – O campo visível é booleano.

ALTER TABLE Tb_loja
alter column visivel bit 

--I – O status da loja segue o mesmo padrão de status das outras tabelas.

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
       AND ( c.segmento_cliente <> 'construção'
              OR ( c.segmento_cliente = 'construção'
                   AND p.segmento NOT IN ( 'alimentos', 'bebidas' ) ) ) 