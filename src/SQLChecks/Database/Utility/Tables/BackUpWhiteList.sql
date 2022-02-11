create table Utility.BackUpWhiteList (
    DatabaseName sys.sysname not null,
    constraint PK_BackUpWhiteList
        primary key clustered (DatabaseName));
go
