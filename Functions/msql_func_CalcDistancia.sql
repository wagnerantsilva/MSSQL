

-- =============================================
-- Author:        Wagner Carmo da Silva
-- Create date:   20/10/2010 17:24
-- Description:   Calcula a distância em quilometros
-- =============================================
CREATE FUNCTION [fun_CalcDistancia] 
(
     @latIni float, -- Latitude do ponto inicial
     @lonIni float, -- Longitude do ponto inicial
     @latFim float,-- Latitude do ponto final
     @lonFim float -- Longitude do ponto final
)
RETURNS float
AS
BEGIN
     DECLARE @Result AS FLOAT
     DECLARE @arcoA AS FLOAT
     DECLARE @arcoB AS FLOAT
     DECLARE @arcoC AS FLOAT
     DECLARE @auxPI AS FLOAT

     SET @auxPi = Pi() / 180
     SET @arcoA = (@lonFim - @lonIni) * @auxPi
     SET @arcoB = (90 - @latFim) * @auxPi
     SET @arcoC = (90 - @latIni) * @auxPi
     SET @Result = Cos(@arcoB) * Cos(@arcoC) + Sin(@arcoB) * Sin(@arcoC) * Cos(@arcoA)
     SET @Result = (40030 * ((180 / Pi()) * Acos(@Result))) /360

     RETURN Round(@Result,2)
END