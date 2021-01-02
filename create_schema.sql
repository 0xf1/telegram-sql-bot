IF NOT EXISTS(SELECT *
              FROM sys.schemas
              WHERE name = '#SCHEMA#')
    BEGIN
        EXEC ('CREATE SCHEMA [#SCHEMA#]')
    END


-- USERS >>>>>>>>>>>>>>>>>>>
if object_id('[#SCHEMA#].t_users', 'U') is null
    begin
        create table [#SCHEMA#].t_users
        (
            chat_id  nvarchar(100) primary key,
            username nvarchar(60),
            groups   nvarchar(500)
        )
    end
-- USERS <<<<<<<<<<<<<<<<<<<

-- GROUPS >>>>>>>>>>>>>>>>>>>
if object_id('[#SCHEMA#].t_groups', 'U') is null
    begin
        create table [#SCHEMA#].t_groups
        (
            group_name nvarchar(100) primary key,
            is_admin   bit
        )
    end
-- GROUPS <<<<<<<<<<<<<<<<<<<

-- INBOX >>>>>>>>>>>>>>>>>
if object_id('[#SCHEMA#].t_inbox', 'U') is null
    begin
        create table [#SCHEMA#].t_inbox
        (
            message_id     bigint identity primary key,
            chat_id        nvarchar(100),
            username       nvarchar(60),
            message_text   nvarchar(max),
            message_time   datetime,
            processed      bit,
            processed_time datetime
        )
        create nonclustered index [processed_t_inbox] on [#SCHEMA#].t_inbox (processed)
    end

-- INBOX <<<<<<<<<<<<<<<<


-- OUTBOX >>>>>>>>>>>>>>>>>
if object_id('[#SCHEMA#].t_outbox', 'U') is null
    begin
        create table [#SCHEMA#].t_outbox
        (
            message_id     bigint identity primary key,
            chat_id        nvarchar(100),
            username       nvarchar(60),
            message_text   nvarchar(max),
            message_time   datetime,
            processed      bit,
            processed_time datetime,
            persist        bit

        )
        create nonclustered index [processed_t_outbox] on [#SCHEMA#].t_outbox (processed)
    end

-- OUTBOX <<<<<<<<<<<<<<<<


-- LOG >>>>>>>>>>>>>>>>>>>>>

if object_id('[#SCHEMA#].t_log', 'U') is null
    begin
        create table [#SCHEMA#].t_log
        (
            log_id bigint identity primary key,
            txt    nvarchar(max),
            log_time datetime default getdate()
        )
    end

-- LOG <<<<<<<<<<<<<<<<<<<<<