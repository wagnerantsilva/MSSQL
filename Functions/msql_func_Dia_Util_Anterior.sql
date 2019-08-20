USE DW_BI_OBERACAO
GO

CREATE FUNCTION [dbo].[fncDia_Util_Anterior] ( @Data_Dia DATETIME )
RETURNS DATETIME
AS
BEGIN
 
    WHILE (1 = 1)
    BEGIN

        SET @Data_Dia = @Data_Dia - (CASE DATEPART(WEEKDAY, @Data_Dia) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END)

        IF EXISTS ( SELECT TOP 1 Nr_Dia FROM dbo.Feriado WITH ( NOLOCK ) WHERE Nr_Dia = DAY(@Data_Dia) AND Nr_Mes = MONTH(@Data_Dia) AND Tp_Feriado = '1'  AND ( Nr_Ano = 0 OR Nr_Ano = YEAR(@Data_Dia) ) )
            SET @Data_Dia = @Data_Dia - 1
        ELSE
            BREAK  

    END

    RETURN CAST(FLOOR(CAST(@Data_Dia AS FLOAT)) AS DATETIME)

END