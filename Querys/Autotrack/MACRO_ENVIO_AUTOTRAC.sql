USE [Onixsat]
GO

--CREATE PROCEDURE usp_envia_macro_autotrac
--AS
--BEGIN

	IF OBJECT_ID('tempdb..#TEMP_INI_JORNADA_AUTOTRAC') IS NOT NULL
			DROP TABLE #TEMP_INI_JORNADA_AUTOTRAC

	Declare @AccountNumber int,
	@MctAddress int,
	@MsgStatus smallint,
	@MsgSubtype smallint,
	@BinaryDatatype tinyint,
	@MsgPriority   tinyint,
	@MacroNumber tinyint,
	@MacroVersion tinyint,
	@Text varchar(4000)



	DECLARE @TAB_FROTA TABLE(   
								AccountNumber int,
								MctAddress int,
								MsgStatus smallint,
								MsgSubtype smallint,
								BinaryDatatype tinyint,
								MsgPriority   tinyint,
								MacroNumber tinyint,
								MacroVersion tinyint,
								Text varchar(4000)
							)

						
	SET @AccountNumber = 4942848
	--SET @MctAddress = 1024664
	SET @MsgStatus = 10
	SET @MsgSubtype = 0
	SET @BinaryDatatype = 0
	SET @MsgPriority   = 0
	SET @MacroNumber = 0
	SET @MacroVersion = 0
	SET @Text = ''

		   --INSERT INTO @TAB_FROTA
			  SELECT   @AccountNumber AS AccountNumber ,
					   MCT AS MctAddress,
					   @MsgStatus AS MsgStatus, 
					   @MsgSubtype AS MsgSubtype,
					   @BinaryDatatype AS BinaryDatatype,
					   @MsgPriority AS MsgPriority,
					   @MacroNumber AS MacroNumber,
					   @MacroVersion AS MacroVersion,
					   MACRO AS 'Text',
					   CHAVE AS 'key'
			  into #TEMP_INI_JORNADA_AUTOTRAC
			  FROM [dbo].[SEND_MACRO]  
				  WHERE RASTREADOR = 'Autotrac'  
				  AND STATUS_MSG = ''
				  ORDER BY DATA DESC
	 
		--SELECT * FROM #TEMP_INI_JORNADA_AUTOTRAC


	-- CURSOR
	
	Declare @var_AccountNumber int,
			@var_MctAddress int,
			@var_MsgStatus smallint,
			@var_MsgSubtype smallint,
			@var_BinaryDatatype tinyint,
			@var_MsgPriority   tinyint,
			@var_MacroNumber tinyint,
			@var_MacroVersion tinyint,
			@var_Text varchar(4000),
			@var_chave varchar(150)

	-- Cursor para percorrer os nomes dos objetos 
	DECLARE CURSOR_ENVIA_MACRO CURSOR FOR
		SELECT TOP 1 * FROM #TEMP_INI_JORNADA_AUTOTRAC;

	-- Abrindo Cursor para leitura
	OPEN CURSOR_ENVIA_MACRO

	-- Lendo a próxima linha
	FETCH NEXT FROM CURSOR_ENVIA_MACRO INTO 
	 @var_AccountNumber,
	 @var_MctAddress,
	 @var_MsgStatus,
	 @var_MsgSubtype,
	 @var_BinaryDatatype,
	 @var_MsgPriority,
	 @var_MacroNumber,
	 @var_MacroVersion,
	 @var_Text,
	 @var_chave


	-- Percorrendo linhas do cursor (enquanto houverem)
	WHILE @@FETCH_STATUS = 0
	BEGIN

		INSERT INTO [Integra].[dbo].[ForwardMessage_IIFWD_2017]
			   (
					[IIFWD_AccountNumber]
				   ,[IIFWD_MctAddress]
				   ,[IIFWD_MsgStatus]
				   ,[IIFWD_MsgSubtype]
				   ,[IIFWD_BinaryDatatype]
				   ,[IIFWD_MsgPriority]
				   ,[IIFWD_MacroNumber]
				   ,[IIFWD_MacroVersion]
				   ,IIFWD_Text  
			   )
		VALUES   (
					 @var_AccountNumber,
					 @var_MctAddress,
					 @var_MsgStatus,
					 @var_MsgSubtype,
					 @var_BinaryDatatype,
					 @var_MsgPriority,
					 @var_MacroNumber,
					 @var_MacroVersion,
					 'TESTE_'+@var_Text
	
				) 
	
		UPDATE SEND_MACRO SET STATUS_MSG = '*', DATA_ENVIO = GETDATE() WHERE CHAVE =  @var_chave   
   

		--EXEC sp_helptext @fullName

		-- Lendo a próxima linha
		FETCH NEXT FROM CURSOR_ENVIA_MACRO INTO  @var_AccountNumber,
												 @var_MctAddress,
												 @var_MsgStatus,
												 @var_MsgSubtype,
												 @var_BinaryDatatype,
												 @var_MsgPriority,
												 @var_MacroNumber,
												 @var_MacroVersion,
												 @var_Text,
												 @var_chave
	END

	-- Fechando Cursor para leitura
	CLOSE CURSOR_ENVIA_MACRO

	-- Desalocando o cursor
	DEALLOCATE CURSOR_ENVIA_MACRO 

--END