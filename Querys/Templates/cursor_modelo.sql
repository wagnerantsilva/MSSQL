

declare @sSQL nvarchar(4000)
Declare @des_Name VarChar(200)

set @sSQL = 'Declare Teste_cursor CURSOR FOR Select name from sys.objects'

exec sp_executesql @sSQL

OPEN Teste_cursor
FETCH NEXT FROM Teste_cursor
INTO @des_Name

WHILE @@FETCH_STATUS = 0
BEGIN
Print @des_Name


FETCH NEXT FROM Teste_cursor
INTO @des_Name

END
CLOSE Teste_cursor
DEALLOCATE Teste_cursor