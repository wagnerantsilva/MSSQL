CREATE FUNCTION fu_busca_posic_no_poligono (@tb_lat float, @tb_lon float)
RETURNS @ret_table TABLE (
  id int,
  no_local bit
)
AS
BEGIN

IF OBJECT_ID('TEMPDB..#temp_pos') IS NOT NULL
  DROP TABLE #temp_pos

  DECLARE @g_pol_eadi geography
  DECLARE @h_point geography

  DECLARE @sSQL nvarchar(4000)
  --Declare @des_Name VarChar(200)
  --declare @ret_table table (id int, no_local bit )

  DECLARE @p_id int,
          @p_Poligono_text nvarchar(max)

  SET @sSQL = 'Declare cusror_percorre_poligonos CURSOR FOR SELECT id, Poligono_text FROM Poligono'

  EXEC sp_executesql @sSQL

  OPEN cusror_percorre_poligonos
  FETCH NEXT FROM cusror_percorre_poligonos
  INTO @p_id, @p_Poligono_text

  WHILE @@FETCH_STATUS = 0
  BEGIN

    SET @g_pol_eadi = geography ::STGeomFromText(@p_Poligono_text, 4326)
    SET @h_point = geography ::Point(@tb_lat, @tb_lon, 4326)

    --select @p_id, @p_Poligono_text


    --DECLARE @VAL_LOC  bit =  ( @g_pol_eadi.STIntersects(@h_point) )
    INSERT INTO @ret_table
      SELECT
        @p_id,
        (@g_pol_eadi.STIntersects(@h_point))

    FETCH NEXT FROM cusror_percorre_poligonos
    INTO @p_id, @p_Poligono_text

  END
  CLOSE cusror_percorre_poligonos
  DEALLOCATE cusror_percorre_poligonos

  RETURN;
END;