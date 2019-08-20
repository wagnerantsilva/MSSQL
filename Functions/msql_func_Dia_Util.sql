CREATE FUNCTION [dbo].[fncDia_Util] ( @Data_Dia DATETIME )
RETURNS BIT
AS
BEGIN 

    DECLARE @retorno BIT

    IF ( DATEPART(WEEKDAY, @Data_Dia) IN ( 1, 7 ) )
        SET @retorno = 0	
    ELSE
    BEGIN

        IF EXISTS ( SELECT TOP 1 Nr_Dia FROM dbo.Feriado WITH ( NOLOCK ) WHERE Nr_Dia = DAY(@Data_Dia) AND Nr_Mes = MONTH(@Data_Dia) AND Tp_Feriado = '1' AND ( Nr_Ano = 0 OR Nr_Ano = YEAR(@Data_Dia) ) )
            SET @retorno = 0
        ELSE
            SET @retorno = 1
        
    END
    
    RETURN @retorno

END