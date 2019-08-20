USE [Usifast_Imp]
GO

CREATE PROCEDURE [dbo].[stpBusca_String_Tabela](
    @Ds_Texto VARCHAR(100), 
    @Ds_Banco AS VARCHAR(100), 
    @Ds_Filtro_Tabela AS VARCHAR(100) = NULL,
    @Ds_Filtro_Coluna AS VARCHAR(100) = NULL,
    @Ds_Tabela_Destino AS VARCHAR(100) = NULL
)
AS BEGIN
    
    SET NOCOUNT ON
    
    DECLARE @query VARCHAR(MAX)
    SET @query = '
    
    USE ' + @Ds_Banco + '
    
    IF (OBJECT_ID(''tempdb..##lista_colunas'') IS NOT NULL) DROP TABLE ##lista_colunas

    SELECT
        tabelas.TABLE_SCHEMA					AS [Schema],
        tabelas.TABLE_NAME						AS Tabela,
        colunas.COLUMN_NAME						AS Coluna,
        colunas.DATA_TYPE						AS Tipo,
        colunas.NUMERIC_PRECISION_RADIX			AS Tamanho
    INTO
        ##lista_colunas
    FROM 
        INFORMATION_SCHEMA.TABLES tabelas
        JOIN INFORMATION_SCHEMA.COLUMNS colunas ON (tabelas.TABLE_NAME = colunas.TABLE_NAME AND tabelas.TABLE_SCHEMA = colunas.TABLE_SCHEMA)
    WHERE 
        colunas.DATA_TYPE IN(''text'', ''ntext'', ''varchar'', ''nvarchar'')
        AND tabelas.TABLE_TYPE = ''BASE TABLE''
    ORDER BY
        1, 2, 3'
        
    EXEC(@query)
    
    
    IF (@Ds_Filtro_Tabela IS NOT NULL)
    BEGIN 
    
        DELETE FROM ##lista_colunas WHERE Tabela NOT LIKE '%' + @Ds_Filtro_Tabela + '%'
        
    END
    
    
    
    IF (@Ds_Filtro_Coluna IS NOT NULL)
    BEGIN 
    
        DELETE FROM ##lista_colunas WHERE Coluna NOT LIKE '%' + @Ds_Filtro_Coluna + '%'
        
    END
    


    ALTER TABLE ##lista_colunas ADD Id INT IDENTITY(1,1)
    
    
    DECLARE 
        @numeroColunas INT = 0,
        @contadorColunas INT = 1,
        @numeroLinhas INT = 0,
        @contadorLinhas INT = 1,
        @schema VARCHAR(100),
        @tabela VARCHAR(100),
        @coluna VARCHAR(100)
        
        
    SET @numeroColunas = (SELECT COUNT(*) FROM ##lista_colunas)
    
    
    -- Tabela que guardará o resultado final
    IF (OBJECT_ID('tempdb..##Resultado_Final') IS NOT NULL) DROP TABLE ##Resultado_Final
    
    CREATE TABLE ##Resultado_Final (
        ID INT IDENTITY(1,1),
        [Schema] varchar(100),
        Tabela VARCHAR(100),
        Coluna VARCHAR(100),
        Resultado VARCHAR(MAX)
    )
    
    
    IF (OBJECT_ID('tempdb..##Resultado_Busca') IS NOT NULL) DROP TABLE ##Resultado_Busca
    
    CREATE TABLE ##Resultado_Busca (
        ID INT IDENTITY(1,1),
        Texto_Encontrado VARCHAR(MAX)
    )
    
    
    WHILE (@contadorColunas <= @numeroColunas)
    BEGIN	
    
        SELECT @schema = [Schema], @tabela = [Tabela], @coluna = [Coluna] FROM ##lista_colunas WHERE Id = @contadorColunas
        
        SET @query = 'TRUNCATE TABLE ##Resultado_Busca; INSERT INTO ##Resultado_Busca(Texto_Encontrado) SELECT [' + @coluna + '] FROM [' + @Ds_Banco + '].[' + @schema + '].[' + @tabela + '] WHERE [' + @coluna + '] LIKE ''%' + @Ds_Texto + '%'''
        EXEC(@query)
        
        SET @contadorLinhas = 1
        SET @numeroLinhas = (SELECT COUNT(*) FROM ##Resultado_Busca)
        
        WHILE(@contadorLinhas <= @numeroLinhas)
        BEGIN
    
            SET @query = (SELECT Texto_Encontrado FROM ##Resultado_Busca WHERE Id = @contadorLinhas)
            
            IF(@query IS NOT NULL)
            BEGIN
    
                INSERT INTO ##Resultado_Final([Schema], Tabela, Coluna, Resultado)
                SELECT @schema, @tabela, @coluna, @query
                
            END
            
            SET @contadorLinhas = @contadorLinhas + 1
            
        END
        
        SET @contadorColunas = @contadorColunas + 1
    
    END
    
    
    
    IF (@Ds_Tabela_Destino IS NOT NULL)
    BEGIN
    
        SET @query = 'SELECT * INTO ' + @Ds_Tabela_Destino + ' FROM ##Resultado_Final'
        EXEC(@query)
    
    END
    ELSE BEGIN
    
        SELECT [Schema], Tabela, Coluna, Resultado FROM ##Resultado_Final
    
    END
    
    
    -- Apaga as tabelas usadas pela SP
    IF (OBJECT_ID('tempdb..##lista_colunas') IS NOT NULL) DROP TABLE ##lista_colunas
    IF (OBJECT_ID('tempdb..##Resultado_Busca') IS NOT NULL) DROP TABLE ##Resultado_Busca
    IF (OBJECT_ID('tempdb..##Resultado_Final') IS NOT NULL) DROP TABLE ##Resultado_Final
    

END

---- Realiza uma busca pela palavra "Dirceu" em todas as colunas e tabelas do database Clientes
--EXEC CLR.dbo.stpBusca_String_Tabela
--    @Ds_Texto = 'Dirceu' , -- varchar(100)
--    @Ds_Banco = 'Clientes' -- varchar(max)

---- Realiza uma busca pela palavra "Dirceu" em todas as tabelas que contenham a string "Clientes" no database Clientes
--EXEC CLR.dbo.stpBusca_String_Tabela
--    @Ds_Texto = 'Dirceu' , -- varchar(100)
--    @Ds_Banco = 'Clientes', -- varchar(max)
--    @Ds_Filtro_Tabela = 'Clientes' -- varchar(max)

---- Realiza uma busca pela palavra "Dirceu" nas colunas que contenham a string "Cd_" das tabelas que contenham a string "Clientes" no database Clientes
--EXEC CLR.dbo.stpBusca_String_Tabela
--    @Ds_Texto = 'Dirceu' , -- varchar(100)
--    @Ds_Banco = 'Clientes', -- varchar(max)
--    @Ds_Filtro_Tabela = 'Clientes' -- varchar(max),
--    @Ds_Filtro_Coluna = 'Cd_'

---- Realiza uma busca pela palavra "Dirceu" no database Clientes e grava o resultado na tabela temporária global ##Resultado
--EXEC CLR.dbo.stpBusca_String_Tabela
--    @Ds_Texto = 'Dirceu' , -- varchar(100)
--    @Ds_Banco = 'Clientes' -- varchar(max),
--    @Ds_Tabela_Destino = '##Resultado'