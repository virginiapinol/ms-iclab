SET NOCOUNT ON
:out "C:\\Users\\virginia.pino\\Documents\\GitHub\\Facturacolombia\\Backend\\Programs\\home\\4809465.txt"
SELECT REPLICATE(CONVERT(NVARCHAR(MAX), docu_json), 9000)   FROM dte_docu_json where corr_json = 4809465  
GO
:out "C:\\Users\\virginia.pino\\Documents\\GitHub\\Facturacolombia\\Backend\\Programs\\home\\4810783.txt"
SELECT REPLICATE(CONVERT(NVARCHAR(MAX), docu_json), 9000)   FROM dte_docu_json where corr_json = 4810783  
GO
:out stdout

