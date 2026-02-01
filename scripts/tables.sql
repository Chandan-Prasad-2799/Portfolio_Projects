IF NOT EXISTS (SELECT 1 FROM sys.Tables where object_id = Object_id('user1'))
begin

  create table user1
(
  id int identity(1,1) primary key,
  name nvarchar(50)
)

end
